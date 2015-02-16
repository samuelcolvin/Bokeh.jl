using Bokeh

plotfile("hello_world.html")  # this isn't shown in the actual exmaple for simplicity
autoopen(true)

x = linspace(0, 2pi)
y = sin(x)
plot(x, y, title="Hello World")