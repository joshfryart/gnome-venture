-- stone-wall (lean D2o_13)
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
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stone-wall" }
c:groundShadow(32, 53, 25, 2)
c:fillMask(c:rect(8, 28, 55, 51), STONE[1])
local rampsL = { WARM, STONE, MAUVE }
for r = 0, 3 do
  local y0 = 29 + r * 6
  local x = 8 - ((r % 2) * 4)
  local i = 0
  while x < 56 do
    i = i + 1
    local w = 7 + floor(X.hash(i, r, 7) * 7)
    local x0, x1 = max(8, x), min(55, x + w - 2)
    if x1 - x0 >= 3 then
      paint(c:rrect(x0, y0, x1, y0 + 4, 1), rampsL[1 + floor(X.hash(i, r, 9) * 3)], 3)
    end
    x = x + w
  end
end
-- capstones
local x, i = 7, 0
while x < 57 do
  i = i + 1
  local w = 9 + floor(X.hash(i, 5, 7) * 6)
  local x1 = min(56, x + w - 2)
  paint(c:rrect(x, 21, x1, 28, 3), rampsL[1 + floor(X.hash(i, 5, 9) * 3)], 4)
  x = x + w
end
for _, p in ipairs{ {12,21,3},{13,21,4},{14,22,3},{15,21,2},{40,21,3},{41,21,4},{42,21,3},{26,21,3},{27,21,2} } do c:px(p[1], p[2], MOSS[p[3]]) end
-- crack
G.line(c, { {34,37}, {35,39}, {34,41} }, STONE[1])
-- quirk: a snail on the cap
paint(c:ellipse(47, 18, 2.4, 2.4), { "#5c2a1c", "#8a4a2c", "#b87040", "#dca060", "#f2c888", "#fff0c0" }, 2)
G.line(c, { {44,20}, {50,20} }, "#a89a82") c:px(51, 19, "#a89a82") c:px(52, 18, "#6a5a4a")
G.fin(c, "stone-wall")
