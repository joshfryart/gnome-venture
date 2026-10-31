(function(){
var PUZZLES = []; try{ PUZZLES = JSON.parse(document.getElementById('pz-data').textContent) || []; }catch(e){}
var TOUR = null; try{ var te=document.getElementById('pz-t'); if(te) TOUR = JSON.parse(te.textContent); }catch(e){}
/* v2.0.87: Jigsaw (jigsaw.php) = still pictures in three fixed tiers: MODE = {tiers:[{k,label,n,cols,rows,icon}], api, csrf, live, bests}. No MODE = GIFsaw as before. */
var MODE = null; try{ var mde=document.getElementById('pz-mode'); if(mde) MODE = JSON.parse(mde.textContent); }catch(e){}
function tierFor(n){ if(MODE) for(var i=0;i<MODE.tiers.length;i++) if(MODE.tiers[i].n===n) return MODE.tiers[i]; return null; }
function pcsText(v){ var n=parseInt(v,10), t=tierFor(n); return t ? t.label+' \u00b7 '+n : n+(window.innerWidth<360?' pcs':' pieces'); }
/* v2.0.68: the scramble (tab sides, jitter, shuffles) comes from a seeded mulberry32: ?seed=N, a tournament's seed, or a fresh random one */
function mulberry32(a){ return function(){ a=(a+0x6D2B79F5)|0; var t=Math.imul(a^(a>>>15),1|a); t=(t+Math.imul(t^(t>>>7),61|t))^t; return ((t^(t>>>14))>>>0)/4294967296; }; }
var URL_SEED=(function(){ var m=/[?&]seed=(\d{1,10})(&|$)/.exec(location.search); return m?(parseInt(m[1],10)>>>0):null; })();
var rand=mulberry32((Math.random()*4294967296)>>>0);
function reseed(s){ rand=mulberry32(s>>>0); }
var $ = function(id){ return document.getElementById(id); };
var stage=$('stage'), field=$('field'), board=$('board'), ghost=$('ghost'), finalImg=$('final');
var hud=$('hud'), sub=$('sub'), win=$('win'), countSel=$('count');
var NARROW = window.innerWidth < 700;
if(NARROW) sub.textContent = 'Join neighbours. 2 fingers scroll.';
var SUB_DEFAULT = sub.textContent, SUB_BASE = SUB_DEFAULT;
var ZL=[1,1.25,1.5,2,2.5], zi=0;
var lift=document.createElement('div'); lift.id='lift'; field.appendChild(lift);
var paused=false, curStill=null;
try{ var mv=localStorage.getItem('jiggy.motion'); paused = mv==='0'; }catch(e){}
var tok=0, curId=null, inGame=false, G=null, curUrl=null, timer=null, drag=null, pan=null, raf=0, laidOnce=false;


/* who: jeff (host), ffej (his mischief twin, on Scatter), wiz (the Old Wizard, on the Guide) */
function say(t,who){ sub.textContent=t; clearTimeout(say.t); say.t=setTimeout(function(){ sub.textContent=SUB_DEFAULT; },5000); }
function pick(a){ return a[Math.floor(Math.random()*a.length)]; }
function fmt(s){ var m=Math.floor(s/60), r=s%60; return m+':'+(r<10?'0':'')+r; }
function rnd(a,b){ return a+rand()*(b-a); }


/* ---------- jigsaw edge geometry ---------- */
function edge(A,dir,nrm,L,s,jk){
  var j=jk.j, k=jk.k;
  function P(u,v){ return [A[0]+dir[0]*u*L+nrm[0]*v*k*s*L, A[1]+dir[1]*u*L+nrm[1]*v*k*s*L]; }
  var E=[A[0]+dir[0]*L, A[1]+dir[1]*L];
  return [
    {t:'L',p:P(.40+j,0)},
    {t:'C',c1:P(.40+j,.05),c2:P(.33+j,.08),p:P(.33+j,.15)},
    {t:'C',c1:P(.33+j,.24),c2:P(.42+j,.26),p:P(.50+j,.26)},
    {t:'C',c1:P(.58+j,.26),c2:P(.67+j,.24),p:P(.67+j,.15)},
    {t:'C',c1:P(.67+j,.08),c2:P(.60+j,.05),p:P(.60+j,0)},
    {t:'L',p:E}
  ];
}
function rev(start,segs){
  var out=[];
  for(var i=segs.length-1;i>=0;i--){
    var prev=i===0?start:segs[i-1].p, s=segs[i];
    out.push(s.t==='L'?{t:'L',p:prev}:{t:'C',c1:s.c2,c2:s.c1,p:prev});
  }
  return out;
}
function pathFor(r,c,abs,mask){
  var b=G.b, pw=b.pw, ph=b.ph, X0=abs?0:c*pw-b.pad, Y0=abs?0:r*ph-b.pad;
  function f(p){ return (p[0]-X0).toFixed(1)+' '+(p[1]-Y0).toFixed(1); }
  var TL=[c*pw,r*ph], TR=[(c+1)*pw,r*ph], BR=[(c+1)*pw,(r+1)*ph], BL=[c*pw,(r+1)*ph];
  var d='M'+f(TL), all=true;
  function add(segs){
    for(var i=0;i<segs.length;i++){
      var s=segs[i];
      d+= s.t==='L' ? 'L'+f(s.p) : 'C'+f(s.c1)+','+f(s.c2)+','+f(s.p);
    }
  }
  /* mask (optional): [top,right,bottom,left] booleans; false sides are skipped (used for a joined group's outer outline only) */
  var m=mask||[1,1,1,1];
  if(m[0]){ if(r===0) add([{t:'L',p:TR}]); else add(edge(TL,[1,0],[0,1],pw,G.hS[r-1][c],G.hJ[r-1][c])); } else { d+='M'+f(TR); all=false; }
  if(m[1]){ if(c===G.cols-1) add([{t:'L',p:BR}]); else add(edge(TR,[0,1],[1,0],ph,G.vS[r][c],G.vJ[r][c])); } else { d+='M'+f(BR); all=false; }
  if(m[2]){ if(r===G.rows-1) add([{t:'L',p:BL}]); else add(rev(BL,edge(BL,[1,0],[0,1],pw,G.hS[r][c],G.hJ[r][c]))); } else { d+='M'+f(BL); all=false; }
  if(m[3]){ if(c===0) add([{t:'L',p:TL}]); else add(rev(TL,edge(TL,[0,1],[1,0],ph,G.vS[r][c-1],G.vJ[r][c-1]))); } else { d+='M'+f(TL); all=false; }
  return all ? d+'Z' : d;
}

/* ---------- setup ---------- */
function start(src){
  var im=new Image(), t=tok;
  im.onload=function(){ if(t!==tok||!inGame) return; setup(src, im.naturalWidth||320, im.naturalHeight||288); };
  im.onerror=function(){ say('The picture did not load.'); };
  im.src=src;
}
function setup(src,nw,nh){
  curUrl=src;
  lift.style.transform=''; lift.className='';
  var old=field.querySelectorAll('.piece');
  for(var i=0;i<old.length;i++) old[i].remove();
  clearInterval(timer); timer=null;
  if(drag){ try{ drag.p.cut.releasePointerCapture(drag.id); }catch(err){} }
  drag=null; pan=null; relayoutLater=false; field.style.cursor='';
  win.hidden=true; finalImg.classList.remove('on'); stage.classList.remove('won');

  var n=parseInt(countSel.value,10);
  /* v2.0.87 E: a Jigsaw free-play save for this picture + tier brings its own seed back, so the cuts come out the same */
  var RS=null; if(MODE && !TOUR){ if(skipResume) clearSave(curId,n); else RS=readSave(curId,n); } skipResume=false;
  var seed=TOUR ? TOUR.seed : (RS ? RS.seed : (URL_SEED!==null ? URL_SEED : (Math.random()*4294967296)>>>0));
  reseed(seed);
  var cols=Math.max(2,Math.round(Math.sqrt(n*nw/nh)));
  var rows=Math.max(2,Math.round(n/cols));
  var TI=tierFor(n);   /* Jigsaw: the tier fixes the grid (pictures are 3:2, so it is exact) */
  if(TI && Math.abs(nw/nh-TI.cols/TI.rows)<0.05){ cols=TI.cols; rows=TI.rows; }
  G={src:src,nw:nw,nh:nh,cols:cols,rows:rows,total:cols*rows,locked:0,z:10,won:false,t0:0,elapsed:0,
     hS:[],vS:[],hJ:[],vJ:[],pieces:[],groups:[],b:null,f:null,drops:0,
     seed:seed,base:0,started:false,resumed:false,dirty:false};   /* v2.0.87 E: seed, base (ms of earlier active time), started/resumed/dirty */
  var r,c;
  for(r=0;r<rows;r++){
    G.hS[r]=[];G.hJ[r]=[];G.vS[r]=[];G.vJ[r]=[];
    for(c=0;c<cols;c++){
      G.hS[r][c]=rand()<.5?1:-1; G.hJ[r][c]={j:rnd(-.05,.05),k:rnd(.92,1.08)};
      G.vS[r][c]=rand()<.5?1:-1; G.vJ[r][c]={j:rnd(-.05,.05),k:rnd(.92,1.08)};
    }
  }
  ghost.src=curStill||src; finalImg.style.clipPath=''; finalImg.src=paused?(curStill||src):src;
  for(r=0;r<rows;r++) for(c=0;c<cols;c++){
    var el=document.createElement('div'); el.className='piece';
    var cut=document.createElement('div'); cut.className='cut';
    var img=document.createElement('img'); img.src=paused?(curStill||src):src; img.alt=''; img.draggable=false;
    var svg=document.createElementNS('http://www.w3.org/2000/svg','svg');
    var lo=document.createElementNS('http://www.w3.org/2000/svg','path'); lo.setAttribute('class','lo');
    var hi=document.createElementNS('http://www.w3.org/2000/svg','path'); hi.setAttribute('class','hi');
    svg.appendChild(hi); svg.appendChild(lo);
    var rsvg=document.createElementNS('http://www.w3.org/2000/svg','svg'); rsvg.setAttribute('class','rim');
    var sh=document.createElementNS('http://www.w3.org/2000/svg','path'); sh.setAttribute('class','sh');
    var rm=document.createElementNS('http://www.w3.org/2000/svg','path'); rm.setAttribute('class','rm');
    rsvg.appendChild(sh); rsvg.appendChild(rm);
    cut.appendChild(img); cut.appendChild(svg); el.appendChild(rsvg); el.appendChild(cut); field.appendChild(el);
    var p={r:r,c:c,el:el,cut:cut,img:img,lo:lo,hi:hi,sh:sh,rm:rm,locked:false,grp:null};
    p.grp={list:[p],locked:false,gx:0,gy:0,fx:0,fy:0,c0:c,c1:c,r0:r,r1:r};
    el._p=p; G.pieces.push(p); G.groups.push(p.grp);
  }
  var so=countSel.options[countSel.selectedIndex]; so.textContent=MODE?pcsText(G.total):G.total+(window.innerWidth<360?' pcs':' pieces');
  layout(true);
  scatter(G.groups);
  placeAll();
  setZoomUi();
  updateHud();
  if(RS && applySave(RS)){ updateHud(); say('Welcome back! Picking up where you left off.'); }   /* v2.0.87 E */
  else if(TOUR && TOUR.token){ G.t0=Date.now(); timer=setInterval(updateHud,1000); say(G.total+' pieces. The clock is running. You can do it!'); }
  else say(G.total+' pieces. '+pick(['Edges first, if you like. That\u2019s how I do it!','Happy puzzling!','Take your time. Lovely picture, this one.']));
}

function layout(first){
  if(!G) return;
  var sw=stage.clientWidth, sh=stage.clientHeight, asp=G.nw/G.nh;
  var tray = sw<700, M=12, bw, bh, pw, ph, pad, fw, fh, ox, oy, i;
  var wChanged = G.lastW!==sw; G.lastW=sw;
  var modeChanged = G.tray!==undefined && G.tray!==tray;
  if(tray){
    /* phone: board fits the width (never cropped), loose pieces wait in a tray under it */
    bw=Math.min(sw-2*M, sh*.5*asp);
    bw=Math.max(bw, G.cols*34, 200)*ZL[zi];
  } else {
    bw=Math.min(sw*.6, sh*.6*asp);
    bw=Math.max(bw, G.cols*44, 240)*ZL[zi];
  }
  bh=bw/asp; pw=bw/G.cols; ph=bh/G.rows; pad=.3*Math.max(pw,ph);
  var px=pw*1.2, py=ph*1.2, cells=[], m, rail=tray?18:0;
  if(tray){
    fw=Math.max(sw,Math.round(bw+2*M)); ox=(fw-bw)/2; oy=M+3;
    var per=Math.max(1,Math.floor((fw-2*rail)/px)), nr=Math.ceil(G.total/per), top=oy+bh+18;
    fh=Math.max(sh,Math.round(top+nr*py+M));
    var x0=(fw-per*px)/2;
    for(i=0;i<per*nr;i++) cells.push([x0+(i%per)*px, top+Math.floor(i/per)*py]);
  } else {
    fw=Math.max(sw,Math.round(bw*1.75)); fh=Math.max(sh,Math.round(bh*1.75));
    ox=(fw-bw)/2; oy=(fh-bh)/2;
    for(var yy=8; yy+py<=fh-8; yy+=py) for(var xx=8; xx+px<=fw-8; xx+=px){
      if(xx<ox+bw+10 && xx+px>ox-10 && yy<oy+bh+10 && yy+py>oy-10) continue;
      cells.push([xx,yy]);
    }
  }
  G.b={bw:bw,bh:bh,pw:pw,ph:ph,pad:pad,ox:ox,oy:oy};
  G.f={w:fw,h:fh}; G.cells=cells; G.tray=tray;
  field.style.width=fw+'px'; field.style.height=fh+'px';
  board.style.cssText='left:'+ox+'px;top:'+oy+'px;width:'+bw+'px;height:'+bh+'px';
  finalImg.style.cssText='left:'+ox+'px;top:'+oy+'px;width:'+bw+'px;height:'+bh+'px';
  showAnim();
  var sd='';
  for(i=0;i<G.pieces.length;i++) sd+=pathFor(G.pieces[i].r,G.pieces[i].c,true);
  $('slotp').setAttribute('d',sd);
  var trayEl=$('tray');
  if(tray){ trayEl.hidden=false; trayEl.style.cssText='left:'+(M/2)+'px;top:'+(oy+bh+10)+'px;width:'+(fw-M)+'px;height:'+(fh-(oy+bh+10)-M/2)+'px'; } else trayEl.hidden=true;
  var w=pw+2*pad, h=ph+2*pad, sz=Math.round(w)+'px '+Math.round(h)+'px';
  for(i=0;i<G.pieces.length;i++){
    var p=G.pieces[i], X0=p.c*pw-pad, Y0=p.r*ph-pad;
    p.el.style.width=w+'px'; p.el.style.height=h+'px';    p.img.style.left=(-X0)+'px'; p.img.style.top=(-Y0)+'px';
    p.img.style.width=bw+'px'; p.img.style.height=bh+'px';
    var d=pathFor(p.r,p.c);
    p.cut.style.clipPath="path('"+d+"')";
    p.lo.setAttribute('d',d); p.hi.setAttribute('d',d); rimFor(p);
  }
  if(!first){
    if((tray && wChanged) || modeChanged) scatter(freeGroups());
    placeAll();
  }
  if(first || !laidOnce){
    stage.scrollLeft=(fw-sw)/2; stage.scrollTop=tray?0:(fh-sh)/2; laidOnce=true;
  }
}
/* v2.0.68: loose pieces animate too (Motion off = still first frame). v2.0.61: one animated copy of the picture (#final) is clipped to the locked pieces, so only one GIF runs */
function showAnim(){
  if(!G) return;
  var d='', i, p;
  if(!G.won) for(i=0;i<G.pieces.length;i++){ p=G.pieces[i]; if(p.locked) d+=pathFor(p.r,p.c,true); }
  finalImg.style.clipPath = (G.won||!d) ? '' : "path('"+d+"')";
  finalImg.classList.toggle('on', G.won || !!d);
}
function rimFor(p){
  var g=p.grp, d;
  if(g.list.length<2){ d=pathFor(p.r,p.c); }
  else {
    var nb=function(r,c){ var q=pieceAt(r,c); return !(q && q.grp===g); };
    d=pathFor(p.r,p.c,false,[nb(p.r-1,p.c),nb(p.r,p.c+1),nb(p.r+1,p.c),nb(p.r,p.c-1)]);
  }
  p.sh.setAttribute('d',d); p.rm.setAttribute('d',d);
}
function freeGroups(){ return G.groups.filter(function(g){ return !g.locked; }); }
function setZ(g,z){ for(var i=0;i<g.list.length;i++) g.list[i].el.style.zIndex=z; }
function saveFrac(g){ g.fx=g.gx/G.f.w; g.fy=g.gy/G.f.h; }
/* a group's origin (gx,gy) is where its piece (0,0) would sit; every member sits at origin + (c*pw, r*ph). Locked = origin at the board. */
function clampG(g){
  var b=G.b, F=G.f, lo, hi;
  lo=b.pad-g.c0*b.pw; hi=F.w-b.pad-(g.c1+1)*b.pw; g.gx=Math.max(lo,Math.min(g.gx,Math.max(lo,hi)));
  lo=b.pad-g.r0*b.ph; hi=F.h-b.pad-(g.r1+1)*b.ph; g.gy=Math.max(lo,Math.min(g.gy,Math.max(lo,hi)));
}
function putG(g){
  var b=G.b, i, p;
  if(g.locked){ g.gx=b.ox; g.gy=b.oy; } else clampG(g);
  for(i=0;i<g.list.length;i++){
    p=g.list[i];
    p.el.style.left=(g.gx+p.c*b.pw-b.pad)+'px'; p.el.style.top=(g.gy+p.r*b.ph-b.pad)+'px';
  }
}
function placeGroup(g){
  if(!g.locked){ g.gx=g.fx*G.f.w; g.gy=g.fy*G.f.h; }
  putG(g);
}
function placeAll(){ for(var i=0;i<G.groups.length;i++) placeGroup(G.groups[i]); }

function shuffle(a){ for(var i=a.length-1;i>0;i--){ var j=Math.floor(rand()*(i+1)), t=a[i]; a[i]=a[j]; a[j]=t; } return a; }
/* Deal loose pieces into a jittered grid of free cells (little overlap). On a phone the tray lists edge pieces first. */
function scatter(list){
  var b=G.b, F=G.f, cells=G.cells.slice(), L=list.slice(), i, k;
  if(G.tray){
    var edge=[], mid=[];
    for(i=0;i<L.length;i++){
      var isE=false;
      for(k=0;k<L[i].list.length;k++){ var q=L[i].list[k]; if(q.r===0||q.c===0||q.r===G.rows-1||q.c===G.cols-1) isE=true; }
      (isE?edge:mid).push(L[i]);
    }
    L=shuffle(edge).concat(shuffle(mid));
  } else { shuffle(cells); shuffle(L); }
  var jx=b.pw*.07, jy=b.ph*.07;
  for(i=0;i<L.length;i++){
    var g=L[i], x, y, w=(g.c1-g.c0+1)*b.pw+2*b.pad, h=(g.r1-g.r0+1)*b.ph+2*b.pad;
    if(i<cells.length){
      x=cells[i][0]+(b.pw*1.2-b.pw)/2-b.pad+rnd(-jx,jx); y=cells[i][1]+(b.ph*1.2-b.ph)/2-b.pad+rnd(-jy,jy);
    } else {
      for(var t=0;t<80;t++){
        x=rand()*(F.w-w); y=rand()*(F.h-h);
        if(!(x<b.ox+b.bw && x+w>b.ox && y<b.oy+b.bh && y+h>b.oy)) break;
      }
    }
    g.gx=x-g.c0*b.pw+b.pad; g.gy=y-g.r0*b.ph+b.pad;
    clampG(g); saveFrac(g);
    setZ(g,10+Math.floor(rand()*G.pieces.length));
  }
}

/* ---------- v2.0.87 E: save and resume (Jigsaw free play only; never in a tournament, whose clock is server-side) ----------
   localStorage 'jiggy.save.<pic>.<pieces>' = {v:1, pic, n, seed, t (ms of active time), tr (tray layout), savedAt, grps:[[1,[idx..]] locked | [0,u,v,[idx..]] loose]}.
   idx = row*cols+col. u,v = the group's origin as a fraction of the board (so any screen size maps back). Every access is in try/catch. */
var skipResume=false, saveT=0, SAVE_V=1, SAVE_DAYS=30;
function saveKey(id,n){ return 'jiggy.save.'+id+'.'+n; }
function clearSave(id,n){ try{ localStorage.removeItem(saveKey(id,n)); }catch(e){} }
/* a valid save or null (a stale, foreign, damaged or other-version one is removed). done = pieces already locked. */
function readSave(id,n){
  var raw=null, s, i, k, seen, done=0;
  try{ raw=localStorage.getItem(saveKey(id,n)); }catch(e){ return null; }
  if(!raw) return null;
  try{
    s=JSON.parse(raw);
    if(!s || s.v!==SAVE_V || s.pic!==id || s.n!==n || !tierFor(n)) throw 0;
    if(typeof s.seed!=='number' || !isFinite(s.seed) || typeof s.t!=='number' || !(s.t>=0) || typeof s.savedAt!=='number') throw 0;
    if(Date.now()-s.savedAt>SAVE_DAYS*864e5) throw 0;
    if(!Array.isArray(s.grps)) throw 0;
    seen=new Array(n);
    for(i=0;i<s.grps.length;i++){
      var g=s.grps[i], L;
      if(!Array.isArray(g)) throw 0;
      if(g[0]===1) L=g[1]; else if(g[0]===0){ if(typeof g[1]!=='number'||typeof g[2]!=='number'||!isFinite(g[1])||!isFinite(g[2])) throw 0; L=g[3]; } else throw 0;
      if(!Array.isArray(L) || !L.length) throw 0;
      for(k=0;k<L.length;k++){ var ix=L[k]; if(typeof ix!=='number' || ix%1 || ix<0 || ix>=n || seen[ix]) throw 0; seen[ix]=1; }
      if(g[0]===1) done+=L.length;
    }
    for(i=0;i<n;i++) if(!seen[i]) throw 0;
    if(done>=n) throw 0;
    s.done=done; return s;
  }catch(e){ clearSave(id,n); return null; }
}
function activeMs(){ return G ? (G.base||0)+(G.t0 ? Date.now()-G.t0 : 0) : 0; }
function saveable(){ return !!(MODE && !TOUR && G && curId && !G.won && G.b); }
function scheduleSave(){
  if(!saveable()) return;
  G.dirty=true; clearTimeout(saveT); saveT=setTimeout(saveNow,400);
}
function saveNow(){
  clearTimeout(saveT); saveT=0;
  if(!saveable() || !G.dirty) return;
  try{
    var b=G.b, grps=[], i, k, g, L;
    for(i=0;i<G.groups.length;i++){
      g=G.groups[i]; L=[];
      for(k=0;k<g.list.length;k++) L.push(g.list[k].r*G.cols+g.list[k].c);
      if(g.locked) grps.push([1,L]);
      else grps.push([0,Math.round((g.gx-b.ox)/b.bw*10000)/10000,Math.round((g.gy-b.oy)/b.bh*10000)/10000,L]);
    }
    localStorage.setItem(saveKey(curId,G.total),JSON.stringify({v:SAVE_V,pic:curId,n:G.total,seed:G.seed,t:Math.round(activeMs()),tr:G.tray?1:0,savedAt:Date.now(),grps:grps}));
  }catch(e){}
}
/* rebuild the saved groups on the freshly cut table (the seed gave the same cuts); returns true when applied */
function applySave(s){
  var i, k, g, a, p, L;
  if(s.n!==G.total) return false;
  var order=0;
  for(i=0;i<s.grps.length;i++){
    g=s.grps[i]; L=(g[0]===1?g[1]:g[3]);
    a=G.pieces[L[0]].grp;
    for(k=1;k<L.length;k++) a=join(a,G.pieces[L[k]].grp);
    for(k=0;k<a.list.length;k++){ a.list[k].el.classList.remove('pop','joined'); if(a.list.length>1) a.list[k].el.classList.add('joined'); }
    if(g[0]===1){
      a.locked=true; putG(a);
      for(k=0;k<a.list.length;k++){ p=a.list[k]; p.locked=true; p.el.style.zIndex=1; p.el.classList.add('locked'); }
      G.locked+=a.list.length;
    } else {
      a.gx=G.b.ox+g[1]*G.b.bw; a.gy=G.b.oy+g[2]*G.b.bh; clampG(a); saveFrac(a); setZ(a,10+(order++));
    }
  }
  G.z=10+G.groups.length+order;
  if(!!s.tr!==!!G.tray) scatter(freeGroups());   /* saved on the other layout (desk vs phone tray): deal the loose ones afresh */
  placeAll(); showAnim();
  G.base=Math.round(s.t); G.resumed=true;
  return true;
}
/* active time only: stop the clock when the tab is hidden, restart it when the player is back */
function holdClock(){
  if(!saveable()) return;
  if(G.t0){ G.base+=Date.now()-G.t0; G.t0=0; clearInterval(timer); timer=null; G.held=true; }
  saveNow();
}
function wakeClock(){
  if(G && G.held && !G.won){ G.held=false; G.t0=Date.now(); clearInterval(timer); timer=setInterval(updateHud,1000); updateHud(); }
}
document.addEventListener('visibilitychange',function(){ if(document.hidden) holdClock(); else wakeClock(); });
window.addEventListener('pagehide',holdClock);
window.addEventListener('pageshow',function(e){ if(e.persisted) wakeClock(); });

/* ---------- dragging ---------- */
var relayoutLater=false;
field.addEventListener('contextmenu',function(e){ e.preventDefault(); });
field.addEventListener('pointerdown',function(e){
  if(!G||G.won||e.button>0) return;
  if(drag && e.pointerId!==drag.id){
    /* second pointer while holding a piece: drop it; a second finger then scrolls the table */
    endDrag();
    if(e.pointerType!=='touch') return;
    pan={id:e.pointerId,x:e.clientX,y:e.clientY,sl:stage.scrollLeft,st:stage.scrollTop};
    try{ field.setPointerCapture(e.pointerId); }catch(err){}
    return;
  }
  var el=e.target.closest ? e.target.closest('.piece') : null;
  if(!el||!el._p||el._p.locked){
    if(e.pointerType!=='touch' && !pan){
      pan={id:e.pointerId,x:e.clientX,y:e.clientY,sl:stage.scrollLeft,st:stage.scrollTop};
      try{ field.setPointerCapture(e.pointerId); }catch(err){}
      field.style.cursor='grabbing';
    }
    return;
  }
  e.preventDefault();
  var p=el._p, g=p.grp, fr=field.getBoundingClientRect(), touch=e.pointerType==='touch', gi;
  drag={p:p,g:g,id:e.pointerId,touch:touch,lift:touch?30:0,moved:false,sx:e.clientX,sy:e.clientY,
        ox:e.clientX-fr.left-g.gx,
        oy:e.clientY-fr.top-g.gy,
        cx:e.clientX,cy:e.clientY,x0:g.gx,y0:g.gy};
  try{ e.target.setPointerCapture(e.pointerId); }catch(err){}
  setZ(g,++G.z);
  /* the held group rides in one raised layer that is moved with a single transform (cheap even for 50 animated pieces) */
  lift.className=g.list.length>1?'multi':'';
  for(gi=0;gi<g.list.length;gi++){ lift.appendChild(g.list[gi].el); g.list[gi].el.classList.add('drag'); }
  if(!G.t0 && !G.started){ G.started=true; G.t0=Date.now(); timer=setInterval(updateHud,1000); if(MODE && !TOUR && !G.resumed) pStart(); }   /* v2.0.87 E: a resumed go is never timed on the server */
  if(touch) moveDrag();   /* lift the piece above the thumb */
  if(!raf) raf=requestAnimationFrame(tick);
});
field.addEventListener('pointermove',function(e){
  if(pan&&e.pointerId===pan.id){
    stage.scrollLeft=pan.sl-(e.clientX-pan.x); stage.scrollTop=pan.st-(e.clientY-pan.y); return;
  }
  if(!drag||e.pointerId!==drag.id) return;
  drag.cx=e.clientX; drag.cy=e.clientY;
  if(!drag.moved && Math.hypot(drag.cx-drag.sx,drag.cy-drag.sy)>8) drag.moved=true;
  moveDrag();
});
function dropClasses(g){
  var i, el;
  for(i=0;i<g.list.length;i++){
    el=g.list[i].el; el.classList.remove('drag','multi');
    if(el.parentNode===lift) field.appendChild(el);
  }
  lift.style.transform=''; lift.className='';
}
function nearSlot(g,thr){ var b=G.b; return Math.hypot(g.gx-b.ox,g.gy-b.oy)<thr; }
function pieceAt(r,c){ return (r<0||c<0||r>=G.rows||c>=G.cols)?null:G.pieces[r*G.cols+c]; }
function join(a,o){
  if(o.list.length>a.list.length){ var t=a; a=o; o=t; }
  var i, p;
  for(i=0;i<o.list.length;i++){
    p=o.list[i]; p.grp=a; a.list.push(p);
    p.el.classList.remove('pop'); void p.el.offsetWidth; p.el.classList.add('pop');
  }
  a.c0=Math.min(a.c0,o.c0); a.c1=Math.max(a.c1,o.c1); a.r0=Math.min(a.r0,o.r0); a.r1=Math.max(a.r1,o.r1);
  var ix=G.groups.indexOf(o); if(ix>=0) G.groups.splice(ix,1);
  for(i=0;i<a.list.length;i++){ a.list[i].el.classList.add('joined'); rimFor(a.list[i]); }
  return a;
}
/* merge g with any loose group that holds a true neighbour and sits within thr of g's relative position */
function mergeAround(g,thr){
  var again=true, D=[[1,0],[-1,0],[0,1],[0,-1]], i, d, q, h, joined=false;
  while(again){
    again=false;
    for(i=0;i<g.list.length && !again;i++) for(d=0;d<4;d++){
      q=pieceAt(g.list[i].r+D[d][0],g.list[i].c+D[d][1]);
      if(!q) continue;
      h=q.grp;
      if(h===g||h.locked) continue;
      if(Math.hypot(h.gx-g.gx,h.gy-g.gy)<thr){ g=join(g,h); again=true; joined=true; break; }
    }
  }
  if(joined){ try{ if(navigator.vibrate) navigator.vibrate(8); }catch(e){} }
  return g;
}
function endDrag(e){
  if(!drag||(e&&e.pointerId!==drag.id)) return;
  var g=drag.g, touch=drag.touch; drag=null;
  G.drops++;
  dropClasses(g);
  var b=G.b, thr=Math.min(b.pw,b.ph)*(touch?.45:.32);
  clampG(g);
  if(nearSlot(g,thr)) lock(g);
  else {
    g=mergeAround(g,thr);
    dropClasses(g);
    if(nearSlot(g,thr)) lock(g);
    else { putG(g); saveFrac(g); setZ(g,++G.z); }
  }
  if(relayoutLater){ relayoutLater=false; layout(false); }
  scheduleSave();   /* v2.0.87 E */
}
function endPan(e){
  if(pan&&e.pointerId===pan.id){ pan=null; field.style.cursor=''; }
}
field.addEventListener('pointerup',function(e){ endPan(e); endDrag(e); });
field.addEventListener('pointercancel',function(e){ endPan(e); endDrag(e); });
field.addEventListener('lostpointercapture',function(e){ endPan(e); endDrag(e); });
window.addEventListener('blur',function(){ pan=null; field.style.cursor=''; endDrag(); });

function moveDrag(){
  if(!drag) return;
  var g=drag.g, fr=field.getBoundingClientRect();
  g.gx=drag.cx-fr.left-drag.ox; g.gy=drag.cy-fr.top-drag.oy-drag.lift;
  clampG(g);
  lift.style.transform='translate('+(g.gx-drag.x0)+'px,'+(g.gy-drag.y0)+'px)';
}
function tick(){
  raf=0;
  if(!drag) return;
  if(drag.moved){
    /* edge autoscroll: only once the pointer has really moved, speed grows toward the edge */
    var sr=stage.getBoundingClientRect(), m=44, vmax=9, dx=0, dy=0;
    function sp(d){ return Math.max(2, vmax*Math.min(1,d/m)); }
    if(drag.cx<sr.left+m) dx=-sp(sr.left+m-drag.cx); else if(drag.cx>sr.right-m) dx=sp(drag.cx-(sr.right-m));
    if(drag.cy<sr.top+m) dy=-sp(sr.top+m-drag.cy); else if(drag.cy>sr.bottom-m) dy=sp(drag.cy-(sr.bottom-m));
    if(dx||dy){ stage.scrollLeft+=dx; stage.scrollTop+=dy; moveDrag(); }
  }
  raf=requestAnimationFrame(tick);
}

function lock(g){
  var i, p;
  g.locked=true; putG(g);
  for(i=0;i<g.list.length;i++){
    p=g.list[i]; p.locked=true;
    p.el.style.zIndex=1;
    p.el.classList.add('locked');
    p.el.classList.remove('pop'); void p.el.offsetWidth; p.el.classList.add('pop');
  }
  try{ if(navigator.vibrate) navigator.vibrate(12); }catch(e){}
  G.locked+=g.list.length;
  showAnim();
  updateHud();
  if(G.locked===G.total) solved();
}
function updateHud(){
  if(!G){ hud.textContent='0 / 0'; return; }
  var t = G.won ? G.elapsed : Math.floor(activeMs()/1000);   /* v2.0.87 E: base = active time from earlier visits */
  $('prog').style.width=(G.total?100*G.locked/G.total:0)+'%';
  hud.textContent=G.locked+' / '+G.total+' \u00b7 '+fmt(t);
}
function solved(){
  G.won=true; G.elapsed=Math.floor(activeMs()/1000);
  clearInterval(timer); timer=null;
  stage.classList.add('won');
  showAnim();
  win.setAttribute('data-res','ok'); $('winHead').textContent='Solved!';
  $('winText').textContent='Jeff: \u201c'+G.total+' pieces in '+fmt(G.elapsed)+'. Lovely work!\u201d';
  if(TOUR && TOUR.token) finishRun();
  else if(MODE){
    clearSave(curId,G.total); clearTimeout(saveT);   /* v2.0.87 E */
    if(G.resumed) $('winText').textContent+=' Resumed goes don\'t set bests.'; else pFinish();
  }
  winExtras();
  win.hidden=false;
  if(G.tray){ stage.scrollTop=0; stage.scrollLeft=(G.f.w-stage.clientWidth)/2; }
  updateHud();
}

/* ---------- tournaments (v2.0.68): the server keeps the time; the token is used once ---------- */
function api(body,cb){
  var cfg=TOUR||MODE, q='csrf='+encodeURIComponent(cfg.csrf);
  for(var k in body) q+='&'+k+'='+encodeURIComponent(body[k]);
  fetch(cfg.api,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:q})
    .then(function(r){ return r.json(); }).then(cb,function(){ cb({ok:false,error:'The table wobbled (no connection). Try again.'}); });
}
function finishRun(){
  var tk=TOUR.token; TOUR.token=null;
  $('winText').textContent='Checking your time\u2026';
  api({'do':'finish',token:tk,drops:G.drops},function(r){
    if(r.ok){ $('winText').textContent='Jeff: \u201c'+r.message+' You\u2019re #'+r.rank+' so far!\u201d'+ppalLine(r); }
    else {
      if(r.rejected){ win.setAttribute('data-res','caught'); $('winHead').textContent='Caught Ffej!'; }
      $('winText').textContent=r.rejected ? 'Ffej has been fiddling with the clock again. '+r.error : r.error;
    }
  });
}
/* v2.0.87: Jigsaw free play. The server times the go from the first grab (personal bests, pays nothing); a guest or a failed call just plays on. */
function pStart(){
  var ti=tierFor(G.total); if(!MODE.live || !ti) return;
  var g=G; api({'do':'pstart',pic:curId,tier:ti.k},function(r){ if(r.ok && G===g) g.ptok=r.token; });
}
/* v2.0.88 Puzzle Pals: what a finished go released or earned (the server sends r.ppal only the first time) */
function ppalLine(r){
  var p=r&&r.ppal; if(!p) return '';
  if(p.trophy) return ' \ud83c\udfc6 An Expert trophy for '+p.title+'! It goes on your profile shelf.';
  if(p.released) return ' The magic of the jigsaw is loose! '+p.released+' Puzzle Pals from '+p.title+' will wait at places on the map. Look for their stickers!';
  return '';
}
function pFinish(){
  var g=G, tk=g.ptok; g.ptok=null; if(!tk) return;
  api({'do':'pfinish',token:tk,drops:g.drops},function(r){
    if(r.ok){
      $('winText').textContent='Jeff: \u201c'+r.message+'\u201d'+ppalLine(r);
      if(r.ppal&&r.ppal.released){ MODE.pals=MODE.pals||{}; MODE.pals[curId]=[0,r.ppal.released]; }
      if(MODE.bests){ var m=MODE.bests[curId]||(MODE.bests[curId]={}); m[r.tier]=r.best; }
    }
  });
}
/* the win card's "next tier" button */
function winExtras(){
  var nb=$('nexttier'); if(!nb||!MODE||TOUR) return;   /* v2.0.87 B: no "next tier" in a tournament (one tier each) */
  var ti=tierFor(G.total), nx=null;
  for(var i=0;i<MODE.tiers.length-1;i++) if(MODE.tiers[i]===ti) nx=MODE.tiers[i+1];
  nb.hidden=!nx; nb.setAttribute('data-n',nx?nx.n:''); nb.textContent=nx?'Try '+nx.label+' ('+nx.n+')':'';
}
function startRun(){
  var m=$('tmsg');
  if(!PUZZLES[0]){ location.reload(); return; }   /* v2.0.87 B: a Jigsaw tournament page opened while the picture was still a mystery */
  api({'do':'start',t:TOUR.id},function(r){
    if(!r.ok){ if(m){ m.textContent=r.error; m.hidden=false; } if(inGame){ $('winText').textContent=r.error; } return; }
    TOUR.token=r.token; TOUR.seed=r.seed; TOUR.pieces=r.pieces;
    enterGame(PUZZLES[0],r.pieces);
  });
}

/* ---------- controls ---------- */
countSel.addEventListener('change',function(){
  if(!curId) return;
  saveCount(curId,parseInt(countSel.value,10)); setHash(curId,parseInt(countSel.value,10),true);
  if(MODE && !TOUR){ clearSave(curId,G?G.total:0); clearSave(curId,parseInt(countSel.value,10)); skipResume=true; }   /* v2.0.87 E: a new tier starts fresh */
  if(curUrl) start(curUrl);
});
if($('nexttier')) $('nexttier').addEventListener('click',function(){ var n=parseInt(this.getAttribute('data-n'),10); if(n&&curId){ setHash(curId,n,false); route(); } });
$('again').addEventListener('click',function(){ if(TOUR){ startRun(); return; } if(MODE && curId){ clearSave(curId,G?G.total:0); skipResume=true; } if(curUrl) start(curUrl); });   /* v2.0.87 E */
$('scatter').addEventListener('click',function(){
  if(!G||G.won) return;
  scatter(freeGroups()); placeAll(); scheduleSave();
  say(pick(['Ffej: \u201cOops! Did I bump the table? Hee hee.\u201d','Ffej: \u201cWheee! Pieces everywhere!\u201d','Ffej: \u201cJeff said tidy up. I said no.\u201d']),'ffej');
});
$('guide').addEventListener('click',function(){
  var on=this.getAttribute('aria-pressed')!=='true';
  this.setAttribute('aria-pressed',on?'true':'false');
  field.classList.toggle('noguide',!on);
  say(on?'Old Wizard: \u201cA faint picture lies under the outline now. Match the colours, my dear.\u201d':'Old Wizard: \u201cOff it goes. You have the knack of it now.\u201d','wiz');
});
function setMotionUi(){ $('anim').setAttribute('aria-pressed',paused?'false':'true'); }
$('anim').addEventListener('click',function(){
  paused=!paused; setMotionUi();
  try{ localStorage.setItem('jiggy.motion',paused?'0':'1'); }catch(e){}
  if(G && curUrl){ finalImg.src=paused?(curStill||curUrl):curUrl; for(var k=0;k<G.pieces.length;k++) G.pieces[k].img.src=paused?(curStill||curUrl):curUrl; }
  for(var i=0;i<thumbs.length;i++) thumbs[i][1].src=paused?thumbs[i][0].still:thumbs[i][0].gif;
});
function setZoomUi(){
  $('zl').textContent=ZL[zi]+'\u00d7';
  $('zout').disabled=zi<=0; $('zin').disabled=zi>=ZL.length-1;
}
function setZoom(ni){
  ni=Math.max(0,Math.min(ZL.length-1,ni));
  if(!G||ni===zi) return;
  if(drag) endDrag();
  var sw=stage.clientWidth, sh=stage.clientHeight;
  var rx=(stage.scrollLeft+sw/2)/G.f.w, ry=(stage.scrollTop+sh/2)/G.f.h;
  zi=ni; layout(false);
  stage.scrollLeft=rx*G.f.w-sw/2; stage.scrollTop=ry*G.f.h-sh/2;
  setZoomUi(); say('Zoom '+ZL[zi]+'\u00d7');
}
$('zin').addEventListener('click',function(){ setZoom(zi+1); });
$('zout').addEventListener('click',function(){ setZoom(zi-1); });
window.addEventListener('dragover',function(e){ e.preventDefault(); });
window.addEventListener('drop',function(e){ e.preventDefault(); });
var rt=null, lastSW=0, lastSH=0;
new ResizeObserver(function(){
  clearTimeout(rt);
  rt=setTimeout(function(){
    if(!G) return;
    var w=stage.clientWidth, h=stage.clientHeight;
    /* on a phone the address bar sliding in/out only changes the height: leave the layout alone */
    if(w===lastSW && (w<700 || h===lastSH)) return;
    lastSW=w; lastSH=h;
    if(drag){ relayoutLater=true; return; }
    layout(false);
  },150);
}).observe(stage);

/* ---------- library, routing, teardown ---------- */
var thumbs=[], cardSels=[], COUNTS=MODE?MODE.tiers.map(function(t){ return t.n; }):[24,54,96,150], grid=$('grid'), lib=$('lib'), gameEl=$('game'), libScroll=0;
function byId(id){ for(var i=0;i<PUZZLES.length;i++) if(PUZZLES[i].id===id) return PUZZLES[i]; return null; }
function loadCounts(){ try{ return JSON.parse(localStorage.getItem('jiggy.counts')||'{}')||{}; }catch(e){ return {}; } }
function saveCount(id,n){ try{ var m=loadCounts(); m[id]=n; localStorage.setItem('jiggy.counts',JSON.stringify(m)); }catch(e){} }
function countFor(pz){ var n=loadCounts()[pz.id]; return COUNTS.indexOf(n)>=0 ? n : pz.pieces; }
/* v2.0.87: Jigsaw library: a card per picture with one button per tier (the best time shows once solved), category chips on top. */
var jigCat='';
function ms2t(ms){ var t=Math.floor(ms/1000); return Math.floor(t/60)+':'+('0'+(t%60)).slice(-2); }
/* v2.0.87: a tier's drawn icon (ico-tier-*) before its label; the emoji if the picture is missing */
function tierLabel(el,t,txt){
  el.textContent='';
  if(t.img){ var im=document.createElement('img'); im.src=t.img; im.alt=''; im.width=20; im.height=20; im.className='pztico'; el.appendChild(im); el.appendChild(document.createTextNode(' '+txt)); }
  else el.textContent=t.icon+' '+txt;
}
function buildJigsawLibrary(){
  if(!grid) return;   /* v2.0.87 B: the tournament page has no grid */
  grid.innerHTML='';
  var cats=[], i, k, bar=$('cats');
  for(i=0;i<PUZZLES.length;i++) if(PUZZLES[i].cat && cats.indexOf(PUZZLES[i].cat)<0) cats.push(PUZZLES[i].cat);
  if(bar){
    bar.innerHTML='';
    if(cats.length>1) ['All'].concat(cats).forEach(function(c){
      var b=document.createElement('button'); b.type='button'; b.className='pzchip'+((c==='All'?'':c)===jigCat?' on':''); b.textContent=c;
      b.addEventListener('click',function(){ jigCat=c==='All'?'':c; buildJigsawLibrary(); });
      bar.appendChild(b);
    });
  }
  for(i=0;i<PUZZLES.length;i++) (function(pz){
    if(jigCat && pz.cat!==jigCat) return;
    var li=document.createElement('li'); li.className='pzcard';
    var th=document.createElement('div'); th.className='pzthumb';
    var im=document.createElement('img'); im.src=pz.thumb||pz.still; im.alt=pz.title; im.loading='lazy'; if(pz.px) im.className='px'; th.appendChild(im);
    var body=document.createElement('div'); body.className='pzbody';
    var h=document.createElement('h2'); h.textContent=pz.title;
    var row=document.createElement('div'); row.className='pztiers';
    var mine=(MODE.bests&&MODE.bests[pz.id])||{};
    MODE.tiers.forEach(function(t){
      var b=document.createElement('button'); b.type='button'; b.className='btn pztier'+(mine[t.k]?' done':''); b.setAttribute('data-tier',t.k);
      b.setAttribute('aria-label','Play '+pz.title+' on '+t.label+', '+t.n+' pieces'+(mine[t.k]?', your best '+ms2t(mine[t.k]):''));
      b.innerHTML='<span class="pztn"></span><small></small>';
      tierLabel(b.firstChild,t,t.label); b.lastChild.textContent=mine[t.k]?'\u2713 '+ms2t(mine[t.k]):t.n+' pieces';
      b.addEventListener('click',function(){ setHash(pz.id,t.n,false); route(); });
      /* v2.0.87 E: a saved go shows Continue + progress, with a small Start over beside it */
      var sv=readSave(pz.id,t.n), tr=document.createElement('div'); tr.className='pztrow';
      if(sv){
        b.classList.add('resume'); tierLabel(b.firstChild,t,'Continue'); b.lastChild.textContent='\u25b6 '+sv.done+' / '+t.n;
        b.setAttribute('aria-label','Continue '+pz.title+' on '+t.label+', '+sv.done+' of '+t.n+' pieces placed');
      }
      tr.appendChild(b);
      if(sv){
        var so=document.createElement('button'); so.type='button'; so.className='pzover'; so.textContent='Start over';
        so.setAttribute('aria-label','Start '+pz.title+' over on '+t.label+' (forget the saved go)');
        so.addEventListener('click',function(){ clearSave(pz.id,t.n); setHash(pz.id,t.n,false); route(); });
        tr.appendChild(so);
      }
      row.appendChild(tr);
    });
    body.appendChild(h);
    var pp=MODE.pals&&MODE.pals[pz.id];   /* v2.0.88: a small pals pip once the picture's pals are released */
    if(pp){ var pe=document.createElement('p'); pe.className='ppalpip'+(pp[0]>=pp[1]?' full':''); pe.textContent='\ud83e\udde9 pals '+pp[0]+'/'+pp[1]; body.appendChild(pe); }
    body.appendChild(row);
    li.appendChild(th); li.appendChild(body); grid.appendChild(li);
  })(PUZZLES[i]);
}
function buildLibrary(){
  if(MODE){ buildJigsawLibrary(); return; }
  var i;
  for(i=0;i<PUZZLES.length;i++) (function(pz){
    var li=document.createElement('li'); li.className='pzcard';
    var th=document.createElement('div'); th.className='pzthumb';
    var im=document.createElement('img'); im.src=paused?pz.still:pz.gif; im.alt=pz.title+(paused?' (preview)':' (animated preview)'); th.appendChild(im); thumbs.push([pz,im]);
    var body=document.createElement('div'); body.className='pzbody';
    var h=document.createElement('h2'); h.textContent=pz.title;
    var sel=document.createElement('select'); sel.setAttribute('aria-label','Pieces for '+pz.title);
    for(var k=0;k<COUNTS.length;k++){
      var o=document.createElement('option'); o.value=COUNTS[k]; o.textContent=COUNTS[k]+' pieces'+(COUNTS[k]===pz.pieces?' ★':''); sel.appendChild(o);
    }
    sel.value=String(countFor(pz)); cardSels.push([pz,sel]);
    sel.addEventListener('change',function(){ saveCount(pz.id,parseInt(sel.value,10)); });
    var btn=document.createElement('button'); btn.type='button'; btn.className='btn'; btn.textContent='Play';
    btn.setAttribute('aria-label','Play '+pz.title);
    btn.addEventListener('click',function(){ var n=parseInt(sel.value,10); saveCount(pz.id,n); setHash(pz.id,n,false); route(); });
    body.appendChild(h); body.appendChild(sel); body.appendChild(btn);
    li.appendChild(th); li.appendChild(body); grid.appendChild(li);
  })(PUZZLES[i]);
}
function parseHash(){
  var m=/^#([A-Za-z0-9_-]{1,64})$/.exec(location.hash||''); if(!m) return null;
  var t=m[1], pz=byId(t), n=0;
  if(!pz){
    var x=/^(.*)-(\d{1,3})$/.exec(t);
    if(x){ pz=byId(x[1]); n=parseInt(x[2],10); if(COUNTS.indexOf(n)<0) n=0; }
  }
  return pz ? {pz:pz,n:n||countFor(pz)} : null;
}
function setHash(id,n,replace){
  var h='#'+id+'-'+n;
  try{
    if(replace) history.replaceState(history.state,'',h);
    else history.pushState({jg:1},'',h);
  }catch(e){ try{ location.hash=h; }catch(e2){} }
}
function clearHash(){ try{ history.replaceState(null,'',location.pathname+location.search); }catch(e){ try{ location.hash=''; }catch(e2){} } }
function resetStage(){
  if(G) saveNow();   /* v2.0.87 E: leaving the table (Library button, another picture) keeps the go */
  tok++;
  clearInterval(timer); timer=null; clearTimeout(say.t); clearTimeout(rt);
  if(raf){ cancelAnimationFrame(raf); raf=0; }
  if(drag){ try{ drag.p.cut.releasePointerCapture(drag.id); }catch(err){} }
  drag=null; pan=null; relayoutLater=false; field.style.cursor='';
  var old=field.querySelectorAll('.piece');
  for(var i=0;i<old.length;i++) old[i].remove();
  lift.style.transform=''; lift.className='';
  curUrl=null; curStill=null;
  G=null; curId=null; laidOnce=false; lastSW=0; lastSH=0;
  ghost.removeAttribute('src'); finalImg.removeAttribute('src'); finalImg.classList.remove('on'); finalImg.style.clipPath='';
  win.hidden=true; stage.classList.remove('won'); $('lk').hidden=true;
  $('prog').style.width='0'; hud.textContent='0 / 0';
  sub.textContent=SUB_BASE; SUB_DEFAULT=SUB_BASE;
}
function showLibrary(){
  if(inGame){ resetStage(); inGame=false; }
  for(var i=0;i<cardSels.length;i++) cardSels[i][1].value=String(countFor(cardSels[i][0]));
  if(MODE) buildJigsawLibrary();
  gameEl.hidden=true; lib.hidden=false; document.body.classList.remove('pz-play'); window.scrollTo(0,libScroll);
}
function enterGame(pz,n){
  resetStage(); inGame=true;
  libScroll=window.pageYOffset||0; lib.hidden=true; gameEl.hidden=false; document.body.classList.add('pz-play'); window.scrollTo(0,0);
  for(var i=0;i<countSel.options.length;i++) countSel.options[i].textContent=MODE?pcsText(countSel.options[i].value):countSel.options[i].value+(window.innerWidth<360?' pcs':' pieces');
  countSel.value=String(n); curId=pz.id;
  SUB_DEFAULT=NARROW ? pz.title+' · join neighbours' : pz.title+'. '+SUB_BASE; sub.textContent=SUB_DEFAULT;
  curStill=pz.still||null;
  field.classList.toggle('pxpic',!!pz.px);
  start(pz.gif);
}
function route(){
  var h=parseHash();
  if(!h){
    if(location.hash && location.hash!=='#') clearHash();
    showLibrary(); return;
  }
  if(inGame && curId===h.pz.id && parseInt(countSel.value,10)===h.n) return;
  if(location.hash!=='#'+h.pz.id+'-'+h.n) setHash(h.pz.id,h.n,true);
  enterGame(h.pz,h.n);
}
function leave(){
  if(TOUR){ location.href=TOUR.back; return; }
  var st=null; try{ st=history.state; }catch(e){}
  if(st && st.jg){ try{ history.back(); return; }catch(e){} }
  clearHash(); route();
}
function showLink(url){
  var box=$('lk'), inp=$('lkin'); inp.value=url; box.hidden=false;
  try{ inp.focus(); inp.select(); inp.setSelectionRange(0,url.length); }catch(e){}
}
function copyLink(){
  var url=location.href, ok=false;
  try{
    if(navigator.clipboard && navigator.clipboard.writeText){
      navigator.clipboard.writeText(url).then(function(){ say('Link copied.'); },function(){ showLink(url); });
      ok=true;
    }
  }catch(e){ ok=false; }
  if(!ok) showLink(url);
}
$('back').addEventListener('click',leave);
$('back2').addEventListener('click',leave);
$('copy').addEventListener('click',copyLink);
$('copy2').addEventListener('click',copyLink);
$('lkx').addEventListener('click',function(){ $('lk').hidden=true; });
setMotionUi();
if(TOUR){ var ts=$('tstart'); if(ts) ts.addEventListener('click',startRun); }
else {
  window.addEventListener('popstate',route);
  window.addEventListener('hashchange',route);
  buildLibrary();
  route();
}
})();
