using Bokeh

plotfile("simple_glyphs.html")

x = linspace(0, 2pi)
y1 = sin(x)
y2 = cos(x)
y3 = tan(x)
plot([y1 y2 y3]) # since we haven't passed x this would use the range 1:50

plot(x, [y1 y2 y3], "rs|bo|g*")
showplot()