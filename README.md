<div align="center">

# J.A.R.V.I.S

**Just A Rather Very Intelligent System**

A personal AI assistant with a British butler's voice, a futuristic HUD, and
the ability to act on your phone — open apps, put on a song, place a call,
navigate, run searches — all through natural conversation.

Built as an installable **Progressive Web App (PWA)**: mobile-first, but the
same code runs beautifully on your computer too. No app store required.

</div>

---

## What it does

- 🛰️ **Analysis mode.** Tap the 🔍, name a subject, and JARVIS pulls up a
  visual and a briefing (via Wikipedia — live web data, no key), asks *"Is this
  what you're looking for?"*, analyses it, then offers to file it in your
  **Private Research Files** (stored locally on your device). You can also
  hand it an **image** (tap the picture button, or drag-drop on desktop) and,
  with a vision-capable provider, JARVIS describes it.
- 🔬 **Identify.** Say *"identify this"* (or *"what is this?"*) and drop in a
  picture. JARVIS runs an **on-device X-ray scan** — a keyless neural net
  (MobileNet, 1,000 classes) that runs entirely in your browser — and breaks
  down **the probability of what it is**: *"It seems your image is a carrot —
  87% confidence,"* with a probability bar-chart and a reference photo pulled
  up beside the core. If it can't be sure, JARVIS drops into **focus mode** and
  searches it on Google for you.
- 🌌 **Iron-Man ops-console HUD.** A rotating particle-globe core, live
  telemetry readouts (clock, mode, model, signal), a radar sweep and a
  waveform that reacts to your voice.
- 🖥️ **PC / Desktop mode.** Pick Mobile or Desktop on the start screen. Desktop
  gives a wider ops console with a much larger sphere — and a **holographic
  scanner**: say *"initiate analysis mode"* and drag a file onto the holo-panel
  for JARVIS to scan.


- 🎩 **The classic butler.** Calm, precise, dryly witty — powered by Claude and
  the JARVIS persona. Have a full conversation about anything: code, science,
  writing, advice, brainstorming, trivia.
- 📱 **Controls your phone.** Ask it to _"put on Bohemian Rhapsody"_, _"open
  Spotify"_, _"navigate to the office"_, _"call Mum"_, _"text Alex I'm on my
  way"_, _"search for the tallest mountains in Europe"_, or _"set a 10 minute
  timer"_. It opens the right app / deep link.
- 🗣️ **Voice in and out.** Speak to it; it replies aloud in a British voice.
  Tap-to-talk or go fully hands-free.
- 🌌 **Future-tech HUD.** An animated arc-reactor core that pulses with your
  voice, HUD brackets, and a glassy interface.
