using Bokeh
using Compat
if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

start = now()
x = map(d -> start + Dates.Hour(d), 1:(30 * 24))
println(typeof(x))
# x: Array{DateTime,1}
day = 1000 * 3600 * 24
@compat y = 0.5sin(map(Int, x) * pi / day) + cos(map(Int, x) * pi / (day * 7))
# note x needs to be an array of type DateTime or Date
plot(x, y)
showplot("dates_xy.html")

start = Date(1980, 1, 1)
x = map(d -> start + Dates.Day(d), 1:(365 * 30))
println(typeof(x))
# x: Array{Date,1}
@compat y = 0.5sin(map(Int, x) * pi / 365) + cos(map(Int, x) * pi / (365 * 7))

plot(y, x)
showplot("dates_yx.html")