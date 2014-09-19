download-oxpoints:
	@rm -f oxpoints.rdf
	@rm -f shapes.rdf
	@curl "https://data.ox.ac.uk/graph/oxpoints/data" -L -H "Accept: text/turtle" > oxpoints.rdf
	@curl "https://data.ox.ac.uk/graph/oxpoints-extents/data" -L -H "Accept: text/turtle" > shapes.rdf

prepare-geojson:
	@rm -f colleges-buildings.json
	@rm -f other-buildings.json
	@rm -f university-colleges-halls-sites.json
	@rm -f university-departments-museums-library.json
	@echo "Colleges buildings"
	@python build-data.py oxpoints.rdf shapes.rdf collegesbuildings > colleges-buildings.json
	@echo "Departments"
	@python build-data.py oxpoints.rdf shapes.rdf departments > university-departments-museums-library.json
	@echo "Colleges"
	@python build-data.py oxpoints.rdf shapes.rdf colleges > university-colleges-halls-sites.json
	@echo "Other buildings"
	@python build-data.py oxpoints.rdf shapes.rdf otherbuildings > other-buildings.json
