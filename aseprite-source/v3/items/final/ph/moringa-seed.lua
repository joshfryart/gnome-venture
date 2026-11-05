-- moringa-seed (seed P1b_S1)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
 name="moringa-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
 seed={"#2a1c10","#47301a","#664624","#86602e","#a88040","#c8a458"}, leaf={"#3c5a1c","#527428","#6c9034","#88ac44","#a6c85c","#c6e47e"}, sleaf={"#5c8a24","#76a634","#92c248","#aede62","#c8f284","#e4ffaa"}, stem={"#5a4020","#7a5a30","#9a7840","#a0b050","#c0d070"}, root={"#f5ead2","#e6d6b0","#cebc8c"},
 vein="#e6f6a0", gloss="#fffbe0", cool="#6a9a80", red="#b87a30", sl=1.1, sw=1.3, taper=0.0, drop={4}, marks="spots", markc="#1e1208",
 scrap={8,52,24,57,56,44}, scrapW=7.0, scrapExp=0.9, sprout="trio", leafw=2.6, quirk="none",
 extra=function(x) for _,p in ipairs{{15,46},{16,45},{17,45},{14,47},{19,48},{20,48},{21,49}} do end local c=x.c for _,p in ipairs{{12,50},{13,49},{14,48},{22,50},{23,51},{24,52},{36,43},{37,42},{38,41}} do end end
})
