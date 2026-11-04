-- stag-beetle-shell (lean D2o_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stag-beetle-shell" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function tshade(m, n, ramp, o) o = o or {}
  local v = X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return v
end
local SH = { "#2a0f12", "#4b1a1a", "#74291f", "#a14526", "#cd7035", "#f0a860" }
local MD = { "#1e0d10", "#3a1a18", "#5e2c22", "#8a4a30" }
local WG = { "#6a5a8a", "#a898c4", "#d8cce8" }
local left = c:ellipse(24.5, 34, 8.5, 19)
local right = c:ellipse(40.5, 34, 8.5, 19):cut(left)
-- hind wing peeking from under the right shell (quirk)
local wing = c:ellipse(41, 53, 8, 4):cut(left):cut(right)
shade(wing, WG, 3)
for x = 36, 46 do if wing:has(x, 55) then c:px(x, 55, WG[1]) end end
-- mandibles
local m1, n1 = G.tube({ {26, 15}, {20, 9}, {19, 4}, {26, 4} }, function(t) return 2.2 - 1.3 * t end)
local m2, n2 = G.tube({ {38, 15}, {44, 9}, {45, 4}, {38, 4} }, function(t) return 2.2 - 1.3 * t end)
tshade(m1, n1, MD) tshade(m2, n2, MD)
c:px(19, 8, MD[4]) c:px(20, 7, MD[4]) c:px(45, 8, MD[4])
c:px(20, 10, MD[1])
-- shells: seamed halves
local b1, b2 = {}, {}
X.ao(b1, left, c:rect(32, 14, 34, 54), 2, -1)
shade(left, SH, 8, { bias = b1 })
shade(right, SH, 8)
-- seam shadow column and ridges
for y = 14, 54 do
  if left:has(32, y) then c:px(32, y, SH[1]) end
  if left:has(31, y) then c:px(31, y, SH[2]) end
  if right:has(33, y) then c:px(33, y, SH[2]) end
end
for _, r in ipairs{ {20, 0.012}, {27, 0.01}, {36, -0.01}, {44, -0.012} } do
  for y = 20, 49 do
    local x = floor(r[1] + r[2] * (y - 34) ^ 2 * (r[1] < 32 and -1 or 1) * 1.0 + 0.5)
    local m = (r[1] < 32) and left or right
    if m:has(x, y) and y % 5 ~= 0 then c:px(x, y, SH[2]) end
    if m:has(x - 1, y) and y % 5 ~= 0 and (x - 1) ~= 32 then c:px(x - 1, y, SH[5]) end
  end
end
-- glints
c:px(20, 24, "#fff2d8") c:px(21, 24, "#fff2d8") c:px(20, 25, SH[6]) c:px(20, 26, SH[6])
c:px(36, 26, SH[6]) c:px(36, 27, SH[6])
-- wing-case hinge nubs
c:px(26, 15, SH[1]) c:px(38, 15, SH[1])
G.fin(c, "stag-beetle-shell")
