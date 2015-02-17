using Bokeh
autoopen(true)

plotfile("legend.html")

y1 = [-10:10].^2
y2 = [-10:10].^3
plot([y1 y2], legends=["x^2", "x^3"], legendsgo=:bottom_right)
