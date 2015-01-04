import numpy as np

from bokeh.plotting import *

N = 100

x = np.linspace(0, 4*np.pi, N)
y = np.sin(x)

output_file("glyphs.html", title="glyphs.py example")

TOOLS = "pan,wheel_zoom,box_zoom,reset,save,box_select"

p2 = figure(title="Another Legend Example", tools=TOOLS)

p2.circle(x, y, legend="sin(x)")
p2.line(x, y, legend="sin(x)")

p2.line(x, 2*y, legend="2*sin(x)",
    line_dash=[4, 4], line_color="orange", line_width=2)

p2.square(x, 3*y, legend="3*sin(x)",
    fill_color=None, line_color="green")
p2.line(x, 3*y, legend="3*sin(x)",
    fill_color=None, line_color="green")
show(p2)

from bokeh.document import Document
from bokeh.protocol import serialize_json
doc = Document()
doc.add(p2)
json = serialize_json(doc.dump(), indent=2)
open('glyphs.json', 'w').write(json)