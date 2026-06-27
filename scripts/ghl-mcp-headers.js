// Dynamic auth header for the GHL MCP server.
// Claude Code runs this fresh on every MCP connection (`headersHelper` in .mcp.json)
// and reads the JSON object we print to stdout as connection headers.
//
// Single source of truth: GHL_ADKINS_API_KEY in the repo-root .env.
// Rotate the token there and restart Claude Code — no other file to touch.
const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '..', '.env');
let token = '';
try {
  const m = fs.readFileSync(envPath, 'utf8').match(/^GHL_ADKINS_API_KEY=(.*)$/m);
  if (m) token = m[1].trim().replace(/^["']|["']$/g, '');
} catch (_) { /* fall through to env var */ }
if (!token) token = process.env.GHL_ADKINS_API_KEY || '';

process.stdout.write(JSON.stringify({ Authorization: `Bearer ${token}` }));
