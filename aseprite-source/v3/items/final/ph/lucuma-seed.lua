-- lucuma-seed (seed W1_2)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="lucuma-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#1e1014","#3a1c1a","#5c2c20","#823e28","#a85c34","#cc8450"}, leaf={"#1e3a2e","#2a5a3a","#3a7a42","#549a46","#76b856","#9cd478"}, sleaf={"#2e6a44","#448e4a","#62b050","#86d05c","#aaea78","#cef89c"},
stem={"#4a3028","#6a4636","#8a6244","#6a9a48","#8cbc58"}, root={"#e8d8bc","#d0bc98","#b6a078"},
vein="#d0e8a0", gloss="#ffd8a0", cool="#4a2a5a", red="#9a4a34",
sl=1.35, sw=1.25, taper=0.05, drop={4}, marks="none", markc="#e8c898",
scrap={5,57,28,54,58,38}, scrapW=5.0, scrapExp=0.5, sprout="single", leafw=4.6, quirk="none",
extra=function(ctx) for y=46,49 do ctx.c:put(29,y,"#e8c898",{r={name="q"}}) end end
})
