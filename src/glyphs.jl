module Glyphs
    typealias NullString Union(String, Nothing)
    typealias NullFloat Union(Float64, Nothing)
    typealias NullInt Union(Int, Nothing)

    type Glyph
        gtype::String
        linewidth::NullInt
        linecolor::NullString
        fillcolor::NullString
        linealpha::NullFloat
        fillalpha::NullFloat
        size::NullInt
        dash::Union(Nothing, Array{Int, 1})
    end

    function Glyph(gtype::String; 
    	linewidth=nothing, linecolor=nothing, fillcolor=nothing, linealpha=nothing, fillalpha=nothing, size=nothing, dash=nothing)
    	Glyph(gtype, linewidth, linecolor, fillcolor, linealpha, fillalpha, size, dash)
    end

    function Circle(;linewidth=1, linecolor="blue", fillcolor="blue", linealpha=1, fillalpha=0.5, size=4)
        Glyph("circle",linewidth, linecolor, fillcolor, linealpha, fillalpha, size)
    end
end

typealias Glyph Glyphs.Glyph

typealias NullRange Union(Range, Nothing)

type DataColumn
    columns::Array{String, 1}
    data::Dict{String, Real1d}
    glyph::Glyph
    xrange::NullRange
    yrange::NullRange
end

function DataColumn(xdata::Real1d, ydata::Real1d, glyph::Glyph)
	data = ["x" => xdata, "y" => ydata]
	DataColumn(["x", "y"], data, glyph, nothing, nothing)
end

type Plot
    datacolumns::Array{DataColumn, 1}
    filename::String
    title::String
    width::Int
    height::Int
end