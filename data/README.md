Maps.ox data
============

All university data
-------------------

We are getting a GeoJSON feed from Mobile Oxford, the URL is as follow:

    http://127.0.0.1:5000/places/search.geojson?type_exact=/university/college&type_exact=/university/hall&type_exact=/university/department&type_exact=/university/building&type_exact=/university/library&type_exact=/university/site&type_exact=/leisure/museum&count=5000

Buildings:

    http://127.0.0.1:5000/places/search.geojson?type_exact=/university/building&count=5000

Departments, museums and libraries (to be simplified by types):

    http://127.0.0.1:5000/places/search.geojson?type_exact=/university/department&type_exact=/university/library&type_exact=/leisure/museum&count=5000

Sites, colleges and halls:

    http://127.0.0.1:5000/places/search.geojson?type_exact=/university/college&type_exact=/university/hall&type_exact=/university/site&count=5000

Curated sites
-------------

Curated sites should as much as possible come from OxPoints data / the GeoJSON feed.

However, it is possible to create arbitrary shapes and/or points potentially using online tools such as http://geojson.io/.

One property is mandatory for each feature: `short_name`.

GeoJSON properties
------------------

Each feature should have the following properties:

* `type`
* `type_name`
* `name`
* `short_name`

University shapes
-----------------

The script situated in `data/simplify-university-shapes.py` should be executed against the main GeoJSON feed to reduce all shapes to a set of "unique" shapes per type to be used to produce the actual shapes in the tiles.
