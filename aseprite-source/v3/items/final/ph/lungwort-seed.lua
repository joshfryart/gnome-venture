-- lungwort-seed (seed E1_A)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="lungwort-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#101420","#1c2230","#2c3646","#445062","#667488","#8c9cb0"}, leaf={"#2a5a48","#3a7a54","#549a62","#78b87c","#a0d09a","#c8e8b8"}, sleaf={"#3a8a64","#56b07a","#7ccc90","#a6e0a8","#c8f0c4","#e2fadc"}, stem={"#4a5a50","#667a62","#84967a","#98c08a","#b8dca6"}, root={"#f0eadc","#dcd2bc","#c0b49a"},
vein="#d8f0cc", gloss="#d8e4f4", cool="#3a4a84", red="#7a58a0",
sl=1.1, sw=0.85, taper=0.3, drop={4,1}, marks="none", markc="#2c3646",
scrap={7,55,27,53,57,40}, scrapW=6.4, scrapExp=0.65, sprout="pair", leafw=3.8, quirk="none",
extra=function(ctx) local c=ctx.c; for _,p in ipairs({{12,50},{22,47},{32,49},{40,45},{17,54},{28,53},{46,43},{36,52}}) do c:put(p[1],p[2],"#e8f6e0",{r={name="q"}}); c:put(p[1]+1,p[2],"#d0e8d0",{r={name="q"}}) end end,
})
