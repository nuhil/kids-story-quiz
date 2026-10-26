import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile,stat} from 'node:fs/promises';
import {JSDOM} from 'jsdom';
const content=JSON.parse(await readFile('public/content.json','utf8'));
const assets=JSON.parse(await readFile('public/assets.json','utf8'));
const source=await readFile('app.js','utf8');
async function boot(saved,hash='',setup){const dom=new JSDOM('<div id="app"></div>',{url:'http://localhost/'+hash,runScripts:'outside-only',pretendToBeVisual:true});const w=dom.window;w.scrollTo=()=>{};w.fetch=async path=>({ok:true,json:async()=>structuredClone(path.includes('content')?content:assets)});if(saved)w.localStorage.setItem(saved.profiles?'storyspark.web.v2':'storyspark.web.v1',JSON.stringify(saved));setup?.(w);await w.eval(`(async()=>{${source}\n})()`);return {w,doc:w.document,close:()=>w.close()};}
const profile={name:'Tester',age:7};
const tick=()=>new Promise(r=>setTimeout(r,20));
const stored=w=>JSON.parse(w.localStorage.getItem('storyspark.web.v2'));
const active=w=>{const store=stored(w);return store.profiles[store.active];};
function spell(doc,word){for(const ch of word)doc.querySelector(`[data-key="${ch}"]`).click();}
function pickAge(doc,age){doc.querySelector(`[data-age="${age}"]`).click();}
const modalButtons=doc=>[...doc.querySelectorAll('.modal button')];
const clickModal=(doc,label)=>modalButtons(doc).find(b=>b.textContent.includes(label)).click();
test('all original stories, answers and images are valid',async()=>{assert.equal(content.length,10);assert.equal(content.flatMap(c=>c.stories).length,100);const ids=new Set();for(const c of content)for(const s of c.stories){assert(!ids.has(s.story_id));ids.add(s.story_id);assert(s.pages.length>0);for(const q of s.quiz)assert(q.options.includes(q.correct_answer));}for(const path of Object.values(assets))assert((await stat('public/'+path)).size>0);});
test('onboarding, search, reading and persistence',async()=>{const {w,doc,close}=await boot();try{assert.match(doc.body.textContent,/Meet Our Explorer/);assert(doc.querySelector('#start').disabled);spell(doc,'AVERY');doc.querySelector('#start').click();clickModal(doc,'I’m New');await tick();assert.match(doc.body.textContent,/Hello, Avery/);w.location.hash='/explore';await tick();assert.equal(doc.querySelectorAll('.story').length,100);const search=doc.querySelector('#search');search.value='Whaley';search.dispatchEvent(new w.Event('input'));assert.equal(doc.querySelectorAll('.story').length,1);w.location.hash='/read/ocean_01/2';await tick();assert.match(doc.querySelector('.reading').textContent,/salty/);assert.equal(active(w).reading.ocean_01.page,2);w.location.hash='/read/ocean_01/999';await tick();assert.match(doc.querySelector('.page-count').textContent,/11 of 11/);}finally{close();}});
test('complete quiz awards points, badge and pass exactly once',async()=>{const {w,doc,close}=await boot({profile});try{w.location.hash='/quiz/ocean_01';await tick();const questions=content[0].stories[0].quiz;for(let i=0;i<questions.length;i++){const options=[...doc.querySelectorAll('[data-option]')];options.find(b=>b.querySelector('span').textContent===questions[i].correct_answer).click();doc.querySelector('[data-action="check"]').click();assert(doc.querySelector('[data-action="check"]').disabled);await new Promise(r=>setTimeout(r,1020));assert(doc.querySelector('[role="dialog"]'));doc.querySelector('.modal button').click();}const saved=active(w);assert.equal(saved.points,100);assert.equal(saved.passes,1);assert.equal(saved.badges.ocean_01,1);assert.equal(saved.stats.ocean_01.attempts,1);assert.match(doc.body.textContent,/Look At You Grow/);}finally{close();}});
test('game unlock consumes a pass; all five games render; memory and tic-tac-toe work',async()=>{const {w,doc,close}=await boot({profile,passes:1,points:240});try{w.location.hash='/play';await tick();doc.querySelector('[data-action="unlock:memory:pass"]').click();await tick();assert.equal(doc.querySelectorAll('[data-card]').length,12);let saved=active(w);assert.equal(saved.passes,0);assert(saved.unlocks.memory>Date.now());const unlocks=Object.fromEntries(['bubbles','snake','blocks','tictactoe','memory'].map(id=>[id,Date.now()+100000]));saved.unlocks=unlocks;close();const second=await boot(saved);try{for(const id of Object.keys(unlocks)){second.w.location.hash='/game/'+id;await tick();assert.match(second.doc.body.textContent,/Back To Play Zone/);assert(!second.doc.querySelector('.notice'));}second.w.location.hash='/game/tictactoe';await tick();second.doc.querySelector('[data-mode="friends"]').click();for(const i of [0,3,1,4,2])second.doc.querySelector(`[data-cell="${i}"]`).click();assert.match(second.doc.querySelector('#game-status').textContent,/wins/);}finally{second.close();}}finally{close();}});
test('hash navigation works under GitHub Pages repository path',async()=>{const {w,doc,close}=await boot({profile});try{w.history.replaceState({},'','/kids-story-quiz/#/story/ocean_01');w.dispatchEvent(new w.HashChangeEvent('hashchange'));assert.match(doc.body.textContent,/Whaley/);assert([...doc.querySelectorAll('img')].every(i=>i.getAttribute('src').startsWith('./assets/')));}finally{close();}});
test('mixed topic quiz validates selection and assembles ten questions',async()=>{const {w,doc,close}=await boot({profile});try{w.location.hash='/mix';await tick();assert.equal(doc.querySelectorAll('[name="topic"]').length,10);doc.querySelector('form').dispatchEvent(new w.Event('submit',{cancelable:true}));assert.match(doc.querySelector('#mix-error').textContent,/at least one/);doc.querySelector('[name="topic"]').checked=true;doc.querySelector('form').dispatchEvent(new w.Event('submit',{cancelable:true}));await tick();assert.equal(w.location.hash,'#/quiz/category_mix');assert.equal(doc.querySelectorAll('.quiz-progress span').length,10);assert(doc.querySelector('[data-option]'));}finally{close();}});

