/* JARVIS — service worker: cache the app shell for offline launch.
   Network-first for navigation and API; cache-first for static assets. */

const CACHE = 'jarvis-v25';
const SHELL = [
  './',
  './index.html',
  './styles.css',
  './config.js',
  './jarvis-core.js',
  './voice.js',
  './actions.js',
  './ondevice.js',
  './panels.js',
  './career.js',
  './atlas.js',
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

  // Network-first for everything (shell + app code) so updates land immediately
  // whenever the device is online; fall back to cache only when offline. This
  // avoids stale-app-stuck-on-old-version problems, at the cost of a network
  // round trip while online (the app is tiny, so this is imperceptible).
  event.respondWith(
    fetch(request)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(request, copy)).catch(() => {});
        return res;
      })
      .catch(() =>
        caches.match(request).then((cached) => cached || caches.match('./index.html'))
      )
  );
});
