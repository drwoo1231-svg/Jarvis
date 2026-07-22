/* JARVIS — service worker: cache the app shell for offline launch.
   Network-first for navigation and API; cache-first for static assets. */

const CACHE = 'jarvis-v1';
const SHELL = [
  './',
  './index.html',
  './styles.css',
  './config.js',
  './jarvis-core.js',
  './voice.js',
  './actions.js',
  './app.js',
  './manifest.webmanifest',
  './icons/icon.svg',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Never cache API traffic.
  if (url.pathname.startsWith('/api/')) return;

  // Only handle same-origin GETs; let everything else hit the network.
  if (request.method !== 'GET' || url.origin !== self.location.origin) return;

  // Navigation requests: network-first, fall back to cached shell.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request).catch(() => caches.match('./index.html'))
    );
    return;
  }

  // Static assets: cache-first, then network (and cache the result).
  event.respondWith(
    caches.match(request).then((cached) =>
      cached ||
      fetch(request).then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(request, copy)).catch(() => {});
        return res;
      }).catch(() => cached)
    )
  );
});
