module Bokeh
	debug = false
	set_debug(b::Bool) = (global debug = b)
	autoopen = true
	set_autoopen(b::Bool) = (global autoopen = b)
	include("objects.jl")
	include("browser.jl")
	include("generate.jl")
	include("plot.jl")
	export plot, set_debug, set_autoopen
end