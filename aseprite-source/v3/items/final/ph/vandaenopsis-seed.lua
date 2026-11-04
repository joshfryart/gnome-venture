-- vandaenopsis-seed (seed D3s_1)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="vandaenopsis-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#3a3028","#5a4a36","#7a6446","#9a825a","#bca070","#dcc490"}, leaf={"#244e40","#2c6a52","#38866a","#54a284","#80bea2","#aad8c0"}, sleaf={"#3a9070","#58aa88","#78c4a0","#98dab6","#b8eccc","#d6f8e2"}, stem={"#4a6a50","#648a66","#7ea87c","#6cb078","#8cc894"}, root={"#c8d4c0","#dce4d4","#f0f4ec"},
vein="#c0e8d4", gloss="#e8dcb0", cool="#40408a", red="#a85090",
sl=0.5, sw=0.6, taper=0.4, drop={4}, marks="none", markc="#9a825a", scrap={5,55,26,53,59,44}, scrapW=5, scrapExp=0.95, sprout="blades", leafw=4.6, quirk="none",
extra=function(ctx) for i=0,5 do ctx.c:put(40+i,50+i%2,"#e8dcc0",{r={name="q"}}) end end
})
