using JSON
using Mustache

function obdict(ob::Bokehjs.PlotObject, doc::Bokehjs.UUID)
	d = Dict{String, Bokehjs.VALUE_TYPES}()
	d["id"] = string(ob.uuid)
	extra_attrs = typeof(ob).names
	d["type"] = in(:_type_name, extra_attrs) ? ob._type_name : typeof(ob)
	attrs = Dict{String, Any}()
	attrs["id"] = d["id"]
	attrs["doc"] = string(doc)
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

function genmodels(x::Real1d, y::Real1d, title::String, width::Int, height::Int)
	plot = Bokehjs.Plot()
	doc = Bokehjs.uuid4()

	obs = Any[]

	column_names = String["x", "y"]
	data = Dict{String, Real1d}([
		"x" => x,
		"y" => y])
	column = Bokehjs.ColumnDataSource(column_names, data)
	pushdict!(obs, column, doc)

	ticker0 = Bokehjs.BasicTicker()
	ticker1 = Bokehjs.BasicTicker()
	pushdict!(obs, ticker0, doc)
	pushdict!(obs, ticker1, doc)

	tickform0 = Bokehjs.BasicTickFormatter()
	tickform1 = Bokehjs.BasicTickFormatter()
	pushdict!(obs, tickform0, doc)
	pushdict!(obs, tickform1, doc)

	axis0 = Bokehjs.LinearAxis(0, tickform0, ticker0, plot)
	axis1 = Bokehjs.LinearAxis(1, tickform1, ticker1, plot)
	pushdict!(obs, axis0, doc)
	pushdict!(obs, axis1, doc)

	dr1x = Bokehjs.DataRange1d(column, String["x"])
	dr1y = Bokehjs.DataRange1d(column, String["y"])
	pushdict!(obs, dr1x, doc)
	pushdict!(obs, dr1y, doc)

	grid0 = Bokehjs.Grid(0, plot, axis0)
	grid1 = Bokehjs.Grid(1, plot, axis1)
	pushdict!(obs, grid0, doc)
	pushdict!(obs, grid1, doc)

	pantool = Bokehjs.Metatool("PanTool", plot, String["width", "height"])
	pushdict!(obs, pantool, doc)

	glyph = Bokehjs.Glyph(column, dr1x, dr1y)
	pushdict!(obs, glyph, doc)

	renderers = Bokehjs.PlotObject[
		glyph,
		axis0,
		axis1,
		grid0,
		grid1
	]
	tools = Bokehjs.PlotObject[pantool]
	plot = Bokehjs.Plot(plot,
				column,
				dr1x,
				dr1y,
				renderers,
				tools,
				title,
				height,
				width)
	pushdict!(obs, plot, doc)

	plotcontext = Bokehjs.PlotContext(plot)
	pushdict!(obs, plotcontext, doc)

	indent = DEBUG ? 2 : 0
	method_exists(json, (Dict, Int)) ? (json(obs, indent), plotcontext): 
									   (json(obs), plotcontext)
end

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
	open(fname, "w") do f
		print(f, result)
	end
end





