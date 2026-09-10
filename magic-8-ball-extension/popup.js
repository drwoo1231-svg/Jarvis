/* Magic 8 Ball — popup logic. No network, no page access; history lives in extension storage. */

const ANSWERS = [
  // 10 affirmative
  { text: "It is certain", tone: "yes" },
  { text: "It is decidedly so", tone: "yes" },
  { text: "Without a doubt", tone: "yes" },
  { text: "Yes definitely", tone: "yes" },
  { text: "You may rely on it", tone: "yes" },
  { text: "As I see it, yes", tone: "yes" },
  { text: "Most likely", tone: "yes" },
  { text: "Outlook good", tone: "yes" },
  { text: "Yes", tone: "yes" },
  { text: "Signs point to yes", tone: "yes" },
  // 5 non-committal
  { text: "Reply hazy, try again", tone: "maybe" },
  { text: "Ask again later", tone: "maybe" },
  { text: "Better not tell you now", tone: "maybe" },
  { text: "Cannot predict now", tone: "maybe" },
  { text: "Concentrate and ask again", tone: "maybe" },
  // 5 negative
  { text: "Don't count on it", tone: "no" },
  { text: "My reply is no", tone: "no" },
  { text: "My sources say no", tone: "no" },
  { text: "Outlook not so good", tone: "no" },
  { text: "Very doubtful", tone: "no" },
];

const HISTORY_KEY = "m8b:history";
const MUTED_KEY = "m8b:muted";
const HISTORY_MAX = 12;
const SHAKE_MS = 820;

const el = {
  ball: document.getElementById("ball"),
  die: document.getElementById("die"),
  dieText: document.getElementById("dieText"),
  window: document.querySelector(".window"),
  hint: document.getElementById("hint"),
  status: document.getElementById("status"),
  form: document.getElementById("askForm"),
  question: document.getElementById("question"),
  shake: document.getElementById("shake"),
  mute: document.getElementById("mute"),
  historyToggle: document.getElementById("historyToggle"),
  history: document.getElementById("history"),
  historyList: document.getElementById("historyList"),
  historyEmpty: document.getElementById("historyEmpty"),
  clearHistory: document.getElementById("clearHistory"),
};

let busy = false;
let muted = false;
let lastIndex = -1;
let history = [];
let audioCtx = null;

/* ---------- storage (extension storage, with a localStorage fallback) ---------- */

const hasChromeStorage =
  typeof chrome !== "undefined" && chrome.storage && chrome.storage.local;

function load(keys) {
  if (hasChromeStorage) {
    return new Promise((resolve) => {
      chrome.storage.local.get(keys, (got) => resolve(got || {}));
    });
  }
  const out = {};
  for (const key of keys) {
    try {
      const raw = localStorage.getItem(key);
      if (raw !== null) out[key] = JSON.parse(raw);
    } catch (_) {
      /* ignore unreadable values */
    }
  }
  return Promise.resolve(out);
}

function save(items) {
  if (hasChromeStorage) {
    chrome.storage.local.set(items);
    return;
  }
  for (const [key, value] of Object.entries(items)) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (_) {
      /* storage full or blocked — history is a nicety, not a requirement */
    }
  }
}

/* ---------- randomness ---------- */

function pickAnswer() {
  const buf = new Uint32Array(1);
  let index;
  // Rejection-sample so every answer stays equally likely, and never repeat
  // the previous one back-to-back — a repeat reads as a bug, not as fate.
  do {
    crypto.getRandomValues(buf);
    if (buf[0] >= Math.floor(4294967296 / ANSWERS.length) * ANSWERS.length) continue;
    index = buf[0] % ANSWERS.length;
  } while (index === undefined || (ANSWERS.length > 1 && index === lastIndex));
  lastIndex = index;
  return ANSWERS[index];
}

/* ---------- sound ---------- */

function tone({ type = "sine", from, to, start = 0, dur = 0.2, gain = 0.2 }) {
  const ctx = audioCtx;
  const t0 = ctx.currentTime + start;
  const osc = ctx.createOscillator();
  const amp = ctx.createGain();
  osc.type = type;
  osc.frequency.setValueAtTime(from, t0);
  if (to && to !== from) osc.frequency.exponentialRampToValueAtTime(to, t0 + dur);
  amp.gain.setValueAtTime(0.0001, t0);
  amp.gain.exponentialRampToValueAtTime(gain, t0 + 0.015);
  amp.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
  osc.connect(amp).connect(ctx.destination);
  osc.start(t0);
  osc.stop(t0 + dur + 0.05);
}

