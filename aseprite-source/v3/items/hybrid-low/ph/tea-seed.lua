-- tea-seed (seed H1l_0)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="tea-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#2a1810","#4a2a1a","#6c4026","#8c5a34","#ae7c48","#d0a068"}, leaf={"#1c4a30","#286a38","#368a42","#4aa850","#6cc464","#92dc84"}, sleaf={"#2c7a40","#42a052","#5cc064","#7cd880","#a0ec9c","#c4f8bc"}, stem={"#4a3a2a","#665238","#826c4a","#6ab45a","#8ad078"}, root={"#efe0c0","#dccaa0","#c4ae80"},
vein="#1c4a30", gloss="#ffe8c8", cool="#4a3a70", red="#8a4a2a",
sl=1.0, sw=1.2, taper=0.0, drop={4}, marks="none", markc="#d0a068",
scrap={6,55,28,49,58,41}, scrapW=6.5, scrapExp=0.65, sprout="single", leafw=4.0, quirk="none",
extra=function(ctx) ctx.c:put(40,50,"#d0a068",{r={name="q"}}) end,
})