test('profiles: new explorer, sign out, returning match, and not-found guidance',async()=>{const {w,doc,close}=await boot();try{
spell(doc,'MIA');pickAge(doc,7);assert.equal(doc.querySelector('#age-value').textContent,'7');doc.querySelector('#start').click();
assert.match(doc.querySelector('.modal').textContent,/Hi, Mia/);assert.match(doc.querySelector('.modal').textContent,/Mia.*age 7/);clickModal(doc,'I’m New');await tick();
assert.match(doc.body.textContent,/Hello, Mia/);assert.equal(stored(w).active,'mia7');
const store=stored(w);store.profiles.mia7.points=50;close();
const second=await boot(store);try{const {doc:d}=second;
assert.match(d.body.textContent,/Hello, Mia/,'stays signed in after reload');
second.w.location.hash='/achievements';await tick();d.querySelector('[data-action="signout"]').click();
assert.deepEqual(modalButtons(d).map(b=>b.textContent),['Keep Exploring','See You Soon! 👋']);clickModal(d,'Keep Exploring');assert.match(d.body.textContent,/My Little Victories/,'cancel keeps the explorer signed in');
d.querySelector('[data-action="signout"]').click();clickModal(d,'See You Soon');await tick();
assert.match(d.body.textContent,/Meet Our Explorer/);assert.equal(stored(second.w).active,null);assert.equal(stored(second.w).profiles.mia7.points,50,'progress is kept after sign out');
spell(d,'MIA');pickAge(d,8);d.querySelector('#start').click();clickModal(d,'Played Before');
assert.match(d.querySelector('.modal').textContent,/how you spelled/);clickModal(d,'Try Again');assert(!d.querySelector('.modal'));assert.match(d.querySelector('#name-preview').textContent,/MIA/,'name is kept for another try');assert.equal(Object.keys(stored(second.w).profiles).length,1,'no profile created');
pickAge(d,7);d.querySelector('#start').click();assert.match(d.querySelector('.modal').textContent,/Welcome Back, Mia.*50 points/);clickModal(d,'Go');
assert.match(d.body.textContent,/Hello, Mia/);assert.match(d.querySelector('.stat strong').textContent,/50/);
second.w.location.hash='/achievements';await tick();d.querySelector('[data-action="signout"]').click();clickModal(d,'See You Soon');await tick();
spell(d,'LEO');d.querySelector('#start').click();clickModal(d,'I’m New');await tick();assert.equal(d.querySelector('.stat strong').textContent,'0','a new explorer starts fresh');
}finally{second.close();}}finally{close();}});
test('name keyboard limits, undo, space, clear and age wheel keys',async()=>{const {w,doc,close}=await boot();try{
spell(doc,'ABCDEFGHI');assert.match(doc.querySelector('#name-preview .sr-only').textContent,/ABCDEFG$/);
doc.querySelector('[data-key="undo"]').click();doc.querySelector('[data-key="space"]').click();doc.querySelector('[data-key="space"]').click();assert.match(doc.querySelector('.sr-only').textContent,/ABCDEF $/);
doc.querySelector('[data-key="clear"]').click();assert.match(doc.querySelector('#name-preview').textContent,/Tap colorful letters/);assert(doc.querySelector('#start').disabled);
const wheel=doc.querySelector('#wheel');wheel.dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowDown',bubbles:true}));assert.equal(wheel.getAttribute('aria-valuenow'),'6');wheel.dispatchEvent(new w.KeyboardEvent('keydown',{key:'End',bubbles:true}));assert.equal(doc.querySelector('#age-value').textContent,'14');wheel.dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowDown',bubbles:true}));assert.equal(doc.querySelector('#age-value').textContent,'14');
w.dispatchEvent(new w.KeyboardEvent('keydown',{key:'z'}));assert.match(doc.querySelector('.sr-only').textContent,/Z$/,'physical keyboard types too');
}finally{close();}});
test('legacy single-profile save is migrated',async()=>{const {w,doc,close}=await boot({profile:{name:'Ava',age:6},points:340,badges:{ocean_01:1}});try{assert.match(doc.body.textContent,/Hello, Ava/);assert.equal(stored(w).active,'ava6');assert.equal(active(w).points,340);}finally{close();}});

