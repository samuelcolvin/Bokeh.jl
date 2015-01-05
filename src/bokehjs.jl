using JSON
using Compat

module Bokehjs
  using Compat
	typealias RealVect Union(AbstractVector{Int}, AbstractVector{Float64})
	typealias RealMat Union(AbstractMatrix{Int}, AbstractMatrix{Float64})
	typealias RealMatVect Union(RealMat, RealVect)
	# would be nice to parameterize, but more important to constrain dims to 1 or 2
	# typealias RealMatVect{N} Union(AbstractArray{Int, N}, AbstractArray{Float64, N})

	# like nothing except omitted from json rather than being null
	type Omit
		v::String
		Omit() = new("__omitted from json__")
	end
	const omit = Omit()
	
	# in case we want to restrict value types in future:
	typealias BkAny Any # Union(Dict, Array, String, Number, Bool, Nothing, UUID)
	typealias NullDict Union(Nothing, Dict{String, BkAny})
	typealias OmitDict Union(Omit, Dict{String, BkAny})

	typealias NullString Union(Nothing, String)
	typealias OmitString Union(Omit, String)

	typealias NullSymbol Union(Nothing, Symbol)
	typealias OmitSymbol Union(Omit, Symbol)

    typealias NullFloat Union(Float64, Nothing)

    typealias NullInt Union(Int, Nothing)

	uuid4 = Base.Random.uuid4
	UUID = Base.Random.UUID

	abstract PlotObject

	abstract BkRange <: PlotObject

	typealias NullBkRange Union(Nothing, BkRange)

	abstract Renderer <: PlotObject

	abstract Axis <: PlotObject

	type TypeID
		plotob::Union(PlotObject, Nothing)
	end

	function TypeID()
		TypeID(nothing)
	end

	type Plot <: PlotObject
		uuid::UUID
		title::String
		tools::Vector{BkAny}
		outer_height::Int
		canvas_height::Int
		outer_width::Int
		canvas_width::Int
		x_range::TypeID
		y_range::TypeID
		# could be Vector{TypeID}?:
		renderers::Vector{BkAny}
		above::Vector{TypeID}
		below::Vector{TypeID}
		left::Vector{TypeID}
		right::Vector{TypeID}
		data_sources::Vector{BkAny}
	end

	type ColumnDataSource <: PlotObject
		uuid::UUID
		column_names::Vector{String}
		selected::Vector{Any}
		discrete_ranges::Dict{String, BkAny}
		cont_ranges::Dict{String, BkAny}
		data::Dict{String, RealVect}
	end

	function ColumnDataSource(column_names::Vector{String}, data::Dict{String, RealVect})
		ColumnDataSource(uuid4(),
						 column_names,
						 BkAny[],
						 Dict{String, BkAny}(), 
						 Dict{String, BkAny}(), 
						 data)
	end

	type DataRange1d <: BkRange
		uuid::UUID
		sources::Vector{BkAny}
	end

	function DataRange1d(cdss::Vector{ColumnDataSource}, columns::Vector{String})
		source(cds) = @Compat.compat Dict{String, BkAny}("columns" => columns, "source" => TypeID(cds))
		sources = map(source, cdss)
		DataRange1d(uuid4(), sources)
	end

	type TickFormatter <: PlotObject
		uuid::UUID
		_type_name::String
		format::OmitDict
		function TickFormatter(name::String)
			@assert name in ("BasicTickFormatter", "DatetimeTickFormatter", "LogTickFormatter")
			# format only seems to occur for DatetimeTickFormatter and even then is empty
			format = name == "DatetimeTickFormatter" ? Dict{String, BkAny}() : omit
			new(uuid4(), name, format)
		end
	end

	type Ticker <: PlotObject
		uuid::UUID
		_type_name::String
		num_minor_ticks::Int64
		Ticker(name::String) = new(uuid4(), name, 5)
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
		ticker::TypeID
	end

	function Grid(dimension::Int, plot::Plot, ticker::Ticker)
		Grid(uuid4(), dimension, TypeID(plot), TypeID(ticker))
	end

	type Legend <: Renderer
		uuid::UUID
		plot::TypeID
		legends::Vector{Tuple}
		orientation::OmitSymbol
	end

	function Legend(plot::Plot, legends::Vector{Tuple})
		Legend(plot, legends, nothing)
	end

	function Legend(plot::Plot, legends::Vector{Tuple}, orientation::NullSymbol)
		orientation = orientation == nothing ? omit : orientation
		@assert orientation in (omit, :top_left, :top_center, :top_right, 
								:right_center, :bottom_right, :bottom_center, 
								:bottom_left, :left_center, :center)
		Legend(uuid4(),
			   TypeID(plot),
			   [(l, [TypeID(r)]) for (l, r) in legends],
			   orientation)
	end

	type Glyph <: PlotObject
		uuid::UUID
		_type_name::String
		line_color::OmitDict
		line_width::OmitDict
		line_alpha::OmitDict
		line_dash::Union(Omit, Vector{Int64})
		fill_color::OmitDict
		fill_alpha::OmitDict
		size::OmitDict
		x::Dict{String, String}
		y::Dict{String, String}
	end

	function Glyph(glyphtype::String,
				   linecolor::NullString, 
				   linewidth::NullInt, 
				   linealpha::NullFloat, 
				   dash::Union(Nothing, Vector{Int64}),
				   fillcolor::NullString,
				   fillalpha::NullFloat,
				   size::NullInt)
		linecolor = linecolor == nothing ? omit : @Compat.compat Dict{String, BkAny}("value" => linecolor)
		linewidth = linewidth == nothing ? omit : @Compat.compat Dict{String, BkAny}("units" => "data", "value" => linewidth)
		linealpha = linealpha == nothing ? omit : @Compat.compat Dict{String, BkAny}("units" => "data", "value" => linealpha)
		dash = dash == nothing ? omit : dash
		fillcolor = fillcolor == nothing ? omit : @Compat.compat Dict{String, BkAny}("value" => fillcolor)
		fillalpha = fillalpha == nothing ? omit : @Compat.compat Dict{String, BkAny}("units" => "data", "value" => fillalpha)
		size = size == nothing ? omit : @Compat.compat Dict{String, BkAny}("units" => "screen", "value" => size)
		x = @Compat.compat Dict("units" => "data", "field" => "x")
		y = @Compat.compat Dict("units" => "data", "field" => "y")
		Glyph(uuid4(), glyphtype, linecolor, linewidth, linealpha, dash, fillcolor, fillalpha, size, x, y)
	end

	function Glyph(;glyphtype=nothing,
				   linecolor=nothing, 
				   linewidth=nothing, 
				   linealpha=nothing, 
				   dash=nothing,
				   fillcolor=nothing, 
				   fillalpha=nothing,
				   size=nothing)
		glyphtype == nothing && error("glyphtype is required in Glyph definitions")
		Glyph(glyphtype, linecolor, linewidth, linealpha, dash, fillcolor, fillalpha, size)
	end

    function Base.show(io::IO, g::Glyph)
        names = Glyph.names
        features = String[]
        for name in Glyph.names
            showname = name == :_type_name ? :type : name
            g.(name) != nothing && push!(features, "$showname: $(g.(name))")
        end
        print(io, "Glyph(", join(features, ", "), ")")
    end

	type GlyphRenderer <: Renderer
		uuid::UUID
		data_source::TypeID
		nonselection_glyph::TypeID
		selection_glyph::TypeID
		glyph::TypeID
		name::Union(Nothing, String)
		server_data_source::NullDict
	end

	typealias NullGlyph Union(Nothing, Glyph)

	function GlyphRenderer(coldata::ColumnDataSource, nonsel_g::NullGlyph, sel_g::NullGlyph, glyph::Glyph)
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
		dimensions::Union(Vector{String}, Nothing, Omit)
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
		children::Vector{TypeID}
	end

	function PlotContext(plot::Plot)
		PlotContext(uuid4(),[TypeID(plot)])
	end
end
typealias RealVect Bokehjs.RealVect
typealias RealMat Bokehjs.RealMat
typealias RealMatVect Bokehjs.RealMatVect
typealias BkAny Bokehjs.BkAny

typealias Glyph Bokehjs.Glyph
typealias NullString Bokehjs.NullString
typealias NullSymbol Bokehjs.NullSymbol
typealias NullFloat Bokehjs.NullFloat
typealias NullInt Bokehjs.NullInt

function JSON._print(io::IO, state::JSON.State, uuid::Bokehjs.UUID)
    JSON._print(io, state, string(uuid))
end

function JSON._print(io::IO, state::JSON.State, tid::Bokehjs.TypeID)
    tid.plotob == nothing && (return JSON._print(io, state, nothing))
    attrs = typeof(tid.plotob).names
    obtype = in(:_type_name, attrs) ? tid.plotob._type_name : typeof(tid.plotob)
    d = @compat Dict{String, BkAny}(
        "type" => obtype,
        "id" => tid.plotob.uuid
    )
    JSON._print(io, state, d)
end

function JSON._print{T<:Bokehjs.PlotObject}(io::IO, state::JSON.State, d::Type{T})
    Base.print(io, "\"", d.name.name, "\"")
end