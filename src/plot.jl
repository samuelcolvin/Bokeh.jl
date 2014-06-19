function plot(x::Array, y::Array;
              title::String="Bokeh Plot", width::Int=WIDTH, height::Int=HEIGHT,
              filename::String=FILENAME, autoopen::Bool=AUTOOPEN)
	models, plotcon = genmodels(x, y, title, width, height)
	rendertemplate(models, plotcon, filename)
	autoopen && openhtml(filename)
end

# function plot(data::Array, start::Real=-10, stop::Real=10;
#               title::String="Bokeh Plot", width::Int=800, height::Int=600)
# 	