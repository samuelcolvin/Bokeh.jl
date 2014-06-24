module Bokeh
	include("plot.jl")
	# displays indented JSON, uses unminified js and saves the raw JSON to "bokeh_models.json" if true
	DEBUG = false
	debug(b::Bool) = (global DEBUG = b)
	debug() = DEBUG
	# whether or not to show the plot immediately after `plot`
	AUTOOPEN = true
	autoopen(b::Bool) = (global AUTOOPEN = b)
	autoopen() = AUTOOPEN
	# default width of plot
	WIDTH = 800
	width(w::Int) = (global WIDTH = w)
	width() = WIDTH
	# default height of plot
	HEIGHT = 600
	height(h::Int) = (global HEIGHT = h)
	height() = HEIGHT
	# default glyph type
	DEFAULT_GLYPHS_STR = "b|r|g|k|y|c|m|b--|r--|g--|k--|y--|c--|m--|--"
	DEFAULT_GLYPHS = convert(Vector{Glyph}, DEFAULT_GLYPHS_STR)
	glyphs(gs::Vector{Glyph}) = (global DEFAULT_GLYPHS = gs)
	glyphs(s::String) = (global DEFAULT_GLYPHS = convert(Vector{Glyph},s))
	glyphs() = DEFAULT_GLYPHS
	# default glyph size
	DEFAULT_SIZE = 8
	glyphsize(gs::Int) = (global DEFAULT_SIZE = gs)
	glyphsize() = DEFAULT_SIZE
	# default filename 
	DEFAULT_FILL_ALPHA = 0.7
	FILENAME = "bokeh_plot.html"
	filename(fn::String) = (global FILENAME = fn)
	filename() = FILENAME
	# default plot title
	TITLE = "Bokeh Plot"
	title(t::String) = (global TITLE = t)
	title() = TITLE
	# number of points at which to evaluate functions
	COUNTEVAL = 500
	counteval(count::Int) = (global COUNTEVAL = count)
	counteval() = COUNTEVAL

	export plot,
		   Glyphs,
		   Glyph,
		   Plot,
		   DataColumn, 
		   debug, 
		   autoopen, 
		   width,
		   height,
		   glyphs,
		   glyphsize,
		   filename,
		   title
end