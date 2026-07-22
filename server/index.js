/**
 * JARVIS — zero-dependency Node backend.
 *
 * Responsibilities:
 *   1. Serve the PWA in /public.
 *   2. Proxy chat requests to the Anthropic (Claude) API so the API key is
 *      never exposed to the browser.
 *
 * Run with:  node server/index.js
 * Requires Node 18+ (uses the built-in global fetch). Node 20+ recommended.
 */

'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const PUBLIC_DIR = path.join(ROOT, 'public');
const PROMPT_FILE = path.join(ROOT, 'prompts', 'jarvis-system-prompt.md');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';
const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY || '';
const MODEL = process.env.JARVIS_MODEL || 'claude-sonnet-5';
const ANTHROPIC_VERSION = '2023-06-01';
const MAX_TOKENS = Number(process.env.JARVIS_MAX_TOKENS || 1024);

const BASE_PROMPT = (() => {
  try {
    return fs.readFileSync(PROMPT_FILE, 'utf8');
  } catch {
    return 'You are JARVIS, a refined and highly intelligent AI assistant.';
  }
})();

/* ------------------------------------------------------------------ *
 * The "device action" protocol.
 *
 * JARVIS can control the user's device by embedding one or more action
 * directives in its reply using <action>{...json...}</action> tags. The
 * browser strips these tags before displaying/speaking, then executes them
 * (open an app, play a song, place a call, etc). This is appended to the
 * base persona prompt at request time, along with the user's chosen name.
 * ------------------------------------------------------------------ */
function buildActionProtocol(userName, honorific) {
  const addressLine = honorific && honorific !== 'none'
    ? `Address the user as "${honorific}"${userName ? ` or by name ("${userName}")` : ''}. Use it sparingly and naturally, not in every sentence.`
    : userName
      ? `The user's name is "${userName}". Address them by name occasionally and naturally.`
      : `You do not yet know the user's name; you may ask for it.`;

  return `
# The User

${addressLine}

# Voice Output

Your replies are spoken aloud with a British butler's voice as well as shown on
screen. Therefore:

- Write in clean, natural prose. Do NOT use markdown, asterisks, bullet
  characters, headings, or emojis in your reply — they are read aloud literally
  and sound wrong.
- Keep everyday replies brief and conversational (one to three sentences).
  Expand only when the user genuinely needs depth.
- Spell things out the way a person would say them.

# Device Control

You are running inside an app on the user's phone (and computer). You can act on
the device by emitting one or more action directives anywhere in your reply,
each on its own line, in this exact format:

<action>{"type":"ACTION_TYPE", ...fields}</action>

The app removes these tags before showing or speaking your reply, then performs
the action. Always ALSO include a short, natural spoken confirmation in the same
reply (e.g. "Right away. Putting that on for you now.").

Available actions:

- Play a song or video:
  <action>{"type":"play_music","query":"song and artist","service":"youtube"}</action>
  (service may be "youtube", "spotify", or "apple"; default to "youtube".)

- Open an app by name (youtube, spotify, maps, whatsapp, instagram, twitter,
  x, tiktok, facebook, gmail, phone, messages, camera, netflix, chrome, etc.):
  <action>{"type":"open_app","app":"spotify"}</action>

- Search the web:
  <action>{"type":"search_web","query":"tallest mountains in Europe"}</action>

- Open a specific website:
  <action>{"type":"open_url","url":"https://example.com"}</action>

- Get directions / navigate:
  <action>{"type":"navigate","destination":"Central Park, New York"}</action>

- Start a phone call:
  <action>{"type":"call","number":"+15551234567"}</action>

- Compose a text message:
  <action>{"type":"text","number":"+15551234567","message":"On my way."}</action>

- Compose an email:
  <action>{"type":"email","to":"someone@example.com","subject":"Hi","body":"..."}</action>

- Set an in-app countdown timer:
  <action>{"type":"timer","seconds":300,"label":"tea"}</action>

Rules for actions:

- Only emit an action when the user actually asks you to do something on the
  device. For ordinary conversation, questions, or advice, do NOT emit any
  action — just talk.
- If you lack a detail you truly need (like which song), ask a brief clarifying
  question instead of guessing wildly. Reasonable assumptions are fine.
- Never invent phone numbers or email addresses. If the user hasn't provided
  one, ask for it.
- You may emit more than one action if a request requires it.
`;
}

function buildSystemPrompt(userName, honorific) {
  return `${BASE_PROMPT}\n${buildActionProtocol(userName, honorific)}`;
}

/* ------------------------------------------------------------------ *
 * Static file serving
 * ------------------------------------------------------------------ */
const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.webmanifest': 'application/manifest+json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8',
};

function safeJoin(base, target) {
  const targetPath = path.normalize(path.join(base, target));
  if (!targetPath.startsWith(base)) return null; // path traversal guard
  return targetPath;
}

