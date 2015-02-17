using Bokeh
autoopen(true)

x1 = linspace(0, 2pi, 10)
x2 = linspace(0, 2pi, 20)

xs=Vector[x1, x2]
ys=Vector[sin(x1), cos(x2)]
glyphsize(20)  # adjust the default glyph size
plot(xs, ys, "ro|ko")
