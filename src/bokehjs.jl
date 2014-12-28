using JSON

module Bokehjs
	typealias RealVect Union(AbstractVector{Int}, AbstractVector{Float64})
	typealias RealMat Union(AbstractMatrix{Int}, AbstractMatrix{Float64})
	typealias RealMatVect Union(RealMat, RealVect)
	# would be nice to parameterize, but more important to constrain dims to 1 or 2
	# typealias RealMatVect{N} Union(AbstractArray{Int, N}, AbstractArray{Float64, N})
	
	# in case we want to restrict value types in future:
	typealias BkAny Any # Union(Dict, Array, String, Number, Bool, Nothing, UUID)
	typealias NullDict Union(Nothing, Dict{String, BkAny})
	typealias NullString Union(Nothing, String)
	uuid4 = Base.Random.uuid4
	UUID = Base.Random.UUID

	# like nothing except omitted from json rather than being null
	type Omit
		v::String
		Omit() = new("__omitted from json__")
	end
	const omit = Omit()

	abstract PlotObject

	abstract BkRange <: PlotObject

	typealias NullBkRange Union(Nothing, BkRange)

	abstract Renderer <: PlotObject

	abstract Axis <: PlotObject

	abstract Ticker <: PlotObject

	abstract TickFormatter <: PlotObject

	type TypeID
		plotob::Union(PlotObject, Nothing)
	end

	function TypeID()
		TypeID(nothing)
	end

	type Plot <: PlotObject
		uuid::UUID
		title::String
		tools::Array{BkAny, 1}
		outer_height::Int
		canvas_height::Int
		outer_width::Int
		canvas_width::Int
		x_range::TypeID
		y_range::TypeID
		# could be Array{TypeID, 1}?:
		renderers::Array{BkAny, 1}
		above::Array{TypeID, 1}
		below::Array{TypeID, 1}
		left::Array{TypeID, 1}
		right::Array{TypeID, 1}
		data_sources::Array{BkAny, 1}
	end

	type ColumnDataSource <: PlotObject
		uuid::UUID
		column_names::Array{String, 1}
		selected::Array{Any, 1}
		discrete_ranges::Dict{String, BkAny}
		cont_ranges::Dict{String, BkAny}
		data::Dict{String, RealVect}
	end

	function ColumnDataSource(column_names::Array{String, 1}, data::Dict{String, RealVect})
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
		source(cds) = Dict{String, BkAny}(["columns" => columns, "source" => TypeID(cds)])
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
		formatter::TypeID
		ticker::TypeID
		plot::TypeID
	end

	function LinearAxis(dimension::Int, tf::TickFormatter, t::Ticker, plot::Plot)
		LinearAxis(uuid4(), 
				   dimension, 
				   "auto",
				   "min",
				   TypeID(tf), 
				   TypeID(t), 
				   TypeID(plot))
	end

	type Grid <: Renderer
		uuid::UUID
		dimension::Int
		plot::TypeID
		# axis::TypeID
    	ticker::TypeID
	end

	function Grid(dimension::Int, plot::Plot, ticker::BasicTicker)
		Grid(uuid4(), dimension, TypeID(plot), TypeID(ticker))
	end

	type AnyGlyph <: PlotObject
		uuid::UUID
		_type_name::String
		line_color::Union(Omit, Dict{String, String})
		line_width::Union(Omit, Dict{String, BkAny})
		line_alpha::Union(Omit, Dict{String, BkAny})
		line_dash::Union(Omit, Array{Int64, 1})
		fill_color::Union(Omit, Dict{String, String})
		fill_alpha::Union(Omit, Dict{String, BkAny})
		x::Dict{String, String}
		y::Dict{String, String}
	end


	function AnyGlyph(glyph_name::String,
					  linecolor::Union(Nothing, String), 
					  linewidth::Union(Nothing, Int64), 
					  linealpha::Union(Nothing, Float64), 
					  linedash::Union(Nothing, Array{Int64, 1}),
					  fillcolor::Union(Nothing, String),
					  fillalpha::Union(Nothing, Float64))
		linecolor = linecolor == nothing ? omit : Dict{String, String}({"value" => linecolor})
		linewidth = linewidth == nothing ? omit : Dict{String, BkAny}({"units" => "data", "value" => linewidth})
		linealpha = linealpha == nothing ? omit : Dict{String, BkAny}({"units" => "data", "value" => linealpha})
		linedash = linedash == nothing ? omit : linedash
		fillcolor = fillcolor == nothing ? omit : Dict{String, String}({"value" => fillcolor})
		fillalpha = fillalpha == nothing ? omit : Dict{String, BkAny}({"units" => "data", "value" => fillalpha})
		AnyGlyph(uuid4(), 
				 glyph_name,
			 	 linecolor,
				 linewidth,
				 linealpha,
				 linedash,
				 fillcolor,
				 fillalpha,
				 Dict{String, String}({"units" => "data", "field" => "x"}),
				 Dict{String, String}({"units" => "data", "field" => "y"}),
		)
	end

	type GlyphRenderer <: Renderer
		uuid::UUID
		data_source::TypeID
		nonselection_glyph::TypeID
		selection_glyph::TypeID
		glyph::TypeID
		name::NullString
		server_data_source::NullDict
	end

	typealias NullAnyGlyph Union(Nothing, AnyGlyph)

	function GlyphRenderer(coldata::ColumnDataSource, nonsel_g::NullAnyGlyph, sel_g::NullAnyGlyph, glyph::AnyGlyph)
		GlyphRenderer(uuid4(), 
					  TypeID(coldata),
					  TypeID(nonsel_g),
					  TypeID(sel_g),
					  TypeID(glyph),
					  nothing,
					  nothing
		)
	end

	type Metatool <: PlotObject
		uuid::UUID
		_type_name::String
		plot::TypeID
		dimensions::Union(Array{String, 1}, Nothing, Omit)
	end

	function Metatool(typename::String, plot::Plot, dimensions)
		plot = TypeID(plot)
		Metatool(uuid4(), typename, plot, dimensions)
	end

	function Metatool(typename::String, plot::Plot)
		Metatool(typename, plot, omit)
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
			 TypeID(),
			 TypeID(),
			 Nothing[],

			 Nothing[],
			 Nothing[],
			 Nothing[],
			 Nothing[],
			 
			 Nothing[])
	end

	function Plot(plot::Plot,
				  xrange::BkRange, 
				  yrange::BkRange,
				  renderers::Array{PlotObject,1},
				  axes,#::Dict{Symbol, Array{PlotObject,1}},
				  tools::Array{PlotObject,1},
				  title::String="Bokeh Plot",
				  height::Int=_DEFAULT_HEIGHT,
				  width::Int=_DEFAULT_WIDTH)
		data_sources = BkAny[]# [TypeID(coldata)]

		Plot(plot.uuid,
			 title,
			 map(TypeID, tools),
			 height,
			 height,
			 width,
			 width,
			 TypeID(xrange),
			 TypeID(yrange),
			 map(TypeID, renderers),
			 map(TypeID, axes[:above]),
			 map(TypeID, axes[:below]),
			 map(TypeID, axes[:left]),
			 map(TypeID, axes[:right]),
			 data_sources)
	end

	type PlotContext <: PlotObject
		uuid::UUID
		children::Array{TypeID, 1}
	end

	function PlotContext(plot::Plot)
		PlotContext(uuid4(),[TypeID(plot)])
	end
