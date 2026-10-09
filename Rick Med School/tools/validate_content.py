#!/usr/bin/env python3
"""Validate a Rick Med School content batch file.  usage: validate.py <batch.json> [<batch2.json> ...]
Prints every problem; exit code 0 only when the file is fully valid."""
import json, sys, os, re
SPEC = json.load(open(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "content", "_spec.json")))
LIM = SPEC["limits"]
problems = []
def bad(where, msg): problems.append(f"{where}: {msg}")
def text(where, field, s, lim):
    if not isinstance(s, str): bad(where, f"{field} must be a string"); return
    if not s.strip(): bad(where, f"{field} is empty")
    if len(s) > lim: bad(where, f"{field} is {len(s)} chars (max {lim}): {s[:60]}...")
    if any(ord(ch) < 32 or ord(ch) > 126 for ch in s): bad(where, f"{field} has non-ASCII / control characters: {[ch for ch in s if ord(ch)<32 or ord(ch)>126][:5]}")
def check(path):
    try: d = json.load(open(path))
    except Exception as e: bad(path, f"not valid JSON: {e}"); return
    ids = set()
    owned = {dg for dg, t in SPEC["part_owner"].items()}
    topics_here = []
    for t in d.get("topics", []):
        tn = t.get("topic")
        if tn not in SPEC["topics"]: bad(path, f"unknown topic {tn!r}"); continue
        topics_here.append(tn)
        tspec = SPEC["topics"][tn]
        lv = {l.get("level"): l for l in t.get("levels", [])}
        if sorted(lv) != [1, 2, 3, 4]: bad(tn, f"levels must be exactly 1,2,3,4 (got {sorted(lv)})")
        for L in [1, 2, 3, 4]:
            if L not in lv: continue
            lev = lv[L]; w = f"{tn} L{L}"
            ls = lev.get("lessons", [])
            if len(ls) != SPEC["per_level"]["lessons"]: bad(w, f"needs {SPEC['per_level']['lessons']} lessons, has {len(ls)}")
            for i, le in enumerate(ls):
                lw = f"{w} lesson {le.get('id', i)}"
                lid = le.get("id")
                if not lid or not re.fullmatch(rf"{tn}-{L}-L\d+", lid): bad(lw, f"lesson id must look like {tn}-{L}-L1")
                if lid in ids: bad(lw, "duplicate id")
                ids.add(lid)
                text(lw, "title", le.get("title"), LIM["lesson.title"])
                text(lw, "fact", le.get("fact"), LIM["lesson.fact"])
                text(lw, "rick", le.get("rick"), LIM["lesson.rick"])
                dg, pt = le.get("diagram", ""), le.get("part", "")
                if dg or pt:
                    if dg not in tspec["diagrams"]: bad(lw, f"diagram {dg!r} not allowed for {tn} (use {tspec['diagrams']} or empty)")
                    elif pt not in SPEC["diagrams"][dg]: bad(lw, f"part {pt!r} is not in diagram {dg}")
            qs = lev.get("questions", [])
            mcq = [q for q in qs if q.get("type") == "mcq"]
            lab = [q for q in qs if q.get("type") == "label"]
            if len(mcq) != SPEC["per_level"]["mcq"]: bad(w, f"needs {SPEC['per_level']['mcq']} mcq, has {len(mcq)}")
            want = tspec["labels"][L - 1]
            if len(lab) != want: bad(w, f"needs {want} label questions, has {len(lab)}")
            if len(mcq) + len(lab) != len(qs): bad(w, "every question needs type 'mcq' or 'label'")
            seen_parts = set()
            for q in qs:
                qid = q.get("id"); qw = f"{w} {qid}"
                if not qid or not re.fullmatch(rf"{tn}-{L}-\d\d", qid): bad(qw, f"question id must look like {tn}-{L}-01")
                if qid in ids: bad(qw, "duplicate id")
                ids.add(qid)
                text(qw, "q", q.get("q"), LIM["question.q"])
                text(qw, "explain", q.get("explain"), LIM["question.explain"])
                text(qw, "rick", q.get("rick"), LIM["question.rick"])
                if q.get("type") == "mcq":
                    ch = q.get("choices")
                    if not isinstance(ch, list) or len(ch) != 4: bad(qw, "needs exactly 4 choices"); continue
                    for c in ch: text(qw, "choice", c, LIM["question.choice"])
                    if len(set(c.strip().lower() for c in ch)) != 4: bad(qw, "choices must be distinct")
                    if q.get("answer") not in (0, 1, 2, 3): bad(qw, "answer must be the index 0-3 of the correct choice")
                    if any(c.strip().lower() in ("all of the above", "none of the above", "both a and b") for c in ch): bad(qw, "no all/none-of-the-above style choices (choices get shuffled)")
                elif q.get("type") == "label":
                    dg, pt = q.get("diagram"), q.get("part")
                    if dg not in tspec["diagrams"]: bad(qw, f"diagram {dg!r} not allowed for {tn}")
                    elif pt not in SPEC["diagrams"][dg]: bad(qw, f"part {pt!r} is not in diagram {dg}")
                    if (dg, pt) in seen_parts: bad(qw, "same part asked twice in one level")
                    seen_parts.add((dg, pt))
    for p in d.get("parts", []):
        dg, pid = p.get("diagram"), p.get("id"); pw = f"part {dg}:{pid}"
        if dg not in SPEC["diagrams"] or pid not in SPEC["diagrams"].get(dg, []): bad(pw, "unknown diagram/part"); continue
        if SPEC["part_owner"][dg] not in topics_here: bad(pw, f"diagram {dg} belongs to topic {SPEC['part_owner'][dg]}, not this batch")
        text(pw, "name", p.get("name"), LIM["part.name"])
        text(pw, "desc", p.get("desc"), LIM["part.desc"])
        text(pw, "rick", p.get("rick"), LIM["part.rick"])
    have = {(p.get("diagram"), p.get("id")) for p in d.get("parts", [])}
    for dg, owner in SPEC["part_owner"].items():
        if owner in topics_here:
            for pid in SPEC["diagrams"][dg]:
                if (dg, pid) not in have: bad(path, f"missing part description for {dg}:{pid}")
    if len(have) != len(d.get("parts", [])): bad(path, "duplicate part descriptions")
for f in sys.argv[1:]: check(f)
if problems:
    print(f"{len(problems)} PROBLEM(S):"); [print(" -", p) for p in problems[:200]]
    sys.exit(1)
print("VALID")
