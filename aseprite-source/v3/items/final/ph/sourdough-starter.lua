-- sourdough-starter (lean D2o_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sourdough-starter" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias) return v, n end
local function fill(m, hex) c:fillMask(m, hex) end
-- glass jar of bubbly starter, gingham cloth lid with rubber band, dough bubble about to pop (quirk)
local GLASS = { "#3b5f7d", "#5f8fae", "#8fc0d6", "#c4e4ee", "#eaf8fa" }
local DOUGH = { "#b99a62", "#d9bf84", "#efdcaa", "#fbefcc", "#fffaf0" }
c:groundShadow(32, 58, 15, 3)
local jar = c:rrect(17, 22, 47, 55, 4)
shade(jar, 11, GLASS, { amb = 0.2 })
local dough = HP.mask() dough:add(c:rrect(19, 31, 45, 53, 3))
dough:add(c:ellipse(25, 31, 4, 2)) dough:add(c:ellipse(37, 31, 5, 2)) dough:add(c:ellipse(31, 29, 3, 2))
shade(dough, 8, DOUGH)
-- bubbles
local B = { {24,37,3}, {35,40,4}, {28,47,3}, {40,34,2}, {40,48,3}, {22,50,2} }
for _, b in ipairs(B) do
  local e = c:ellipse(b[1], b[2], b[3], b[3]) local ring = e:copy():cut(e:copy():shrink(1))
  fill(ring, "#a98a58") c:px(b[1] - 1, b[2] - 1, "#fffaf0") end
c:px(31, 28, "#fffaf0") c:px(30, 28, "#efdcaa") c:px(32, 28, "#a98a58") c:px(29, 29, "#a98a58") c:px(33, 29, "#a98a58")
-- paper label
fill(c:rect(27, 44, 38, 51), "#f3e6c8") fill(c:rect(27, 51, 38, 51), "#c4a876")
for x = 29, 36 do c:px(x, 46, "#7a5a3a") end for x = 29, 34 do c:px(x, 48, "#a98a58") end
c:px(32, 49, "#a98a58")
-- glass streaks
for y = 25, 50 do c:px(19, y, "#eaf8fa") end for y = 33, 46 do c:px(20, y, "#c4e4ee") end
for y = 30, 52 do c:px(45, y, "#5f8fae") end
-- cloth lid
local cloth = c:rrect(15, 13, 49, 24, 3)
cloth:each(function(x, y)
  local chk = (floor((x - 15) / 3) + floor((y - 13) / 3)) % 2 == 0
  local sh = (x > 42) or y > 22 or (x % 11 == 5)
  local hx = chk and (sh and "#9f2a2a" or "#d6574c") or (sh and "#c9bcc0" or "#f1e8e6")
  c:put(x, y, hx, { r = { name = "cloth" } }) end)
for x = 17, 47 do c:px(x, 24, "#8a7078") end
fill(c:rect(16, 25, 48, 26), "#d6402e") fill(c:rect(16, 26, 48, 26), "#8e2a2a") for x = 20, 44, 6 do c:px(x, 25, "#f08a5e") end
G.fin(c, "sourdough-starter")
