-- steppe-peony-seed (seed W1_6)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
 name="steppe-peony-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
 seed={"#1a1024","#2e1a3c","#472a58","#68407a","#8a5e9a","#b48cc0"}, leaf={"#1e3a3a","#2a5646","#3a7452","#549a5a","#7cbc6c","#a8dc88"}, sleaf={"#2c5a44","#3e7c50","#58a05c","#7cc468","#a4e080","#c8f0a0"}, stem={"#5a3a4a","#7c4c52","#a06458","#6a9a4a","#8cbc5c"}, root={"#e8d8c0","#f4e8d4","#fff4e4"},
 vein="#2a5a4a", gloss="#e0c8f0", cool="#3a2a6a", red="#a8305a", sl=1.3, sw=1.25, taper=0, drop={4,1}, marks="none", markc="#6a4a80", scrap={7,55,28,52,57,40}, scrapW=4.2, scrapExp=0.6, sprout="trio", leafw=2.6, quirk="none",
 extra=function(ctx) ctx.c:put(20,46,"#b83a4a",{r={name="q"}}) ctx.c:put(21,46,"#d85a60",{r={name="q"}}) ctx.c:put(20,47,"#8a2a46",{r={name="q"}}) end
})
