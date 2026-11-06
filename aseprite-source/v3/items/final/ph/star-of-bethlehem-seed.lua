-- star-of-bethlehem-seed (seed D2s_0)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="star-of-bethlehem-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#0e0e14","#1c1c2a","#2e2e44","#46465e","#686884","#9898b4"}, leaf={"#2a6a3c","#3a8a4a","#4eaa5a","#6cc470","#94dc8c","#c4f4b8"}, sleaf={"#3a9a4c","#54b862","#74d078","#9ce694","#c4f8b8","#e8ffe0"}, stem={"#4a7a4a","#5e965a","#74b06a","#8cc87e","#a8e096"}, root={"#e4ecd0","#f2f6e4","#fdfff4"},
vein="#f4fff0", gloss="#d8d8f0", cool="#383c88", red="#6a9a6a",
sl=0.7, sw=0.85, taper=0.0, drop={4}, marks="none", markc="#e8e8f0",
scrap={4,56,28,52,58,40}, scrapW=4.2, scrapExp=0.5, sprout="blades", leafw=2.2, quirk="none",
extra=function(ctx) local c=ctx.c for x=14,46,2 do c:put(x,48-math.floor((x-14)/10),"#f4fff0",{r={name="q"}}) end end,
})
