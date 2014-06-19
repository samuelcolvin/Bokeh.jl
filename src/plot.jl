function plot(x::Array, y::Array;
              title::String="Bokeh Plot", width::Int=800, height::Int=600,
              fname::String="bokeh_plot.html")
	models, plotcon = genmodels(x, y)
	rendertemplate(models, plotcon, fname)
	AUTOOPEN && openhtml(fname)
end

# function plot(data::Array, start::Real=-10, stop::Real=10;
#               title::String="Bokeh Plot", width::Int=800, height::Int=600)
# 	