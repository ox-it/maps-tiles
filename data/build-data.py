import rdflib
from geojson import load as geojson_load
from geojson import dump as geojson_dump
from geojson import Feature, FeatureCollection

def simplify(features, differentiate_types):
    """Simplify a GeoJSON feed to avoid exact forms duplication
    :param features: dict of a GeoJSON FeatureCollection
    :param differentiate_types: bool decide if we differentiate per type or not
    :return dict simplified shapes per coordinates and per type depending on differentiate_types
    """
    shapes = dict()
    for feature in features['features']:
        coord = feature['geometry']['coordinates']
        type_name = feature['properties']['type_name']
        if differentiate_types:
          key = '{coords}-{type}'.format(coords=str(coord),
                                          type=type_name)
        else:
          key = '{coords}'.format(coords=str(coord))
        shapes[key] = feature
    return shapes

def do_buildings():
  pass

def do_colleges():
  pass

def do_departments():
  pass


FUNCTIONS = {
  'buildings': do_buildings,
  'colleges': do_colleges,   # Site, College, Hall
  'departments': do_departments,  # Department, Library, Museum
}


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Produce GeoJSON feeds to be used by TileMill')
    parser.add_argument('oxpoints_file', type=argparse.FileType('r'), help='Main RDF dump expected in text/turtle format')
    parser.add_argument('oxpoints_shape', type=argparse.FileType('r'), help='Shapes RDF dump expected in text/turtle format')
    parser.add_argument('function', help='Function: either buildings, colleges or departments')
    parser.add_argument('--rdf-serialization', dest='rdf_serialization', action='store_true', default='text/turtle', help='RDF serialization, defaults to text/turtle')

    ns = parser.parse_args()

    print("==> Loading data into the graph")
    graph = rdflib.Graph()
    graph.parse(ns.oxpoints_file, format=ns.rdf_serialization)
    graph.parse(ns.oxpoints_shape, format=ns.rdf_serialization)
    print("==> Data loaded")


if __name__ == '__main__':
    main()
