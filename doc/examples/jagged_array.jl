using Bokeh
autoopen(true)
plotfile("jagged_array.html")

# jagged array
ys=Vector[[1,2,3], [4,5,6], [7,8,9,10]]
plot(ys)