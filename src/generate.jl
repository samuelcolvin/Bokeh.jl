include("objects.jl")
using JSON
using Mustache

function obdict(ob::PlotObject, doc::UUID)
	d = Dict{String, VALUE_TYPES}()
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

function genmodels(x::Array, y::Array)
	plot = Plot()
	doc = uuid4()

	pushdict!(obs::Any, ob::PlotObject, doc::UUID) = push!(obs, obdict(ob, doc))

	obs = Any[]

	column_names = String["x", "y"]
	data = Dict{String, Array{Number, 1}}()
	data["x"] = x
	data["y"] = y
	column = ColumnDataSource(column_names, data)
	pushdict!(obs, column, doc)

	ticker0 = BasicTicker()
	ticker1 = BasicTicker()
	pushdict!(obs, ticker0, doc)
	pushdict!(obs, ticker1, doc)

	tickform0 = BasicTickFormatter()
	tickform1 = BasicTickFormatter()
	pushdict!(obs, tickform0, doc)
	pushdict!(obs, tickform1, doc)

	axis0 = LinearAxis(0, tickform0, ticker0, plot)
	axis1 = LinearAxis(1, tickform1, ticker1, plot)
	pushdict!(obs, axis0, doc)
	pushdict!(obs, axis1, doc)

	dr1x = DataRange1d(column, String["x"])
	dr1y = DataRange1d(column, String["y"])
	pushdict!(obs, dr1x, doc)
	pushdict!(obs, dr1y, doc)

	grid0 = Grid(0, plot, axis0)
	grid1 = Grid(1, plot, axis1)
	pushdict!(obs, grid0, doc)
	pushdict!(obs, grid1, doc)

	pantool = Metatool("PanTool", plot, String["width", "height"])
	pushdict!(obs, pantool, doc)

	glyph = Glyph(column, dr1x, dr1y)
	pushdict!(obs, glyph, doc)

	renderers = PlotObject[
		glyph,
		axis0,
		axis1,
		grid0,
		grid1
	]
	tools = PlotObject[pantool]
	plot = Plot(plot,
				column,
				dr1x,
				dr1y,
				renderers,
				tools)
	pushdict!(obs, plot, doc)

	plotcontext = PlotContext(plot)
	pushdict!(obs, plotcontext, doc)

	indent = debug ? 2 : 0
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

function rendertemplate(models::String, plotcon::PlotContext, fname::String)
	template = gettemplate()
	jspath, csspath = bokehjs_paths(!debug)
	if debug
		open("bokeh_models.json", "w") do f
			print(f, allmodels)
		end
	end
	context = Dict{String, String}([
		"model_id" => string(plotcon.uuid),
		"all_models" => models,
		"div_id" => string(uuid4()),
		"js_path" => jspath,
		"css_path" => csspath
	])
	result = render(template, context)
	open(fname, "w") do f
		print(f, result)
	end
end





