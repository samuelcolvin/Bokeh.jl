using Bokeh
autoopen(true)

plotfile("glyphs.html")

x = linspace(0, 2pi, 10)
y = ones(x) + 0.1sin(x)
glyphs = "rs|bo|g*|kd|m+|cx|y^|rv|oxb|o+b|sxg|s+g" 
ys = Vector[i*y for i in -1:-1:-length(split(glyphs, '|'))]
# ys =[-1*y -2*y -3*y -4*y -5*y -6*y -7*y -8*y]
plot(ys, glyphs)