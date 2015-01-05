using Bokeh
if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end
# by default autoopen is false (since v0.0.2) so to cause plots to show
# when plot is called we switch it on
# this can also be achieved by passing autoopen=true to plot
autoopen(true)

# for consistency we set the name of the html file to generate in this example
# if you dont set this the default name "bokeh_plot.html" is used
plotfile("dates1.html")

# this simple example uses unix time stamps for datetimes
epoch = DateTime(1970, 1, 1)
n = int(now() - epoch) #  ms
# 1 month range
day = 1000 * 3600 * 24
x = linspace(n, n + day * 30, 1000)
y = 0.5sin(x * pi / day) + cos(x * pi / (day * 7))
# autoopen is set to true so `plot` will try to open a browser to show the plot 
plot(x, y, x_axis_type=:datetime)