const at=(w,hash)=>{w.location.hash=hash;return tick();};
const answer=async(w,doc,q)=>{[...doc.querySelectorAll('[data-option]')].find(b=>b.querySelector('span').textContent===q.correct_answer).click();doc.querySelector('[data-action="check"]').click();await new Promise(r=>setTimeout(r,1020));};
test('reset progress asks first, then clears progress but keeps the explorer',async()=>{const {w,doc,close}=await boot({profile,points:240,passes:2,badges:{ocean_01:1},reading:{ocean_01:{page:3,at:1}}});try{
await at(w,'/achievements');doc.querySelector('[data-action="reset"]').click();assert.match(doc.querySelector('.modal').textContent,/240 points, 1 badge/);assert.equal(doc.activeElement.textContent,'Keep My Progress','cancel is focused');
clickModal(doc,'Keep My Progress');assert.equal(active(w).points,240);
doc.querySelector('[data-action="reset"]').click();clickModal(doc,'Yes, Start Over');
const p=active(w);assert.equal(p.points,0);assert.equal(p.passes,0);assert.deepEqual(p.badges,{});assert.deepEqual(p.reading,{});assert.equal(p.profile.name,'Tester');assert.equal(stored(w).active,'tester7');assert.match(doc.querySelector('.modal').textContent,/Fresh Start/);
}finally{close();}});
test('backup code moves progress to a new device, rejects bad codes, and asks before replacing',async()=>{const first=await boot({profile:{name:'Ava',age:6},points:340,badges:{ocean_01:2},stats:{ocean_01:{attempts:3,best:10}}});let code;try{
await at(first.w,'/achievements');first.doc.querySelector('[data-action="backup"]').click();code=first.doc.querySelector('textarea.code').value;assert.match(code,/^STORYSPARK-[\w-]+$/);}finally{first.close();}
const {w,doc,close}=await boot();try{
doc.querySelector('#restore').click();assert.equal(doc.activeElement.id,'backup-code');doc.querySelector('#backup-code').value='hello';clickModal(doc,'Bring Back');assert.match(doc.querySelector('#backup-error').textContent,/doesn’t work/);
doc.querySelector('#backup-code').value=code.slice(0,20)+'\n'+code.slice(20);clickModal(doc,'Bring Back');await tick();
assert.match(doc.querySelector('.modal').textContent,/Welcome Back, Ava.*340 points and 2 badges/);clickModal(doc,'Go');assert.match(doc.body.textContent,/Hello, Ava/);assert.equal(active(w).stats.ocean_01.best,10);assert.equal(stored(w).active,'ava6');
active(w);await at(w,'/achievements');doc.querySelector('[data-action="signout"]').click();clickModal(doc,'See You Soon');await tick();
doc.querySelector('#restore').click();doc.querySelector('#backup-code').value=code;clickModal(doc,'Bring Back');assert.match(doc.querySelector('.modal').textContent,/already has progress/);clickModal(doc,'Keep What’s Here');assert.match(doc.body.textContent,/Meet Our Explorer/);
}finally{close();}});
test('damaged saved data is cleaned up instead of breaking the app',async()=>{const {w,doc,close}=await boot({version:2,active:'ava6',profiles:{ava6:{profile:{name:'Ava',age:6},points:'lots',passes:-3,badges:{ocean_01:'x',ocean_02:2},stats:{ocean_01:'bad'},reading:{ocean_01:{page:'2'}},unlocks:null,activeQuiz:{story_id:'ocean_01',questions:[{nope:1}]}},broken:{profile:{name:'',age:99}},junk:'text'}});try{
assert.match(doc.body.textContent,/Hello, Ava/);const p=active(w);assert.equal(p.points,0);assert.equal(p.passes,0);assert.deepEqual(p.badges,{ocean_01:0,ocean_02:2});assert.deepEqual(p.stats,{});assert.equal(p.reading.ocean_01.page,2);assert.equal(p.activeQuiz,null);assert.deepEqual(Object.keys(stored(w).profiles),['ava6']);
}finally{close();}});
test('another tab’s save is picked up without switching this tab’s explorer',async()=>{const {w,doc,close}=await boot({profile});try{
const other=stored(w);other.profiles.tester7.points=777;other.profiles.leo5={...other.profiles.tester7,profile:{name:'Leo',age:5},points:5};other.active='leo5';
w.dispatchEvent(new w.StorageEvent('storage',{key:'storyspark.web.v2',newValue:JSON.stringify(other)}));
assert.match(doc.body.textContent,/Hello, Tester/);assert.equal(doc.querySelector('.stat strong').textContent,'777');
await at(w,'/achievements');doc.querySelector('[data-action="reset"]').click();clickModal(doc,'Yes, Start Over');assert.equal(stored(w).profiles.leo5.points,5,'other explorer is not overwritten');
}finally{close();}});
test('a quiz in progress survives a refresh and ends when you leave',async()=>{const questions=content[0].stories[0].quiz;const first=await boot({profile});let saved;try{
await at(first.w,'/quiz/ocean_01');await answer(first.w,first.doc,questions[0]);clickModal(first.doc,'Next');await answer(first.w,first.doc,questions[1]);saved=stored(first.w);}finally{first.close();}
assert.equal(saved.profiles.tester7.activeQuiz.index,1);assert.equal(saved.profiles.tester7.activeQuiz.checked,true);
const {w,doc,close}=await boot(saved,'#/quiz/ocean_01');try{
assert.equal(doc.querySelectorAll('.quiz-progress .done').length,2);await tick();assert.match(doc.querySelector('.modal').textContent,/Got It/,'feedback for the checked answer shows again');clickModal(doc,'Next');assert.equal(doc.querySelectorAll('.quiz-progress .done').length,3);assert.equal(active(w).activeQuiz.correct,2);
await at(w,'/explore');assert.equal(active(w).activeQuiz,null);await at(w,'/quiz/ocean_01');assert.equal(doc.querySelectorAll('.quiz-progress .done').length,1,'leaving starts the quiz over');
await at(w,'/quiz/category_mix');assert.equal(w.location.hash,'#/mix','no mixed quiz to resume');
}finally{close();}});
test('finished stories offer Read Again and leave Keep The Story Going',async()=>{const {w,doc,close}=await boot({profile,reading:{ocean_01:{page:10,at:2},ocean_02:{page:3,at:1}}});try{
const cards=[...doc.querySelectorAll('section .stack .story')];assert.equal(cards.length,1);assert.equal(cards[0].getAttribute('href'),'#/read/ocean_02/3');
await at(w,'/story/ocean_01');const read=[...doc.querySelectorAll('a.cta')].find(a=>/Read Again/.test(a.textContent));assert.equal(read.getAttribute('href'),'#/read/ocean_01/0');
}finally{close();}});
test('snake pause is only available once the game starts',async()=>{const {w,doc,close}=await boot({profile,unlocks:{snake:Date.now()+1e6}});try{
await at(w,'/game/snake');const pause=()=>doc.querySelector('[data-action="pause"]');assert(pause().disabled);doc.querySelector('[data-dir="-12"]').click();assert(!pause().disabled);pause().click();assert.equal(pause().textContent,'Resume');doc.querySelector('[data-dir="1"]').click();assert.equal(pause().textContent,'Pause','steering resumes');
}finally{close();}});
test('explore keeps the search text when coming back',async()=>{const {w,doc,close}=await boot({profile});try{
await at(w,'/explore');const search=doc.querySelector('#search');search.value='Whaley';search.dispatchEvent(new w.Event('input'));await at(w,'/story/ocean_01');await at(w,'/explore');assert.equal(doc.querySelector('#search').value,'Whaley');assert.equal(doc.querySelectorAll('.story').length,1);
}finally{close();}});

