-- white-clover-seed (seed P1b_S4)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
 name="white-clover-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
 seed={"#b8985a","#cfb272","#e2c98c","#eedaa4","#f6e8bc","#fcf4d6"}, leaf={"#0c2620","#123629","#1a4632","#235a3c","#2e6e46","#3c8456"}, sleaf={"#1e5a3a","#2c7648","#3e9258","#58ae6a","#7cc684","#a4dca0"}, stem={"#3a4a28","#506632","#6a8240","#86a050","#a4bc66"}, root={"#f6f0dc","#e6dcb8","#cdbf92"},
 vein="#9cd8a8", gloss="#e4fadc", cool="#2c6a78", red="#7a3a50", sl=1.3, sw=1.35, taper=0.0, drop={4}, marks="none",
 scrap={9,53,29,57,56,50}, scrapW=7.6, scrapExp=0.5, sprout="trio", leafw=4.4, quirk="none",
 extra=function(ctx)
  local c, X = ctx.c, ctx.X
  -- pale trefoil chevron on the dark scrap + heart notch on each seed
  for _, p in ipairs{ {44,50},{45,51},{46,52},{47,52},{44,53},{45,52},{46,51},{47,50} } do if ctx.lm:has(p[1], p[2]) then c:put(p[1], p[2], "#6fb27c", {r={name="chev"}}) end end
  for i, s in ipairs(ctx.seeds) do
   local nx = math.floor(s[1] - math.cos(s[5]) * (s[3] * 1.3 - 0.4) + 0.5)
   local ny = math.floor(s[2] - math.sin(s[5]) * (s[3] * 1.3 - 0.4) + 0.5)
   c:put(nx, ny, "#7a5a30", {r={name="notch"..i}})
  end
 end
})
