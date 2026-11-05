-- ph/ginseng-seed (seed P1pilot)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
 name="ginseng-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
 seed={"#8a6a3a","#a8864c","#c4a262","#dcbc7c","#eed4a0","#faeac8"}, leaf={"#1e4a2a","#2a6236","#397c44","#4a9854","#64b46c","#86d08c"}, sleaf={"#3f9a42","#58b44e","#74cc62","#94e280","#b4f4a0","#d2ffc2"}, stem={"#7a3a2a","#9a503a","#b86a4e","#d28a6c","#e8aa8e"}, root={"#f6ecd2","#e8d8b0","#d0bc88"},
 vein="#d0f0b4", gloss="#fff8e4", cool="#7aa0b8", red="#d42430", sl=1.1, sw=1.0, taper=0.1, drop={4}, marks="pits", markc="#b08e54",
 scrap={7,56,27,53,58,42}, scrapW=6.4, scrapExp=0.72, sprout="trio", leafw=3.4, quirk="none",
 extra=function(ctx)
  local c=ctx.c
  -- three-prong forked palmate leaf with rounded oval leaflets
  local function oval(cx,cy,rx,ry,col) for y=-ry,ry do for x=-rx,rx do if (x*x)/(rx*rx)+(y*y)/(ry*ry)<=1.0 then c:put(cx+x,cy+y,col,{r={name="q"}}) end end end end
  for i=0,5 do c:put(48,22-i,"#7a3a2a",{r={name="q"}}) end
  local prongs={{40,9},{48,5},{56,9}}
  for _,p in ipairs(prongs) do
   for t=0,5 do c:put(48+math.floor((p[1]-48)*t/5),17+math.floor((p[2]-17)*t/5),"#58b44e",{r={name="q"}}) end
   oval(p[1],p[2]-2,3,4,"#3f9a42"); oval(p[1],p[2]-3,2,2,"#94e280")
  end
  oval(43,14,2,3,"#2a6236"); oval(53,14,2,3,"#2a6236")
  -- red berry cluster
  for _,b in ipairs({{56,20},{60,18},{59,23},{55,24},{62,22}}) do
   oval(b[1],b[2],2,2,"#d42430"); c:put(b[1]-1,b[2]-1,"#ff8a80",{r={name="q"}}); c:put(b[1]+1,b[2]+1,"#8a1420",{r={name="q"}})
  end
 end
})
