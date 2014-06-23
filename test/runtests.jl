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


x = linspace(0, 2pi, 5)
y = sin(x)
ys = [sin(x) cos(x)]

plot(x, y)
plot(x, ys)
plot(y)
plot(ys)

plot(cos)

plot([sin, cos])

# check they're correct:
# Bokeh.parse_spec("r--") |> println

# Bokeh.parse_spec("r:") |> println