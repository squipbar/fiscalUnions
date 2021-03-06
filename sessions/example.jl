using Polygons
using CHull2D
using JLD

include("../julia/dwl.jl")
include("../julia/fiscalGame.jl")
include("../julia/fiscalSol.jl")

A_jt = [ 3 3
         3 3 ]
g_jt = [ .215   .205
         .205   .215 ]
P = [ .6 .4
      .4 .6 ]
nR = 20
psi = .75
chi = 7.0
nb = 40
r = .03
delta = 1.0
ndirsl = 8

fg = FiscalGame( r=r, delta=[delta, delta], psi=[ psi, psi ], chi=[ chi, chi ],
              A=A_jt, g=g_jt, P=P, nR=nR, rho=.5, nb=nb, ndirsl=ndirsl )
init, ndirs = initGame(fg)
polyPlot(init[:,1])

betta_hat = fg.betta * fg.delta
thisndirs = 20
dirs = hcat( [ cos(2*pi*(i-1)/thisndirs)::Float64 for i in 1:thisndirs ],
             [ sin(2*pi*(i-1)/thisndirs)::Float64 for i in 1:thisndirs ] )

# ff = uncSetUpdate( fg.surp[3,2], vec(fg.pdLoss[3,:,2]), fg.bgrid[4],
#                          r, fg.bgrid, init, vec(P[2,:]), betta_hat,
#                          dirs )
# gg = uncSetUpdate( fg.surp[3,2], vec(fg.pdLoss[3,:,2]), fg.bgrid[4],
#                         r, fg.bgrid, init, vec(P[2,:]), betta_hat,
#                         dirs, false )
# polyPlot([ff, gg])
#
# hh = uncSetUpdate( fg.surp[1,1], vec(fg.pdLoss[1,:,1]), fg.bgrid[1],
#                   r, fg.bgrid, init, vec(P[1,:]), betta_hat, dirs )
iS = 1
ib = 40
for k in find(fg.potFeas[iS,ib])
  println( "k=", k )
  jj = uncSetUpdate( fg.surp[k,iS], vec(fg.pdLoss[k,:,iS]), fg.bgrid[ib],
                                    fg.r, fg.bgrid, init, vec(fg.P[iS,:]),
                                    betta_hat, dirs )
end

kk = [ uncSetUpdate( fg.surp[k,iS], vec(fg.pdLoss[k,:,iS]), fg.bgrid[ib],
                                  fg.r, fg.bgrid, init, vec(fg.P[iS,:]), betta_hat,
                                  dirs )::Polygon
                      for k in find(fg.potFeas[iS,ib]) ]
    # Compilation
ll = union(kk)
# using BenchmarkTools
# bmk = @benchmark kk = [ uncSetUpdate( fg.surp[k,iS], vec(fg.pdLoss[k,:,iS]), fg.bgrid[ib],
#                                   fg.r, fg.bgrid, init, vec(fg.P[iS,:]), betta_hat,
#                                   dirs )::Polygon
#                                   for k in find(fg.potFeas[iS,ib]) ]
#     # Averages about 3.5ms (0.0035s)
#     # Following aggresive typing in Polygons, this went *up*
# println(bmk)

W = uncSetUpdate( fg, init, ndirs )
# W = init
#
# it = 0
# hd = 10.0
#
# while it < 80 && maximum(hd) > 1e-05
#   it += 1
#   println("*** it = ", it , " ***")
#   W_new = uncSetUpdate( fg, W, ndirs )
#   hd = hausdorff( W, W_new )
#   println("   ** mean & max hausdorff dist = ", ( mean(hd), maximum(hd) ), "**" )
#   W = copy(W_new)
#   ndirs = ndirsUpdate( ndirs, hd, fg.hddirs, fg.ndirsu )
#   println("   ** mean # search dirs = ", mean(ndirs), "**" )
#   println("   ** extremal # search dirs = ", extrema(ndirs), "**\n" )
# end




# jldopen("/home/philip/Dropbox/data/2016/fiscalUnions/unc.jld", "w") do file
#     addrequire(file, Polygons)
#     write(file, "W", W)
# end
#
# # Can then acecss W with:
# d = load("/home/philip/Dropbox/data/2016/fiscalUnions/unc.jld")
# W = d["W"]
