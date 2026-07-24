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
    safari:    { label: 'Browser',   url: () => 'https://www.google.com' },
    browser:   { label: 'Browser',   url: () => 'https://www.google.com' },
    snapchat:  { label: 'Snapchat',  url: () => (isIOS || isAndroid) ? 'snapchat://' : 'https://www.snapchat.com' },
    discord:   { label: 'Discord',   url: () => 'https://discord.com/app' },
    soundcloud:{ label: 'SoundCloud',url: () => 'https://soundcloud.com' },
    pinterest: { label: 'Pinterest', url: () => 'https://www.pinterest.com' },
    linkedin:  { label: 'LinkedIn',  url: () => 'https://www.linkedin.com' },
    uber:      { label: 'Uber',      url: () => (isIOS || isAndroid) ? 'uber://' : 'https://m.uber.com' },
    lyft:      { label: 'Lyft',      url: () => (isIOS || isAndroid) ? 'lyft://' : 'https://www.lyft.com' },
    doordash:  { label: 'DoorDash',  url: () => 'https://www.doordash.com' },
    'app store': { label: 'App Store', url: () => 'https://apps.apple.com' },
    facetime:  { label: 'FaceTime',  url: () => 'facetime://' },
    line:      { label: 'LINE',      url: () => 'line://' },
    wechat:    { label: 'WeChat',    url: () => 'weixin://' },
    zoom:      { label: 'Zoom',      url: () => 'https://zoom.us' },
    slack:     { label: 'Slack',     url: () => 'https://app.slack.com' },
    paypal:    { label: 'PayPal',    url: () => 'https://www.paypal.com' },
    venmo:     { label: 'Venmo',     url: () => (isIOS || isAndroid) ? 'venmo://' : 'https://venmo.com' },
    'cash app':{ label: 'Cash App',  url: () => 'https://cash.app' },
    github:    { label: 'GitHub',    url: () => 'https://github.com' },
    chatgpt:   { label: 'ChatGPT',   url: () => 'https://chat.openai.com' },
    weather:   { label: 'Weather',   url: () => 'https://weather.com' },
    calculator:{ label: 'Calculator',url: () => 'https://www.google.com/search?q=calculator' },
    'youtube music': { label: 'YT Music', url: () => 'https://music.youtube.com' },
    'apple maps': { label: 'Apple Maps', url: () => 'https://maps.apple.com' },
  };

  /* Native protocol handlers — these actually launch the INSTALLED desktop or
     mobile app on the user's own machine (the OS hands the scheme to the
     registered app). Used first; the https URL above is the fallback if the
     app isn't installed. Never a web search. */
  const isMac = /Mac/.test(ua) && !isIOS;
  const NATIVE = {
    spotify:   'spotify:',
    discord:   'discord://',
    slack:     'slack://open',
    whatsapp:  'whatsapp://',
    telegram:  'tg://',
    steam:     'steam://open/main',
    vscode:    'vscode://',
    snapchat:  'snapchat://',
    facetime:  'facetime://',
    line:      'line://',
    wechat:    'weixin://',
    zoom:      'zoommtg://',
    mail:      'mailto:',
    gmail:     'mailto:',
    music:     isMac || isIOS ? 'music://' : '',
    'apple music': isMac || isIOS ? 'music://' : '',
    maps:      isMac || isIOS ? 'maps://' : '',
    'apple maps': 'maps://',
    messages:  isMac || isIOS ? 'imessage://' : (isAndroid ? 'sms:' : ''),
    phone:     'tel:',
    facebook:  isIOS || isAndroid ? 'fb://' : '',
    instagram: isIOS || isAndroid ? 'instagram://' : '',
    twitter:   isIOS || isAndroid ? 'twitter://' : '',
    x:         isIOS || isAndroid ? 'twitter://' : '',
    reddit:    isIOS || isAndroid ? 'reddit://' : '',
    netflix:   isIOS || isAndroid ? 'nflx://' : '',
    twitch:    isIOS || isAndroid ? 'twitch://' : '',
  };

  // Launch a native app by scheme; if it doesn't take over, open the web app.
  // Assigning location to an external scheme is handled by the OS WITHOUT
  // unloading the page (for registered protocols), so JARVIS stays put.
  function launchApp(scheme, web) {
    if (!scheme) { if (web) autoOpen(web); return false; }
    let handed = false;
    const mark = () => { handed = true; };
    document.addEventListener('visibilitychange', mark, { once: true });
    window.addEventListener('blur', mark, { once: true });
    const started = Date.now();
    try { window.location.href = scheme; } catch { /* unregistered scheme */ }
    // Fallback to the web app if we're still here and the OS didn't switch away.
    if (web) setTimeout(() => {
      if (!handed && document.visibilityState === 'visible' && Date.now() - started < 2500) autoOpen(web);
    }, 1500);
    return true;
  }

  // Public: open an app by key. Native first, real web app second — never a
  // Google search for a known app.
  function openApp(key) {
    key = String(key || '').toLowerCase().trim();
    const app = APPS[key];
    const web = app ? app.url() : '';
    const scheme = NATIVE[key] || (web && /^[a-z][a-z0-9.+-]*:/i.test(web) && !/^https?:/i.test(web) ? web : '');
    const JA = window.JarvisActions || { launchApp, autoOpen };
    if (scheme) { JA.launchApp(scheme, /^https?:/i.test(web) ? web : ''); return { label: app ? app.label : key, native: true }; }
    if (web) { JA.autoOpen(web); return { label: app ? app.label : key, native: false }; }
    // Truly unknown app: last-resort search so the click still does something.
    JA.autoOpen('https://www.google.com/search?q=' + enc(key + ' app'));
    return { label: key, native: false };
  }

  // In-app search URLs.
  const APP_SEARCH = {
    youtube: (q) => `https://www.youtube.com/results?search_query=${enc(q)}`,
    'youtube music': (q) => `https://music.youtube.com/search?q=${enc(q)}`,
    instagram: (q) => `https://www.instagram.com/explore/search/keyword/?q=${enc(q)}`,
    twitter: (q) => `https://twitter.com/search?q=${enc(q)}`,
    x: (q) => `https://x.com/search?q=${enc(q)}`,
    tiktok: (q) => `https://www.tiktok.com/search?q=${enc(q)}`,
    spotify: (q) => `https://open.spotify.com/search/${enc(q)}`,
    google: (q) => `https://www.google.com/search?q=${enc(q)}`,
    reddit: (q) => `https://www.reddit.com/search/?q=${enc(q)}`,
    amazon: (q) => `https://www.amazon.com/s?k=${enc(q)}`,
    ebay: (q) => `https://www.ebay.com/sch/i.html?_nkw=${enc(q)}`,
    maps: (q) => `https://www.google.com/maps/search/?api=1&query=${enc(q)}`,
    'google maps': (q) => `https://www.google.com/maps/search/?api=1&query=${enc(q)}`,
    pinterest: (q) => `https://www.pinterest.com/search/pins/?q=${enc(q)}`,
    soundcloud: (q) => `https://soundcloud.com/search?q=${enc(q)}`,
    netflix: (q) => `https://www.netflix.com/search?q=${enc(q)}`,
    linkedin: (q) => `https://www.linkedin.com/search/results/all/?keywords=${enc(q)}`,
    github: (q) => `https://github.com/search?q=${enc(q)}&type=repositories`,
    wikipedia: (q) => `https://en.wikipedia.org/w/index.php?search=${enc(q)}`,
    'apple music': (q) => `https://music.apple.com/search?term=${enc(q)}`,
    twitch: (q) => `https://www.twitch.tv/search?term=${enc(q)}`,
  };

  function musicUrl(query, service) {
    const q = enc(query || '');
    switch ((service || 'youtube').toLowerCase()) {
      case 'spotify':
        return { label: `Spotify · ${query}`, url: `https://open.spotify.com/search/${q}` };
      case 'apple':
      case 'apple music':
        return { label: `Apple Music · ${query}`, url: `https://music.apple.com/search?term=${q}` };
      case 'soundcloud':
        return { label: `SoundCloud · ${query}`, url: `https://soundcloud.com/search?q=${q}` };
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
      case 'search_in_app': {
        const app = String(action.app || '').toLowerCase().trim();
        const q = action.query || '';
        const fn = APP_SEARCH[app];
        const url = fn ? fn(q) : `https://www.google.com/search?q=${enc(q + ' ' + app)}`;
        const label = APPS[app] ? APPS[app].label : (app.charAt(0).toUpperCase() + app.slice(1));
        return { kind: 'link', label: `Search ${label}: ${q}`, url, auto: true };
      }
      case 'open_chat': {
        const app = String(action.app || '').toLowerCase().trim();
        const num = String(action.number || '').replace(/\D/g, '');
        const who = action.name || '';
        if (app === 'whatsapp' && num) return { kind: 'link', label: `WhatsApp · ${who}`, url: `https://wa.me/${num}`, auto: true };
        if ((app === 'messages' || app === 'sms' || app === 'text') && action.number) return { kind: 'link', label: `Messages · ${who}`, url: `sms:${String(action.number).replace(/[^\d+*#]/g, '')}`, auto: true };
        if (app === 'telegram' && action.handle) return { kind: 'link', label: `Telegram · ${who}`, url: `https://t.me/${String(action.handle).replace(/^@/, '')}`, auto: true };
        // Apps that can't target a specific chat via URL — just open the app.
        const appEntry = APPS[app];
        return { kind: 'link', label: `Open ${appEntry ? appEntry.label : app}`, url: appEntry ? appEntry.url() : `https://www.google.com/search?q=${enc(app + ' app')}`, auto: true };
      }
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
        const app = String(action.app || '').toLowerCase().trim();
        const who = action.name || action.number || '';
        if (!num) return null;
        const digits = num.replace(/\D/g, '');
        if (app === 'facetime')
          return { kind: 'link', label: `FaceTime ${who}`, url: `facetime://${num}`, auto: true };
        if (app === 'facetime audio' || app === 'facetime-audio')
          return { kind: 'link', label: `FaceTime ${who}`, url: `facetime-audio://${num}`, auto: true };
        if (app === 'whatsapp')
          return { kind: 'link', label: `WhatsApp ${who}`, url: `https://wa.me/${digits}`, auto: true };
        return { kind: 'link', label: `Call ${who}`, url: `tel:${num}`, auto: true };
      }
      case 'text': {
        const num = String(action.number || '').replace(/[^\d+*#]/g, '');
        const app = String(action.app || '').toLowerCase().trim();
        const who = action.name || action.number || '';
        const digits = num.replace(/\D/g, '');
        if (app === 'whatsapp')
          return { kind: 'link', label: `WhatsApp ${who}`.trim(), url: `https://wa.me/${digits}${action.message ? '?text=' + enc(action.message) : ''}`, auto: true };
        const body = action.message ? `${isIOS ? '&' : '?'}body=${enc(action.message)}` : '';
        return { kind: 'link', label: `Text ${who}`.trim(), url: `sms:${num}${body}`, auto: true };
      }
      case 'email': {
        const to = enc(action.to || '');
        const subj = action.subject ? `subject=${enc(action.subject)}` : '';
        const body = action.body ? `body=${enc(action.body)}` : '';
        const q = [subj, body].filter(Boolean).join('&');
        return { kind: 'link', label: `Email ${action.to || ''}`.trim(), url: `mailto:${to}${q ? '?' + q : ''}`, auto: true };
      }
      case 'calendar': {
        const title = enc(action.title || 'New event');
        const dates = action.start ? `&dates=${action.start}/${action.end || action.start}` : '';
        const details = action.details ? `&details=${enc(action.details)}` : '';
        const loc = action.location ? `&location=${enc(action.location)}` : '';
        // Bare dates in a TEMPLATE link are read as UTC; pass the local zone so
        // the event lands at the time the user actually meant.
        let ctz = '';
        try { const z = Intl.DateTimeFormat().resolvedOptions().timeZone; if (z) ctz = `&ctz=${enc(z)}`; } catch { /* */ }
        const url = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${title}${dates}${ctz}${details}${loc}`;
        return { kind: 'link', label: `Calendar · ${action.title || 'Event'}`, url, auto: true };
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

  window.JarvisActions = { build, autoOpen, openApp, launchApp, formatDuration, isIOS, isAndroid };
})();
