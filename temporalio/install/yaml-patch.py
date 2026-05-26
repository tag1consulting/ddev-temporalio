#!/usr/bin/env python3
import argparse, re
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedSeq

def get(doc, path, create=False):
    for key in path:
        if isinstance(doc, list):
            doc = doc[int(key)]
        else:
            if create and (doc is None or key not in doc):
                doc[key] = CommentedSeq()
            doc = doc[key]
    return doc

def parse_path(s):
    return [p for p in re.split(r'[\.\[\]]+', s) if p]

yaml = YAML()
yaml.preserve_quotes = True
yaml.indent(sequence=2, offset=2)

parser = argparse.ArgumentParser()
parser.add_argument("file")
parser.add_argument("--append",        nargs=2, metavar=("PATH", "VALUE"), action="append", default=[])
parser.add_argument("--append-unique", nargs=2, metavar=("PATH", "VALUE"), action="append", default=[])
parser.add_argument("--set",           nargs=2, metavar=("PATH", "VALUE"), action="append", default=[])
parser.add_argument("--flow",          nargs=1, metavar="PATH",            action="append", default=[])
parser.add_argument("--block",         nargs=1, metavar="PATH",            action="append", default=[])
args = parser.parse_args()

with open(args.file) as f:
    doc = yaml.load(f)

for path, value in args.append:
    seq = get(doc, parse_path(path), create=True)
    seq.append(value)

for path, value in args.append_unique:
    seq = get(doc, parse_path(path), create=True)
    if value not in seq:
        seq.append(value)

for path, value in args.set:
    parts = parse_path(path)
    parent = get(doc, parts[:-1])
    key = parts[-1]
    parent[int(key) if isinstance(parent, list) else key] = value

for (path,) in args.flow:
    node = get(doc, parse_path(path))
    node.fa.set_flow_style()

for (path,) in args.block:
    node = get(doc, parse_path(path))
    node.fa.set_block_style()

with open(args.file, "w") as f:
    yaml.dump(doc, f)
