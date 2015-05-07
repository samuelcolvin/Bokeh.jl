using Bokeh

# more or less the simplest plotting example
x = linspace(0, 2pi, 10)
y = sin(x)#[sin(x) cos(x)]
# by default autoopen is set to true so `plot` will try to open a browser 
# with the plot file (which by default is "bokeh_plot.html")
Bokeh.debug(true)
# plot(y, "k--")
Bokeh.height(400)
Bokeh.width(600)
hold(true)
autoopen(false)
ys = [sin(x) cos(x)]
plot(ys)
showplot()