// Generates the Play Zone sound effects with the ElevenLabs Sound Effects API, then trims silence,
// evens out loudness and shrinks them with ffmpeg into public/sfx/<name>.mp3.
// Usage: node scripts/sfx.mjs [name ...]   (key read from ~/.config/storyspark/elevenlabs.key)
import {readFile,writeFile,mkdir,unlink} from 'node:fs/promises';
import {homedir} from 'node:os';
import {execFileSync} from 'node:child_process';

const STYLE='cute, soft, kid-friendly mobile game sound, clean, no music, no voice';
export const SOUNDS={
  start:[1.0,'playful rising whoosh with a bright sparkle, "ready, go!" game start'],
  pop:[0.5,'single cute soap bubble pop, quick and bubbly'],
  oops:[0.6,'gentle cartoon boing for a wrong tap, soft and friendly, not harsh'],
  tick:[0.5,'single soft wooden clock tick'],
  chomp:[0.5,'tiny cartoon creature taking one crunchy bite of a treat, cute munch'],
  bonk:[0.7,'soft cartoon bonk of bumping into a wall, gentle and funny'],
  drop:[0.5,'wooden toy block placed on a stack, short soft knock'],
  perfect:[0.8,'magical bright sparkle chime for a perfect move'],
  tumble:[1.5,'small wooden toy blocks tumbling down, playful'],
  place_x:[0.5,'soft wooden click of placing a game piece on a board'],
  place_o:[0.5,'soft bubbly bloop, slightly higher pitched, placing a game piece'],
  flip:[0.5,'quick light whoosh of flipping a paper card'],
  match:[0.8,'happy two-note ding ding for a correct match'],
  miss:[0.6,'soft low two-note bloop bloop, not quite, gentle'],
  win:[2.0,'short cheerful victory jingle on xylophone and bells, celebration'],
  draw:[1.0,'friendly neutral two-note chime, it is a tie'],
  lose:[1.5,'gentle descending wah wah on a soft toy trombone, playful not sad'],
  edge:[0.5,'soft short wooden tock of a sliding toy block bouncing off a wall, very gentle'],
};

const key=(await readFile(homedir()+'/.config/storyspark/elevenlabs.key','utf8')).trim();
const only=process.argv.slice(2);
await mkdir('public/sfx',{recursive:true});
for(const [name,[seconds,prompt]] of Object.entries(SOUNDS)){
  if(only.length&&!only.includes(name))continue;
  const r=await fetch('https://api.elevenlabs.io/v1/sound-generation?output_format=mp3_44100_128',{method:'POST',headers:{'xi-api-key':key,'Content-Type':'application/json'},body:JSON.stringify({text:`${prompt}. ${STYLE}`,duration_seconds:seconds,prompt_influence:0.6})});
  if(!r.ok){console.log(`${name}: HTTP ${r.status} ${(await r.text()).slice(0,200)}`);if(r.status===401||r.status===429)process.exit(2);continue;}
  const raw=`public/sfx/${name}.raw.mp3`;
  await writeFile(raw,Buffer.from(await r.arrayBuffer()));
  // Trim leading/trailing silence, normalize loudness, fade the tail, mono 64 kbps.
  execFileSync('ffmpeg',['-y','-loglevel','error','-i',raw,'-af',`silenceremove=start_periods=1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:start_threshold=-50dB,areverse,loudnorm=I=-18:TP=-2:LRA=7,afade=t=out:st=${Math.max(0,seconds-0.08)}:d=0.08`,'-ac','1','-ar','44100','-b:a','64k',`public/sfx/${name}.mp3`]);
  await unlink(raw);
  console.log(`${name}: ok`);
}
