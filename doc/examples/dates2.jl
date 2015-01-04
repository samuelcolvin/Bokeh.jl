using Bokeh
using Dates

# this simple example uses unix time stamps for datetimes
start = now()
x = map(d -> start + Hour(d), 1:(30 * 24))
day = 1000 * 3600 * 24
y = 0.5sin(int(x) * pi / day) + cos(int(x) * pi / (day * 7))
# autoopen is set to true so `plot` will try to open a browser to show the plot 
plot(x, y)
showplot("dates_xy.html")

plot(y, x)
showplot("dates_yx.html")