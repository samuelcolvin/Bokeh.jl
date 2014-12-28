using JSON
using ArgParse

function _comparesets(s1, s2, name::String, indent::Int)
	diff1 = collect(setdiff(s1, s2))
	diff2 = collect(setdiff(s2, s1))
	if length(diff1) > 0 || length(diff2) > 0
		println("*******************************")
		if length(diff1) > 0 
			println(" "^2indent, "$name only in ob1: ", diff1)
		end
		if length(diff2) > 0
			println(" "^2indent, "$name only in ob2: ", diff2)
		end
		println("*******************************")
	end
end

function compare(ob1::Array, ob2::Array, indent::Int)
	if length(ob1) == length(ob2)
		len = length(ob1)
	else
		println("####################################")
		if length(ob1) > length(ob2)
			println(" "^2indent, "length ob1 > length ob2")
			len = length(ob2)
		else
			println(" "^2indent, " length ob1 < length ob2")
			len = length(ob1)
		end
		if indent > 0
			print(" "^2(indent+1), "ob1: ")
			println(ob1)
			print(" "^2(indent+1), "ob2: ")
			println(ob2)
		end
		try
			types1 = Set(map(e -> e["type"], ob1))
			types2 = Set(map(e -> e["type"], ob2))
			_comparesets(types1, types2, "types", indent + 1)
		catch e
			println("Error: $e")
		end
		println("####################################")
	end
	for i in 1:len
		ob2_id = i
		ob1_item = ob1[i]
		if (method_exists(getindex, (typeof(ob1_item), String)) && haskey(ob1_item, "type"))
			type_name = ob1_item["type"]
			ob2_id = findfirst(item -> item["type"] == type_name, ob2)
		end
		ob2_id = ob2_id == 0 ? i : ob2_id
		compare(ob1_item, ob2[ob2_id], indent + 1)
	end
end

function compare(ob1::Dict, ob2::Dict, indent::Int)
	if haskey(ob1, "type")
		indent < 2 && println(" "^2indent, "\n========================")
	 	println(" "^2indent, "dict: ", ob1["type"])
	 end
	k1 = Set(keys(ob1))
	k2 = Set(keys(ob2))
	_comparesets(k1, k2, "keys", indent + 1)
	for k in intersect(k1, k2)
		println(" "^2indent, k)
		compare(ob1[k], ob2[k], indent + 1)
	end
end

function inrange(r::Range, s::String)
	length(s) > minimum(r) && length(s) < maximum(r)
end
inrange(r::Range, s) = false

function compare(ob1, ob2, indent::Int)
	if ob1 == ob2
		return
	end
	# is a uuid
	if inrange(30:40, ob1) && inrange(30:40, ob2)
		return
	end
	println(" "^2indent, "difference, ob1: $ob1, ob2: $ob2")
	# println(" "^2indent, "difference, ob1: $(length(ob1)), ob2: $(length(ob2))")
end

s = ArgParseSettings()
@add_arg_table s begin
    "file1"
        help = "first file path"
        required = true
    "file2"
        help = "second file path"
        required = true
end
parsed_args = parse_args(ARGS, s)

text1 = open(readall, parsed_args["file1"], "r")
text2 = open(readall, parsed_args["file2"], "r")
js1 = JSON.parse(text1)
js2 = JSON.parse(text2)
compare(js1, js2, 0)