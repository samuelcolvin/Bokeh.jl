uuid4 = Base.Random.uuid4
UUID = Base.Random.UUID

abstract PlotObject

abstract Range <: PlotObject

abstract Renderer <: PlotObject

const VALUE_TYPES = Any # Union(Dict, Array, String, Number, Bool, Nothing, UUID)


function typeiddict(name::String, id::UUID)
	Dict{String, VALUE_TYPES}([
		("type", name),
		("id", string(id))])
end

function plotdict(plotid::UUID)
	typeiddict("plot", plotid)
end

type ColumnDataSource <: PlotObject
	uuid::UUID
	column_names::Array{String, 1}
	selected::Array{Any, 1}
	discrete_ranges::Dict{String, VALUE_TYPES}
	cont_ranges::Dict{String, VALUE_TYPES}
	data::Dict{String, Array{Number, 1}}
	ColumnDataSource(column_names::Array{String, 1},
					 selected::Array{Any, 1},
					 discrete_ranges::Dict{String, VALUE_TYPES},
					 cont_ranges::Dict{String, VALUE_TYPES},
					 data::Dict{String, Array{Number, 1}}) = new(
						 uuid4(), 
						 column_names,
						 selected,
						 discrete_ranges, 
						 cont_ranges, 
						 data)
end

function ColumnDataSource(column_names::Array{String, 1}, data::Dict{String, Array{Number, 1}})
	ColumnDataSource(column_names,
					 Any[],
					 Dict{String, VALUE_TYPES}(), 
					 Dict{String, VALUE_TYPES}(), 
					 data)
end

type DataRange1d <: Range
	uuid::UUID
	sources::Dict{String, VALUE_TYPES}
	DataRange1d(sources::Dict{String, VALUE_TYPES}) = new(
		uuid4(), sources)
end

function DataRange1d(coldataid::UUID, columns::Array{String, 1})
	sources = Dict{String, VALUE_TYPES}()
	sources["columns"] = columns
	sources["source"] = typeiddict("ColumnDataSource", coldataid)
	DataRange1d(sources)
end


type Axis <: Renderer
	uuid::UUID
	dimension::Int
	formatter::Any
	ticker::Any
	plot::Dict{String, VALUE_TYPES}
	Axis(dimension::Int, formatter, ticker, plot::Dict{String, VALUE_TYPES}) = new(
		uuid4(),
		dimension, 
		formatter, 
		ticker,
		plot)
end

function Axis(dimension::Int, plotid::UUID)
	Axis(dimension, nothing, nothing, plotdict(plotid))
end

type Glyph <: Renderer
	uuid::UUID
	Glyph() = new(uuid4())
end

type Plot <: PlotObject
	uuid::UUID
	Plot() = new(uuid4())
end

type PlotContext <: PlotObject
	uuid::UUID
	children::Array{Dict{String, VALUE_TYPES}, 1}
	PlotContext(children::Array{Dict{String, VALUE_TYPES}, 1}) = new(uuid4(),children)
end

function PlotContext(plotid::UUID)
	PlotContext([plotdict(plotid)])
end

