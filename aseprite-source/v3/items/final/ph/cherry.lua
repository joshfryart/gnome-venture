-- cherry (final pass, Opus single pass). A pair of sweet cherries hanging from two slim stems that meet at a
-- woody spur, with one serrated leaf. Fruit: sphere light on a 6-tone crimson ramp, sunken stem cavity, faint
-- suture crease, waxy bloom specular + cream glint, cool reflected light lower-right, AO where stem enters.
-- Stems: 4-tone green tubes; spur: brown bark knob. Leaf: midrib + veins, V-fold light.
-- quirk: a caterpillar has nibbled a bite-shaped notch out of the leaf edge.
local NAME = "cherry"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local RED  = { "#4a1030", "#7a1534", "#b01e35", "#dc2f37", "#f25a4a", "#ff9a7a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#3c4a2a", "#5e7a34", "#8fae4a", "#c4d878" }
local BARK = { "#3e2422", "#6a4030", "#94603e", "#c08a5a" }
local COOL, SPEC = "#8a3a72", "#fff1cf"

local JX, JY = 33, 14
-- leaf first (stems and spur paint over its base)
local lm, LT, LS = A.leaf(c, JX + 1, JY, 44, 7, 56, 11, 4.6, LEAF, { vs = 3.0, fold = 0.5 })
-- serrated margin: nick every 3 px on both edges
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] and LT[k] > 0.15 and LT[k] < 0.9 and abs(LS[k]) > 0.7 and (x + y) % 3 == 0 then c.pix[y * c.w + x] = nil end end)
-- quirk: nibbled notch on the upper edge (two-bite arc)
for _, q in ipairs{ {47,6},{48,6},{49,6},{48,7},{47,7},{49,7},{48,8} } do c.pix[q[2] * c.w + q[1]] = nil end

-- stems: slim green tubes curving down to each cherry
local L = { cx = 20.5, cy = 45, r = 7.6 }
local R = { cx = 40, cy = 47.5, r = 7.6 }
local stok = { r = { name = "stem" } }
local sl = A.stem(c, { { JX - 1, JY + 1 }, { 28, 20 }, { 22, 29 }, { 21, 38 } }, function() return 0.95 end, STEM, { tok = stok })
local sr = A.stem(c, { { JX, JY + 1 }, { 36, 22 }, { 40, 31 }, { 40, 40 } }, function() return 0.95 end, STEM, { tok = stok })
-- woody spur at the joint
local spur = c:ellipse(JX, JY, 1.6, 1.2)
spur:add(c:rect(JX - 1, JY - 2, JX, JY - 1))
A.shade(c, spur, X.pillow(spur, 1.4), BARK, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "spur" } } })
c:put(JX - 1, JY - 2, BARK[4]) c:put(JX, JY - 2, BARK[2])

-- cherries: right one behind the left
local function cherry(f, other)
  local m = c:ellipse(f.cx, f.cy, f.r, f.r - 0.3)
  local n = X.sphere(f.cx - 0.6, f.cy - 0.8, f.r, m)
  -- stem cavity: tilt normals inward around the top dimple
  local bias = {}
  local dx0, dy0 = f.cx, f.cy - f.r + 1.6
  m:each(function(x, y) local k = K(x, y)
    local d = sqrt((x - dx0) ^ 2 + (y - dy0) ^ 2)
    if d < 2.2 then bias[k] = -2 elseif d < 3.2 and y <= dy0 + 1 then bias[k] = -1 end
  end)
  if other then X.ao(bias, m, other, 1, -1) end
  local tok = { r = { name = "cherry" .. f.cx } }
  local idx = A.shade(c, m, n, RED, { amb = 0.08, wrap = 0.3, cuts = { 0.12, 0.3, 0.5, 0.7, 0.88 }, bias = bias, tok = tok })
  -- lit lip on the cavity's lower-left
  c:put(floor(dx0) - 2, floor(dy0) + 1, RED[5], tok)
  -- suture crease: faint darker line down the right face
  for i = 0, 6 do local x, y = floor(f.cx + 2 + i * 0.25), floor(dy0 + 2 + i)
    if m:has(x, y) and idx[K(x, y)] and idx[K(x, y)] > 2 then A.step(c, idx, RED, x, y, -1, tok) end end
  -- cool reflected light on the lower-right rim
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.62 and idx[k] and idx[k] <= 3 then c:put(x, y, COOL, tok) end end)
  -- waxy bloom: specular streak + one cream glint
  local sx, sy = floor(f.cx - f.r * 0.45), floor(f.cy - f.r * 0.42)
  c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, RED[6], tok) c:put(sx, sy + 1, RED[6], tok)
  c:put(sx - 1, sy + 3, RED[6], tok) c:put(sx - 1, sy + 4, RED[5], tok)
  -- stem foot sits in the cavity
  return m
end
local mr = cherry(R)
local ml = cherry(L, nil)
-- AO on the right cherry where the left one overlaps (it's behind)
for _, f in ipairs{ L, R } do
  local x, y = floor(f.cx), floor(f.cy - f.r + 1)
  c:put(x, y, STEM[2], stok) c:put(x, y - 1, STEM[3], stok)
end
A.save(c, NAME)
