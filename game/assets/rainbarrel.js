/* v2.0.71: Rain Barrel. The server deals the tiles (masks N=1 E=2 S=4 W=8) and checks the hand-in; this file draws, turns and shows the water.
   No inline styles (CSP): tiles are SVG built here, colours come from CSS classes in puzzles.css. */
(function(){
'use strict';
var D; try{ D=JSON.parse(document.getElementById('rb-data').textContent); }catch(e){ return; }
var $=function(id){ return document.getElementById(id); };
var NS='http://www.w3.org/2000/svg';
var DIRS=[[1,4,0,-1],[2,8,1,0],[4,1,0,1],[8,2,-1,0]];
var G=null;   // {token,n,tiles[],r[],src,t0,hints,timer,over}
function rot(m,t){ for(var k=0;k<(t&3);k++) m=((m<<1)|(m>>3))&15; return m; }
function cur(i){ return rot(G.tiles[i],G.r[i]); }
function post(fields,cb){
  var q='csrf='+encodeURIComponent(D.csrf), k;
  for(k in fields) q+='&'+k+'='+encodeURIComponent(fields[k]);
  fetch(D.api,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:q})
    .then(function(r){ return r.json(); }).then(cb).catch(function(){ cb({ok:false,error:'Couldn’t reach the garden. Try again.'}); });
}
function say(t){ $('rbmsg').textContent=t||''; }
function wet(){   // flood from the barrel through mutually open sides
  var n=G.n, seen={}, st=[G.src]; seen[G.src]=true;
  while(st.length){
    var c=st.pop(), m=cur(c), x=c%n, y=(c-x)/n;
    for(var d=0;d<4;d++){
      if(!(m&DIRS[d][0])) continue;
      var nx=x+DIRS[d][2], ny=y+DIRS[d][3]; if(nx<0||ny<0||nx>=n||ny>=n) continue;
      var j=ny*n+nx; if(seen[j]||!(cur(j)&DIRS[d][1])) continue;
      seen[j]=true; st.push(j);
    }
  }
  return seen;
}
function valid(){
  var n=G.n, N=n*n, i, d;
  for(i=0;i<N;i++){
    var m=cur(i), x=i%n, y=(i-x)/n;
    for(d=0;d<4;d++){
      if(!(m&DIRS[d][0])) continue;
      var nx=x+DIRS[d][2], ny=y+DIRS[d][3];
      if(nx<0||ny<0||nx>=n||ny>=n||!(cur(ny*n+nx)&DIRS[d][1])) return false;
    }
  }
  var s=wet(), c=0, k; for(k in s) c++;
  return c===N;
}
var LINES=[[5,5,5,0],[5,5,10,5],[5,5,5,10],[5,5,0,5]];
function el(tag,attrs){ var e=document.createElementNS(NS,tag); for(var k in attrs) e.setAttribute(k,attrs[k]); return e; }
function paint(i,btn,isWet){
  var m=cur(i), svg=btn.firstChild;
  while(svg.firstChild) svg.removeChild(svg.firstChild);
  svg.appendChild(el('rect',{x:0,y:0,width:10,height:10,'class':'rbbg'}));
  for(var d=0;d<4;d++) if(m&DIRS[d][0]) svg.appendChild(el('line',{x1:LINES[d][0],y1:LINES[d][1],x2:LINES[d][2],y2:LINES[d][3],'class':'rbpipe'+(isWet?' wet':'')}));
  svg.appendChild(el('circle',{cx:5,cy:5,r:1.5,'class':'rbhub'+(isWet?' wet':'')}));
  if(i===G.src){ svg.appendChild(el('rect',{x:2.2,y:2.2,width:5.6,height:5.6,rx:1,'class':'rbbarrel'})); svg.appendChild(el('line',{x1:2.4,y1:4,x2:7.6,y2:4,'class':'rbhoop'})); svg.appendChild(el('line',{x1:2.4,y1:6,x2:7.6,y2:6,'class':'rbhoop'})); }
  else if([1,2,4,8].indexOf(m)>=0){ svg.appendChild(el('circle',{cx:5,cy:5,r:2.2,'class':'rbsprout'+(isWet?' wet':'')})); svg.appendChild(el('path',{d:'M5 6 L5 3.6 M5 4.6 L3.9 3.7 M5 4.4 L6.2 3.5','class':'rbleaf'})); }
}
function repaint(){
  var w=wet(), kids=$('rbgrid').children;
  for(var i=0;i<kids.length;i++) paint(i,kids[i],!!w[i]);
}
function build(){
  var g=$('rbgrid'), n=G.n; g.textContent='';
  g.className='rbn'+n;
  for(var i=0;i<n*n;i++) (function(i){
    var b=document.createElement('button'); b.type='button'; b.className='rbcell';
    b.setAttribute('aria-label','Gutter '+(Math.floor(i/n)+1)+','+(i%n+1)+': turn');
    var svg=document.createElementNS(NS,'svg'); svg.setAttribute('viewBox','0 0 10 10'); svg.setAttribute('aria-hidden','true'); b.appendChild(svg);
    b.addEventListener('click',function(){ if(G.over) return; G.r[i]=(G.r[i]+1)&3; repaint(); if(valid()) finish(); });
    g.appendChild(b);
  })(i);
  repaint();
}
function clock(){
  if(!G||G.over) return;
  var s=Math.floor((Date.now()-G.t0)/1000)+G.hints*D.hintMs/1000;
  $('rbclock').textContent=Math.floor(s/60)+':'+('0'+(s%60)).slice(-2);
}
function start(mode,size){
  say('Tipping the barrel…');
  post({g:'barrel','do':'start',mode:mode,size:size},function(r){
    if(!r.ok){ say(r.error||'Couldn’t start.'); return; }
    if(G&&G.timer) clearInterval(G.timer);
    G={token:r.token,n:r.n,tiles:r.tiles,r:r.tiles.map(function(){return 0;}),src:r.src,t0:Date.now(),hints:0,over:false,mode:r.mode};
    $('rbwin').hidden=true; $('rbplay').hidden=false; $('rbhints').textContent=''; $('rbhint').disabled=false;
    say(mode==='daily'?'Today’s barrel. Good luck!':'Practice. No pressure.');
    build(); G.timer=setInterval(clock,500); clock();
    $('rbplay').scrollIntoView({block:'nearest'});
  });
}
function finish(){
  if(G.over) return; G.over=true; clearInterval(G.timer);
  say('Counting the drops…');
  post({g:'barrel','do':'finish',token:G.token,r:JSON.stringify(G.r)},function(r){
    if(!r.ok){
      if(r.retry){ G.over=false; G.timer=setInterval(clock,500); say(r.error); return; }
      say(r.error||'That didn’t count.'); return;
    }
    say(''); $('rbwintx').textContent=r.message; $('rbwin').hidden=false;
    $('rbstat').textContent='Done ✓ '+(r.best?'best today '+Math.floor(r.best/60000)+':'+('0'+Math.floor(r.best/1000)%60).slice(-2)+'.':'')+' Reload for the board.';
    $('rbwin').scrollIntoView({block:'nearest'});
  });
}
$('rbdaily').addEventListener('click',function(){ start('daily',6); });
$('rbprac').addEventListener('click',function(){ start('practice',parseInt($('rbsize').value,10)||6); });
$('rbhint').addEventListener('click',function(){
  if(!G||G.over) return;
  post({g:'barrel','do':'hint',token:G.token,r:JSON.stringify(G.r)},function(r){
    if(!r.ok){ say(r.error||'No hint right now.'); return; }
    G.r[r.cell]=r.r; G.hints=r.hints; $('rbhints').textContent='Hints '+r.hints+'/'+D.maxHints; say('The Old Wizard turned a tile.');
    if(r.hints>=D.maxHints) $('rbhint').disabled=true;
    repaint(); clock(); if(valid()) finish();
  });
});
})();
