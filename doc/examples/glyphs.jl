using Bokeh
autoopen(true)

plotfile("circles.html")

x = linspace(0, 2pi)
ys = [sin(x) cos(x)]
plot(x, ys, "rs|bo")