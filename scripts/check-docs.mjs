#!/usr/bin/env node
// Doc-graph + doc-hygiene validator for the ZiroWork repo.
// Called by scripts/verify.sh. Exit 0 = clean. Exit 1 = at least one problem.
//
// Checks (facts, not opinions):
//   LINKS    every markdown link + ROUTES TO: target resolves (tracked OR on-disk).
//   ORPHANS  every tracked *.md is reachable from CLAUDE.md by following links/routes.
//   HEADERS  every tracked *.md carries the FILE/WHAT/READ WHEN/SKIP WHEN/ROUTES TO/HARD RULES block.
//   ONE-NOW  exactly one tracked "current-stage" file, and it is CONTEXT.md.
//   WIP      at most meta.wip_limit feature_list.json items are in progress.
//
// Design notes:
//   - Each target is classified by asking GIT, not by hardcoding paths (so there is no
//     second copy of the ignore list to drift from .gitignore):
//       tracked (git ls-files)       → must resolve as tracked
//       ignored (git check-ignore)   → disk-check when present, skip (loud) when absent
//       neither tracked nor ignored  → FAIL: a genuine dangling / typo reference
//     New ignored zones (secrets/, vendors/, …) are handled automatically — no code change.
//   - Only markdown links `](path)` and ROUTES TO: targets are validated — NOT backtick
//     code-spans or prose filenames. This keeps append-only logs (MEMORY/DECISIONS) from
//     failing on historical mentions of since-moved files.

import { execSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';

const ARCHIVE = /(^|\/)_archive\//;
const ALLOWED_ORPHANS = new Set([
  // tracked *.md deliberately not reachable from CLAUDE.md (none today)
]);
const HEADER_KEYS = ['FILE:', 'WHAT:', 'READ WHEN:', 'SKIP WHEN:', 'ROUTES TO:', 'HARD RULES:'];
const NOW_RE = /(^|\/)(CONTEXT|PROGRESS|STATUS|NOW|progress)\.md$/;
const WIP_RE = /in[_\s-]?progress|active|wip|doing/i;

const tracked = new Set(
  execSync('git ls-files', { encoding: 'utf8' }).split(/\r?\n/).filter(Boolean),
);
const trackedMd = [...tracked].filter((f) => f.endsWith('.md') && !ARCHIVE.test(f));

const read = (f) => readFileSync(f, 'utf8');
const isPlaceholder = (t) => /[<>…*]/.test(t);
const isExternal = (t) => /^(https?:|mailto:|tel:|#)/.test(t);

// strip ./ prefix, surrounding punctuation, trailing #anchor
function normalize(t) {
  let s = t.trim().replace(/^\.\//, '').replace(/[#?].*$/, '');
  s = s.replace(/^[`("'<]+/, '').replace(/[`)"'>.,;:|]+$/, '');
  return s;
}

// A route token is only a path if it ends in a known extension. Requiring an
// extension (not just a "/") rejects prose like "MCP/API" or "scope/WIP".
function looksLikePath(t) {
  return /\.(md|mjs|cjs|js|ts|tsx|json|sh|py)$/.test(t);
}

// markdown links: [text](target)
function mdLinks(content) {
  return [...content.matchAll(/\]\(([^)]+)\)/g)].map((m) => normalize(m[1]));
}

// ROUTES TO: header line — split on separators, keep path-shaped tokens
function routeTargets(content) {
  const out = [];
  for (const line of content.split(/\r?\n/)) {
    // Only the header directive (ROUTES TO: at line start), never a mid-prose mention.
    const m = line.match(/^\s*ROUTES TO:\s*(.+)$/);
    if (!m) continue;
    for (const raw of m[1].split(/[\s|→,]+/)) {
      const t = normalize(raw);
      if (t && looksLikePath(t)) out.push(t);
    }
  }
  return out;
}

const fails = [];
const ok = (label) => console.log(`  ✓ ${label}`);
const bad = (label) => {
  console.log(`  ✗ ${label}`);
  fails.push(label);
};

// ---- LINKS ----------------------------------------------------------------
// Ask git which non-tracked targets are deliberately ignored (single source of truth).
function gitIgnored(paths) {
  if (!paths.length) return new Set();
  try {
    const out = execSync('git check-ignore --stdin', { input: paths.join('\n'), encoding: 'utf8' });
    return new Set(out.split(/\r?\n/).filter(Boolean));
  } catch (e) {
    // exit status 1 = nothing matched (not an error for us); stdout holds any matches
    return new Set(String(e.stdout || '').split(/\r?\n/).filter(Boolean));
  }
}

const candidates = [];
for (const f of trackedMd) {
  const content = read(f);
  for (const t of [...mdLinks(content), ...routeTargets(content)]) {
    if (!t || isExternal(t) || isPlaceholder(t)) continue;
    candidates.push({ f, t });
  }
}
const ignored = gitIgnored([...new Set(candidates.filter((c) => !tracked.has(c.t)).map((c) => c.t))]);

const dangling = [];
let ignoredOnDisk = 0;
let ignoredSkipped = 0;
for (const { f, t } of candidates) {
  if (tracked.has(t)) continue; // tracked → resolves
  if (ignored.has(t)) {
    // deliberately excluded (e.g. the sealed clients/ tree): verify on disk where we have it
    if (existsSync(t)) ignoredOnDisk++;
    else ignoredSkipped++; // excluded + absent (fresh clone) → can't verify
  } else {
    dangling.push(`${f} -> ${t} (neither tracked nor gitignored — dangling reference)`);
  }
}
if (dangling.length === 0) {
  ok(`LINKS: all links/routes resolve (${ignoredOnDisk} gitignored route(s) validated on disk)`);
  if (ignoredSkipped)
    console.log(`      ⚠ ${ignoredSkipped} gitignored route(s) UNVERIFIED — excluded path absent (e.g. fresh clone)`);
} else {
  bad(`LINKS: ${dangling.length} dangling pointer(s)`);
  dangling.forEach((d) => console.log(`      ${d}`));
}

// ---- ORPHANS --------------------------------------------------------------
const ROOT = 'CLAUDE.md';
const adjacency = new Map();
for (const f of trackedMd) {
  const content = read(f);
  const edges = [...mdLinks(content), ...routeTargets(content)]
    .map(normalize)
    .filter((t) => t.endsWith('.md') && trackedMd.includes(t));
  adjacency.set(f, edges);
}
const visited = new Set();
const queue = [ROOT];
while (queue.length) {
  const cur = queue.shift();
  if (visited.has(cur)) continue;
  visited.add(cur);
  for (const nxt of adjacency.get(cur) || []) if (!visited.has(nxt)) queue.push(nxt);
}
const orphans = trackedMd.filter((f) => !visited.has(f) && !ALLOWED_ORPHANS.has(f));
if (orphans.length === 0) ok(`ORPHANS: all ${trackedMd.length} tracked docs reachable from ${ROOT}`);
else {
  bad(`ORPHANS: ${orphans.length} doc(s) unreachable from ${ROOT}`);
  orphans.forEach((o) => console.log(`      ${o}`));
}

// ---- HEADERS --------------------------------------------------------------
const headerless = [];
for (const f of trackedMd) {
  const head = read(f).split(/\r?\n/).slice(0, 12).join('\n');
  const missing = HEADER_KEYS.filter((k) => !head.includes(k));
  if (missing.length) headerless.push(`${f} (missing: ${missing.join(', ')})`);
}
if (headerless.length === 0) ok('HEADERS: every tracked doc has the routing header block');
else {
  bad(`HEADERS: ${headerless.length} doc(s) missing header fields`);
  headerless.forEach((h) => console.log(`      ${h}`));
}

// ---- ONE-NOW --------------------------------------------------------------
const nowFiles = [...tracked].filter((f) => NOW_RE.test(f) && !ARCHIVE.test(f));
if (nowFiles.length === 1 && nowFiles[0] === 'CONTEXT.md') {
  ok('ONE-NOW: exactly one current-stage file (CONTEXT.md)');
} else {
  bad(`ONE-NOW: expected only CONTEXT.md, found [${nowFiles.join(', ') || 'none'}]`);
}

// ---- WIP ------------------------------------------------------------------
try {
  const fl = JSON.parse(read('feature_list.json'));
  const limit = fl?.meta?.wip_limit ?? 1;
  const inflight = [];
  for (const v of Object.values(fl)) {
    if (!Array.isArray(v)) continue;
    for (const item of v) if (item?.state && WIP_RE.test(item.state)) inflight.push(item.id || item.title);
  }
  if (inflight.length <= limit) ok(`WIP: ${inflight.length} item(s) in progress (limit ${limit})`);
  else bad(`WIP: ${inflight.length} items in progress > limit ${limit}: ${inflight.join(', ')}`);
} catch (e) {
  bad(`WIP: could not parse feature_list.json (${e.message})`);
}

// ---------------------------------------------------------------------------
process.exit(fails.length ? 1 : 0);
