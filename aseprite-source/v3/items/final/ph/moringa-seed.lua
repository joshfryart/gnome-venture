-- moringa-seed (seed W1_3)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
 name="moringa-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
 seed={"#3a2c2a","#584440","#7a6458","#9c8470","#bea48a","#dcc8a8"}, leaf={"#2a4a4a","#386460","#4a8070","#62a080","#86bc94","#b0d8b0"}, sleaf={"#4a9078","#66b08a","#88cc9c","#a8e4b0","#c8f4cc","#e4ffe4"}, stem={"#4a4058","#6a5c68","#8a7c76","#70a888","#92c8a0"}, root={"#f0e4d0","#f8f0e0","#fffaf0"},
 vein="#c0e8c4", gloss="#f4ead8", cool="#46486a", red="#b0705a",
 sl=0.9, sw=0.95, taper=0.0, drop={4}, marks="none", markc="#cdb89a",
 scrap={7,54,30,56,57,40}, scrapW=5.0, scrapExp=0.5, sprout="pair", leafw=2.6, quirk="none",
 extra=function(ctx) local c=ctx.c for _,p in ipairs({{22,47},{23,46},{24,45},{34,48},{35,47}}) do c:put(p[1],p[2],"#d8c8a8",{r={name="q"}}) end end,
})
