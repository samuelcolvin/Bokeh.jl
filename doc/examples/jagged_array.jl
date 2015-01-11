using Bokeh
plotfile("jagged_array.html")
hold(true)
# jagged array, this is an array of arrays, not something we should use if possible, 
# but Bokeh.jl can deal with it
ys=Vector[[1,2,3], [4,5,6], [7,8,9,10]]
plot(ys, "ro|go|bo")

x=[4,3,2,1]
plot(x, ys, "rd|gd|bd")

xs = Vector[[6,4,2], [3,2,1], [10.1,10,8, 7.5]]
plot(xs, ys, "rs|gs|bs")
println(Bokeh.CURPLOT)
showplot()