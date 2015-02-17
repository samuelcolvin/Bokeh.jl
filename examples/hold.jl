using Bokeh

plotfile("hold.html")

x = linspace(-3pi, 3pi)
y1 = cos(x)
plot(x,y1)

hold(true)

y2 = sin(x)./x
plot(x, y2, "r")
showplot()