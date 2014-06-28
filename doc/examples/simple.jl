using Bokeh

# for consistency we set the name of the html file to generate in this example
# if you dont set this the default name "bokeh_plot.html" is used
plotfile("simple.html")

# more or less the simplest plotting example
x = linspace(0, 2pi)
y = sin(x)
# by default autoopen is set to true so `plot` will try to open a browser 
plot(x, y)