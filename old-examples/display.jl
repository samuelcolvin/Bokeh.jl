using Bokeh

plotfile("display.html")

x = linspace(0, 2pi)

# plot returns a Plot object
myplot = plot(x, sin(x))
# which can then be displayed with
showplot(myplot)

# if you wish to generate a plot but not display it, you can use genplot
genplot(myplot)

# you can also specify the filename directly to genplot:
genplot(myplot, "display1.html")

# underneither genplot there's renderplot which returns the actual html
html = renderplot(myplot)
println(html[1:100], "...")

# however bokeh.jl also keeps a reference to the current plot, which you can access
plot(x, cos(x))
showplot(curplot())

# for convienience there's a shorthand for this:
showplot()

# Note: in this example, we've generated display.html and opened it in the browser
# 3 times, however probably all three plots will show the final plot,
# that's because the browser is too slow for julia which has generated the last version of
# display.html before the browser has time to opening it the first two times
# (or so I assume????)