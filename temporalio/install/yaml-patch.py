#!/usr/bin/env python3
import argparse, re, os, sys, tempfile
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedSeq, CommentedMap
from ruamel.yaml.scalarstring import SingleQuotedScalarString

def die(msg):
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)

def make_scalar(value):
    return SingleQuotedScalarString(value) if '$' in value else value

def get(doc, path, create=False):
    parent = None
    parent_key = None
    for key in path:
        if isinstance(doc, list):
            try:
                idx = int(key)
            except ValueError:
                die(f"expected integer index for list, got '{key}'")
            if idx >= len(doc) or idx < -len(doc):
                die(f"list index {idx} out of range (length {len(doc)})")
            parent, parent_key = doc, idx
            doc = doc[idx]
        else:
            if create:
                if doc is None:
                    parent[parent_key] = CommentedMap()
                    doc = parent[parent_key]
                if key not in doc:
                    doc[key] = CommentedSeq()
            elif doc is None or key not in doc:
                die(f"key '{key}' not found")
            parent, parent_key = doc, key
            doc = doc[key]
    return doc

def parse_path(s):
    parts = [p for p in re.split(r'[\.\[\]]+', s) if p]
    if not parts:
        die(f"invalid path: '{s}'")
    return parts

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

if not os.path.exists(args.file):
    die(f"file not found: {args.file}")

with open(args.file) as f:
    doc = yaml.load(f)

if doc is None:
    doc = CommentedMap()

for path, value in args.append:
    seq = get(doc, parse_path(path), create=True)
    if not isinstance(seq, list):
        die(f"'{path}' is not a sequence")
    seq.append(make_scalar(value))

for path, value in args.append_unique:
    seq = get(doc, parse_path(path), create=True)
    if not isinstance(seq, list):
        die(f"'{path}' is not a sequence")
    if value not in seq:
        seq.append(make_scalar(value))

for path, value in args.set:
    parts = parse_path(path)
    parent = get(doc, parts[:-1], create=True)
    key = parts[-1]
    parent[int(key) if isinstance(parent, list) else key] = make_scalar(value)

for (path,) in args.flow:
    node = get(doc, parse_path(path))
    if not hasattr(node, 'fa'):
        die(f"'{path}' is a scalar, cannot set flow style")
    node.fa.set_flow_style()

for (path,) in args.block:
    node = get(doc, parse_path(path))
    if not hasattr(node, 'fa'):
        die(f"'{path}' is a scalar, cannot set block style")
    node.fa.set_block_style()

dirpath = os.path.dirname(os.path.abspath(args.file))
with tempfile.NamedTemporaryFile("w", dir=dirpath, delete=False) as tmp:
    try:
        yaml.dump(doc, tmp)
        tmp_path = tmp.name
    except Exception as e:
        os.unlink(tmp.name)
        die(f"failed to serialize YAML: {e}")

os.replace(tmp_path, args.file)
