using Bokeh

# more or less the simplest plotting example
x = linspace(0, 2pi)
y = sin(x)#[sin(x) cos(x)]
# by default autoopen is set to true so `plot` will try to open a browser 
# with the plot file (which by default is "bokeh_plot.html")
Bokeh.debug(true)
# plot(y, "k--")
hold(true)
autoopen(false)
ys = [sin(x) cos(x)]
plot(ys, "ko|bo")
plot(sin)
showplot()