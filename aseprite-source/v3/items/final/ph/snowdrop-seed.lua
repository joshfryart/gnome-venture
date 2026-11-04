-- snowdrop-seed (seed D2s_0)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="snowdrop-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#101a22","#1e2e36","#304650","#486068","#6a8890","#9ab8bc"}, leaf={"#2a5a6a","#3a7a84","#4a9a98","#68b8aa","#90d0bc","#c0ecd4"}, sleaf={"#3a8a8a","#52aaa0","#74c8b0","#9ce0c0","#c4f4d8","#e8fff0"}, stem={"#4a7a6a","#5a9a80","#74b498","#8ccaa8","#a8e0bc"}, root={"#ece4cc","#f8f0dc","#fffaec"},
vein="#c0f0dc", gloss="#e8f4f8", cool="#34508c", red="#7a6aa0",
sl=0.85, sw=0.75, taper=0.25, drop={4,1}, marks="none", markc="#f0ecd8",
scrap={6,56,24,54,58,38}, scrapW=5.0, scrapExp=0.5, sprout="blades", leafw=2.4, quirk="none",
extra=function(ctx) local c=ctx.c for i=0,2 do c:put(20+i,47+i,"#f4f0dc",{r={name="q"}}) c:put(21+i,47+i,"#d8d0b4",{r={name="q"}}) end end,
})
