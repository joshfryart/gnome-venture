-- tile-bark-path (lean E2_17)
local NAME = "tile-bark-path"
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
local SOIL = { "#1c1218", "#33201f", "#4a2e26" }
local BARK = { "#3a1f1c", "#5c3322", "#7f4a2c", "#a2693a", "#c48a50", "#e0ae6e" }
local base = HP.mask() base:add(c:rrect(7, 7, 56, 56, 5))
local tk = { r = { name = "soil" } }
base:each(function(x, y) c:put(x, y, SOIL[1 + floor(X.hash(x, y, 3) * 2.6) % 3], tk) end)
local chips = {
 {16,16,9,4.5,0.5},{33,14,8,4,-0.3},{49,17,8,5,0.9},{12,30,7,4.5,-0.6},{27,28,9,5,0.2},{44,31,8,4.5,-0.5},
 {54,43,6,4.5,1.2},{16,44,9,4.5,0.35},{33,43,8,5,-0.4},{47,52,7,3.5,0.1},{24,54,7,3.2,-0.2},{58,28,3.5,3,0} }
for i, s in ipairs(chips) do
  local m = ell(s[1], s[2], s[3], s[4], s[5]) m:clip(base:shrink(1))
  local tok = { r = { name = "chip" .. i } }
  local n = shade(m, BARK, tok, s[4] + 1, 0.08, 0.15)
  local ca, sa = cos(s[5]), sin(s[5])
  m:each(function(x, y)
    local v = -(x - s[1]) * sa + (y - s[2]) * ca
    if floor(v * 0.9 + 100) % 3 == 0 and X.hash(x, y, i) > 0.35 then c:put(x, y, BARK[2], tok) end
  end)
  m:shift(1, 1):cut(m):clip(base):each(function(x, y) c:put(x, y, SOIL[1], tk) end)
  local bx, by = G.specAt(m, n, 20) if bx then c:put(bx, by, BARK[6], tok) end
end
-- quirk: tiny green seedling pushing through between chips
for _, p in ipairs{ {38,36,"#3f8f4c"},{38,35,"#3f8f4c"},{37,34,"#62ad55"},{39,34,"#62ad55"},{36,33,"#93cb68"},{40,33,"#93cb68"} } do dot(p[1], p[2], p[3], { r = { name = "sprout" } }) end
G.save(c, NAME)