end
typealias RealVect Bokehjs.RealVect
typealias RealMat Bokehjs.RealMat
typealias RealMatVect Bokehjs.RealMatVect
typealias BkAny Bokehjs.BkAny

if in(:_print, names(JSON, true))
	# implement correct UUID printing for both old and new JSON.jl
	function JSON._print(io::IO, state::JSON.State, uuid::Bokehjs.UUID)
	    JSON._print(io, state, string(uuid))
	end
	function JSON._print(io::IO, state::JSON.State, tid::Bokehjs.TypeID)
		tid.plotob == nothing && (return JSON._print(io, state, nothing))
		attrs = typeof(tid.plotob).names
		obtype = in(:_type_name, attrs) ? tid.plotob._type_name : typeof(tid.plotob)
		d = Dict{String, BkAny}([
			"type" => obtype,
			"id" => tid.plotob.uuid])
	    JSON._print(io, state, d)
	end
else
	function JSON.print(io::IO, uuid::Bokehjs.UUID)
	    JSON.print(io, string(uuid))
	end	
	function JSON.print(io::IO, tid::Bokehjs.TypeID)
		tid.plotob == nothing && (return JSON.print(io, nothing))
		attrs = typeof(tid.plotob).names
		obtype = in(:_type_name, attrs) ? tid.plotob._type_name : typeof(tid.plotob)
		d = Dict{String, BkAny}([
			"type" => obtype,
			"id" => tid.plotob.uuid])
	    JSON.print(io, d)
	end
end