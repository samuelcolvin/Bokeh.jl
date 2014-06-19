using Bokeh
using Base.Test

x = [1:10]
y = x.^2
set_autoopen(false)
plot(x, y)