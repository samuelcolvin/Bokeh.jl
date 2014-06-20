module Bokeh
	# displays indented JSON, uses unminified js and saves the raw JSON to "bokeh_models.json" if true
	DEBUG = false
	set_debug(b::Bool) = (global DEBUG = b)
	# whether or not to show the plot immediately after `plot`
	AUTOOPEN = true
	set_autoopen(b::Bool) = (global AUTOOPEN = b)
	# default width of plot
	WIDTH = 800
	set_width(w::Int) = (global WIDTH = w)
	# default height of plot
	HEIGHT = 600
	set_height(h::Int) = (global HEIGHT = h)
	# default filename 
	FILENAME = "bokeh_plot.html"
	set_filename(fn::String) = (global FILENAME = fn)
	# default plot title
	TITLE = "Bokeh Plot"
	set_title(t::String) = (global TITLE = t)
	# number of points at which to evaluate functions
	COUNTEVAL = 500
	set_counteval(count::Int) = (global COUNTEVAL = count)

	include("plot.jl")
	export plot, 
		   set_debug, 
		   set_autoopen, 
		   set_width,
		   set_height,
		   set_filename,
		   set_title
end