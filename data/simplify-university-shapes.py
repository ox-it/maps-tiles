import json
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


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Makes sure there is only one shape per type per coordinates in the produced GeoJSON feed')
    parser.add_argument('shapes', type=argparse.FileType('r'), help='File containing all shapes, expected to be reduced')
    parser.add_argument('output', type=argparse.FileType('w'), help='File to be written with only one shape per type per coordinates')
    parser.add_argument('--indent', dest='indent', action='store_true', default=False, help='Indent the JSON file to be written')
    parser.add_argument('--differentiate-types', dest='differentiate_types', action='store_true', default=False, help='Keep types distinction')
    ns = parser.parse_args()
    features = json.load(ns.shapes)
    print "{count} features in original file".format(count=len(features['features']))
    shapes = simplify(features, ns.differentiate_types)
    print "{count} features in new file".format(count=len(shapes))
    features = FeatureCollection(shapes.values())
    geojson_dump(features, ns.output, indent=ns.indent)


if __name__ == '__main__':
    main()
