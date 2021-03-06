import sys

import rdflib
from rdflib import RDF
from rdflib.namespace import Namespace, DC
from geojson import load as geojson_load
from geojson import dumps as geojson_dumps
from geojson import Feature, FeatureCollection
from shapely.wkt import loads as wkt_loads
from shapely.geos import ReadingError
from shapely.geometry import Point

OxPoints = Namespace('http://ns.ox.ac.uk/namespace/oxpoints/2009/02/owl#')
Geometry = Namespace('http://data.ordnancesurvey.co.uk/ontology/geometry/')
Geo = Namespace('http://www.w3.org/2003/01/geo/wgs84_pos#')
Org = Namespace('http://www.w3.org/ns/org#')
SpatialRelations = Namespace('http://data.ordnancesurvey.co.uk/ontology/spatialrelations/')

DEFAULT_NAMESPACES = {'oxp': OxPoints, 'spatialrelations': SpatialRelations, 'org': Org}


def _get_feature(ident, name, type_name, geometry):
    """Prepare a GeoJSON feature
    :param ident: URI of the Thing
    :param name: feature name
    :param type_name: name of the type
    :param geometry: geometry (shapely)
    :return geojson.Feature
    """
    oxpoints_id = 'oxpoints:{ident}'.format(ident=ident.toPython().rsplit('/')[-1])
    return Feature(id=oxpoints_id, geometry=geometry,
                    properties={'name': name,
                                'type_name': type_name})

def _get_type(graph, subjects, type_name, ignore=None):
    """Get all things from a type from OxPoints, use shape or fallback on lat/lon
    :param graph: rdflib Graph
    :param subjects: subjects to process
    :param type_name: mapped (friendly) type name
    :param ignore: list of subjects to ignore
    :return list of features, list of URI processed
    """
    ignore = ignore or list()
    processed = list()
    features = list()
    for subject in subjects:
        if subject not in ignore:
            title = graph.value(subject, DC.title)
            short_name = graph.value(subject, OxPoints.shortLabel)
            map_label = graph.value(subject, OxPoints.mapLabel)
            if type_name == 'College':
                # Colleges should always use the main title, not short name
                name = title
            else:
                # name is the map label defined but fallbacks on short name or title
                name = map_label or short_name or title
            shape = graph.value(subject, Geometry.extent)
            if shape:
                wkt = graph.value(shape, Geometry.asWKT)
                if not wkt:
                    sys.stderr.write("!! No WKT for {place}\n".format(place=subject))
                else:
                    wkt = wkt.toPython()
                    try:
                        features.append(_get_feature(subject, name, type_name, wkt_loads(wkt)))
                    except ReadingError as e:
                        sys.stderr.write("!! Issue with WKT for {place}: {exc}\n".format(place=subject,
                                                                                         exc=e))
                    processed.append(subject)
            # fallback on latitude / longitude
            elif (subject, Geo.lat, None) in graph and (subject, Geo.long, None) in graph:
                lat = graph.value(subject, Geo.lat).toPython()
                lon = graph.value(subject, Geo.long).toPython()
                features.append(_get_feature(subject, name, type_name, Point(float(lon), float(lat))))
                processed.append(subject)
            # try to get info from the primary place of the thing
            else:
                primary_place = graph.value(subject, OxPoints.primaryPlace)
                if primary_place:
                    shape = graph.value(primary_place, Geometry.extent)
                    if shape:
                        wkt = graph.value(shape, Geometry.asWKT)
                        if not wkt:
                            sys.stderr.write("!! No WKT for {place}\n".format(place=primary_place))
                        else:
                            wkt = wkt.toPython()
                            try:
                                features.append(_get_feature(subject, name, type_name, wkt_loads(wkt)))
                            except ReadingError as e:
                                sys.stderr.write("!! Issue with WKT for {place}: {exc}\n".format(place=primary_place,
                                                                                                 exc=e))
                            processed.append(subject)
                            processed.append(primary_place)
                    elif (primary_place, Geo.lat, None) in graph and (primary_place, Geo.long, None) in graph:
                        lat = graph.value(primary_place, Geo.lat).toPython()
                        lon = graph.value(primary_place, Geo.long).toPython()
                        features.append(_get_feature(subject, name, type_name, Point(float(lon), float(lat))))
                        processed.append(subject)
                        processed.append(primary_place)
    return features, processed


def do_colleges_buildings(graph):
    """Get buildings contained by a College
    :param graph: RDFLib graph to process
    :return GeoJSON FeatureCollection
    """

    buildings = set()

    # buildings directly attached to College
    college_query = """SELECT DISTINCT ?building
    WHERE {
        ?building a oxp:Building .
        ?occupied org:hasSite ?building .
        ?occupied a oxp:College . }"""

    qres = graph.query(college_query, initNs=DEFAULT_NAMESPACES)
    buildings.update([row[0] for row in qres])

    # buildings attached to sites occupied by colleges
    site_query = """SELECT DISTINCT ?building
    WHERE {
        ?college a oxp:College .
        ?college org:hasSite ?site .
        ?site a oxp:Site .
        ?building a oxp:Building .
        ?building spatialrelations:within ?site . }"""

    qres = graph.query(site_query, initNs=DEFAULT_NAMESPACES)
    buildings.update([row[0] for row in qres])

    features, processed = _get_type(graph, buildings, 'Building')
    return FeatureCollection(features)


