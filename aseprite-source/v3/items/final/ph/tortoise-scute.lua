-- tortoise-scute (lean E2_17)
local NAME = "tortoise-scute"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function ell(cx, cy, rx, ry, a)
  a = a or 0
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy - max(rx, ry)) - 1, floor(cy + max(rx, ry)) + 1 do for x = floor(cx - max(rx, ry)) - 1, floor(cx + max(rx, ry)) + 1 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u, v = (dx * ca + dy * sa) / rx, (-dx * sa + dy * ca) / ry
    if u * u + v * v <= 1 then m:set(x, y) end
  end end
  return m
end
local function shade(m, ramp, tok, R, amb, wrap)
  local n = X.pillow(m, R)
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = amb or 0.1, wrap = wrap or 0.2 })
  return n
end
local function dot(x, y, col, tok) c:put(floor(x), floor(y), col, tok) end
local SC = { "#2e1c14", "#5a3a1e", "#8c5e28", "#bf8c3a", "#e0b45a", "#fbe49a" }
local DARK = "#2a1810"
c:groundShadow(32, 57, 21, 3)
local m = c:poly{ {32,6},{52,14},{57,36},{45,55},{19,55},{7,36},{12,14} }
local n = X.pillow(m, 22)
local t = { r = { name = "scute" } }
G.toneN(c, m, n, SC, { tok = t, cuts = CUTS, amb = 0.08, wrap = 0.18 })
-- growth rings (concentric, shrinking), slightly off-centre areola
local cx, cy = 32, 32
for _, k in ipairs{ 1, 5, 9, 14, 19 } do
  local r = m:shrink(k)
  r:edge():each(function(x, y) c:put(x, y, (x + y < 64) and SC[5] or SC[1], t) end)
end
m:shrink(19):each(function(x, y) c:put(x, y, SC[4], t) end)
-- radial seams to the corners
for _, p in ipairs{ {32,6},{52,14},{57,36},{45,55},{19,55},{7,36},{12,14} } do
  c:line({ {cx, cy}, {p[1], p[2]} }, 1):clip(m:shrink(2)):each(function(x, y) if (x + y) % 3 ~= 0 and abs(x - cx) + abs(y - cy) > 9 then c:put(x, y, SC[2], t) end end)
end
local bx, by = G.specAt(m, n, 40) if bx then c:put(bx, by, SC[6], t) c:put(bx + 1, by, SC[6], t) c:put(bx, by + 1, SC[5], t) end
-- quirk: bite chip in the lower-right rim with a speck of green algae
local chip = ell(52, 50, 4, 3) chip:clip(m) chip:each(function(x, y) c:put(x, y, SC[1], t) end)
chip:shrink(1):each(function(x, y) c:put(x, y, SC[2], t) end)
for _, p in ipairs{ {26,40},{27,40},{26,41},{40,22} } do dot(p[1], p[2], "#5aa84a", { r = { name = "alga" } }) end
dot(27, 41, "#8ed06a", { r = { name = "alga" } })
G.save(c, NAME)
