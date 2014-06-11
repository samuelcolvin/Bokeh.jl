module Bokeh
	include("objects.jl")
	using JSON
	using PrettyPrint


	function obdict(ob::PlotObject, doc::UUID)
		d = Dict{String, VALUE_TYPES}()
		d["id"] = string(ob.uuid)
		d["type"] = typeof(ob)
		attrs = Dict{String, Any}()
		attrs["id"] = d["id"]
		attrs["doc"] = string(doc)
		extra_attrs = typeof(ob).names
		for name in extra_attrs[2:end]
			attrs[string(name)] = ob.(name)
		end
		d["attributes"] = attrs
		d
	end

	function test()
		pid= uuid4()
		p = PlotContext(pid)
		doc = uuid4()
		d = obdict(p, doc)
		JSON.print(d, 2)
		axis = Axis(0, pid)
		axis = obdict(axis, doc)
		JSON.print(axis, 2)
		column_names = String["x", "y"]
		data = Dict{String, Array{Number, 1}}()
		data["x"] = [1, 2, 3, 4, 5]
		data["y"] = [1, 4, 9, 16, 25]
		column = ColumnDataSource(column_names, data)
		column = obdict(column, doc)
		JSON.print(column, 2)
	end
end
