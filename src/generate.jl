include("bokehjs.jl")
include("glyphs.jl")
using Mustache

function Bokehjs.Glyph(glyph::Glyph,
					   coldata::Bokehjs.ColumnDataSource, 
					   xrange::Bokehjs.NullBkRange=nothing, 
					   yrange::Bokehjs.NullBkRange=nothing)
	glyphspec = Dict{String, BkAny}([
		"type" => glyph.gtype,
		"y" => ["units" => "data", "field" => "y"],
		"x" => ["units" => "data", "field" => "x"],
		])
	glyph.linewidth != nothing && (glyphspec["line_width"] = ["units" => "data", "value" => glyph.linewidth])

	glyph.linecolor != nothing && (glyphspec["line_color"] = ["value" => glyph.linecolor])
	glyph.fillcolor != nothing && (glyphspec["fill_color"] = ["value" => glyph.fillcolor])

	glyph.linealpha != nothing && (glyphspec["line_alpha"] = ["value" => glyph.linealpha])
	glyph.fillalpha != nothing && (glyphspec["fill_alpha"] = ["value" => glyph.fillalpha])

	glyph.size != nothing && (glyphspec["size"] = ["units" => "screen", "value" => glyph.size])

	glyph.dash != nothing && (glyphspec["line_dash"] = glyph.dash)
	
	Bokehjs.Glyph(coldata, xrange, yrange, glyphspec)
end

function genmodels(plot::Plot)
	bkplot = Bokehjs.Plot()
	doc = Bokehjs.uuid4()
	obs = Dict{String, BkAny}[]

	cdss = Bokehjs.ColumnDataSource[]
	bkglyphs = Bokehjs.PlotObject[]
	for datacolumn in plot.datacolumns
		cds = Bokehjs.ColumnDataSource(datacolumn.columns, datacolumn.data)
		pushdict!(obs, cds, doc)
		bg = Bokehjs.Glyph(datacolumn.glyph, cds)
		push!(cdss, cds)
		push!(bkglyphs, bg)
		pushdict!(obs, bg, doc)
	end
	dr1x = Bokehjs.DataRange1d(cdss, String["x"])
	dr1y = Bokehjs.DataRange1d(cdss, String["y"])
	pushdict!(obs, dr1x, doc)
	pushdict!(obs, dr1y, doc)

	ticker0 = Bokehjs.BasicTicker()
	ticker1 = Bokehjs.BasicTicker()
	pushdict!(obs, ticker0, doc)
	pushdict!(obs, ticker1, doc)

	tickform0 = Bokehjs.BasicTickFormatter()
	tickform1 = Bokehjs.BasicTickFormatter()
	pushdict!(obs, tickform0, doc)
	pushdict!(obs, tickform1, doc)

	axis0 = Bokehjs.LinearAxis(0, tickform0, ticker0, bkplot)
	axis1 = Bokehjs.LinearAxis(1, tickform1, ticker1, bkplot)
	pushdict!(obs, axis0, doc)
	pushdict!(obs, axis1, doc)
	grid0 = Bokehjs.Grid(0, bkplot, axis0)
	grid1 = Bokehjs.Grid(1, bkplot, axis1)
	pushdict!(obs, grid0, doc)
	pushdict!(obs, grid1, doc)

	pantool = Bokehjs.Metatool("PanTool", bkplot, String["width", "height"])
	pushdict!(obs, pantool, doc)

	renderers = Bokehjs.PlotObject[
		axis0,
		axis1,
		grid0,
		grid1
	]
	append!(renderers, bkglyphs)
	tools = Bokehjs.PlotObject[pantool]
	bkplot = Bokehjs.Plot(bkplot,
				dr1x,
				dr1y,
				renderers,
				tools,
				plot.title,
				plot.height,
				plot.width)
	pushdict!(obs, bkplot, doc)

	plotcontext = Bokehjs.PlotContext(bkplot)
	pushdict!(obs, plotcontext, doc)

	indent = DEBUG ? 2 : 0
	method_exists(json, (Dict, Int)) ? (json(obs, indent), plotcontext): 
									   (json(obs), plotcontext)
end

function obdict(ob::Bokehjs.PlotObject, doc::Bokehjs.UUID)
	d = Dict{String, BkAny}()
	d["id"] = ob.uuid
	extra_attrs = typeof(ob).names
	d["type"] = in(:_type_name, extra_attrs) ? ob._type_name : typeof(ob)
	attrs = Dict{String, Any}()
	attrs["id"] = d["id"]
	attrs["doc"] = doc
	special = [:_type_name]
	for name in extra_attrs[2:end]
		in(name, special) && continue
		key = string(name)
		# key = begingswith(key, "_") ? key[2:end] : key
		attrs[key] = ob.(name)
	end
	d["attributes"] = attrs
	return d
end

pushdict!(obs::Any, ob::Bokehjs.PlotObject, doc::Bokehjs.UUID) = push!(obs, obdict(ob, doc))

get_resources_dir() = Pkg.dir("Bokeh", "deps", "resources")

# DEFAULT_PATH = "_default _resources _directory"
function gettemplate(template::String="basic.html", path::Union(String, Nothing)=nothing)
	path = path == nothing ? get_resources_dir() : path
	fname = joinpath(path, template)
	open(readall, fname, "r")
end

function bokehjs_paths(minified::Bool=true)
	dir = Pkg.dir("Bokeh", "deps", "bokehjs")
	jspath = joinpath(dir, "js", minified ? "bokeh.min.js" : "bokeh.js")
	csspath = joinpath(dir, "css", minified ? "bokeh.min.css" : "bokeh.css")
	(jspath, csspath)
end

function rendertemplate(models::String, plotcon::Bokehjs.PlotContext, fname::String)
	template = gettemplate()
	jspath, csspath = bokehjs_paths(!DEBUG)
	if DEBUG
		open("bokeh_models.json", "w") do f
			print(f, models)
		end
	end
	context = Dict{String, String}([
		"model_id" => string(plotcon.uuid),
		"all_models" => models,
		"div_id" => string(Bokehjs.uuid4()),
		"js_path" => jspath,
		"css_path" => csspath
	])
	result = render(template, context)
	ispath(fname) && warn("$fname already exists, overwriting")
	open(fname, "w") do f
		print(f, result)
	end
end





