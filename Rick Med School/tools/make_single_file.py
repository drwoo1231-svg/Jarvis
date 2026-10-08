#!/usr/bin/env python3
"""
Builds the one-file version of the sketch:
  Rick_Med_School/*.pde  ->  Rick_Med_School_SingleFile/Rick_Med_School_SingleFile.pde

Processing itself glues tabs together (main tab first, then the others in
alphabetical order) before compiling, so the merged file behaves exactly like
the tabbed sketch. Imports are moved to the top.

Usage:  python3 tools/make_single_file.py
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "Rick_Med_School")
DST_DIR = os.path.join(HERE, "..", "Rick_Med_School_SingleFile")
DST = os.path.join(DST_DIR, "Rick_Med_School_SingleFile.pde")

tabs = sorted(f for f in os.listdir(SRC) if f.endswith(".pde"))
tabs.remove("Rick_Med_School.pde")
tabs.insert(0, "Rick_Med_School.pde")

imports, body = [], []
for t in tabs:
    with open(os.path.join(SRC, t), encoding="utf-8") as f:
        text = f.read()
    kept = []
    for line in text.split("\n"):
        if re.match(r"^\s*import\s+[\w.]+(\.\*)?\s*;\s*$", line):
            if line.strip() not in imports:
                imports.append(line.strip())
        else:
            kept.append(line)
    body.append("// " + "=" * 70 + "\n// TAB: " + t + "\n// " + "=" * 70 + "\n" + "\n".join(kept).strip() + "\n")

header = """// RICK MED SCHOOL - single-file edition (generated from the tabbed sketch by
// tools/make_single_file.py). Paste this whole file into an empty Processing
// 4.5.6 sketch (Java mode) and press Run. No libraries, no data folder.
"""
os.makedirs(DST_DIR, exist_ok=True)
with open(DST, "w", encoding="utf-8") as f:
    f.write(header + "\n" + "\n".join(imports) + "\n\n" + "\n\n".join(body))
print("wrote", os.path.relpath(DST, os.path.join(HERE, "..")), "-", sum(1 for _ in open(DST, encoding="utf-8")), "lines from", len(tabs), "tabs")
