-- lungwort-seed (seed W1_2)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="lungwort-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#12101e","#22182e","#34223a","#4c3040","#6a4a50","#8a6c68"}, leaf={"#24402e","#34603a","#4a8044","#6c9c58","#90b878","#b4d49c"}, sleaf={"#386a44","#509052","#70b462","#94d478","#b8ec98","#d8ffbc"},
stem={"#3c3040","#5a4854","#7c6468","#78a058","#98c070"}, root={"#e4dcc8","#ccc0a4","#b0a488"},
vein="#d8f0d0", gloss="#c0b0d8", cool="#3a2a6a", red="#7a4a6a",
sl=0.7, sw=0.85, taper=0.25, drop={4,1}, marks="spots", markc="#e8e0cc",
scrap={7,56,26,50,56,44}, scrapW=6.4, scrapExp=0.75, sprout="pair", leafw=3.4, quirk="none",
extra=function(ctx) for _,p in ipairs({{22,51},{30,49},{38,46},{27,54},{44,48}}) do ctx.c:put(p[1],p[2],"#e4ecdc",{r={name="q"}}) end end
})
