const CACHE_NAME = 'firmas-menshen-shell-v5';
const APP_BASE_URL = new URL('./', self.location.href);
const APP_PATH = APP_BASE_URL.pathname;
const SHELL_FILES = [
    './',
    './index.html',
    './estilos.css',
    './manifest.webmanifest',
    './assets/app-icon.svg',
    './assets/app-icon.png',
    './assets/menshen-logo.jpg'
].map((path) => new URL(path, APP_BASE_URL).href);

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => cache.addAll(SHELL_FILES))
            .then(() => self.skipWaiting())
    );
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys()
            .then((cacheNames) => Promise.all(
                cacheNames
                    .filter((cacheName) => cacheName.startsWith('firmas-menshen-shell-')
                        && cacheName !== CACHE_NAME)
                    .map((cacheName) => caches.delete(cacheName))
            ))
            .then(() => self.clients.claim())
    );
});

self.addEventListener('fetch', (event) => {
    const requestUrl = new URL(event.request.url);
    if (event.request.method !== 'GET'
        || requestUrl.origin !== self.location.origin
        || !requestUrl.pathname.startsWith(APP_PATH)) {
        return;
    }

    event.respondWith(
        caches.match(event.request)
            .then((cachedResponse) => cachedResponse || fetch(event.request).then((response) => {
                if (response.ok) {
                    const copy = response.clone();
                    caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
                }
                return response;
            }))
            .catch(() => {
                if (event.request.mode === 'navigate') {
                    return caches.match(new URL('./index.html', APP_BASE_URL).href);
                }
                throw new Error('El recurso no está disponible sin conexión.');
            })
    );
});
