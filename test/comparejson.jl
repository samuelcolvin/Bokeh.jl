using JSON
using ArgParse

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
		println(" "^2(indent+1), "ob1: ", string(ob1))
		println(" "^2(indent+1), "ob2: ", string(ob2))
		println("####################################")
	end
	for i in 1:len
		compare(ob1[i], ob2[i], indent + 1)
	end
end

function compare(ob1::Dict, ob2::Dict, indent::Int)
	haskey(ob1, "type") && println(" "^2indent, "dict: ", ob1["type"])
	k1 = Set(keys(ob1))
	k2 = Set(keys(ob2))
	diff1 = collect(setdiff(k1, k2))
	if length(diff1) > 0 
		println("####################################")
		println(" "^2indent, "keys only in ob1: ", diff1)
		println("####################################")
	end
	diff2 = collect(setdiff(k2, k1))
	if length(diff2) > 0
		println("####################################")
		println(" "^2indent, "keys only in ob2: ", diff2)
		println("####################################")
	end
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
	println("####################################")
	println(" "^2indent, "difference, ob1: $ob1, ob2: $ob2")
	println("####################################")
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