test('every link on the main screens leads to a real page',async()=>{const {w,doc,close}=await boot({profile,reading:{ocean_02:{page:3,at:1}}});try{
const id="[a-z_]+_\\d+";const valid=new RegExp(`^#/(journey|explore(/[a-z_]+)?|play|achievements|mix|story/${id}|read/${id}/\\d+|quiz/${id}|game/[a-z]+)$`);
for(const hash of ['/journey','/explore','/explore/ocean','/achievements','/play','/story/ocean_01','/read/ocean_01/0']){await at(w,hash);const links=[...doc.querySelectorAll('a[href]')].map(a=>a.getAttribute('href'));assert(links.length,hash);for(const href of links)assert.match(href,valid,`${hash} links to ${href}`);}
await at(w,'/explore');doc.querySelector('.story').click();await tick();assert.equal(w.location.hash,'#/story/ocean_01');assert.match(doc.body.textContent,/Continue Reading/);
}finally{close();}});

test('leaving a quiz after answering asks first',async()=>{const questions=content[0].stories[0].quiz;const {w,doc,close}=await boot({profile});try{
await at(w,'/quiz/ocean_01');doc.querySelector('.back').click();await tick();assert.equal(w.location.hash,'#/story/ocean_01','no answers yet, so no question');
await at(w,'/quiz/ocean_01');await answer(w,doc,questions[0]);clickModal(doc,'Next');doc.querySelector('.nav a[href="#/play"]').click();
assert.match(doc.querySelector('.modal').textContent,/answered 1 of 10/);clickModal(doc,'Keep Going');await tick();assert.equal(w.location.hash,'#/quiz/ocean_01');assert.equal(doc.querySelectorAll('.quiz-progress .done').length,2);
doc.querySelector('.back').click();clickModal(doc,'Leave Quiz');await tick();assert.equal(w.location.hash,'#/story/ocean_01');
}finally{close();}});
test('play zone shows time left and best scores; games record new bests',async()=>{const {w,doc,close}=await boot({profile,unlocks:{memory:Date.now()+(5*60+12)*60000-30000},best:{bubbles:90}});try{
await at(w,'/play');assert.match(doc.body.textContent,/Unlocked · 5h 12m left/);assert.match(doc.body.textContent,/Best score: 90/);
await at(w,'/game/memory');const tiles=[...doc.querySelectorAll('[data-card]')];const faces={};
for(const t of tiles){t.click();const i=Number(t.dataset.card);faces[i]=doc.querySelector(`[data-card="${i}"]`).getAttribute('aria-label');await new Promise(r=>setTimeout(r,900));}
const byFace={};Object.entries(faces).forEach(([i,f])=>(byFace[f]??=[]).push(Number(i)));
for(const [a,b] of Object.values(byFace)){if(doc.querySelector(`[data-card="${a}"]`).disabled)continue;doc.querySelector(`[data-card="${a}"]`).click();doc.querySelector(`[data-card="${b}"]`).click();}
assert.match(doc.querySelector('#game-status').textContent,/new best/);const best=active(w).best.memory;assert(best>=6&&best<=12);
await at(w,'/play');assert.match(doc.body.textContent,new RegExp(`Fewest turns: ${best}`));
}finally{close();}});
test('tic-tac-toe robot answers, blocks when clever, and modes switch',async()=>{const {w,doc,close}=await boot({profile,unlocks:{tictactoe:Date.now()+1e6}});try{
await at(w,'/game/tictactoe');assert.equal(doc.querySelector('[data-mode].active').dataset.mode,'easy');doc.querySelector('[data-cell="4"]').click();assert.match(doc.querySelector('#game-status').textContent,/thinking/);assert(doc.querySelector('[data-cell="0"]').disabled||doc.querySelector('[data-cell="0"]').textContent,'board waits for the robot');
await new Promise(r=>setTimeout(r,600));assert.equal([...doc.querySelectorAll('[data-cell]')].filter(b=>b.textContent==='○').length,1);
doc.querySelector('[data-mode="clever"]').click();assert.equal(doc.querySelector('[data-mode].active').dataset.mode,'clever');
doc.querySelector('[data-cell="0"]').click();await new Promise(r=>setTimeout(r,600));assert.equal(doc.querySelector('[data-cell="4"]').textContent,'○','clever robot takes the centre');
const next=[1,3].find(i=>!doc.querySelector(`[data-cell="${i}"]`).textContent);doc.querySelector(`[data-cell="${next}"]`).click();await new Promise(r=>setTimeout(r,600));
assert.equal(doc.querySelector(`[data-cell="${next===1?2:6}"]`).textContent,'○','clever robot blocks the row');
}finally{close();}});
test('read aloud speaks the page, highlights words, pauses and stops on leaving',async()=>{const log=[];let current;const setup=w=>{w.SpeechSynthesisUtterance=class{constructor(text){this.text=text;}};w.speechSynthesis={getVoices:()=>[{lang:'en-US',localService:true,name:'Test'}],speak:u=>{current=u;log.push('speak:'+u.text.slice(0,10));},pause:()=>log.push('pause'),resume:()=>log.push('resume'),cancel:()=>log.push('cancel')};};
const {w,doc,close}=await boot({profile},'#/read/ocean_01/2',setup);try{
const btn=()=>doc.querySelector('#read-aloud');assert.equal(btn().textContent,'🔊 Read To Me');btn().click();assert.equal(current.rate,.85);assert.equal(current.voice.name,'Test');assert.equal(btn().textContent,'⏸ Pause');
const second=doc.querySelectorAll('#reading [data-at]')[1];current.onboundary({name:'word',charIndex:Number(second.dataset.at)});assert(second.classList.contains('spoken'));assert.equal(doc.querySelectorAll('.spoken').length,1);
btn().click();assert.equal(btn().textContent,'▶ Keep Reading');btn().click();assert.equal(btn().textContent,'⏸ Pause');current.onend();assert.equal(doc.querySelectorAll('.spoken').length,0);assert.equal(btn().textContent,'🔊 Read To Me');
log.length=0;await at(w,'/read/ocean_01/3');assert(log.includes('cancel'),'speech stops when the page changes');
}finally{close();}});
test('read aloud is hidden when the browser has no speech',async()=>{const {w,doc,close}=await boot({profile},'#/read/ocean_01/0');try{assert(!doc.querySelector('#read-aloud'));}finally{close();}});
test('offline cache lists only files that exist',async()=>{const sw=await readFile('sw.js','utf8');const shell=JSON.parse(sw.match(/const SHELL=(\[.*?\]);/)[1].replace(/'/g,'"'));for(const path of shell.filter(p=>p!=='./')){const local=['./index.html','./app.js','./styles.css'].includes(path)?path:'public/'+path.slice(2);assert((await stat(local)).size>0,path);}});
test('every story has its own cover and page images, with no repeated text or questions',async()=>{
const art=['Ocean','Animals','Space','Science','Math','Culture','Emotions','History','Geography','Technology'];const missing=[],pages=new Map(),questions=new Map();
content.forEach((cat,ci)=>cat.stories.forEach((s,i)=>{const cover=`StoryCover${art[ci]}${String(i+1).padStart(2,'0')}`;if(!assets[cover])missing.push(cover);
s.pages.forEach((p,pi)=>{const key=`StoryPage_${s.story_id}_${String(pi+1).padStart(2,'0')}`;if(!assets[key])missing.push(key);const t=p.text.toLowerCase().trim();assert(!pages.has(t),`${s.story_id} p${pi+1} repeats ${pages.get(t)}`);pages.set(t,`${s.story_id} p${pi+1}`);});
s.quiz.forEach((q,qi)=>{const t=q.question.toLowerCase().trim();assert(!questions.has(t),`${s.story_id} Q${qi+1} repeats ${questions.get(t)}`);questions.set(t,`${s.story_id} Q${qi+1}`);});}));
assert.deepEqual(missing,[],'every cover and page has its own image');});
test('home card features a topic and opens Explore with it selected',async()=>{const {w,doc,close}=await boot({profile});try{
const hero=doc.querySelector('a.hero');const id=hero.getAttribute('href').replace('#/explore/','');const cat=content.find(c=>c.category_id===id);assert(cat,'links to a real topic');assert.match(hero.textContent,new RegExp(cat.category_name.replace('&','&')));
await at(w,'/explore');await at(w,'/journey');assert.equal(doc.querySelector('a.hero').getAttribute('href'),'#/explore/'+id,'same topic while the app is open');
hero.ownerDocument.querySelector('a.hero').click();await tick();assert.equal(w.location.hash,'#/explore/'+id);assert.match(doc.querySelector('.chip.active').textContent,new RegExp(cat.category_name));assert.equal(doc.querySelectorAll('.story').length,cat.stories.length);
}finally{close();}});
test('every story page shows its teaser',async()=>{for(const s of content.flatMap(c=>c.stories))assert(s.teaser&&s.teaser.split(/\s+/).length<=45,`${s.story_id} needs a short teaser`);
const {w,doc,close}=await boot({profile});try{await at(w,'/story/animals_01');assert.equal(doc.querySelector('.teaser-text').textContent,content[1].stories[0].teaser);assert(!doc.querySelector('.objectives'));}finally{close();}});
test('story images are 3:2 landscape',async()=>{const bad=[];for(const [key,path] of Object.entries(assets).filter(([k])=>/^Story/.test(k))){const b=await readFile('public/'+path);let w,h;if(b[0]===0x89){w=b.readUInt32BE(16);h=b.readUInt32BE(20);}else{let i=2;while(i<b.length){const m=b[i+1],len=b.readUInt16BE(i+2);if(m>=0xc0&&m<=0xc3){h=b.readUInt16BE(i+5);w=b.readUInt16BE(i+7);break;}i+=2+len;}}if(Math.abs(w/h-1.5)>0.01)bad.push(`${key} ${w}x${h}`);}assert.deepEqual(bad,[]);});
