local NAME = "stuffed-peppers-goat"
-- stuffed-peppers-goat (simplified redraw): blue oval dish, tomato sauce, TWO big clean pepper halves (red, yellow),
-- each with a smooth golden-browned goat-cheese dome and one basil leaf. quirk: one steam curl. Few big shapes, little noise.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local GLAZE = { "#3e4e72", "#5f78a0", "#8aa6c6", "#b4cadc", "#dcecf0", "#f6fbf6" }
local SAUCE = { "#5a1420", "#862224", "#b0342a", "#d0502e", "#e8743a", "#f8a05c" }
local RED   = { "#4a1424", "#7a1c2c", "#a82a2a", "#d0402e", "#ec6a3e", "#ff9a62" }
local YEL   = { "#6a3a22", "#a85a1e", "#d88a1c", "#f2b52a", "#ffd24e", "#fff09a" }
local CHEESE= { "#b08a54", "#d8b878", "#ecd49a", "#f8ecc4", "#fffae6", "#fffdf0" }
local GRN   = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local function T(nm) return { r = { name = nm } } end
c:groundShadow(32, 54, 22, 3)
-- dish: wide shallow oval bowl
local top = G.oval(32, 40, 24, 12, 0, 1)
local bot = G.oval(32, 44, 21, 10, 0, 1)
local body = HP.mask() body:add(top) body:add(bot) body:add(c:rect(11, 40, 53, 44))
local bn = {}
body:each(function(x, y) local dx, dy = (x - 32) / 26, (y - 44) / 12 local z = sqrt(max(1 - dx * dx - dy * dy * 0.6, 0.05)) bn[K(x, y)] = { G.norm(dx, dy * 0.8, z) } end)
G.toneN(c, body, bn, GLAZE, { tok = T("dish"), cuts = CUTS, amb = 0.1, wrap = 0.25 })
top:edge():each(function(x, y) if y < 40 and x < 38 then c:put(x, y, GLAZE[6], T("dish")) end end)
for x = 14, 50 do if body:has(x, 49) then c:put(x, 49, GLAZE[2], T("dish")) end end
-- sauce
local sm, sn = G.oval(32, 40, 21, 9, 0, 1)
G.toneN(c, sm, sn, SAUCE, { tok = T("sauce"), cuts = CUTS, amb = 0.12, wrap = 0.25 })
-- pepper halves: big smooth ovals with a plain rice-gold filling and a cheese dome
local function pepper(cx, cy, RAMP, nm)
  local om, on = G.oval(cx, cy, 12, 7.5, 0, 1)
  om:shift(1, 2):each(function(x, y) if not om:has(x, y) and sm:has(x, y) then c:put(x, y, SAUCE[1], T("sh")) end end)
  G.toneN(c, om, on, RAMP, { tok = T(nm), cuts = CUTS, amb = 0.1, wrap = 0.25 })
  om:edge():each(function(x, y) if y > cy - 2 then c:put(x, y, RAMP[1], T(nm)) end end)
  local im, inn = G.oval(cx, cy + 0.5, 9, 5, 0, 1.4)
  c:fillMask(im:grow(1):clip(om), RAMP[2])
  local ch, cn = G.oval(cx, cy + 0.5, 8.5, 4.5, 0, 1.2)
  G.toneN(c, ch, cn, CHEESE, { tok = T("ch" .. nm), cuts = CUTS, amb = 0.12, wrap = 0.25 })
  -- golden browned patch (one clean blob), upper right of the dome
  ch:each(function(x, y) if (x - cx - 2) ^ 2 / 16 + (y - cy + 1) ^ 2 / 4 < 1 then c:put(x, y, "#e0a040", T("br" .. nm)) end end)
  c:put(cx + 3, cy - 1, "#b87428", T("br" .. nm)) c:put(cx + 4, cy - 1, "#b87428", T("br" .. nm))
  c:put(cx - 4, cy - 2, CHEESE[6], T("ch" .. nm)) c:put(cx - 3, cy - 2, CHEESE[6], T("ch" .. nm))
  return om
end
pepper(23, 37, RED, "pa")
pepper(42, 43, YEL, "pb")
-- basil leaf
local lm, ln = G.blade(20, 38, 24, 32, 29, 33, function(t) if t > 0.985 then return -1 end return max(0.5, 2.6 * sin(pi * t) ^ 0.8) end, { fold = 0.5 })
G.toneN(c, lm, ln, GRN, { tok = T("basil"), cuts = CUTS })
-- quirk: one steam curl
for _, p in ipairs{ {30,26},{29,24},{30,22},{31,20},{30,18},{29,16} } do c:put(p[1], p[2], "#d6e2ea", T("steam")) c:put(p[1] + 1, p[2], "#b4c6d2", T("steam")) end
G.save(c, NAME)