- 🙋 **It calls you what you like.** Pick your name and how JARVIS addresses you
  (Sir, Ma'am, Boss, your name, or nothing).
- 💻 **Works on desktop too.** Same URL, responsive layout.

---

## Quick start (on your computer, 60 seconds)

You need [Node.js](https://nodejs.org/) 18+ (20+ recommended). No `npm install`
needed — the server has **zero dependencies**.

```bash
# 1. Get an Anthropic API key from https://console.anthropic.com/
export ANTHROPIC_API_KEY=sk-ant-...

# 2. Start JARVIS
npm start        # (or: node server/index.js)

# 3. Open http://localhost:3000
```

On first launch it asks your name and preferred form of address, then you're in.
Type in the dock, or tap the mic to speak.

> No key yet? It still runs in **Demo mode** — the interface is fully alive and
> device actions (open apps, play music, search) still work; only the free-form
> conversation is limited until you add a key.

---

## 📲 Getting JARVIS onto your phone

There are three ways, depending on how much you want to set up. **Voice input on
a phone requires HTTPS** (a browser security rule), so pick accordingly.

### Option A — Host it (recommended, best for phones)

Deploy the `public/` folder to any static host — **GitHub Pages, Netlify, Vercel,
Cloudflare Pages** — and use **Direct mode**:

1. Put the contents of `public/` online (drag-and-drop to Netlify is easiest).
2. Open the site on your phone.
3. Tap the ⚙️ settings, set **Connection mode → Direct**, paste your Anthropic
   API key (it's stored only in your phone's browser), Save.
4. Add to Home Screen (see below).

No server to run, HTTPS is automatic, and voice works. 

### Option B — Run the server and tunnel it

Run `npm start` on your computer, then expose it over HTTPS with a tunnel so your
phone can reach it with working voice:

```bash
# using cloudflared
cloudflared tunnel --url http://localhost:3000
# ...or ngrok
ngrok http 3000
```

Open the `https://…` URL it prints on your phone. Your API key stays on your
computer (Server mode).

### Option C — Same Wi-Fi, text only

Find your computer's local IP (e.g. `192.168.1.20`) and open
`http://192.168.1.20:3000` on your phone. Text chat and app-opening work; **voice
input won't** because it's plain `http` (browsers block the mic off-HTTPS).

### Add to Home Screen (makes it a real app)

- **iPhone (Safari):** Share → _Add to Home Screen_.
- **Android (Chrome):** ⋮ menu → _Install app_ / _Add to Home screen_.

It then launches full-screen with its own icon, just like a native app.

---

## Connection modes

Open **⚙️ Settings → Connection mode**:

| Mode | How it works | Best for |
|------|--------------|----------|
| **Server** | Browser → your Node server → Claude. Key lives on the server. | Running locally / on your own host. Most private. |
| **Direct** | Browser → your chosen AI provider directly (your key, stored in the browser). | Static hosting (GitHub Pages/Netlify) with no backend. |
| **On-device** | A small open model runs **on your device** via WebGPU (WebLLM). No key, no cost, no cloud. | Free & private use, offline. Needs a recent device. |
| **Onboard brain** | JARVIS's own keyless logic core — no API, no cloud AI. Does maths, time/date, dictionary definitions, quick facts (keyless Wikipedia/dictionary), identity & small talk, plus all device commands. | **Works instantly with zero setup.** The default when you have no key. Not a full conversationalist — connect a brain for that. |

### On-device mode (no API key, no cost)

JARVIS can run a small open model (Llama 3.2, Qwen 2.5) **entirely on your
device** using WebGPU — no key, no signup, nothing sent to a cloud, works
offline once loaded. In **⚙️ Settings → Connection mode → On-device**, pick a
model and tap **Download & load model**.

Caveats, honestly:
- Needs **WebGPU**: a recent iPhone (**iOS 18+**, WebGPU enabled) or a recent
  desktop **Chrome/Edge**. Older devices can't run it.
- First load **downloads the model (~1 GB)** and needs a good connection.
- It is **noticeably less capable and slower** than the cloud models (Claude,
  Gemini, GPT). Great for chat and commands; not for heavy reasoning.

No app or web page can *be* a full ChatGPT-class brain on its own — that runs on
data-center GPUs. On-device mode is the real "no cloud" option, within the
limits of what a phone can run.

### Choose your AI provider (Direct mode)

JARVIS isn't tied to one company. In **⚙️ Settings → Direct → AI provider**, pick:

| Provider | Get a key at | Notes |
|----------|--------------|-------|
| **Free cloud (no key)** | — | Keyless, hosted on real servers (via pollinations.ai). **Fast, zero setup** — JARVIS uses this automatically when you have no key. Community-run, so it can be rate-limited or briefly down. |
| **Google Gemini** | aistudio.google.com/apikey | **Free tier**, needs a key. Reliable and smart. |
| **Anthropic (Claude)** | console.anthropic.com | Paid. |
| **OpenAI (GPT)** | platform.openai.com/api-keys | Paid. GPT-4o and friends. |
| **Other (OpenAI-compatible)** | your provider | Works with **Groq**, **OpenRouter**, **Together**, **DeepSeek**, local servers, etc. Just set the **base URL** (e.g. `https://api.groq.com/openai/v1`) and model. |

> **No key, fast, works immediately:** the **Free cloud** provider. On a phone,
> prefer this over On-device — most phones run the on-device model on the CPU
> (WebGPU isn't engaged), which is painfully slow.

The provider must allow browser (CORS) requests. Anthropic, OpenAI, Google
Gemini and OpenRouter are all known to work directly from the browser. Your key
is stored only on your device.

---

## Voice notes

- **JARVIS speaking (text-to-speech)** works in virtually every modern browser.
  Choose the voice in Settings — it prefers a British male voice (e.g. _Daniel_,
  _Google UK English Male_) when available.
- **Talking to JARVIS (speech-to-text)** uses the Web Speech API. It works great
  in **Chrome on Android and desktop** over HTTPS. **iOS support is limited** —
  if the mic doesn't respond on an iPhone, just type; everything else still works.

---

## What you can ask it to do

| You say… | JARVIS does |
|----------|-------------|
| "Put on _Bohemian Rhapsody_" / "Play some jazz" | Opens YouTube (or Spotify/Apple Music) to that track |
| "Open Instagram / Spotify / Maps / WhatsApp…" | Opens the app (deep link) |
| "Search for the best ramen near me" | Google search |
| "Navigate to Central Park" | Google Maps directions |
| "Call +1 555 010 1234" | Starts a phone call |
| "Text +1 555… saying I'm running late" | Opens Messages, pre-filled |
| "Email alex@example.com about lunch" | Opens your mail composer |
| "Open example.com" | Opens the site |
| "Set a 10 minute timer for the pasta" | In-app countdown, alerts you |
| _Anything else_ | Just talks with you |

> On mobile, an action launches the target app automatically; a tappable chip
> also appears in the chat as a reliable one-tap fallback (browsers sometimes
> block automatic navigation, so the chip guarantees it always works).

---

## Customisation

- **Your name & form of address** — Settings, or during onboarding.
- **Voice** — Settings → JARVIS voice (+ "Test voice").
- **Model** — Settings → Model. Defaults to `claude-sonnet-5` (fast & balanced);
  `claude-opus-4-8` for maximum capability; `claude-haiku-4-5` for speed.
  Server-side default is set with `JARVIS_MODEL`.
- **Personality** — edit `prompts/jarvis-system-prompt.md`. The server reads it
  at startup; restart to apply.

### Server environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `ANTHROPIC_API_KEY` | – | Your Claude API key (Server mode). |
| `JARVIS_MODEL` | `claude-sonnet-5` | Model to use. |
| `PORT` | `3000` | Port to listen on. |
| `JARVIS_MAX_TOKENS` | `1024` | Max tokens per reply. |

See `.env.example`.

---

## Project structure

```
Jarvis/
├── server/
│   └── index.js               # Zero-dependency Node server + Claude proxy
├── public/                    # The PWA (deploy this folder for static hosting)
│   ├── index.html
│   ├── styles.css             # Futuristic HUD styling
│   ├── config.js              # Persistent settings (localStorage)
│   ├── jarvis-core.js         # Animated arc-reactor canvas
│   ├── voice.js               # Speech recognition + synthesis
│   ├── actions.js             # Device actions → deep links / URL schemes
│   ├── app.js                 # Main app logic
│   ├── manifest.webmanifest   # PWA manifest
│   ├── service-worker.js      # Offline app shell
│   └── icons/                 # App icons (arc-reactor emblem)
├── prompts/
│   └── jarvis-system-prompt.md
├── scripts/
│   └── make_icons.py          # Regenerate icons (needs Pillow)
├── package.json
└── .env.example
```

---

## Security & privacy

- In **Server mode**, your API key stays server-side and is never sent to the
  browser.
- In **Direct mode**, your key is stored only in your browser's `localStorage`
  and sent directly to Anthropic — convenient for static hosting, but don't use
  it on a shared/public device.
- Conversations are sent to Anthropic to generate replies; nothing else is
  collected or stored beyond your browser.

---

## A note on scope

A web app can open other apps via deep links and URL schemes — that covers the
vast majority of "do something on my phone" requests. Things a browser genuinely
can't reach (toggling system settings, controlling the camera flash, reading your
contacts) would need a native wrapper. The PWA approach was chosen deliberately:
it's installable, cross-platform, needs no app store, and gets you 95% of the way
today. A native shell (e.g. Capacitor) could be layered on later for the rest.

---

<div align="center">
<em>"At your service."</em>
</div>
