-- titan-claw (lean E2_17)
local NAME = "titan-claw"
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
local BONE = { "#3b2a2e", "#6e5a52", "#a08b78", "#cdb99a", "#e6d7b8", "#faf0d6" }
local WRAP = { "#2a1418", "#5a1f26", "#8a2f34", "#b84a40" }
c:groundShadow(32, 58, 18, 3)
local m, n, T = G.tube({ {18,8}, {52,14}, {52,42}, {26,56} }, function(t) return 7.2 * (1 - t) ^ 0.8 + 0.7 end)
local tok = { r = { name = "claw" } }
G.toneN(c, m, n, BONE, { tok = tok, cuts = CUTS, amb = 0.1, wrap = 0.2 })
m:each(function(x, y) local k = K(x, y) local t = T[k]
  for _, r in ipairs{ 0.3, 0.45, 0.6, 0.75 } do if abs(t - r) < 0.012 then c:put(x, y, BONE[2], tok) end end
  if t > 0.85 and t < 0.97 then c:put(x, y, BONE[6], tok) end
  if t < 0.2 then local lit = X.light(n, { amb = 0.1, wrap = 0.2 })[k] c:put(x, y, WRAP[1 + floor(min(0.99, lit) * 3.9) % 4], tok) end
end)
for _, p in ipairs{ {19,9},{19,13},{21,16} } do end
-- cord wrap highlights + knot
for i = 0, 3 do local y = 7 + i * 3 c:line({ {13 + i, y}, {24 + i, y + 3} }, 1):clip(m):each(function(x, yy) c:put(x, yy, i % 2 == 0 and WRAP[4] or WRAP[2], tok) end) end
-- quirk: gold bead on a short cord tail
dot(14, 20, "#e8b84a", { r = { name = "bead" } }) dot(15, 20, "#fbe08a", { r = { name = "bead" } }) dot(14, 21, "#a8782a", { r = { name = "bead" } }) dot(15, 21, "#c89838", { r = { name = "bead" } })
dot(14, 17, WRAP[3], tok) dot(14, 18, WRAP[3], tok) dot(14, 19, WRAP[2], tok)
G.save(c, NAME)
