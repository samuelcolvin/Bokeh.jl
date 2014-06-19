
function openhtml(filepath::String)
	os = Sys.OS_NAME 
	open = os == :Linux ? "xdg-open" :
		   os == :Darwin ? "open" :
		   error("Not Implemented: No idea how to open a browser in Windows but thanks for donating to the Gates foundation.")
	run(`$open $filepath`)
end