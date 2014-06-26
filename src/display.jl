function openhtmldoc(filepath::String)
	os = Sys.OS_NAME 
	open = os == :Linux ? "xdg-open" :
		   os == :Darwin ? "open" :
		   warn("Not Implemented: No idea how to open a browser in Windows, perhaps you could work it out and submit a pull request?")
	open == nothing && return
	run(`$open $filepath`)
end

_basic(p::Plot) = "Plot(\"$(p.title)\" with $(length(p.datacolumns)) datacolumns)"

function Base.writemime(io::IO, ::MIME"text/html", p::Plot)
    print(io, renderplot(p, true))
    print(io, "<p>", _basic(p), "</p>")
end

function Base.writemime(io::IO, ::MIME"text/plain", p::Plot)
    print(io, _basic(p))
end

if !isdefined(Main, :IJulia)
	type BokehDisplay <: Display
	end    

	function Base.display(d::BokehDisplay, p::Plot)
		display("text/plain", p)
	    html = renderplot(p, false)
		if ispath(p.filename) 
			println()
			warn("$(p.filename) already exists, overwriting")
		end
		open(p.filename, "w") do f
			print(f, html)
		end
	    openhtmldoc(p.filename)
    end
    pushdisplay(BokehDisplay())
end

function setupnotebook()
	jspath, csspath = _bokehjs_paths(!DEBUG)
	jscss = _render_jscss(jspath, csspath, true)
	display("text/html", jscss)
	display("text/html", "<p>BokehJS successfully loaded.</p>")
end