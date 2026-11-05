-- holly-hedge (lean E2_02)
local NAME = "holly-hedge"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, nm, o)
  o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = CUTS, tok = { r = { name = nm or "p" } } })
  return idx, n
end
local function px(x, y, col, nm) c:put(x, y, col, { r = { name = nm or "d" } }) end
local function spec(m, n, col)
  local x, y = G.specAt(m, n, 30)
  if x then px(x, y, col or "#fff4dc", "spec") end
end
c:groundShadow(32, 54, 27, 3)
local HG = { "#0f2a22", "#17402e", "#1f5a38", "#2c7a44", "#44a055", "#7cc872" }
local RD = { "#4a0e18", "#8a1a22", "#c42828", "#e8463a", "#ff7a5a", "#ffd0b0" }
local hed = c:rrect(7, 28, 57, 51, 7)
for i = 0, 10 do local x = 9 + i * 4
  hed:add(c:poly{ {x, 29}, {x + 2, 23 + (i % 3 == 0 and 0 or 2)}, {x + 4, 29} }) end
local idx = shade(hed, HG, 10, "hedge")
-- holly leaves: spiky lobed
local lv = { {16,34},{28,32},{40,33},{51,34},{12,44},{23,43},{34,44},{45,43},{55,45},{20,26},{34,26},{46,27} }
for _, p in ipairs(lv) do local x, y = p[1], p[2]
  local m = c:poly{ {x-4,y}, {x-2,y-2}, {x-1,y-1}, {x+1,y-3}, {x+2,y-1}, {x+4,y}, {x+2,y+1}, {x+1,y+3}, {x,y+1}, {x-2,y+2} }
  m:shrink(0)
  m:each(function(a, b) if hed:has(a, b) then px(a, b, HG[4], "lv") end end)
  for dx = -3, 3 do if hed:has(x + dx, y) then px(x + dx, y, HG[5], "rib") end end
  if hed:has(x - 3, y - 1) then px(x - 3, y - 1, HG[6], "lv") end
end
-- berries
local B = { {17,38},{20,40},{15,41}, {36,38},{39,36},{34,41}, {48,40},{51,38},{47,44}, {26,47},{29,45} }
for i, p in ipairs(B) do
  local m = c:ellipse(p[1], p[2], 3, 3)
  m:grow(1):each(function(x, y) if hed:has(x, y) then px(x, y, HG[1], "bao") end end)
  shade(m, RD, 3, "b" .. i, { amb = 0.05 })
  px(p[1] - 1, p[2] - 1, RD[6], "bs")
end
-- robin
local rb = c:ellipse(41, 19, 6, 5)
shade(rb, { "#3a2418", "#5e3a24", "#7e5434", "#a07048", "#c09068", "#dcb088" }, 4, "robin")
local br = c:ellipse(44, 21, 3, 3)
shade(br, RD, 3, "breast", { amb = 0.1 })
c:poly{ {35,19}, {28,23}, {37,22} }:each(function(x, y) px(x, y, "#4e3020", "tail") end)
px(44, 17, "#1a1018", "eye"); px(47, 19, "#f0c030", "beak"); px(48, 19, "#f0c030", "beak")
px(41, 24, "#8a6a40", "leg"); px(41, 25, "#8a6a40", "leg")
G.save(c, NAME)
