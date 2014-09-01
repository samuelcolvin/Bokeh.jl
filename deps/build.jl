
function getfile(fname)
	url = "http://cdn.pydata.org/" * fname
	path = Pkg.dir("Bokeh", "deps", "bokehjs", nfame)
	println("downloading from $url to $path")
	download(url, path)
end

bokehjs = "bokeh-0.5.2"
getfile("$bokehjs.js")
getfile("$bokehjs.min.js")
getfile("$bokehjs.css")
getfile("$bokehjs.min.css")