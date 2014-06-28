
# in scripts (eg. here) that's done by calling showplot inside plot

# if interactive() == true (eg. in the shell or IJulia)

using Bokeh

plotfile("display.html")
# by default Bokeh.jl opens a plot whenever the "plot" function is called
# we can stop that by setting autoopen to false, that in turn can be done
# using the autoopen function or setting the autoopen key word argument in plot
autoopen(false)

x = linspace(0, 2pi)

# plot returns a Plot object
myplot = plot(x, sin(x))
# which can then be displayed with
showplot(myplot)

# if you wish to generate a plot but not display it you can use genplot
genplot(myplot)

# you can also specify the filename directly to genplot:
genplot(myplot, "display1.html")

# underneither genplot there's renderplot which returns the actual html
html = renderplot(myplot)
println(html[1:100], "...")

# however it also keeps a reference to the current plot, which you can access
plot(x, cos(x))
showplot(curplot())

# for convienience there's a shorthand for this:
showplot()

# Note: in this example, we've generated display.html and opened it in the browser
# 3 times, however probably all three plots will show the final plot,
# that's because the browser is to slow julia which has generated the last version of
# display.html before the browser has got round to opening it the first time
# (or so I assume????)