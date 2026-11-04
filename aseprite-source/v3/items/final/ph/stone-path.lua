-- stone-path (lean D2o_13)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function pick(r, v) return r[max(1, min(#r, floor(v * #r) + 1))] end
local WOOD  = { "#3a2218", "#5c3a26", "#80522f", "#a8733d", "#cf9a55", "#ecc57e" }
local STEEL = { "#2c3040", "#4a5068", "#6d7690", "#94a0b8", "#c0cad8", "#eef2f6" }
local GOLD  = { "#5a3414", "#8a5a1a", "#b88426", "#dcae3a", "#f2d05a", "#fff0a0" }
local STONE = { "#3a3644", "#57536a", "#78748a", "#9a96a8", "#bcb8c4", "#dcd8e0" }
local WARM  = { "#4a3a38", "#6e5a52", "#917a6a", "#b49c88", "#d3bea8", "#ecdcc8" }
local MAUVE = { "#44304a", "#654666", "#876088", "#a8809f", "#c9a4b8", "#e6c8d4" }
local MOSS  = { "#1f3d2a", "#2f5c34", "#4a7f3c", "#75a64a", "#a2c862" }
local RED   = { "#4a1224", "#7a1c34", "#a82c40", "#d04a4c", "#ec7a64", "#ffb090" }
local function paint(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R); local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, o.bias, nil); return v end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stone-path" }
local S = {
 {48,15,5,3.5,WARM},{34,17,6,4,STONE},{29,26,7,4.5,MAUVE},{44,25,6,4,STONE},{18,31,6,4,WARM},{36,35,7,4.5,WARM},
 {49,37,5,4,MAUVE},{23,41,6,4,MAUVE},{42,45,7,4.5,STONE},{27,49,7,4.5,WARM},{14,50,6,4,STONE} }
local all = HP.mask()
for _, s in ipairs(S) do all:add(c:ellipse(s[1], s[2], s[3] + 1, s[4] + 1)) end
-- grass tufts in the gaps first
local tufts = { {40,20},{24,22},{36,29},{12,38},{30,43},{54,31},{20,46},{38,52},{8,44},{55,46},{22,34},{43,11} }
for _, t in ipairs(tufts) do local x, y = t[1], t[2]
  c:px(x, y, MOSS[3]) c:px(x - 1, y - 1, MOSS[4]) c:px(x + 1, y - 2, MOSS[4]) c:px(x, y - 1, MOSS[2]) c:px(x + 2, y, MOSS[2]) end
for _, s in ipairs(S) do
  local cx, cy, rx, ry, R = s[1], s[2], s[3], s[4], s[5]
  paint(c:ellipse(cx, cy + 2, rx, ry), R, 3, { amb = 0.0, wrap = 0.0 })
  local top = c:ellipse(cx, cy, rx, ry)
  paint(top, R, 4)
  c:px(cx - floor(rx / 2), cy - floor(ry / 2), R[6])
end
-- quirk: a tiny daisy in a crack
c:px(7, 36, "#fff6f2") c:px(9, 36, "#fff6f2") c:px(8, 35, "#fff6f2") c:px(8, 37, "#fff6f2") c:px(8, 36, "#f2d05a") c:px(8, 38, MOSS[3])
G.fin(c, "stone-path")
