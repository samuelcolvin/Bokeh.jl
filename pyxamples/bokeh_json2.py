from __future__ import division

from bokeh.plotting import *
from bokeh.objects import Range1d
from bokeh.document import Document
from bokeh.protocol import serialize_json

x = range(6)
y = [xx**2 for xx in x]

# output to static HTML file
output_file("simple_line.html")

# Plot the Archimedean spiral using the `line` renderer. Note how we set the
# color, line thickness, title, and legend value.
plot = line(x, y, color="red", line_width=2,
     title="line title", tools="pan")

# EXERCISE: reproduce the above plot for one of the other spirals

# Let's try to put all lines on one plot for comparison. First we need to
# turn on `hold` so that each renderer does not create a brand new plot
hold()

# Next we need to actually create a new figure, so that the following
# renderers work on a new plot, and not the last one.
figure()

# EXERCISE: add all four spirals to one plot, each with different line colors
# and legend values. NOTE: title only set on the first renderer.

# OK, so that doesn't look so good because Bokeh tried to autoscale to
# accomodate all the data. We can use the Range1d object to set the plot range
# explicitly

# EXERCISE: create a new figure

# EXERCISE: add x_range and y_range parameters to the first `line`, to set the
# range to [-10, 10]. NOTE: Range1d are created like: Range1d(start=0, end-10)

show()      # show the plot

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
print json
fn = 'bokeh_example2.json'
open(fn, 'w').write(json)
print '\n================================'
print 'json written to %s' % fn