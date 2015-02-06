# Maps.ox data

## All university data

It is recommended to use the `Makefile` provided, and run the following commands:

    make download-oxpoints
    make prepare-geojson

## Curated sites

Curated sites should as much as possible come from OxPoints data / the GeoJSON feed and
be placed in the `curated_sites.json` file.

However, it is possible to create arbitrary shapes and/or points potentially using online tools such as http://geojson.io/.

One property is mandatory for each feature: `short_name`.

## GeoJSON properties

Each feature should have the following properties:

* `type_name`
* `name`
* `short_name`
