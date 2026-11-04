-- garden-gate-cross (lean W2_4)
-- Two weathered pickets crossed in an X, pointed tips, bound with a rope wrap and a nail; a red ribbon quirk.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local function shade(c, m, R, r, amb, bias) local n = X.pillow(m, r) local v = X.light(n, { amb = amb or 0.1, wrap = 0.25 }) G.tone(c, m, v, R, CUTS, bias) return v, n end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "garden-gate-cross" }
local WD = { "#3d2418", "#5c3a22", "#805030", "#a8703e", "#cf9a5a", "#ebc684" }
local RP = { "#6d5a32", "#9a8448", "#c6af6a", "#e6d596" }
local RD = { "#7a1d28", "#b32e36", "#e0505a" }
local function picket(ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  local len = sqrt(dx * dx + dy * dy)
  local ux, uy = dx / len, dy / len
  local px, py = -uy, ux
  local w = 3.2
  local tip = 8
  local pts = { {ax + px * w, ay + py * w}, {bx - ux * tip + px * w, by - uy * tip + py * w}, {bx, by}, {bx - ux * tip - px * w, by - uy * tip - py * w}, {ax - px * w, ay - py * w} }
  local m = c:poly(pts)
  local v = shade(c, m, WD, 3.5, 0.1)
  m:each(function(x, y)
    local s = (x - ax) * px + (y - ay) * py
    local t = (x - ax) * ux + (y - ay) * uy
    if abs(s - 0.5) < 0.6 and t > 2 and t < len - 10 and X.hash(floor(t), 1, 5) > 0.3 then c:put(x, y, WD[2]) end
    if abs(s + 1.8) < 0.5 and X.hash(floor(t / 2), 2, 5) > 0.5 then c:put(x, y, WD[5]) end
  end)
  return m
end
picket(14, 54, 49, 8)
picket(50, 54, 15, 8)
-- rope wrap at the crossing
for i = 0, 4 do
  local y = 30 + i * 2
  for x = 27, 37 do if (x + i) % 4 < 3 then c:put(x, y, RP[2 + (i % 2)]) else c:put(x, y, RP[1]) end end
end
for x = 27, 37 do c:put(x, 29, "#2b1c26") c:put(x, 39, "#2b1c26") end
c:put(28, 31, RP[4]) c:put(29, 31, RP[4])
-- nail head
c:put(32, 34, "#c9d2dc") c:put(33, 34, "#6c7686")
-- red ribbon quirk
G.line(c, { {37,33},{41,35},{43,40} }, RD[2]) c:put(44, 41, RD[1]) c:put(42, 36, RD[3]) c:put(43, 42, RD[1])
G.fin(c, "garden-gate-cross")
