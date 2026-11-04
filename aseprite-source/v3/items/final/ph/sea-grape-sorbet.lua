-- sea-grape-sorbet (first draft, Sonnet). A stemmed glass coupe holding two frosty purple sorbet scoops with
-- speckled crystals, a cluster of four sea grapes and a round red-veined sea-grape leaf tucked behind as garnish.
-- quirk: a purple drip melts over the coupe lip and runs down the stem.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sea-grape-sorbet")
local floor = math.floor
c:groundShadow(32, 58, 14, 2)
-- leaf behind (round, red veins)
local lf = c:ellipse(44, 17, 9, 8)
A.lit(c, lf, A.R("#4a9a4e"), 4, { amb = .1 })
for i = -6, 6, 3 do A.ln(c, 44, 24, 44 + i, 13, "#b5394a") end
A.ln(c, 44, 25, 44, 12, "#e86a5a")
-- foot, stem, bowl
A.lit(c, c:ellipse(32, 56, 12, 3), A.R("#cfe8f0"), 2, {})
A.rod(c, 32, 56, 32, 42, 1.6, "#cfe8f0", { amb = .1 })
local bowl = c:ellipse(32, 34, 16, 11):clip(c:rect(0, 32, 63, 50))
bowl:add(c:rect(16, 28, 48, 32))
A.lit(c, bowl, A.R("#b6f0e0"), 6, { amb = .12, wrap = .4 })
-- scoops
local sc = A.R("#7a58c8")
A.sph(c, 25, 26, 8, sc, { nospec = true })
A.sph(c, 39, 25, 8.5, sc, { nospec = true })
for _, s in ipairs{ { 25, 26, 8 }, { 39, 25, 8.5 } } do
  A.speck(c, c:ellipse(s[1], s[2], s[3], s[3]), { "#c9b2f0", "#5a459e", "#fff4d6" }, .14, s[1])
end
c:px(22, 22, "#e0d0ff") c:px(23, 22, "#e0d0ff") c:px(36, 20, "#e0d0ff") c:px(37, 20, "#e0d0ff")
-- scoop frill
for x = 17, 46, 3 do c:px(x, 31, sc[2]) end
-- bowl lip + shine
c:fillMask(c:rect(16, 31, 48, 31), "#e4fff8")
for y = 33, 42 do c:px(20 + floor((y - 33) / 3), y, "#f4fffc") end
-- grape cluster on top
for _, g in ipairs{ { 30, 15 }, { 35, 14 }, { 32, 19 }, { 37, 19 } } do
  A.sph(c, g[1], g[2], 2.6, "#8a3a8a", { spec = "#ffd8f4" })
end
c:px(31, 11, "#7a4a28") c:px(31, 12, "#7a4a28")
-- drip
c:fillMask(c:rect(47, 32, 48, 36), "#7a58c8") c:px(47, 37, "#7a58c8") c:px(48, 37, "#5a459e") c:px(47, 33, "#c9b2f0")
c:fillMask(c:rect(33, 44, 33, 47), "#7a58c8")
A.fin()
