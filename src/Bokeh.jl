module Bokeh
	# displays indented JSON and unminified js and save the raw JSON to "bokeh_models.json" if true
	DEBUG = false
	set_debug(b::Bool) = (global DEBUG = b)
	# whether or not to show the plot immediately after `plot`
	AUTOOPEN = true
	set_autoopen(b::Bool) = (global AUTOOPEN = b)
	# default width of plot
	WIDTH = 800
	set_width(w::Int) = (global WIDTH = w)
	# default height of plot
	HEIGHT = 800
	set_height(h::Int) = (global HEIGHT = h)
	# default filename 
	FILENAME = "bokeh_plot.html"
	set_filename(fn::String) = (global FILENAME = fn)
	# default plot title
	TITLE = "Bokeh Plot"
	set_title(t::String) = (global TITLE = t)

	include("objects.jl")
	include("browser.jl")
	include("generate.jl")
	include("plot.jl")
	export plot, 
		   set_debug, 
		   set_autoopen, 
		   set_width,
		   set_height,
		   set_filename,
		   set_title
end