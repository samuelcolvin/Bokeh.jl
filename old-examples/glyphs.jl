using Bokeh
autoopen(true)

plotfile("glyphs.html")

x = linspace(0, 2pi, 10)
y = ones(x) + 0.1sin(x)
glyphs = "rs|bo|g*|kd|m+|cx|y^|rv|.g|oxb|o+b|sxg|s+g" 
ys = Vector[i*y for i in -1:-1:-length(split(glyphs, '|'))]
plot(ys, glyphs)