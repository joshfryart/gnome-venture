-- lilac-seed (seed W1_2)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="lilac-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#2a1c20","#4a2c28","#6e4430","#946444","#b88a5c","#dcb480"}, leaf={"#24443c","#2e6048","#3e8050","#58a058","#7cc068","#a4dc84"}, sleaf={"#2e6a50","#44905a","#62b464","#88d474","#acf08c","#d0ffb0"},
stem={"#4a3438","#6a4a48","#8c6858","#6c9c58","#8cc070"}, root={"#ece0c8","#d6c4a4","#bca888"},
vein="#c0e8a8", gloss="#f4d4a8", cool="#4a2a6a", red="#8a4a6a",
sl=1.0, sw=0.95, taper=0.2, drop={4}, marks="none", markc="#3a2a26",
scrap={6,54,22,46,57,42}, scrapW=6.6, scrapExp=0.7, sprout="pair", leafw=3.8, quirk="none",
extra=function(ctx) for i=0,2 do ctx.c:put(20+i*3,50-i,"#b890d8",{r={name="q"}}) end end
})
