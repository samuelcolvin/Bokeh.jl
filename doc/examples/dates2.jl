using Bokeh
using Dates

start = now()
x = map(d -> start + Hour(d), 1:(30 * 24))
println(typeof(x))
# x: Array{DateTime,1}
day = 1000 * 3600 * 24
y = 0.5sin(int(x) * pi / day) + cos(int(x) * pi / (day * 7))
# note x needs to be an array of type DateTime or Date
plot(x, y)
showplot("dates_xy.html")

start = Date(1980, 1, 1)
x = map(d -> start + Day(d), 1:(365 * 30))
println(typeof(x))
# x: Array{Date,1}
y = 0.5sin(int(x) * pi / 365) + cos(int(x) * pi / (365 * 7))

plot(y, x)
showplot("dates_yx.html")