def do_other_buildings(graph):
    """Get buildings not contained by a college, or a college's site
    Meaning buildings occupied by something else than a College (e.g. Department),
    or not having a known occupier
    :param graph: RDFLib graph to process
    :return GeoJSON FeatureCollection
    """

    # 1) get all buildings
    # 2) filter buildings having a relation to a College or an Hall
    # 3) filter buildings having a relation to a Site related to a College or an Hall
    # see property paths documentation at http://www.w3.org/TR/sparql11-query/#propertypaths
    buildings_not_occupied_by_colleges = """SELECT ?building WHERE {
                                              ?building a oxp:Building .
                                              FILTER NOT EXISTS {
                                                ?building spatialrelations:within*/^org:hasSite/org:subOrganizationOf*/rdf:type ?type .
                                                FILTER (?type IN (oxp:Hall, oxp:College))
                                              } .
                                              FILTER NOT EXISTS {
                                                ?building org:hasSite|spatialrelations:within ?site .
                                                ?site a oxp:Site .
                                                ?site org:hasSite ?type .
                                                FILTER (?type IN (oxp:Hall, oxp:College))
                                              }
                                            }"""

    result_not_colleges = graph.query(buildings_not_occupied_by_colleges, initNs=DEFAULT_NAMESPACES)

    features, processed = _get_type(graph, [row[0] for row in result_not_colleges], 'Building')
    return FeatureCollection(features)


def do_colleges(graph):
    """Get colleges, halls and sites, but ignore sites of colleges and halls
    :param graph: RDFLib graph to process
    :return GeoJSON FeatureCollection
    """
    types = [
        (OxPoints.College, 'College'),
        (OxPoints.Hall, 'Hall'),
    ]
    features = list()
    to_ignore = list()
    for oxp_type, type_name in types:
        feats, processed = _get_type(graph, graph.subjects(RDF.type, oxp_type), type_name)
        features.extend(feats)
        to_ignore.extend(processed)
    feats, processed = _get_type(graph, graph.subjects(RDF.type, oxp_type), 'Site', ignore=to_ignore)
    features.extend(feats)
    return FeatureCollection(features)

def do_departments(graph):
    """Get Department, Faculty, Unit, Library and Museum
    Only get one shape per type (to avoid e.g. multiple departments
    occupying the same building)
    :param graph: RDFLib graph to process
    :return GeoJSON FeatureCollection
    """
    types = [
        (OxPoints.Department, 'Department'),
        (OxPoints.Faculty, 'Department'),
        (OxPoints.Unit, 'Department'),
        (OxPoints.Library, 'Library'),
        (OxPoints.Museum, 'Museum')
    ]
    features = list()
    for oxp_type, type_name in types:
        feats, processed = _get_type(graph, graph.subjects(RDF.type, oxp_type), type_name)
        features.extend(feats)

    # Make sure we have only one shape per coordinates and per type
    shapes = dict()
    for feature in features:
        coord = feature['geometry']['coordinates']
        type_name = feature['properties']['type_name']
        # Differentiate by type -- get only one shape per type
        key = '{coords}-{type}'.format(coords=str(coord),
                                          type=type_name)
        shapes[key] = feature

    return FeatureCollection(shapes.values())


FUNCTIONS = {
  'collegesbuildings': do_colleges_buildings,    # Colleges buildings
  'otherbuildings': do_other_buildings,     # all buildings except Colleges buildings
  'colleges': do_colleges,   # Site, College, Hall
  'departments': do_departments,  # Department, Library, Museum
}

DEFAULT_SERIALIZATION = 'text/turtle'


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Produce GeoJSON feeds to be used by TileMill')
    parser.add_argument('oxpoints_file', type=argparse.FileType('r'), help='Main RDF dump expected in {default_serialization} format'.format(default_serialization=DEFAULT_SERIALIZATION))
    parser.add_argument('oxpoints_shape', type=argparse.FileType('r'), help='Shapes RDF dump expected in text/turtle format')
    parser.add_argument('function', help="Function (should be one of '{available_functions}')".format(available_functions=', '.join(FUNCTIONS.iterkeys())))
    parser.add_argument('--rdf-serialization', dest='rdf_serialization', action='store_true', default=DEFAULT_SERIALIZATION, help='RDF serialization, defaults to text/turtle')

    ns = parser.parse_args()

    sys.stderr.write("==> Loading data into the graph\n")
    graph = rdflib.Graph()
    graph.parse(ns.oxpoints_file, format=ns.rdf_serialization)
    graph.parse(ns.oxpoints_shape, format=ns.rdf_serialization)
    sys.stderr.write("==> Data loaded\n")

    if ns.function not in FUNCTIONS:
        sys.exit("Incorrect function (should be one of '{available_functions}')".format(available_functions=', '.join(FUNCTIONS.iterkeys())))
    else:
        collection = FUNCTIONS[ns.function](graph)
        sys.stdout.write(geojson_dumps(collection))


if __name__ == '__main__':
    main()
