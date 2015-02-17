using Bokeh

autoopen(true)

x = linspace(0, 2pi)
y = sin(x)
plot(x, y, title="Hello World")