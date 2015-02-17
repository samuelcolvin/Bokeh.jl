using Bokeh

Bokeh.includejs(true)  # this is required as these files will be published online
plotfile("functions.html")

plot(sin) # this uses the default range of -10 to 10
plot(sin, 0:20)
# the two plots above won't be shown since we haven't set hold, see below

plot([sin, cos, tan, sinh, cosh, tanh], -1:1)
showplot()