__precompile__()

module Bokeh

include("bokehjs.jl")
include("glyphs.jl")
include("display.jl")
include("generate.jl")
include("plot.jl")

# if DEBUG == true, displays indented JSON, uses unminified js and saves the raw
# JSON to "bokeh_models.json" if true
DEBUG = false
debug(b::Bool) = (global DEBUG = b)
debug() = DEBUG

# whether or not to show the plot immediately after `plot`
AUTOOPEN = isdefined(Main, :IJulia)
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

# default axis types
X_AXIS_TYPE = :auto
Y_AXIS_TYPE = :auto

# default glyph type
DEFAULT_GLYPHS_STR = "b|r|g|k|y|c|m|b--|r--|g--|k--|y--|c--|m--|--"
DEFAULT_GLYPHS = convert(Vector{Glyph}, DEFAULT_GLYPHS_STR)
glyphs(gs::Vector{Glyph}) = (global DEFAULT_GLYPHS = gs)
glyphs(s::AbstractString) = (global DEFAULT_GLYPHS = convert(Vector{Glyph},s))
glyphs() = DEFAULT_GLYPHS

# default glyph size
DEFAULT_SIZE = 6
glyphsize(gs::Int) = (global DEFAULT_SIZE = gs)
glyphsize() = DEFAULT_SIZE

# default alpha value for filled glyphs
DEFAULT_FILL_ALPHA = 0.7

# default filename
PLOTFILE = "bokeh_plot.html"
function warn_overwrite()
    if ispath(PLOTFILE) && isinteractive() && !isdefined(Main, :IJulia)
        warn("""
        $PLOTFILE already exists, it will be overwritten when a plot is generated
        Change the output file with plotfile(<new file name>)
        """)
    end
end

warn_overwrite()

function plotfile(fn::AbstractString)
    global PLOTFILE = fn
    warn_overwrite()
    nothing
end
plotfile() = PLOTFILE

# default plot title
TITLE = "Bokeh Plot"
title(t::AbstractString) = (global TITLE = t)
title() = TITLE

# number of points at which to evaluate functions
COUNTEVAL = 500
counteval(count::Int) = (global COUNTEVAL = count)
counteval() = COUNTEVAL

# hold on to plots
HOLD = false

function hold(h::Bool, clear::Union{Bool, Void}=nothing)
    if (!h && clear == nothing) || clear == true
        global CURPLOT = nothing
    end
    global HOLD = h
end

hold() = hold(!HOLD)  # method to flip hold status

# current plot object
CURPLOT = nothing
curplot(cp::Plot) = (global CURPLOT = cp)
curplot() = CURPLOT

# tools to add to display
TOOLS = [:pan, :wheelzoom, :boxzoom, :resize, :reset]
tools(t::Vector{Symbol}) = (global TOOLS = t)
tools() = TOOLS

# to avoid giving the same warning lots of times remember the file we've
# just warned about overwriting
WARN_FILE = nothing

# this overrides autoopen and disables opening html files used for travis CI,
# shouldn't be necessary elsewhere
NOSHOW = false
noshow(b::Bool) = (global NOSHOW = b)

# generally js and css is not copied into HTML pages but rather the files
# referenced, the only common exception is IJulia plots, this allows that to be
# ovwritten so js and css are always included in pages
INCLUDE_JS = false
includejs(ijs::Bool) = (global INCLUDE_JS = ijs)

# filesystem warning switch
FILE_WARNINGS = true
filewarnings(warn::Bool) = (global FILE_WARNINGS = warn)

# if we're in IJulia call setupnotebook to load js and css
if isdefined(Main, :IJulia) && Main.IJulia.inited
    setupnotebook()
end

export plot,
       setupnotebook,
       Glyph,
       Plot,
       BokehDataSet,
       renderplot,
       genplot,
       showplot,
       autoopen,
       width,
       height,
       glyphs,
       glyphsize,
       plotfile,
       title,
       counteval,
       hold,
       curplot,
       tools

end  # module
