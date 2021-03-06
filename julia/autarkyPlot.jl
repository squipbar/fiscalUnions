#= autarkyPlot.jl
Philip Barrett, pobarrett@gmail.com
25may2016, Chicago

Plots an AutarkySol object
=#

using Gadfly, Colors

"""
    plot_as( x::LinSpace, y::Matrix{Float64} )
Core plotting function for the autarky solutions
"""
function plot_as( x::LinSpace, y::Matrix{Float64} )
  color_vec = [ "magenta" "red" "blue" "black" "green" "cyan" "orange"  ]
  # Theme(default_color=)?
  Gadfly.plot( [ layer( x=x, y=y[:,i], Geom.line,
             Theme(default_color=color(parse(Colorant, color_vec[i%7+1]))) )
             for i in 1:(size(y)[2]) ]... )
end


"""
    plot_as( as::AutarkySol, part::AbstractString="V" )
Core plotting function for the autarky solutions
"""
function plot_as( as::AutarkySol, part::AbstractString="V" )
  if part == "V"
    y = as.V
  end
      # Value function
  if part == "R"
    y = as.R
  end
      # Government revenue
  if part == "b"
    y = as.bprime
  end
      # Continuation debt
  if part == "x"
    y = as.x
  end
      # Leisure
  plot_as( as.am.bgrid, y )
      # Plot
end

"""
    plot_sim( sim::Matrix, pds=1:100 )
Plots (some periods of) a simulation
"""
function plot_sim( sim::Matrix, pds=1:100 )
  color_vec = [ "red" "blue" "black" "green" ]
      # Theme(default_color=)?
  mu = mean( sim, 1 )
  sd = std( sim, 1 )
  sim_pd = log( sim[ pds, [ 1, 2, 3, 5 ] ] )
  y = ( sim_pd - ( ones( length(pds), 1 ) *  log( mu[[1 2 3 5]] ) ) ) #./
              # ( ones( length(pds), 1 ) *  [ sd[1] / sd[2] 1 1 1 ] )
      # Normalize debt by the variance of expenditures
  Gadfly.plot( [ layer( x=pds, y=y[:,i], Geom.line,
             Theme(default_color=color(parse(Colorant, color_vec[i]))) )
             for i in 1:4 ]..., Guide.xlabel("Period"),
             Guide.ylabel("Log deviations from mean"),
             Guide.manual_color_key("Variables",
                ["A", "g", "b", "R" ],
                color_vec) )

end

"""
    plot_sim( sim::Matrix, pds=1:100 )
Plots (some periods of) a simulation
"""
function plot_sim_prs( sim::Matrix, pds=1:100, chi=1 )
  color_vec = [ "red" "blue" "black" "green" ]
      # Theme(default_color=)?
  mu = mean( sim, 1 )
  sd = std( sim, 1 )
  sim_pd = sim[ pds, [ 1, 2, 4, 5 ] ]
  y = ( sim_pd - ( ones( length(pds), 1 ) *  mu[[1 2 4 5]] ) ) .*
               ( ones( length(pds), 1 ) *  [ 1 / ( 1 + chi ) ( sd[1] / sd[2] ) 1 1] )
      # Normalize debt by the variance of taxes
  Gadfly.plot( [ layer( x=pds, y=y[:,i], Geom.line,
             Theme(default_color=color(parse(Colorant, color_vec[i]))) )
             for i in 1:4 ]... )

end
