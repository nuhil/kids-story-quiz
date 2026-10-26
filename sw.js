// Offline support. App files come from the network first, so updates show up right away, and fall back to the cache offline.
// Images are cached the first time they are shown, so stories a kid has already read keep working without internet.
// Bump VERSION to drop every cached file (for example after replacing an image under the same name).
const VERSION='storyspark-v3';
const SHELL=['./','./index.html','./app.js','./styles.css','./content.json','./assets.json','./manifest.webmanifest','./icons/icon-192.png','./icons/apple-touch-icon.png','./icons/favicon-32.png','./assets/SplashHero.jpg'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(VERSION).then(c=>c.addAll(SHELL)).then(()=>self.skipWaiting()));});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==VERSION).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',e=>{const req=e.request,url=new URL(req.url);if(req.method!=='GET'||url.origin!==location.origin)return;
if(/\.(jpe?g|png|webp|svg)$/i.test(url.pathname)){e.respondWith(caches.open(VERSION).then(async cache=>{const hit=await cache.match(req);if(hit)return hit;const res=await fetch(req);if(res.ok)cache.put(req,res.clone());return res;}));return;}
e.respondWith(fetch(req).then(res=>{if(res.ok){const copy=res.clone();caches.open(VERSION).then(c=>c.put(req,copy));}return res;}).catch(()=>caches.match(req,{ignoreSearch:true}).then(hit=>hit||(req.mode==='navigate'?caches.match('./index.html'):Response.error()))));});
