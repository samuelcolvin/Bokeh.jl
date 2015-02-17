using Bokeh

plotfile("functions.html")

plot(sin) # this uses the default range of -10 to 10
plot(sin, 0:20) # supply the rante
plot(x -> x^3 - 2x^2 + 3x, -5, 5) # also supplies the range
# the three plots above won't be shown since we haven't set hold, see below

plot([sin, cos, tan, sinh, cosh, tanh], -1:1)
showplot()