/* ============================================================
   JARVIS — device actions
   Translates action directives from JARVIS into deep links /
   URL schemes and other on-device behaviour.

   Because a reply arrives asynchronously (after the LLM call), the
   browser gesture that started it may have expired, so automatic
   navigation can be blocked. Every action therefore ALSO produces a
   tappable chip (a real <a href>) that is guaranteed to work.
   ============================================================ */
(function () {
  'use strict';

  const ua = navigator.userAgent || '';
  const isIOS = /iPad|iPhone|iPod/.test(ua) || (/Mac/.test(ua) && 'ontouchend' in document);
  const isAndroid = /Android/.test(ua);
  const enc = encodeURIComponent;

  /* Known apps -> a link that opens the installed app on mobile and the web
     app on desktop. Universal https links are preferred as they degrade well. */
  const APPS = {
    youtube:   { label: 'YouTube',   url: () => 'https://www.youtube.com' },
    spotify:   { label: 'Spotify',   url: () => (isIOS || isAndroid) ? 'spotify://' : 'https://open.spotify.com' },
    'apple music': { label: 'Apple Music', url: () => 'https://music.apple.com' },
    music:     { label: 'Music',     url: () => 'https://music.youtube.com' },
    maps:      { label: 'Maps',      url: () => 'https://maps.google.com' },
    'google maps': { label: 'Maps',  url: () => 'https://maps.google.com' },
    whatsapp:  { label: 'WhatsApp',  url: () => 'https://wa.me' },
    instagram: { label: 'Instagram', url: () => 'https://www.instagram.com' },
    twitter:   { label: 'X',         url: () => 'https://twitter.com' },
    x:         { label: 'X',         url: () => 'https://x.com' },
    tiktok:    { label: 'TikTok',    url: () => 'https://www.tiktok.com' },
    facebook:  { label: 'Facebook',  url: () => 'https://www.facebook.com' },
    messenger: { label: 'Messenger', url: () => 'https://www.messenger.com' },
    telegram:  { label: 'Telegram',  url: () => 'https://web.telegram.org' },
    reddit:    { label: 'Reddit',    url: () => 'https://www.reddit.com' },
    gmail:     { label: 'Gmail',     url: () => 'https://mail.google.com' },
    mail:      { label: 'Mail',      url: () => 'mailto:' },
    outlook:   { label: 'Outlook',   url: () => 'https://outlook.live.com' },
    netflix:   { label: 'Netflix',   url: () => 'https://www.netflix.com' },
    'prime video': { label: 'Prime Video', url: () => 'https://www.primevideo.com' },
    disney:    { label: 'Disney+',   url: () => 'https://www.disneyplus.com' },
    twitch:    { label: 'Twitch',    url: () => 'https://www.twitch.tv' },
    chrome:    { label: 'Browser',   url: () => 'https://www.google.com' },
    google:    { label: 'Google',    url: () => 'https://www.google.com' },
    phone:     { label: 'Phone',     url: () => 'tel:' },
    dialer:    { label: 'Phone',     url: () => 'tel:' },
    messages:  { label: 'Messages',  url: () => 'sms:' },
    calendar:  { label: 'Calendar',  url: () => 'https://calendar.google.com' },
    photos:    { label: 'Photos',    url: () => 'https://photos.google.com' },
    drive:     { label: 'Drive',     url: () => 'https://drive.google.com' },
    notes:     { label: 'Keep',      url: () => 'https://keep.google.com' },
    amazon:    { label: 'Amazon',    url: () => 'https://www.amazon.com' },
  };

  function musicUrl(query, service) {
    const q = enc(query || '');
    switch ((service || 'youtube').toLowerCase()) {
      case 'spotify':
        return { label: `Spotify · ${query}`, url: `https://open.spotify.com/search/${q}` };
      case 'apple':
      case 'apple music':
        return { label: `Apple Music · ${query}`, url: `https://music.apple.com/search?term=${q}` };
      case 'youtube':
      default:
        // YouTube search opens the app on mobile; user taps the top result.
        return { label: `Play · ${query}`, url: `https://www.youtube.com/results?search_query=${q}` };
    }
  }

  /* Build an executable description from a raw action object. */
  function build(action) {
    if (!action || typeof action !== 'object') return null;
    const type = String(action.type || '').toLowerCase();

    switch (type) {
      case 'play_music': {
        const m = musicUrl(action.query, action.service);
        return { kind: 'link', label: m.label, url: m.url, auto: true };
      }
      case 'open_app': {
        const key = String(action.app || '').toLowerCase().trim();
        const app = APPS[key];
        if (app) return { kind: 'link', label: `Open ${app.label}`, url: app.url(), auto: true };
        // Unknown app -> search for it.
        return { kind: 'link', label: `Open ${action.app}`, url: `https://www.google.com/search?q=${enc(action.app + ' app')}`, auto: true };
      }
      case 'search_web':
        return { kind: 'link', label: `Search: ${action.query}`, url: `https://www.google.com/search?q=${enc(action.query || '')}`, auto: true };
      case 'open_url': {
        let url = String(action.url || '');
        if (url && !/^[a-z]+:/i.test(url)) url = 'https://' + url;
        if (!url) return null;
        let host = url;
        try { host = new URL(url).hostname.replace(/^www\./, ''); } catch {}
        return { kind: 'link', label: `Open ${host}`, url, auto: true };
      }
      case 'navigate': {
        const d = enc(action.destination || '');
        return { kind: 'link', label: `Navigate: ${action.destination}`, url: `https://www.google.com/maps/dir/?api=1&destination=${d}`, auto: true };
      }
      case 'call': {
        const num = String(action.number || '').replace(/[^\d+*#]/g, '');
        if (!num) return null;
        return { kind: 'link', label: `Call ${action.number}`, url: `tel:${num}`, auto: true };
      }
      case 'text': {
        const num = String(action.number || '').replace(/[^\d+*#]/g, '');
        const body = action.message ? `${isIOS ? '&' : '?'}body=${enc(action.message)}` : '';
        return { kind: 'link', label: `Text ${action.number || ''}`.trim(), url: `sms:${num}${body}`, auto: true };
      }
      case 'email': {
        const to = enc(action.to || '');
        const subj = action.subject ? `subject=${enc(action.subject)}` : '';
        const body = action.body ? `body=${enc(action.body)}` : '';
        const q = [subj, body].filter(Boolean).join('&');
        return { kind: 'link', label: `Email ${action.to || ''}`.trim(), url: `mailto:${to}${q ? '?' + q : ''}`, auto: true };
      }
      case 'timer': {
        const secs = Math.max(1, parseInt(action.seconds, 10) || 0);
        if (!secs) return null;
        return { kind: 'timer', label: `Timer · ${formatDuration(secs)}${action.label ? ' · ' + action.label : ''}`, seconds: secs, timerLabel: action.label || '' };
      }
      default:
        return null;
    }
  }

  function formatDuration(s) {
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    const sec = s % 60;
    const parts = [];
    if (h) parts.push(`${h}h`);
    if (m) parts.push(`${m}m`);
    if (sec) parts.push(`${sec}s`);
    return parts.join(' ') || '0s';
  }

  /* Attempt automatic navigation. Returns without throwing if blocked. */
  function autoOpen(url) {
    if (!url) return;
    try {
      const a = document.createElement('a');
      a.href = url;
      a.target = '_blank';
      a.rel = 'noopener noreferrer';
      document.body.appendChild(a);
      a.click();
      a.remove();
    } catch {
      // As a last resort, try direct assignment (mostly for custom schemes).
      try { window.location.href = url; } catch {}
    }
  }

  window.JarvisActions = { build, autoOpen, formatDuration, isIOS, isAndroid };
})();
