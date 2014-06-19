uuid4 = Base.Random.uuid4
UUID = Base.Random.UUID

typealias VALUE_TYPES Any # Union(Dict, Array, String, Number, Bool, Nothing, UUID)

abstract PlotObject

abstract Range <: PlotObject

abstract Renderer <: PlotObject

abstract Axis <: PlotObject

abstract Ticker <: PlotObject

abstract TickFormatter <: PlotObject

function typid(plotob::PlotObject)
	attrs = typeof(plotob).names
	obtype = in(:_type_name, attrs) ? plotob._type_name : typeof(plotob)
	Dict{String, VALUE_TYPES}([
		"type" => obtype,
		"id" => string(plotob.uuid)])
end

type Plot <: PlotObject
	uuid::UUID
	title::String
	tools::Array{VALUE_TYPES, 1}
	outer_height::Int
	canvas_height::Int
	outer_width::Int
	canvas_width::Int
	x_range::Dict{String, VALUE_TYPES}
	y_range::Dict{String, VALUE_TYPES}
	renderers::Array{VALUE_TYPES, 1}
	data_sources::Array{VALUE_TYPES, 1}
end

type ColumnDataSource <: PlotObject
	uuid::UUID
	column_names::Array{String, 1}
	selected::Array{Any, 1}
	discrete_ranges::Dict{String, VALUE_TYPES}
	cont_ranges::Dict{String, VALUE_TYPES}
	data::Dict{String, Array{Number, 1}}
end

function ColumnDataSource(column_names::Array{String, 1}, data::Dict{String, Array{Number, 1}})
	ColumnDataSource(uuid4(),
					 column_names,
					 VALUE_TYPES[],
					 Dict{String, VALUE_TYPES}(), 
					 Dict{String, VALUE_TYPES}(), 
					 data)
end

type DataRange1d <: Range
	uuid::UUID
	sources::Array{VALUE_TYPES, 1}
end

function DataRange1d(coldata::ColumnDataSource, columns::Array{String, 1})
	sources = Dict{String, VALUE_TYPES}()
	sources["columns"] = columns
	sources["source"] = typid(coldata)
	DataRange1d(uuid4(), [sources])
end

type BasicTickFormatter <: TickFormatter
	uuid::UUID
	BasicTickFormatter() = new(uuid4())
end

type BasicTicker <: Ticker
	uuid::UUID
	BasicTicker() = new(uuid4())
end

type LinearAxis <: Axis
	uuid::UUID
	dimension::Int
	bounds::String
	location::String
	formatter::Dict{String, VALUE_TYPES}
	ticker::Dict{String, VALUE_TYPES}
	plot::Dict{String, VALUE_TYPES}
end

function LinearAxis(dimension::Int, tf::TickFormatter, t::Ticker, plot::Plot)
	LinearAxis(uuid4(), 
			   dimension, 
			   "auto",
			   "min",
			   typid(tf), 
			   typid(t), 
			   typid(plot))
end

type Grid <: Renderer
	uuid::UUID
	dimension::Int
	plot::Dict{String, VALUE_TYPES}
	axis::Dict{String, VALUE_TYPES}
end

function Grid(dimension::Int, plot::Plot, axis::Axis)
	Grid(uuid4(), dimension, typid(plot), typid(axis))
end

type Glyph <: Renderer
	uuid::UUID
	data_source::Dict{String, VALUE_TYPES}
	server_data_source::Any
	xdata_range::Dict{String, VALUE_TYPES}
	ydata_range::Dict{String, VALUE_TYPES}
	glyphspec::Dict{String, VALUE_TYPES}
end

function Glyph(coldata::ColumnDataSource, 
			   xrange::Range, 
			   yrange::Range, 
			   alpha::Float64=1.0,
			   _type::String="line", 
			   colour::String="blue")
	glyphspec = Dict{String, VALUE_TYPES}([
		"line_color" => ["value" => colour],
		"line_width" => ["units" => "data", "value" => 2],
		"line_alpha" => ["units" => "data", "value" => alpha],
		"y" => ["units" => "data", "field" => "y"],
		"x" => ["units" => "data", "field" => "x"],
		"type" => "line"
		])
	Glyph(coldata, xrange, yrange, glyphspec)
end

function Glyph(coldata::ColumnDataSource, xrange::Range, yrange::Range, glyphspec::Dict{String, VALUE_TYPES})
	data_source = typid(coldata)
	server_data_source = nothing
	xdata_range = typid(xrange)
	ydata_range = typid(yrange)
	Glyph(uuid4(), data_source, server_data_source, xdata_range, ydata_range, glyphspec)
end

type Metatool <: PlotObject
	uuid::UUID
	_type_name::String
	plot::Dict{String, VALUE_TYPES}
	dimensions::Union(Array{String, 1}, Nothing)
end

function Metatool(typename::String, plot::Plot, dimensions)
	plot = typid(plot)
	Metatool(uuid4(), typename, plot, dimensions)
end

DEFAULT_HEIGHT = 600
DEFAULT_WIDTH = 600
function Plot()
	Plot(uuid4(),
		 "",
		 Nothing[],
		 DEFAULT_HEIGHT,
		 DEFAULT_HEIGHT,
		 DEFAULT_WIDTH,
		 DEFAULT_WIDTH,
		 Dict{String, VALUE_TYPES}(),
		 Dict{String, VALUE_TYPES}(),
		 Nothing[],
		 Nothing[])
end

function Plot(plot::Plot,
			  coldata::ColumnDataSource,
			  xrange::Range, 
			  yrange::Range,
			  renderers::Array{PlotObject,1},
			  tools::Array{PlotObject,1},
			  title::String="Bokeh Plot",
			  height::Int=DEFAULT_HEIGHT,
			  width::Int=DEFAULT_WIDTH)
	data_sources = VALUE_TYPES[]# [typid(coldata)]
	xdata_range = typid(xrange)
	ydata_range = typid(yrange)
	renderers = map(typid, renderers)
	tools = map(typid, tools)
	Plot(plot.uuid,
		 title,
		 tools,
		 height,
		 height,
		 width,
		 width,
		 xdata_range,
		 ydata_range,
		 renderers,
		 data_sources)
end

type PlotContext <: PlotObject
	uuid::UUID
	children::Array{Dict{String, VALUE_TYPES}, 1}
end

function PlotContext(plot::Plot)
	PlotContext(uuid4(),[typid(plot)])
end