#! /home/samuel/julia/julia
using JSON
using ArgParse

s = ArgParseSettings()
@add_arg_table s begin
    "jons_file"
        help = "json file path"
        required = true
    "--verbose", "-v"
        help = "verbose, boolean"
        arg_type = Bool
        default = false
end
parsed_args = parse_args(ARGS, s)
text = open(readall, parsed_args["jons_file"], "r")
verbase = parsed_args["verbose"]
js = JSON.parse(text)
sort!(js, by = ob -> ob["type"])
for ob in js
	print(ob["type"])
	if verbase
		println(":")
		k = keys(ob["attributes"])
		println("  attributes: ", join(k, ", "))
	else
		println()
	end
end