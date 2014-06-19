using Bokeh
using Base.Test

# try setting all possible params
# some lime autoopen actually need to be set for travis
set_debug(true)
set_debug(false)
set_autoopen(false)
set_width(600)
set_height(300)
set_filename("testing_bokeh_plot.html")
set_title("Testing Bokeh Plot")

x = 1:10
y = x.^2
plot(x, y)

plot(y)

plot(cos)

Bokeh._parse_spec("r--") |> println

Bokeh._parse_spec("r:") |> println

