import json
from geojson import load as geojson_load
from geojson import dump as geojson_dump
from geojson import Feature, FeatureCollection

def simplify(features):
    shapes = dict()
    for feature in features['features']:
        coord = feature['geometry']['coordinates']
        key = '{coords}'.format(coords=str(coord))
        shapes[key] = feature
    return shapes


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Makes sure there is only one shape per type per coordinates in the produced GeoJSON feed')
    parser.add_argument('shapes', type=argparse.FileType('r'), help='File containing all shapes, expected to be reduced')
    parser.add_argument('output', type=argparse.FileType('w'), help='File to be written with only one shape per type per coordinates')
    parser.add_argument('--indent', dest='indent', action='store_true', default=False, help='Indent the JSON file to be written')
    parser.add_argument('--verbose', dest='verbose', action='store_true', default=False, help='Provides some statistics on reduced shapes')
    ns = parser.parse_args()
    features = json.load(ns.shapes)
    if ns.verbose:
        print "{count} features in original file".format(count=len(features['features']))
    shapes = simplify(features)
    if ns.verbose:
        print "{count} features in new file".format(count=len(shapes))
    features = FeatureCollection(shapes.values())
    geojson_dump(features, ns.output, indent=ns.indent)

                                    
if __name__ == '__main__':
    main()