function serveStatic(req, res) {
  let urlPath = decodeURIComponent((req.url.split('?')[0] || '/'));
  if (urlPath === '/') urlPath = '/index.html';

  let filePath = safeJoin(PUBLIC_DIR, urlPath);
  if (!filePath) {
    res.writeHead(403).end('Forbidden');
    return;
  }

  fs.stat(filePath, (err, stat) => {
    if (err || !stat.isFile()) {
      // SPA-ish fallback to index.html for unknown non-asset routes
      if (!path.extname(filePath)) {
        filePath = path.join(PUBLIC_DIR, 'index.html');
      } else {
        res.writeHead(404).end('Not found');
        return;
      }
    }
    const ext = path.extname(filePath).toLowerCase();
    const type = MIME[ext] || 'application/octet-stream';
    const headers = { 'Content-Type': type };
    // Never cache the service worker or html shell; cache other assets briefly.
    if (ext === '.html' || filePath.endsWith('service-worker.js')) {
      headers['Cache-Control'] = 'no-cache';
    } else {
      headers['Cache-Control'] = 'public, max-age=3600';
    }
    res.writeHead(200, headers);
    fs.createReadStream(filePath).pipe(res);
  });
}

/* ------------------------------------------------------------------ *
 * /api/chat  — proxy to Anthropic
 * ------------------------------------------------------------------ */
function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    let tooBig = false;
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 1_000_000) {
        tooBig = true;
        req.destroy();
      }
    });
    req.on('end', () => (tooBig ? reject(new Error('payload too large')) : resolve(data)));
    req.on('error', reject);
  });
}

function sendJson(res, status, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
  });
  res.end(body);
}

async function handleChat(req, res) {
  if (req.method !== 'POST') {
    sendJson(res, 405, { error: 'method_not_allowed' });
    return;
  }

  if (!ANTHROPIC_API_KEY) {
    sendJson(res, 503, {
      error: 'no_key',
      message:
        'The server has no ANTHROPIC_API_KEY configured. Set it in the ' +
        'environment, or switch JARVIS to Direct mode in Settings and supply ' +
        'your own key.',
    });
    return;
  }

  let payload;
  try {
    payload = JSON.parse(await readBody(req));
  } catch {
    sendJson(res, 400, { error: 'bad_request', message: 'Invalid JSON body.' });
    return;
  }

  const messages = Array.isArray(payload.messages) ? payload.messages : [];
  const userName = String(payload.userName || '').slice(0, 60);
  const honorific = String(payload.honorific || '').slice(0, 20);
  const model = String(payload.model || MODEL);

  if (messages.length === 0) {
    sendJson(res, 400, { error: 'bad_request', message: 'No messages provided.' });
    return;
  }

  try {
    const apiRes = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': ANTHROPIC_VERSION,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model,
        max_tokens: MAX_TOKENS,
        system: buildSystemPrompt(userName, honorific),
        messages,
      }),
    });

    const raw = await apiRes.text();
    if (!apiRes.ok) {
      let detail = raw;
      try { detail = JSON.parse(raw); } catch { /* keep raw */ }
      sendJson(res, apiRes.status, { error: 'api_error', detail });
      return;
    }

    const data = JSON.parse(raw);
    const text = (data.content || [])
      .filter((b) => b.type === 'text')
      .map((b) => b.text)
      .join('\n')
      .trim();

    sendJson(res, 200, { text, model: data.model || model });
  } catch (err) {
    sendJson(res, 502, { error: 'upstream_error', message: String(err && err.message || err) });
  }
}

/* ------------------------------------------------------------------ *
 * Server
 * ------------------------------------------------------------------ */
const server = http.createServer((req, res) => {
  const url = req.url.split('?')[0];

  if (url === '/api/health') {
    sendJson(res, 200, {
      ok: true,
      model: MODEL,
      keyConfigured: Boolean(ANTHROPIC_API_KEY),
    });
    return;
  }

  if (url === '/api/config') {
    // Non-secret config the client may want to know about.
    sendJson(res, 200, { model: MODEL, keyConfigured: Boolean(ANTHROPIC_API_KEY) });
    return;
  }

  if (url === '/api/chat') {
    handleChat(req, res).catch((err) => {
      sendJson(res, 500, { error: 'internal', message: String(err && err.message || err) });
    });
    return;
  }

  serveStatic(req, res);
});

server.listen(PORT, HOST, () => {
  const keyMsg = ANTHROPIC_API_KEY
    ? 'API key detected — server chat mode is ready.'
    : 'No ANTHROPIC_API_KEY set — use Direct mode in Settings, or export the key.';
  /* eslint-disable no-console */
  console.log(`\n  JARVIS is online.`);
  console.log(`  Local:    http://localhost:${PORT}`);
  console.log(`  Network:  http://<your-computer-ip>:${PORT}  (open this on your phone)`);
  console.log(`  Model:    ${MODEL}`);
  console.log(`  ${keyMsg}\n`);
});
