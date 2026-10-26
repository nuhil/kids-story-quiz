import { cp, mkdir, rm } from 'node:fs/promises';
await rm('dist',{recursive:true,force:true}); await mkdir('dist');
await cp('public','dist',{recursive:true});
for(const file of ['index.html','app.js','styles.css']) await cp(file,`dist/${file}`);
console.log('Static site built in dist/');
