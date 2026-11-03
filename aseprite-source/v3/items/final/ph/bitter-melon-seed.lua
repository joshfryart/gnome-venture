-- bitter-melon-seed: flat, ridged, notched tan seeds on a leaf scrap; sprout is a five-lobed palmate vine leaf on a thin stem with a curling tendril. quirk: one seed is still wrapped in a red-orange aril sleeve.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bitter-melon-seed")
local SD = { "#5a3c20", "#8a6234", "#b48a4e", "#d4aa6c", "#ecca90", "#fae8bc" }
D.scrap(4, 56, 56, 50, 8, D.GRN, {})
-- palmate leaf
D.ln(40, 46, 40, 28, "#86b86c") D.ln(41, 46, 41, 28, "#4a7a40")
for _, l in ipairs{ {-1.2, 5.5}, {-.6, 6.5}, {0, 7}, {.6, 6.5}, {1.2, 5.5} } do
  local a = l[1] local ex, ey = 40 + sin(a) * l[2] * 1.4, 22 - cos(a) * l[2] * 1.2
  D.lf((40 + ex) / 2 + .5, (28 + ey) / 2 - 1, 2.8, l[2] * .75, a, D.LEAF2)
end
D.lf(40, 23, 3, 3, 0, D.LEAF2)
for _, a in ipairs{ -1.2, -.6, 0, .6, 1.2 } do D.ln(40, 24, floor(40 + sin(a) * 9), floor(24 - cos(a) * 8), "#c8e898") end
-- tendril
for a = 0, 8, .5 do c:px(floor(44 + cos(a) * (1 + a * .35) + .5), floor(34 + sin(a) * (1 + a * .35) + .5), "#86b86c") end
local function seed(cx, cy, aril)
  c:fillMask(D.ell(cx + 1, cy + 1.2, 5.4, 3.4, .25), "#1f4a3a")
  local m = D.ell(cx, cy, 5.2, 3.2, .25)
  D.lit(m, aril and { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" } or SD, 2)
  if not aril then for i = -3, 3, 2 do c:px(cx + i, cy + floor(i * .25), SD[2]) end c:px(cx - 4, cy - 1, SD[1]) end
  c:px(cx - 2, cy - 2, "#fff4d6")
end
seed(14, 51, false) seed(28, 53, false) seed(42, 49, true)
D.fin()
