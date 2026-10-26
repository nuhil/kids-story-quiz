// Generates "Read To Me" narration with ElevenLabs: one MP3 per story page plus per-story word timings.
// Usage: node scripts/narrate.mjs [story_id ...]   (key read from ~/.config/storyspark/elevenlabs.key)
// Pages whose audio and timings already match the current text are skipped, so the script can be re-run safely.
import {readFile,writeFile,mkdir,access} from 'node:fs/promises';
import {homedir} from 'node:os';

const VOICE='XdnWynrJMN4Iu03ENx3E'; // Leela, "calm" bedtime settings
const MODEL='eleven_multilingual_v2';
const SETTINGS={stability:0.7,similarity_boost:0.75,style:0.15,speed:0.85};
const FORMAT='mp3_22050_32';
const CONCURRENCY=2;

const key=(await readFile(homedir()+'/.config/storyspark/elevenlabs.key','utf8')).trim();
const content=JSON.parse(await readFile('public/content.json','utf8'));
const only=new Set(process.argv.slice(2));
const stories=content.flatMap(c=>c.stories).filter(s=>!only.size||only.has(s.story_id));
const exists=path=>access(path).then(()=>true,()=>false);

// Word timings follow the app's word split (runs of non-space characters, in order).
function wordTimes(text,alignment){
  const starts=alignment.character_start_times_seconds,ends=alignment.character_end_times_seconds,times=[];
  for(const m of text.matchAll(/\S+/g)){const a=m.index,b=m.index+m[0].length-1;times.push([+starts[a].toFixed(2),+ends[Math.min(b,ends.length-1)].toFixed(2)]);}
  return times;
}

async function narrate(text){
  for(let attempt=1;;attempt++){
    const r=await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE}/with-timestamps?output_format=${FORMAT}`,{method:'POST',headers:{'xi-api-key':key,'Content-Type':'application/json'},body:JSON.stringify({text,model_id:MODEL,voice_settings:SETTINGS})});
    if(r.ok){const d=await r.json();if(d.alignment?.characters?.join('')!==text)throw Error('alignment does not match the page text');return d;}
    const body=await r.text();
    // Out of credits or a bad key will not fix itself: stop the whole run.
    if(r.status===401||/quota|credit|insufficient/i.test(body)){console.log(`STOP: HTTP ${r.status} ${body.slice(0,200)}`);process.exit(2);}
    if(attempt>=4)throw Error(`HTTP ${r.status} ${body.slice(0,200)}`);
    await new Promise(res=>setTimeout(res,attempt*4000));
  }
}

let done=0,skipped=0,chars=0;
const total=stories.reduce((n,s)=>n+s.pages.length,0);
async function story(s){
  const timingPath=`public/audio/${s.story_id}.json`;
  const old=await exists(timingPath)?JSON.parse(await readFile(timingPath,'utf8')):{pages:[]};
  const pages=[];
  await mkdir(`public/audio/${s.story_id}`,{recursive:true});
  for(const [i,p] of s.pages.entries()){
    const mp3=`public/audio/${s.story_id}/${String(i+1).padStart(2,'0')}.mp3`;
    if(old.pages[i]?.text===p.text&&await exists(mp3)){pages.push(old.pages[i]);skipped++;continue;}
    const d=await narrate(p.text);
    await writeFile(mp3,Buffer.from(d.audio_base64,'base64'));
    pages.push({text:p.text,words:wordTimes(p.text,d.alignment)});
    done++;chars+=p.text.length;
    if(done%25===0)console.log(`progress ${done+skipped}/${total} pages, ${chars} characters used this run`);
  }
  await writeFile(timingPath,JSON.stringify({voice:'Leela',pages}));
  console.log(`story ${s.story_id} ok (${s.pages.length} pages)`);
}

const queue=[...stories];
await Promise.all(Array.from({length:CONCURRENCY},async()=>{while(queue.length)await story(queue.shift());}));
console.log(`ALL DONE: ${done} generated, ${skipped} already up to date, ${chars} characters used`);
