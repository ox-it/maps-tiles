Maps.ox data
============

All university data
-------------------

Get the data from OxPoints:

    curl "https://data.ox.ac.uk/graph/oxpoints/data" -L -H "Accept: text/turtle" > oxpoints.rdf

    curl "https://data.ox.ac.uk/graph/oxpoints-extents/data" -L -H "Accept: text/turtle" > shapes.rdf

Run the python script (see requirements.txt) to prepare the three different layers required, as follow:

    python build-data.py <oxpoints> <shapes> buildings|departments|colleges > your-output-file.json

Curated sites
-------------

Curated sites should as much as possible come from OxPoints data / the GeoJSON feed.

However, it is possible to create arbitrary shapes and/or points potentially using online tools such as http://geojson.io/.

One property is mandatory for each feature: `short_name`.

GeoJSON properties
------------------

Each feature should have the following properties:

* `type_name`
* `name`
* `short_name`
