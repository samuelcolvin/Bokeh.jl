using JSON

module Bokehjs
	typealias Real1d Union(AbstractArray{Int, 1}, AbstractArray{Float64, 1})
	# increase we want to restrict it in future:
	typealias BkAny Any # Union(Dict, Array, String, Number, Bool, Nothing, UUID)
	typealias NullDict Union(Nothing, Dict{String, BkAny})
	uuid4 = Base.Random.uuid4
	UUID = Base.Random.UUID

	abstract PlotObject

	abstract BkRange <: PlotObject

	typealias NullBkRange Union(Nothing, BkRange)

	abstract Renderer <: PlotObject

	abstract Axis <: PlotObject

	abstract Ticker <: PlotObject

	abstract TickFormatter <: PlotObject

	function typid(plotob::PlotObject)
		attrs = typeof(plotob).names
		obtype = in(:_type_name, attrs) ? plotob._type_name : typeof(plotob)
		Dict{String, BkAny}([
			"type" => obtype,
			"id" => plotob.uuid])
	end

	typid(plotob::Nothing) = nothing

	type Plot <: PlotObject
		uuid::UUID
		title::String
		tools::Array{BkAny, 1}
		outer_height::Int
		canvas_height::Int
		outer_width::Int
		canvas_width::Int
		x_range::Dict{String, BkAny}
		y_range::Dict{String, BkAny}
		renderers::Array{BkAny, 1}
		data_sources::Array{BkAny, 1}
	end

	type ColumnDataSource <: PlotObject
		uuid::UUID
		column_names::Array{String, 1}
		selected::Array{Any, 1}
		discrete_ranges::Dict{String, BkAny}
		cont_ranges::Dict{String, BkAny}
		data::Dict{String, Real1d}
	end

	function ColumnDataSource(column_names::Array{String, 1}, data::Dict{String, Real1d})
		ColumnDataSource(uuid4(),
						 column_names,
						 BkAny[],
						 Dict{String, BkAny}(), 
						 Dict{String, BkAny}(), 
						 data)
	end

	type DataRange1d <: BkRange
		uuid::UUID
		sources::Array{BkAny, 1}
	end

	function DataRange1d(cdss::Array{ColumnDataSource, 1}, columns::Array{String, 1})
		source(cds) = Dict{String, BkAny}(["columns" => columns, "source" => typid(cds)])
		sources = map(source, cdss)
		DataRange1d(uuid4(), sources)
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
		formatter::Dict{String, BkAny}
		ticker::Dict{String, BkAny}
		plot::Dict{String, BkAny}
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
		plot::Dict{String, BkAny}
		axis::Dict{String, BkAny}
	end

	function Grid(dimension::Int, plot::Plot, axis::Axis)
		Grid(uuid4(), dimension, typid(plot), typid(axis))
	end

	type Glyph <: Renderer
		uuid::UUID
		data_source::Dict{String, BkAny}
		server_data_source::NullDict
		xdata_range::NullDict
		ydata_range::NullDict
		glyphspec::Dict{String, BkAny}
	end

	function Glyph(coldata::ColumnDataSource, xrange::NullBkRange, yrange::NullBkRange, glyphspec::Dict{String, BkAny})
		data_source = typid(coldata)
		server_data_source = nothing
		xdata_range = typid(xrange)
		ydata_range = typid(yrange)
		Glyph(uuid4(), data_source, server_data_source, xdata_range, ydata_range, glyphspec)
	end

	type Metatool <: PlotObject
		uuid::UUID
		_type_name::String
		plot::Dict{String, BkAny}
		dimensions::Union(Array{String, 1}, Nothing)
	end

	function Metatool(typename::String, plot::Plot, dimensions)
		plot = typid(plot)
		Metatool(uuid4(), typename, plot, dimensions)
	end

	_DEFAULT_HEIGHT = 600
	_DEFAULT_WIDTH = 600
	function Plot()
		Plot(uuid4(),
			 "",
			 Nothing[],
			 _DEFAULT_HEIGHT,
			 _DEFAULT_HEIGHT,
			 _DEFAULT_WIDTH,
			 _DEFAULT_WIDTH,
			 Dict{String, BkAny}(),
			 Dict{String, BkAny}(),
			 Nothing[],
			 Nothing[])
	end

	function Plot(plot::Plot,
				  xrange::BkRange, 
				  yrange::BkRange,
				  renderers::Array{PlotObject,1},
				  tools::Array{PlotObject,1},
				  title::String="Bokeh Plot",
				  height::Int=_DEFAULT_HEIGHT,
				  width::Int=_DEFAULT_WIDTH)
		data_sources = BkAny[]# [typid(coldata)]
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
		children::Array{Dict{String, BkAny}, 1}
	end

	function PlotContext(plot::Plot)
		PlotContext(uuid4(),[typid(plot)])
	end
end
typealias Real1d Bokehjs.Real1d
typealias BkAny Bokehjs.BkAny

# implement correct UUID printing for both old and new JSON.jl
function JSON._print(io::IO, state::JSON.State, uuid::Bokehjs.UUID)
    JSON._print(io, state, string(uuid))
end

function JSON.print(io::IO, uuid::Bokehjs.UUID)
    JSON.print(io, string(uuid))
end