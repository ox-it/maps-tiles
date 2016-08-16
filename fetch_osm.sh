# copy the ogr.input plugin into the correct place
mv /srv/tilemill/maps-tiles/

mkdir /srv/tilemill
curl "http://download.geofabrik.de/europe/great-britain/england/oxfordshire-latest.osm.pbf" > /srv/tilemill/oxfordshire-latest.osm.pbf

imposm -m /srv/imposm-mapping.py -h localhost -d gis -U docker -p 5432 --read --write --optimize --deploy-production-tables --overwrite-cache /srv/tilemill/oxfordshire-latest.osm.pbf
