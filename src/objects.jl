uuid4 = Base.Random.uuid4
UUID = Base.Random.UUID

abstract PlotObject

abstract Range <: PlotObject

abstract Renderer <: PlotObject

const VALUE_TYPES = Any # Union(Dict, Array, String, Number, Bool, Nothing, UUID)


function typeiddict(name::String, id::UUID)
	Dict{String, VALUE_TYPES}([
		"type" => name,
		"id" => string(id)])
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
	sources::Dict{String, VALUE_TYPES}
end

function DataRange1d(coldata_id::UUID, columns::Array{String, 1})
	sources = Dict{String, VALUE_TYPES}()
	sources["columns"] = columns
	sources["source"] = typeiddict("ColumnDataSource", coldata_id)
	DataRange1d(uuid4(), sources)
end


type Axis <: Renderer
	uuid::UUID
	dimension::Int
	formatter::Any
	ticker::Any
	plot::Dict{String, VALUE_TYPES}
end

function Axis(dimension::Int, plotid::UUID)
	Axis(uuid4(), dimension, nothing, nothing, typeiddict("plot", plotid))
end

type Glyph <: Renderer
	uuid::UUID
	data_source::Dict{String, VALUE_TYPES}
	server_data_source::Any
	xdata_range::Dict{String, VALUE_TYPES}
	ydata_range::Dict{String, VALUE_TYPES}
	glyphspec::Dict{String, VALUE_TYPES}
end

function Glyph(coldata_id::UUID, 
			   xrange_id::UUID, 
			   yrange_id::UUID, 
			   alpha::Float64=1.0,
			   _type::String="line", 
			   colour::String="blue")
	glyphspec = Dict{String, VALUE_TYPES}([
		"line_color" => ["value" => colour],
		"line_width" => ["units" => "data", "field" => "line_width"],
		"line_alpha" => ["units" => "data", "field" => alpha],
		"y" => ["units" => "data", "field" => "y"],
		"x" => ["units" => "data", "field" => "x"],
		"type" => "line"
		])
	Glyph(coldata_id, xrange_id, yrange_id, glyphspec)
end

function Glyph(coldata_id::UUID, xrange_id::UUID, yrange_id::UUID, glyphspec::Dict{String, VALUE_TYPES})
	data_source = typeiddict("ColumnDataSource", coldata_id)
	server_data_source = nothing
	xdata_range = typeiddict("DataRange1d", xrange_id)
	ydata_range = typeiddict("DataRange1d", yrange_id)
	Glyph(uuid4(), data_source, server_data_source, xdata_range, ydata_range, glyphspec)
end

type Plot <: PlotObject
	uuid::UUID
	title::String
	Tools::Array{VALUE_TYPES, 1}
	outer_height::Int
	canvas_height::Int
	outer_width::Int
	canvas_width::Int
	x_range::Dict{String, VALUE_TYPES}
	y_range::Dict{String, VALUE_TYPES}
	renderers::Array{VALUE_TYPES, 1}
	data_sources::Array{VALUE_TYPES, 1}
end

function Plot(coldata_id::UUID,
			  xrange_id::UUID, 
			  yrange_id::UUID,
			  renderers::Array{(ASCIIString, UUID),1},
			  title::String="Bokeh Plot",
			  height::Int=600,
			  width::Int=600)
	data_sources = [typeiddict("ColumnDataSource", coldata_id)]
	xdata_range = typeiddict("DataRange1d", xrange_id)
	ydata_range = typeiddict("DataRange1d", yrange_id)
	renderers = [typeiddict(name, id) for (name, id) in renderers]
	Plot(uuid4(),
		 title,
		 VALUE_TYPES[],
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

function PlotContext(plotid::UUID)
	PlotContext(uuid4(),[typeiddict("plot", plotid)])
end