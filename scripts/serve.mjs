import http from 'node:http';
import {readFile} from 'node:fs/promises';
import {resolve,extname} from 'node:path';
const root=resolve('.');
const types={'.html':'text/html','.js':'text/javascript','.css':'text/css','.json':'application/json','.jpg':'image/jpeg','.jpeg':'image/jpeg','.png':'image/png','.svg':'image/svg+xml'};
http.createServer(async(req,res)=>{try{let path=decodeURIComponent(new URL(req.url,'http://localhost').pathname); if(path==='/')path='/index.html'; const asset=/^\/(assets\/|stories\/|content.json|assets.json)/.test(path); const file=resolve(root,asset?'public'+path:'.'+path);if(!file.startsWith(root+'/'))throw Error();const data=await readFile(file);res.writeHead(200,{'Content-Type':types[extname(file)]||'application/octet-stream','Cache-Control':'no-cache'});res.end(data);}catch{res.writeHead(404);res.end('Not found');}}).listen(4173,'0.0.0.0',()=>console.log('StorySpark: http://localhost:4173'));
