-- steppe-peony-seed (seed P1b_S2)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({ name="steppe-peony-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
 seed={"#080e22","#101c3c","#1a2c58","#284078","#3c5a9c","#6a88c4"}, leaf={"#3a6a5e","#4c8474","#62a08a","#7cbaa0","#9ad2b4","#bceacc"}, sleaf={"#245a4a","#2e7660","#3e927a","#58ae94","#7ac8ae","#a2e0c8"}, stem={"#5a1e30","#7e2c42","#a44058","#6a9a58","#8cb872"},
 vein="#e0fcec", gloss="#f2fcf6", cool="#4a78b0", red="#c8283c", sl=1.15, sw=1.4, taper=0.04, drop={4}, marks="none",
 scrap={8,52,30,56,56,46}, scrapW=6.4, scrapExp=0.6, sprout="pair", leafw=4.4, quirk="none",
 extra=function(ctx)
  local s = ctx.seeds[2]
  local R = {"#4a0a14","#70101e","#962030","#bc3646","#dc5c68","#f49a9c"}
  ctx.X.tone(ctx.c, s.m, ctx.X.light(s.n, { amb = 0.06, wrap = 0.22 }), R, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = { r = { name = "redseed" } } })
 end
})
