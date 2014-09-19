download-oxpoints:
	@rm oxpoints.rdf
	@rm shapes.rdf
	@curl "https://data.ox.ac.uk/graph/oxpoints/data" -L -H "Accept: text/turtle" > oxpoints.rdf
	@curl "https://data.ox.ac.uk/graph/oxpoints-extents/data" -L -H "Accept: text/turtle" > shapes.rdf

prepare-geojson:
	@rm colleges-buildings.json
	@rm other-buildings.json
	@rm university-colleges-halls-sites.json
	@rm university-departments-museums-library.json
	@python build-data.py oxpoints.rdf shapes.rdf collegesbuildings > colleges-buildings.json
	@python build-data.py oxpoints.rdf shapes.rdf departments > university-departments-museums-library.json
	@python build-data.py oxpoints.rdf shapes.rdf colleges > university-colleges-halls-sites.json
	@python build-data.py oxpoints.rdf shapes.rdf otherbuildings > other-buildings.json
