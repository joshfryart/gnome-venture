local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-grain: golden wheat ear on a slim stalk with pairs of fat grains. quirk: a tiny ladybug climbing the stalk.
local c = D.new("ico-grain")
local W = { "#8a4f1c", "#b8761f", "#dc9c2c", "#f2bb44", "#fcd870", "#fff0aa" }
local stalk = D.c:line({ { 32, 58 }, { 32, 22 } }, 3)
D.lit(stalk, { "#4a5a24", "#6a7a2c", "#8a9a34", "#a8b844", "#c8d868", "#e6f09a" }, 1.5, { amb = 0.15 })
-- awns
for _, a in ipairs({ { 28, 10, 24, 2 }, { 36, 10, 40, 2 }, { 25, 18, 19, 9 }, { 39, 18, 45, 9 }, { 32, 6, 32, 0 }, { 25, 26, 19, 17 }, { 39, 26, 45, 17 } }) do
  D.ln(a[1], a[2], a[3], a[4], W[2])
end
for i = 0, 3 do
  local y = 10 + i * 7
  D.lit(D.ell(27, y + 3, 4.4, 2.8, -.9), W, 2) D.lit(D.ell(37, y + 3, 4.4, 2.8, .9), W, 2)
  D.px(26, y + 2, W[6])
end
D.lit(D.ell(32, 6, 2.6, 4), W, 1.5)
-- leaf blade
D.leaf(32, 52, 50, 34, 3, "moss")
-- ladybug
D.fill(D.ell(32, 44, 2.5, 2), D.RED[4]) D.px(31, 43, D.CR) D.px(32, 45, D.INK) D.px(30, 44, D.INK) D.px(34, 44, D.INK)
D.fin()
