using Bokeh
# simple example with debug true so we can read the json more easily
Bokeh.debug(true)
plotfile("debug.html")
y = collect(1:10).^2
# here we don't define x so it's auto generated as 0:(length(y) - 1)
plot(y, autoopen=true)