-- trillium-seed (seed D3s_1)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="trillium-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#3a2a1e","#5e4228","#82602e","#a48040","#c4a258","#e0c47a"}, leaf={"#244c3a","#2c6a44","#38864e","#54a05c","#80ba70","#aad48c"}, sleaf={"#3a8a4a","#58a85a","#78c470","#98dc88","#b8ec9c","#d8f8bc"}, stem={"#4a5a3a","#667a48","#82965a","#6cb064","#8cca7c"}, root={"#ecdcc0","#f6ead0","#fff6e4"},
vein="#c0e4a0", gloss="#f0dc9c", cool="#5a3a6a", red="#a84a58",
sl=0.7, sw=0.85, taper=0.25, drop={4,1}, marks="none", markc="#e0c47a", scrap={8,54,30,54,56,38}, scrapW=7.8, scrapExp=0.85, sprout="trio", leafw=5, quirk="none",
extra=function(ctx) for i=0,2 do ctx.c:put(10+i*2,46+i%2,"#f0e0a8",{r={name="q"}}) end end
})
