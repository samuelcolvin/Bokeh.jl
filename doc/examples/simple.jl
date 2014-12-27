using Bokeh
# by default autoopen is false (since v0.0.2) so to cause plots to show
# when plot is called we switch it on
# this can also be achieved by passing autoopen=true to plot
autoopen(true)

# for consistency we set the name of the html file to generate in this example
# if you dont set this the default name "bokeh_plot.html" is used
plotfile("simple.html")

# more or less the simplest plotting example
x = linspace(0, 2pi)
y = sin(x)
# autoopen is set to true so `plot` will try to open a browser to show the plot 
plot(x, y)