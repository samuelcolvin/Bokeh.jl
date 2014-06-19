
function openhtml(filepath::String)
	os = Sys.OS_NAME 
	open = os == :Linux ? "xdg-open" :
		   os == :Darwin ? "open" :
		   warn("Not Implemented: No idea how to open a browser in Windows but thanks for donating to the Gates foundation.")
	open == nothing && return
	run(`$open $filepath`)
end