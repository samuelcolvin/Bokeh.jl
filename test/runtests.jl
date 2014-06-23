using Bokeh
using Base.Test

# try setting all possible params
# some lime autoopen actually need to be set for travis
debug(true)
debug(false)
autoopen(false)
width(600)
height(300)
filename("testing_bokeh_plot.html")
title("Testing Bokeh Plot")

x = 1:10
y = x.^2
plot(x, y)

plot(y)

plot(cos)

# check they're correct:
# Bokeh.parse_spec("r--") |> println

# Bokeh.parse_spec("r:") |> println