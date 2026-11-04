-- myrtle-seed: tiny pale kidney-shaped seeds on a scrap, sprout with opposite pairs of small pointed dotted leaves. quirk: a white five-stamen myrtle flower bud tops the sprout.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("myrtle-seed")
D.scrap(c, { ramp = "sea", y0 = 52, y1 = 56, x0 = 7, x1 = 57, w = 6 })
local LF = D.R("#b8e890", "#4ea860", "#2b7a56", "#1c4a4a")
D.stem(c, { {32,48}, {31,38}, {32,28}, {32,18} }, 1, "#6a5a3a", "#a89460")
for i, y in ipairs{ 43, 36, 29, 22 } do
  local s = 4.8 - i * .5
  D.leafE(c, 32 - s - 1, y, s, s * .5, -0.35, LF, 0)
  D.leafE(c, 32 + s + 1, y - 2, s, s * .5, 0.35, LF, 0)
end
-- flower bud: pale ball with stamens
B.lit(c, c:ellipse(32, 14, 2.6, 2.6), D.R("#fffaea", "#fff4d6", "#e8d0c8", "#a8908e"), 2)
for _, p in ipairs{ {28,10}, {30,8}, {32,7}, {34,8}, {36,10} } do c:px(p[1], p[2], "#fff4d6") c:px(p[1] + (p[1] > 32 and 0 or 0), p[2] - 1, "#f5b82e") end
local KD = D.R("#fffbe0", "#f0e0a8", "#c8a870", "#7a5a3c")
for _, s in ipairs{ {14,52,0.3}, {22,54,-0.6}, {44,53,0.8}, {52,52,-0.3} } do
  c:fillMask(B.ell(s[1] + 1, s[2] + 1.2, 3.1, 2.4, s[3]), "#1c4a4a")
  local m = B.ell(s[1], s[2], 3, 2.3, s[3]):cut(B.ell(s[1] + 1.5 * sin(s[3]), s[2] + 2.4 * cos(s[3]) , 2, 1.2, s[3]))
  B.lit(c, m, KD, 2)
  c:px(s[1] - 1, s[2] - 1, "#fff4d6")
end
D.fin()
