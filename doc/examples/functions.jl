using Bokeh

plotfile("functions.html")
# here we switch of autoopen as we wont both opening each plot
# see display.jl for details on opening plots
autoopen(false)

# Bokeh.jl tries hard to follow TextPlots.jl's API particularly for functions
# (in future there might be "use textplots" switch in Bokeh.jl)
# the following examples are all equivilent
plot(sin)
plot(sin, -10:10)
plot(sin, -10, 10)

plot([sin, cos, tan, sinh, cosh, tanh], -1:1)
showplot()