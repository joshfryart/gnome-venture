-- wing-scale-lantern (lean W2_40)
-- Hanging hex lantern shingled with overlapping butterfly-wing scales, warm glow slit, tassel bead beneath.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function L(n,o) return X.light(n, o or { amb = 0.1, wrap = 0.25 }) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wing-scale-lantern" }
local BRASS = { "#4a2a2c", "#7a4a30", "#a9702e", "#d49a3e", "#f0c768", "#fff0a6" }
local INK = "#5a2540"
-- ring + chain
G.line(c, { {30,6},{32,5},{34,6},{34,8},{32,9},{30,8},{30,6} }, BRASS[4])
for y = 10, 11 do c:px(32, y, (y % 2 == 0) and BRASS[5] or BRASS[2]) end
-- cap (trapezoid)
local cap = c:poly{ {32,12},{39,15},{43,17},{21,17},{25,15} }
G.tone(c, cap, L(X.pillow(cap, 4)), BRASS, { 0.2, 0.4, 0.6, 0.8, 0.92 })
-- body
local function hw(y) local t = (y - 17) / 25 return 11 + 2.5 * sin(t * pi) end
local body = HP.mask()
for y = 17, 42 do local h = hw(y) for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do body:set(x, y) end end
local n = X.pillow(body, 12)
local v = L(n, { amb = 0.25, wrap = 0.35 })
local SC = { "#b0405e", "#d8587a", "#f27f8c", "#f9a56e", "#fcc86a", "#fff0a0" }
body:each(function(x, y)
  local row = floor((y - 17) / 5)
  local ry = (y - 17) % 5
  local off = (row % 2 == 0) and 0 or 3
  local cx = (x + off) % 6
  -- scallop: bottom edge curves up at scale centre
  local edge = 4 - floor(abs(cx - 2.5) * 0.9)
  local k = v[K(x, y)] or 0.5
  local glow = 1 - min(1, abs(x - 32) / 9)
  local t = min(1, max(0, k * 0.7 + glow * 0.35 - (y - 17) * 0.004))
  local idx = 1 + floor(t * 5.99)
  if ry == edge then idx = max(1, idx - 2) c:px(x, y, SC[idx])
  elseif ry > edge then c:px(x, y, SC[max(1, idx - 2)])
  else c:px(x, y, SC[idx]) end
  if ry == 1 and cx == 2 and X.hash(x, y, 5) > 0.4 then c:px(x, y, SC[6]) end
end)
-- glowing seam slit
for y = 19, 40 do c:px(32, y, (y % 5 == 4) and SC[4] or "#fff6c0") end
-- frame ribs
for y = 17, 42 do local h = hw(y) c:px(floor(32 - h + 0.5), y, BRASS[2]) c:px(floor(32 + h - 0.5), y, BRASS[1]) end
-- bottom cap + tassel
local bot = c:poly{ {22,42},{42,42},{38,45},{26,45} }
G.tone(c, bot, L(X.pillow(bot, 3)), BRASS, { 0.25, 0.5, 0.75, 0.9 })
for y = 46, 47 do c:px(32, y, BRASS[3]) end
local bead = c:ellipse(32, 50, 2.6, 3)
G.tone(c, bead, L(X.pillow(bead, 3)), SC, { 0.2, 0.4, 0.6, 0.8 })
c:px(31, 49, SC[6])
c:px(25, 25, "#fff6c0") c:px(24, 26, "#fff6c0")
G.fin(c, "wing-scale-lantern")
