/* v2.0.72: Gnome Beds. The server deals the bed layout (one bed index per cell) and checks the hand-in; this file draws the garden, cycles
   empty -> mark -> gnome, shows broken rules and sends the columns. No inline styles (CSP): colours are CSS classes in puzzles.css. */
(function(){
'use strict';
var D; try{ D=JSON.parse(document.getElementById('rb-data').textContent); }catch(e){ return; }
var $=function(id){ return document.getElementById(id); };
var NS='http://www.w3.org/2000/svg';
var MARKS=['●','▲','■','◆','★','♣','♠','♥','✚'];
var G=null;   // {token,n,reg[],st[] (0 empty,1 mark,2 gnome),t0,hints,timer,over}
function post(fields,cb){
  var q='csrf='+encodeURIComponent(D.csrf), k;
  for(k in fields) q+='&'+k+'='+encodeURIComponent(fields[k]);
  fetch(D.api,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:q})
    .then(function(r){ return r.json(); }).then(cb).catch(function(){ cb({ok:false,error:'Couldn’t reach the garden. Try again.'}); });
}
function say(t,err){ $('rbmsg').textContent=t||''; var o=$('rboops'); if(o) o.hidden=!(err&&t); }   // v2.0.74: Jeff looks sheepish next to an error
function gnomes(){ var a=[],i; for(i=0;i<G.st.length;i++) if(G.st[i]===2) a.push(i); return a; }
function bad(){   // cells that break a rule: same row, column or bed as another gnome, or touching one
  var n=G.n, gs=gnomes(), out={}, i, j;
  for(i=0;i<gs.length;i++) for(j=i+1;j<gs.length;j++){
    var a=gs[i], b=gs[j], ax=a%n, ay=(a-ax)/n, bx=b%n, by=(b-bx)/n;
    if(ax===bx||ay===by||G.reg[a]===G.reg[b]||(Math.abs(ax-bx)<=1&&Math.abs(ay-by)<=1)){ out[a]=true; out[b]=true; }
  }
  return out;
}
function cols(){ var n=G.n, g=[], r, c; for(r=0;r<n;r++){ g.push(-1); for(c=0;c<n;c++) if(G.st[r*n+c]===2){ g[r]=c; break; } } return g; }
function el(tag,attrs){ var e=document.createElementNS(NS,tag); for(var k in attrs) e.setAttribute(k,attrs[k]); return e; }
function draw(i,btn,isBad){
  var n=G.n, x=i%n, y=(i-x)/n, g=G.reg[i], cl='gbcell gbr'+g;
  if(y===0||G.reg[i-n]!==g) cl+=' bt';
  if(x===n-1||G.reg[i+1]!==g) cl+=' br';
  if(y===n-1||G.reg[i+n]!==g) cl+=' bb';
  if(x===0||G.reg[i-1]!==g) cl+=' bl';
  if(isBad) cl+=' bad';
  btn.className=cl;
  btn.textContent='';
  var tag=document.createElement('i'); tag.className='gbtag'; tag.textContent=MARKS[g%MARKS.length]; tag.setAttribute('aria-hidden','true'); btn.appendChild(tag);
  if(G.st[i]===1){ var m=document.createElement('span'); m.className='gbx'; m.textContent='✕'; m.setAttribute('aria-hidden','true'); btn.appendChild(m); }
  if(G.st[i]===2){
    var s=document.createElementNS(NS,'svg'); s.setAttribute('viewBox','0 0 10 10'); s.setAttribute('class','gbgnome'); s.setAttribute('aria-hidden','true');
    s.appendChild(el('path',{d:'M5 0.8 L8 6 L2 6 Z','class':'gbhat'}));
    s.appendChild(el('circle',{cx:5,cy:6.6,r:1.3,'class':'gbface'}));
    s.appendChild(el('path',{d:'M3.6 7.4 Q5 10 6.4 7.4 Z','class':'gbbeard'}));
    btn.appendChild(s);
  }
  btn.setAttribute('aria-label','Square '+(y+1)+','+(x+1)+', bed '+(g+1)+': '+['empty','marked no gnome','gnome'][G.st[i]]);
}
function repaint(){ var b=bad(), k=$('rbgrid').children, i; for(i=0;i<k.length;i++) draw(i,k[i],!!b[i]); }
function won(){ var gs=gnomes(), b=bad(), k; if(gs.length!==G.n) return false; for(k in b) return false; return true; }
function build(){
  var g=$('rbgrid'), n=G.n; g.textContent=''; g.className='rbn'+n+' gbgrid';
  for(var i=0;i<n*n;i++) (function(i){
    var b=document.createElement('button'); b.type='button';
    b.addEventListener('click',function(){ if(G.over) return; G.st[i]=(G.st[i]+1)%3; repaint(); if(won()) finish(); });
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
  say('Raking the beds…');
  post({g:'beds','do':'start',mode:mode,size:size},function(r){
    if(!r.ok){ say(r.error||'Couldn’t start.',true); return; }
    if(G&&G.timer) clearInterval(G.timer);
    G={token:r.token,n:r.n,reg:r.reg,st:r.reg.map(function(){return 0;}),t0:Date.now(),hints:0,over:false,mode:r.mode};
    $('rbwin').hidden=true; $('rbplay').hidden=false; $('rbhints').textContent=''; $('rbhint').disabled=false;
    say(mode==='daily'?'Today’s garden. Good luck!':'Practice. No pressure.');
    build(); G.timer=setInterval(clock,500); clock();
    $('rbplay').scrollIntoView({block:'nearest'});
  });
}
function finish(){
  if(G.over) return; G.over=true; clearInterval(G.timer);
  say('Counting the gnomes…');
  post({g:'beds','do':'finish',token:G.token,r:JSON.stringify(cols())},function(r){
    if(!r.ok){
      if(r.retry){ G.over=false; G.timer=setInterval(clock,500); say(r.error,true); return; }
      say(r.error||'That didn’t count.',true); return;
    }
    say(''); $('rbwintx').textContent=r.message; $('rbwin').hidden=false;
    $('rbstat').textContent='Done ✓ '+(r.best?'best today '+Math.floor(r.best/60000)+':'+('0'+Math.floor(r.best/1000)%60).slice(-2)+'.':'')+' Reload for the board.';
    $('rbwin').scrollIntoView({block:'nearest'});
  });
}
$('rbdaily').addEventListener('click',function(){ start('daily',8); });
$('rbprac').addEventListener('click',function(){ start('practice',parseInt($('rbsize').value,10)||8); });
$('rbhint').addEventListener('click',function(){
  if(!G||G.over) return;
  post({g:'beds','do':'hint',token:G.token,r:JSON.stringify(cols())},function(r){
    if(!r.ok){ say(r.error||'No hint right now.'); return; }
    var n=G.n, c;
    for(c=0;c<n;c++) if(G.st[r.row*n+c]===2) G.st[r.row*n+c]=0;
    G.st[r.row*n+r.col]=2; G.hints=r.hints; $('rbhints').textContent='Hints '+r.hints+'/'+D.maxHints; say('The Old Wizard planted a gnome.');
    if(r.hints>=D.maxHints) $('rbhint').disabled=true;
    repaint(); clock(); if(won()) finish();
  });
});
})();
