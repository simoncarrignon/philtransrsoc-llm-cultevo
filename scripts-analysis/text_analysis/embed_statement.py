#!/usr/bin/env python3
import argparse
import csv
import os
from pathlib import Path

STATEMENT_COL = "Statement"
ID_COL = "ID"
META_COLS = ["Mutation", "Selection", "Step", "Domain"]
MODEL = "text-embedding-3-small"


def parse_args():
    p = argparse.ArgumentParser(description="Compute embeddings for unique statements in a CSV (batched).")
    p.add_argument("input_csv", help="Path to input CSV")
    p.add_argument("--output", help="Output CSV path (default: embeddings/<input>_statement_embeddings.csv)")
    p.add_argument("--batch-size", type=int, default=200, help="How many statements per API call (default: 200)")
    return p.parse_args()


def read_unique_statements(path: Path):
    with path.open("r", newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        if not r.fieldnames:
            raise SystemExit(f"{path} has no header row.")
        if STATEMENT_COL not in r.fieldnames:
            raise SystemExit(f"Missing '{STATEMENT_COL}' column in {path}.")
        if ID_COL not in r.fieldnames:
            raise SystemExit(f"Missing '{ID_COL}' column in {path}.")

        meta_cols = [c for c in META_COLS if c in r.fieldnames]
        seen = set()
        records = []
        for row in r:
            stmt = (row.get(STATEMENT_COL) or "").strip()
            rid = (row.get(ID_COL) or "").strip()
            if not stmt or stmt in seen:
                continue
            seen.add(stmt)
            rec = {ID_COL: rid, STATEMENT_COL: stmt}
            rec.update({c: (row.get(c) or "").strip() for c in meta_cols})
            records.append(rec)

    return records


def batched(iterable, n: int):
    for i in range(0, len(iterable), n):
        yield iterable[i : i + n]


def fetch_embeddings_batched(statements, batch_size: int):
    if not os.environ.get("OPENAI_API_KEY"):
        raise SystemExit("Set OPENAI_API_KEY before running this script.")

    from openai import OpenAI

    client = OpenAI()
    out = {}

    for batch in batched(statements, batch_size):
        resp = client.embeddings.create(
            model=MODEL,
            input=batch,
            encoding_format="float",
        )
        # response order matches input order
        for text, item in zip(batch, resp.data):
            out[text] = item.embedding

    return out


def write_output(path: Path, records, embeddings_by_text):
    path.parent.mkdir(parents=True, exist_ok=True)

    first_stmt = records[0][STATEMENT_COL]
    dim = len(embeddings_by_text[first_stmt])
    meta_cols = [c for c in META_COLS if c in records[0]]
    fieldnames = [ID_COL] + meta_cols + [STATEMENT_COL] + [f"embedding_{i}" for i in range(dim)]

    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()

        for rec in records:
            stmt = rec[STATEMENT_COL]
            emb = embeddings_by_text[stmt]
            row = {ID_COL: rec[ID_COL], STATEMENT_COL: stmt}
            row.update({c: rec[c] for c in meta_cols})
            row.update({f"embedding_{i}": v for i, v in enumerate(emb)})
            w.writerow(row)


def main():
    args = parse_args()
    in_path = Path(args.input_csv)
    if not in_path.is_file():
        raise SystemExit(f"Input CSV not found: {in_path}")

    out_path = Path(args.output) if args.output else Path(
        f"embeddings/{in_path.stem}_statement_embeddings{in_path.suffix}"
    )

    records = read_unique_statements(in_path)
    if not records:
        raise SystemExit(f"No non-empty statements found in {in_path}.")

    statements = [r[STATEMENT_COL] for r in records]
    embeddings_by_text = fetch_embeddings_batched(statements, args.batch_size)
    write_output(out_path, records, embeddings_by_text)

    print(f"Wrote {out_path} with {len(records)} unique statement embeddings.")


if __name__ == "__main__":
    main()
