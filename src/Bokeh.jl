module Bokeh
	DEBUG = false
	set_debug(b::Bool) = (global DEBUG = b)
	AUTOOPEN = true
	set_autoopen(b::Bool) = (global AUTOOPEN = b)
	include("objects.jl")
	include("browser.jl")
	include("generate.jl")
	include("plot.jl")
	export plot, set_debug, set_autoopen
end