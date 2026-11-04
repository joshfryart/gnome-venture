-- root_cellar-mossy (first draft, Sonnet). An old lumpy cellar swallowed by thick moss: shaggy moss clumps, a
-- mossy block-stone arch with a small plank door, two red toadstools at the foot.
-- quirk: a snail has parked on top of the arch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("root_cellar-mossy")
c:groundShadow(32, 58, 24, 3)
local m = c:ellipse(30, 40, 24, 15):add(c:ellipse(18, 42, 12, 12)):add(c:ellipse(44, 44, 12, 10)):add(c:ellipse(30, 36, 14, 14)):clip(c:rect(0, 0, 63, 54))
A.lit(c, m, "#4a8a4a", 5, { amb = .08, wrap = .3 })
A.speck(c, m, { "#8fc060", "#2c5a40", "#b0d870" }, .22, 4)
A.lit(c, c:rect(6, 54, 56, 56), "wood", 1.6)
local fr = A.archM(c, 30, 54, 10, 19)
A.lit(c, fr, "stone", 2.4)
for _, p in ipairs{ { 20, 44 }, { 20, 49 }, { 40, 42 }, { 40, 48 } } do A.ln(c, p[1], p[2], p[1] + 2, p[2], "#444663") end
for _, p in ipairs{ { 24, 37 }, { 30, 36 }, { 36, 37 } } do A.ln(c, p[1], p[2], p[1], p[2] + 3, "#444663") end
A.door(c, 30, 54, 7, 15, "#864c33", { strap = "#444663" })
-- moss drips over the arch
for _, p in ipairs{ { 22, 40 }, { 27, 36 }, { 33, 36 }, { 38, 41 } } do for d = 0, 2 do c:px(p[1], p[2] + d, "#6aa84a") end c:px(p[1], p[2] + 3, "#3f7a40") end
-- mushrooms
for _, s in ipairs{ { 9, 52 }, { 54, 51 } } do
  c:fillMask(c:rect(s[1], s[2], s[1] + 1, s[2] + 3), "#f0e0c0")
  A.lit(c, c:ellipse(s[1] + .5, s[2] - 1, 3.5, 2.5), "ember", 1.4)
  c:px(s[1], s[2] - 2, "#fff4d6") c:px(s[1] + 2, s[2] - 1, "#fff4d6")
end
-- snail on top
A.sph(c, 31, 22, 3, "#d9a070", {}) c:px(31, 22, "#864c33") c:px(32, 22, "#864c33")
A.lit(c, c:rect(25, 25, 34, 26), "#c0b090", 1)
A.ln(c, 25, 24, 24, 21, "#c0b090") A.ln(c, 26, 24, 27, 21, "#c0b090")
A.fin()
