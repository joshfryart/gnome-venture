local NAME = "stuffed-peppers-goat"
-- stuffed-peppers-goat: blue-glazed oval baking dish with tomato sauce holding two bell pepper halves (red, yellow),
-- each filled with herby rice and topped with golden-browned goat cheese rounds, basil leaf, green stem stubs. quirk: steam curls.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local GLAZE = { "#3e4e72", "#5f78a0", "#8aa6c6", "#b4cadc", "#dcecf0", "#f6fbf6" }
local SAUCE = { "#5a1420", "#862224", "#b0342a", "#d0502e", "#e8743a", "#f8a05c" }
local RED   = { "#4a1424", "#7a1c2c", "#a82a2a", "#d0402e", "#ec6a3e", "#ff9a62" }
local YEL   = { "#6a3a22", "#a85a1e", "#d88a1c", "#f2b52a", "#ffd24e", "#fff09a" }
local FILL  = { "#5a3a22", "#8a5a30", "#b8844a", "#d8aa68", "#ecc98a", "#f8e2b0" }
local CHEESE= { "#a8885a", "#d0b47e", "#ecdcae", "#f8f0d4", "#fffae6", "#fffdf0" }
local GRN   = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local function T(nm) return { r = { name = nm } } end
c:groundShadow(32, 58, 25, 3)
-- dish body: top ellipse + bottom ellipse + joining rect
local top = G.oval(32, 43, 25, 11, 0, 1)
local bot = G.oval(32, 47, 24, 10, 0, 1)
local body = HP.mask() body:add(top) body:add(bot) body:add(c:rect(8, 43, 56, 47))
local bn = {}
body:each(function(x, y) local dx, dy = (x - 32) / 26, (y - 47) / 12 local nx, ny = dx, dy local z = sqrt(max(1 - nx * nx - ny * ny * 0.6, 0.05)) bn[K(x, y)] = { G.norm(nx, ny * 0.8, z) } end)
G.toneN(c, body, bn, GLAZE, { tok = T("dish"), cuts = CUTS, amb = 0.1, wrap = 0.25 })
-- lugs
for _, p in ipairs{ {4,44},{5,44},{4,45},{5,45},{58,44},{59,44},{58,45},{59,45},{6,44},{57,44} } do c:put(p[1], p[2], GLAZE[3], T("lug")) end
c:put(4, 45, GLAZE[2], T("lug")) c:put(5, 45, GLAZE[2], T("lug")) c:put(58, 45, GLAZE[2], T("lug")) c:put(59, 45, GLAZE[2], T("lug"))
-- rim highlight band along top-left of the ellipse, blue stripe near base
top:edge():each(function(x, y) if y < 42 and x < 40 then c:put(x, y, GLAZE[6], T("dish")) end end)
for x = 12, 52 do local y = 52 if body:has(x, y) then c:put(x, y, GLAZE[2], T("dish")) end end
-- sauce inside
local sm, sn = G.oval(32, 43, 22, 8.6, 0, 1)
G.toneN(c, sm, sn, SAUCE, { tok = T("sauce"), cuts = CUTS, amb = 0.12, wrap = 0.25 })
-- pepper boat
local function pepper(cx, cy, ang, RAMP, nm, stemSide)
  local rx, ry = 11.5, 7.2
  local om, on = G.oval(cx, cy, rx, ry, ang, 1)
  -- soft shadow on sauce
  om:shift(1, 2):each(function(x, y) if not om:has(x, y) and sm:has(x, y) then c:put(x, y, SAUCE[1], T("sh")) end end)
  G.toneN(c, om, on, RAMP, { tok = T(nm), cuts = CUTS, amb = 0.1, wrap = 0.25 })
  local im, inn = G.oval(cx, cy + 0.4, rx - 2.4, ry - 2.2, ang, 1.4)
  -- inner wall: darker ring then filling
  c:fillMask(im:grow(1):clip(om), RAMP[2])
  local ft = T(nm .. "f")
  local idx = G.toneN(c, im, inn, FILL, { tok = ft, cuts = CUTS, amb = 0.15, wrap = 0.3 })
  im:each(function(x, y) local h = X.hash(x, y, 5 + cx)
    if h > 0.9 then c:put(x, y, GRN[4], ft) elseif h > 0.82 then c:put(x, y, FILL[5], ft) elseif h > 0.78 then c:put(x, y, RED[3], ft) end end)
  -- stem stub at one end
  local sx = cx + stemSide * (rx + 0.5) * cos(ang)
  local sy = cy + stemSide * (rx + 0.5) * sin(ang)
  local stm, stn = G.oval(sx, sy - 0.5, 2.6, 2.2, 0, 1)
  G.toneN(c, stm, stn, GRN, { tok = T(nm .. "s"), cuts = CUTS })
  return om, im
end
local aom, aim = pepper(22, 38, -0.2, RED, "pa", -1)
local bom, bim = pepper(42, 43, 0.15, YEL, "pb", 1)
-- goat cheese rounds, browned on top
local function cheese(cx, cy, r)
  local m, n = G.oval(cx, cy, r, r * 0.8, 0, 1.2)
  G.toneN(c, m, n, CHEESE, { tok = T("ch" .. cx), cuts = CUTS, amb = 0.12, wrap = 0.25 })
  m:each(function(x, y) if y <= cy - r * 0.2 and X.hash(x, y, cx) > 0.35 and x >= cx - 1 then c:put(x, y, "#e0a040", T("ch" .. cx)) end end)
  c:put(floor(cx - r * 0.4), floor(cy - r * 0.4), CHEESE[6], T("ch" .. cx))
end
cheese(20, 37, 3.2) cheese(26, 39, 2.6)
cheese(40, 42, 3.2) cheese(46, 44, 2.6)
-- basil leaf on the red pepper
local lm, ln = G.blade(21, 40, 24, 35, 29, 36, function(t) if t > 0.985 then return -1 end return max(0.4, 2.2 * sin(pi * t) ^ 0.8) end, { fold = 0.5 })
G.toneN(c, lm, ln, GRN, { tok = T("basil"), cuts = CUTS })
-- steam curls (quirk)
local function steam(pts) for _, p in ipairs(pts) do c:put(p[1], p[2], "#d6e2ea", T("steam")) c:put(p[1] + 1, p[2], "#b4c6d2", T("steam")) end end
steam{ {20,29},{19,27},{20,25},{21,23},{20,21} }
steam{ {40,33},{39,31},{40,29},{41,27},{40,25} }
G.save(c, NAME)
