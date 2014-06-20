from __future__ import division

from bokeh.plotting import *
from bokeh.objects import Range1d
from bokeh.document import Document
from bokeh.protocol import serialize_json

x = range(6)
y = [xx**2 for xx in x]

# output to static HTML file
output_file("line.html")

# Plot the Archimedean spiral using the `line` renderer. Note how we set the
# color, line thickness, title, and legend value.
plot = line(x, y, color="red", line_width=2, line_dash = [8, 2],
     title="line title", tools="pan")

show()

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
fn = 'line.json'
open(fn, 'w').write(json)