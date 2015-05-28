using Bokeh
using Compat
if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

autoopen(true)

plotfile("dates1.html")

# this simple example uses unix time stamps for datetimes
epoch = DateTime(1970, 1, 1)
@compat n = Int(now() - epoch) #  ms
# 1 month range
day = 1000 * 3600 * 24
x = linspace(n, n + day * 30, 1000)
y = 0.5sin(x * pi / day) + cos(x * pi / (day * 7))
# autoopen is set to true so `plot` will try to open a browser to show the plot 
plot(x, y, x_axis_type=:datetime)