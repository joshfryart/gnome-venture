-- stag-beetle-shell (lean E2_08)
local NAME = "stag-beetle-shell"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function blob(m, ramp, name, R, o)
  o = o or {}
  local n = X.pillow(m, R or 3)
  local tok = { r = { name = name } }
  return X.tone(c, m, X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n, tok
end
local function put(x, y, col, name) c:put(floor(x + .5), floor(y + .5), col, { r = { name = name or "d" } }) end
local function dots(m, col, name) m:each(function(x, y) c:put(x, y, col, { r = { name = name or "d" } }) end) end

local SH = { "#2a0e0c", "#521a12", "#7e2c1a", "#a84a24", "#d27a38", "#f4b668" }
local DK = { "#1a0a0c", "#32161a", "#4e2422", "#6c3830", "#8c5444", "#b07c62" }
c:groundShadow(34, 56, 22, 3)
-- legs (curled, jointed) under body
local function leg(pts) local m = c:line(pts, 1) blob(m, DK, "leg", 1.5) end
leg({ {27,45},{22,52},{17,55} }) leg({ {34,47},{33,54},{29,57} }) leg({ {42,46},{47,52},{53,53} })
-- head + antler mandibles (left)
local head = c:ellipse(15, 37, 6, 5)
blob(head, SH, "head", 5)
local m1 = G.tube({ {12,33}, {5,30}, {5,20}, {11,13} }, function(t) return 2.0 - 0.9 * t end)
blob(m1, DK, "mand1", 2)
local m2 = G.tube({ {12,40}, {6,43}, {4,50}, {8,53} }, function(t) return 1.5 - 0.4 * t end)
blob(m2, DK, "mand2", 2)
-- inner tooth
for _, p in ipairs{ {7,26},{8,25} } do put(p[1], p[2], DK[5], "tooth") end
-- pronotum
local pro = c:ellipse(23, 36, 6, 9)
blob(pro, SH, "pronotum", 6)
-- elytra (the shell): big glossy dome
local el = c:ellipse(40, 36, 18, 12)
local _, en, etok = blob(el, SH, "elytra", 13, { wrap = 0.3 })
-- seam crack along the top back + ribs
for x = 26, 56 do local y = 24 + floor((x - 26) * 0.25 + .5) if el:has(x, y) then put(x, y, SH[1], "seam") end end
for _, rx in ipairs{ 31, 37, 43, 49 } do for y = 28, 44 do
  local yy = y + floor(sin((rx - 26) / 8) * 1.5)
  if el:has(rx, yy) and (y % 2 == 0) then c:put(rx, yy, SH[3], { r = { name = "rib" } }) end end end
-- big gloss streak + spec
for i = 0, 8 do put(30 + i, 27 - floor(i / 3) + 2 + floor(i / 2), SH[6], "gloss") end
put(32,28,"#fff6d8") put(33,28,"#fff6d8")
-- empty-shell tell: open hatch on the rear, dark hollow
local hol = c:ellipse(55, 41, 2, 4); hol:clip(el)
dots(hol, SH[1], "hollow")
-- quirk: a dewdrop on the shell
put(46,31,"#d8f0ff","dew") put(46,32,"#6aa8e0","dew") put(45,31,"#fafcff","dew")
c:sparkle(31, 24)
G.save(c, NAME)
