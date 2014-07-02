# Bokeh

[![Build Status](https://travis-ci.org/samuelcolvin/Bokeh.jl.svg?branch=master)](https://travis-ci.org/samuelcolvin/Bokeh.jl)
[![Bokeh](http://pkg.julialang.org/badges/Bokeh_0.3.svg)](http://pkg.julialang.org/?pkg=Bokeh&ver=0.3)

Bokeh is a work in progress, but it's getting there, the examples below start to demonstrate its use.

It works with IJulia, an example can be found in [doc](doc).

Install with:
    
    Pkg.add("Bokeh")

Methods: 

	x = 1:10
	y = x.^2

	# 1:length(y) vs. y
	plot(y)

	# x vs. y
	plot(x, y)

	# cos evaluated in range -10:10-, 500 points
	plot(cos)

	# cos evaluated in range 0:5, 500 points
	plot(cos, 0, 5)

	# same
	plot(cos, 0:5)

	# as above with a red dashed line
	plot(y, "r--")

    x=linspace(0,2,5)
    ys = [sin(x) cos(x)]

    # x .vs ys[:,1] and x vs. ys[:,2]
    plot(x, ys)

    # x .vs ys[:,1] and x vs. ys[:,2] where x is 1:size(y,1)
    plot(ys)

	# as above with a red dashed line for ys[:,1] and a blue dotted line for ys[:,2]
	plot(ys, "r--|b:")

	y2 = map(xv -> xv^3 - 2xv^2 + 3xv, x)
	# x vs. y and x vs. y2 on the same plot, will require autoopen set to false
	autoopen(false)
	plot(x, y)
	hold()
	plot(x, y2)
	showplot()

	# ======================
	# not yet implemented:
	# ======================

	# grid of plots
	autoopen(false)

	p1 = plot(x, y)

	p2 = plot(x, y2)

	plot(p1, p2)
	showplot()
