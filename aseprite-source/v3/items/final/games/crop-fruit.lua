-- crop-fruit (final, Opus single pass). A slim, slightly tall apple: twin shoulders around a sunken stem cavity,
-- tapering to a narrow base with a little calyx; a thin curved stalk and one veined leaf.
-- Material: per-pixel sphere/pillow light (6-tone red, cool-violet shade), faint vertical streaks of the skin,
-- pale lenticel dots, waxy bloom specks, one cream specular + glint, cool reflected light lower-right,
-- AO in the stalk cavity, stalk with paler snapped end grain. Leaf: midrib + angled veins.
-- quirk: someone took one bite out of the right cheek (cream flesh, tooth ridges, thin skin edge).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs
local c = A.new("crop-fruit")
local RED   = { "#5c1a36", "#90203c", "#c22e3b", "#e4473c", "#f5704a", "#ffa36a" }
local STRK  = { "#4c1430", "#7a1a38", "#a82538", "#cc3738", "#e45a44", "#f58a5c" }
local LEAF  = { "#1b3e3a", "#245844", "#31774a", "#4a9850", "#71b85a", "#a4d470" }
local STEM  = { "#3a2622", "#5e3d2c", "#86603e", "#b08752" }
local FLESH = { "#c69a6a", "#e2c38e", "#f3dfae", "#fff1cf" }
local SPEC, BOUNCE, BLOOM = "#fff4d6", "#9a4a78", "#f7a08a"

-- stalk + leaf first (body overlaps the stalk base)
local sm, sn, ST = A.stem(c, { {32, 28}, {32, 23}, {33, 19}, {35, 15} }, function(t) return 1.15 - 0.25 * t end, STEM)
c:px(35, 14, STEM[4]) c:px(36, 14, STEM[3])          -- snapped end grain
A.leaf(c, 33.5, 21, 40, 12, 49, 14, 3.6, LEAF, { vs = 3 })

-- body
local m = c:ellipse(27, 36, 9, 10):add(c:ellipse(36, 36, 9, 10)):add(c:ellipse(31.5, 43, 10.5, 8)):add(c:ellipse(31.5, 49, 6, 4))
m:cut(c:ellipse(31.5, 25.2, 3.2, 2.6))
-- bite (quirk): two overlapping scoops on the right cheek
local bite = c:ellipse(43.6, 38.5, 3.2, 3.6):add(c:ellipse(42.8, 43.4, 2.6, 2.4))
local face = bite:grow(4):clip(m):cut(bite)
m:cut(bite)
local n = A.body(m, 30.4, 37.4, 14, 6, 0.65)
-- cavity: normals tilt toward the stalk pit
m:each(function(x, y) local k = K(x, y)
  local dx, dy = x - 31.5, y - 26
  local d = sqrt(dx*dx + dy*dy)
  if d < 6 and d > 0 then local a = n[k] local f = (6 - d) / 6 * 0.8
    n[k] = { A.norm(a[1] - dx / d * f, a[2] - dy / d * f, a[3]) } end
end)
local bias = {}
X.ao(bias, m, c:ellipse(31.5, 25.2, 3.2, 2.6), 2, -1)
local tok = { r = { name = "apple" } }
local idx, v = A.shade(c, m, n, RED, { bias = bias, tok = tok, cuts = { 0.16, 0.34, 0.56, 0.76, 0.9 } })
-- vertical skin streaks (curve with the body), darker streak ramp on the same index
m:each(function(x, y) local k = K(x, y)
  local u = (x - 31.5) / (11 + 0.2 * (y - 36))
  local ph = u * 6.5 + (y - 36) * 0.04
  if (ph % 1) < 0.22 and y > 29 and y < 51 and X.hash(floor(ph), floor(y / 6), 7) > 0.3 then c:put(x, y, STRK[idx[k]], tok) end
end)
-- lenticels and bloom
m:copy():shrink(2):each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 21)
  if h > 0.975 and idx[k] >= 3 then c:put(x, y, RED[min(6, idx[k] + 2)], tok)
  elseif h < 0.025 and v[k] > 0.7 then c:put(x, y, BLOOM, tok) end
end)
-- cool reflected light lower-right
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.78 and y > 40 and x > 32 and not face:grow(1):has(x, y) then c:put(x, y, BOUNCE, tok) end end)
-- bite face: flesh, lit by depth into the scoop, with tooth ridges and a skin edge on the inner rim
local fd = {}
local ftok = { r = { name = "flesh" } }
local bd = X.dist(bite:copy():add(HP.mask()))
face:each(function(x, y) local k = K(x, y)
  local best = 99
  bite:each(function(bx, by) local q = sqrt((bx - x)^2 + (by - y)^2) if q < best then best = q end end)
  fd[k] = best
end)
face:each(function(x, y) local k = K(x, y)
  local d = fd[k]
  if d > 3.4 then c:put(x, y, RED[1], tok)                 -- skin edge where the flesh ends
  else
    local i = (d < 1.5) and 4 or ((d < 2.6) and 3 or 2)
    if y < 37 then i = i + 1 end
    if y > 44 then i = i - 1 end
    c:put(x, y, FLESH[max(1, min(4, i))], ftok)
  end
end)
-- tooth ridges: short darker ticks across the scoop
for _, p in ipairs{ {41, 36}, {40, 39}, {41, 42}, {40, 44} } do if face:has(p[1], p[2]) then c:put(p[1], p[2], FLESH[1], ftok) end end
-- calyx at the base: tiny dark star
for _, p in ipairs{ {31, 51}, {32, 51}, {30, 50}, {33, 50}, {31, 50} } do if m:has(p[1], p[2]) then c:put(p[1], p[2], RED[1], tok) end end
c:put(32, 50, STEM[2], tok)
-- specular: 2x1 cream + glint, on the left shoulder
c:put(22, 32, SPEC, tok) c:put(23, 32, SPEC, tok) c:put(22, 33, RED[6], tok) c:put(25, 30, SPEC, tok)
-- stalk base sinks into the pit
c:put(31, 26, RED[1], tok) c:put(32, 27, RED[1], tok) c:put(32, 26, STEM[1]) c:put(31, 27, RED[1], tok)
A.save(c, "crop-fruit")
