from numpy import cumprod, linspace, random

from bokeh.plotting import *
from bokeh.protocol import serialize_json

num_points = 10

now = time.time()
dt = 24*3600 # days in seconds
dates = linspace(now, now + num_points*dt, num_points) * 1000 # times in ms
acme = cumprod(random.lognormal(0.0, 0.04, size=num_points))

output_file('dates.html')

plot = figure(x_axis_type='datetime')

plot.line(dates, acme, color='#1F78B4', legend='ACME')

show(plot)  # open a browser

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
fn = 'dates.json'
open(fn, 'w').write(json)