function sound(kind) {
  if (muted) return;
  try {
    if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    if (audioCtx.state === "suspended") audioCtx.resume();
    if (kind === "shake") {
      tone({ type: "sine", from: 150, to: 55, dur: 0.22, gain: 0.22 });
      tone({ type: "triangle", from: 240, to: 90, start: 0.16, dur: 0.2, gain: 0.1 });
    } else {
      tone({ type: "triangle", from: 587.33, to: 587.33, dur: 0.18, gain: 0.11 });
      tone({ type: "triangle", from: 880, to: 880, start: 0.09, dur: 0.28, gain: 0.09 });
    }
  } catch (_) {
    /* audio is optional */
  }
}

/* ---------- the shake ---------- */

function fitText(text) {
  const n = text.length;
  if (n <= 10) return "11px";
  if (n <= 16) return "10px";
  if (n <= 24) return "9.5px";
  return "8.5px";
}

function shake() {
  if (busy) return;
  busy = true;
  el.shake.disabled = true;

  const question = el.question.value.trim();
  const answer = pickAnswer();

  el.window.classList.remove("is-revealing", "tone-yes", "tone-maybe", "tone-no");
  el.ball.classList.remove("is-shaking");
  void el.ball.offsetWidth; // restart the animation
  el.ball.classList.add("is-shaking");
  el.hint.textContent = "Shaking…";
  sound("shake");

  const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
  setTimeout(() => {
    el.ball.classList.remove("is-shaking");
    el.dieText.textContent = answer.text;
    el.dieText.style.fontSize = fitText(answer.text);
    el.window.classList.add("is-revealing", `tone-${answer.tone}`);
    sound("reveal");

    el.hint.textContent = "Shake again for a second opinion.";
    el.status.textContent = `${answer.text}.`;

    record(question, answer);
    busy = false;
    el.shake.disabled = false;
  }, reduced ? 60 : SHAKE_MS);
}

/* ---------- history ---------- */

function record(question, answer) {
  history.unshift({ q: question, a: answer.text, tone: answer.tone, t: Date.now() });
  if (history.length > HISTORY_MAX) history.length = HISTORY_MAX;
  save({ [HISTORY_KEY]: history });
  renderHistory();
}

function renderHistory() {
  el.historyList.textContent = "";
  el.historyEmpty.hidden = history.length > 0;
  for (const entry of history) {
    const li = document.createElement("li");
    if (entry.q) {
      const q = document.createElement("span");
      q.className = "h-q";
      q.textContent = entry.q;
      q.title = entry.q;
      li.append(q);
    }
    const a = document.createElement("span");
    a.className = `h-a tone-${entry.tone || "maybe"}`;
    a.textContent = entry.a;
    li.append(a);
    el.historyList.append(li);
  }
}

/* ---------- wiring ---------- */

el.form.addEventListener("submit", (event) => {
  event.preventDefault();
  shake();
});

el.ball.addEventListener("click", shake);

function paintMute() {
  el.mute.setAttribute("aria-pressed", String(muted));
  el.mute.title = muted ? "Unmute sound" : "Mute sound";
  el.mute.classList.toggle("is-muted", muted);
}

el.mute.addEventListener("click", () => {
  muted = !muted;
  paintMute();
  save({ [MUTED_KEY]: muted });
});

el.historyToggle.addEventListener("click", () => {
  const open = el.history.hidden;
  el.history.hidden = !open;
  el.historyToggle.setAttribute("aria-expanded", String(open));
  el.historyToggle.title = open ? "Hide history" : "History";
});

el.clearHistory.addEventListener("click", () => {
  history = [];
  save({ [HISTORY_KEY]: history });
  renderHistory();
});

load([HISTORY_KEY, MUTED_KEY]).then((stored) => {
  history = Array.isArray(stored[HISTORY_KEY]) ? stored[HISTORY_KEY] : [];
  muted = stored[MUTED_KEY] === true;
  paintMute();
  renderHistory();
  el.question.focus();
});
