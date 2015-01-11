using Bokeh
plotfile("jagged_array.html")
hold(true)
# jagged array, this is an array of arrays, not something we should use if possible, 
# but Bokeh.jl can deal with it
ys=Vector[[1,2,3], [4,5,6], [7,8,9,10]]
plot(ys, "ro|ko|bo")

x=[14,13,12,11]
plot(x, ys, "rd|kd|bd")

xs = Vector[[7,4,2], [6,5,4], [10.1,10,8, 7.5]]
plot(xs, ys, "rs|ks|bs")
showplot()