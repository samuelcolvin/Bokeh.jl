Creating new bindings for Bokeh
===============================

[Bokeh](http://bokeh.pydata.org/) is a plotting library which allows you generate web based visualisations.

Unlike other JavaScript & HTML5 plotting libraries Bokehjs is designed to allow visualisations to be created from other languages. The primary bindings for Bokeh are written in Python however it should be possible to use Bokeh from any language.

As well as Python there are currently [Julia](https://github.com/samuelcolvin/Bokeh.jl) and [Scala](https://github.com/mattpap/bokeh-scala) bindings being developed. 

This document aims to document the process of creating Bokeh binding for other languages.

Bokeh python has the capability to do lots of clever things to start a server and detect interaction with plots from python. This document does not cover that more advanced functionality, instead it summarises the simplest way of generating a plot by creating a "static" HTML file.

## Overview

To create a simple Bokeh plot all you need to do is generate an HTML file. To view the plot, the user just has to open that HTML file with a modern browser.

That files contains:

* Some boilerplate HTML.
* Links to the `bokeh.js` and `bokeh.css` libraries, optionally you can insert these libraries verbatim to remove references to external files.
* **A large JSON object defining your plot.**
* A reference to the id of the object(s) you wish to display.

As you might imagine the great majority of the work in developing new bindings goes into generating the JSON to insert into the HTML file.

## Template

Below is a very simple HTML template for your plots.

    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <link rel="stylesheet" href="{{{ css_path }}}" type="text/css" />
            <script type="text/javascript" src="{{{ js_path }}}"></script>
            <script type="text/javascript">
                $(function() {
                    var modelid = "{{ model_id }}";
                    var modeltype = "PlotContext";
                    var elementid = "{{ div_id }}";
                    var all_models = {{{ all_models }}};
                    Bokeh.load_models(all_models);
                    var model = Bokeh.Collections(modeltype).get(modelid);
                    var view = new model.default_view({model: model, el: "#{{ div_id }}"});
                });
            </script>
        </head>
        <body>
            <div class="plotdiv" id="{{ div_id }}"></div>
        </body>
    </html>

(this template suitable for rendering with [Mustache](http://mustache.github.io/), but obviously you could modify it for other template renders.)

The following variables have to be defined:

* **css_path** either path to `bokeh.css` or `bokeh.min.css` on your local machine, or the URL of an external CDN, eg. `http://cdn.pydata.org/bokeh-0.4.4.css`. Alternatively you can include all the css in `<style>` tags.
* **js_path** either path to `bokeh.js` or `bokeh.min.js` on your local machine, or the URL of an external CDN, eg. `http://cdn.pydata.org/bokeh-0.4.4.js`. Alternatively you can include the entire library in `<script>` tags.
* **model_id** the ID of `PlotContext` in `all_models`, see UUIDs below for details on how ids are defined.
* **div_id** the id of the div where the plot will be place, generally also a UUID, but could be just a simple string.
* **all_models** a JSON object defining the plot, see below for details.

## UUIDs

Bokeh relies heavily on [UUIDs](http://en.wikipedia.org/wiki/Universally_unique_identifier) to identify different objects, in Python and Julia these are generated using standard UUID libraries, however as long as they are unique within a given context they can be strings of any sort.

## JSON Models

The JSON object defining your plot which is copied into the template in the `all_models` variable above is made up of an array of objects, the order of this array is not important.

Each object is a dictionary with three items:

* **id** the id (generally a UUID) of the object.
* **type** a string of the name of the type of the object, this corresponds to the titles in the object definitions below.
* **attributes** a dictionary containing further information about the object, all objects have the following fields in attributes:
  * **id** the same as `id` above
  * **doc** a UUID which is the same for all objects (TODO: what's the meaning/use of `doc`???)

Extra fields within `attributes` define the behaviour of that object.

The list below shows the the extra fields for each type of object.

### Required Objects

These objects are required for a plot to be viewable, an extremely simple example these objects in a plot is shown [here](simplest_bokeh_plot.html).

Bokehjs commonly uses a simple dict containing two items to reference another object of the form `{"id": "<UUID>", "type": "<name of object>"}`, in the below definitions these dicts are referred to as `id-type-dict`s.

#### ColumnDataSource

Holds actual data to be plotted.

Extra fields:

* `selected`: array, can be empty ???
* `cont_range`: dict, can be empty ???
* `column_names`: array of column names eg. `["x", "y"]`
* `data`: dict with keys as from `column_names` and arrays of data as values
* `discrete_ranges`: dict, can be empty ???

#### DataRange1d

What's the actual purpose of a `DataRange1d`? It doesn't actually contain (in it's simplest form) any extra information.

Extra fields:

* `sources`: an array containing one dict which contains:
  * `source`: an id-type-dict for `ColumnDataSource`
  * `columns`: array (in a simple case one element) of names of columns eg. `["x"]`.

#### Glyph

...

#### Plot

...

#### PlotContext

...

### More Objects

The objects above can be used to create a very simple plot, however it only using a tiny proportion of that Bokeh can do. Below Are a number of other objects which can be defined to enrich plots.

#### BasicTicker

...

#### BasicTickFormatter

...

#### PanTool

...

other tools ...