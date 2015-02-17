from __future__ import division

from bokeh.plotting import *
from bokeh.document import Document
from bokeh.protocol import serialize_json

x = range(6)
y = [xx**2 for xx in x]

output_file("line.html")
plot = figure(title="The Title",tools="save")  # , background_fill="#E8DDCB"
plot.line(x, y, color="red", line_width=2, legend="The Legend")  #  , line_dash = [8, 2], tools="pan"
plot.legend.orientation = "top_left"
show()

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
open('line.json', 'w').write(json)