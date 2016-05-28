#= polygonUtils.jl
Philip Barrett, pobarrett@gmail.com
27may2016, Chicago

Defines utilities for polygon objects
=#

# TODO: Hausdorff distance, duplicate removals

"""
    acw( p1, p2, p3 )
Positive if p1 -> p2 -> p3 is anti-clockwise
"""
function acw( p1, p2, p3 )
  return (p2[1] - p1[1]) * (p3[2] - p1[2]) - (p2[2] - p1[2]) * (p3[1] - p1[1])
end

"""
    gScan( pts::Matrix )
Computes a convex hull using the Graham Scan algortithm
"""

function gScan( pts::Matrix )

  N = size(pts)[1]
      # Number of points
  lex = sortrows( pts[ :, [2, 1 ] ] )[ :, [ 2, 1 ] ]
      # Sorts the points lexicographically by y then x
  P = lex[ 1, : ]
      # The initial point
  otherpts = lex[ 2:end, : ]
      # The other points
  orderpts = [ P; otherpts ; P ]
      # Initialize the anti-clockwise ordered points
  cah = zeros( N - 1 )
      # The cosine of the angle between each point and P.  Will be in
      # [-1,1] because of choice of P

  ## Order the points anti-clockwise ##
  for( i in 1:(N-1) )
    diff = otherpts[i,:] - P
    cah[i] = diff[1] / norm(diff)
        # Cosine is adjacent over hypotenuse
  end
  orderpts[2:N,:] = otherpts[ sortperm(cah, rev=true), : ]
      # Order the points by the angle measure

  ## Create the output ##
  out = similar( pts )
  out[ 1:2, : ] = orderpts[1:2,:]
      # Initialize
  M = 2
      # Counts number of rows in convex hull
  for( i in 3:N )
    while( acw( out[ M-1, : ], out[ M, : ], orderpts[ i, : ] ) <= 0 )
      if( M > 2 )
        M -= 1
      elseif( i == N )
        break
      else
        i += 1
      end
    end
    M += 1
        # Increment counter
    out[ M, : ] = orderpts[ i, : ]
        # Add to the output if we have an acw angle
  end
  return out[ 1:M, : ]
end

"""
    deeDoop( pts::Matrix )
De-duplicates a collection of points.  Must already be ordered anti-clockwise.
"""
function deeDoop( pts::Matrix, tol=1e-10 )
  N = size(pts)[1]
      # Number of points
  neighbors = [ pts[ 2:end,: ]; pts[1,:] ]
      # The neighboring points
  diff = [ norm( pts[i,:] - neighbors[i,:] ) for i in 1:N ]
      # The vector of norms
  return pts[ diff .> tol, : ]
end

function deeDoop( poly::polygon, tol=1e-10 )
  return deeDoop( poly.pts )
end