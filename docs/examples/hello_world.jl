using Bokeh

Bokeh.includejs(true)  # this is required as these files will be published online
plotfile("hello_world.html")  # this isn't shown in the actual example for simplicity
autoopen(true)

x = linspace(0, 2pi)
y = sin(x)
plot(x, y, title="Hello World")