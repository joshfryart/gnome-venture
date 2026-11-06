-- meteorite-garden (final, Opus single pass). A squat iron meteorite on a 2-tone ground shadow: cool violet-grey
-- fusion crust with thumbprint regmaglypt dents (lit on their lower-right inner wall), bright nickel-iron flecks and one
-- polished specular facet. A crater on top holds dark soil with a moss cushion, a slim sprout with two leaves rises out
-- of it. quirk: the sprout's bloom is a tiny gold five-point star.
local NAME = "meteorite-garden"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sqrt, max, min, cos, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.cos, math.sin, math.pi
local c = A.new(NAME)
local ROCK = { "#262233", "#383247", "#4e4660", "#686079", "#887f98", "#aea6bd" }
local METAL, SPEC = "#d4d2e2", "#f4f2fa"
local SOIL = { "#2e1f22", "#45302a", "#5e4434" }
local MOSS = { "#24544a", "#2f7449", "#4a9a4e", "#79c25a", "#b5e07a" }
local LEAF = { "#21503f", "#2f6c46", "#45894c", "#66a656", "#93c56a", "#c0de8c" }
local STAR = { "#a8561e", "#e89a26", "#fcd34a", "#fff2a0" }

c:groundShadow(32, 56, 22, 2)

-- rock silhouette: lumpy polygon, flatter base
local rock = HP.poly{ { 12, 40 }, { 16, 32 }, { 24, 28 }, { 33, 27 }, { 42, 29 }, { 50, 34 }, { 53, 42 }, { 52, 50 },
  { 46, 55 }, { 32, 56 }, { 18, 55 }, { 11, 50 } }
rock:add(A.ellipse and HP.ellipse(18, 36, 6, 6) or HP.ellipse(18, 36, 6, 6))
-- crater: bowl cut into the upper middle
local bowl = HP.ellipse(32, 31, 8, 3)
local np = X.pillow(rock, 7)
local dents = { { 20, 44, 2.6 }, { 28, 49, 2.2 }, { 41, 46, 2.8 }, { 46, 38, 2.0 }, { 15, 48, 1.8 }, { 36, 39, 2.0 }, { 24, 37, 1.8 } }
local n = {}
for k, a in pairs(np) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local ux, uy = (x - 32) / 22, (y - 42) / 15
  local nx, ny, nz = a[1] * 0.6 + ux * 0.5, a[2] * 0.6 + uy * 0.5, a[3]
  for _, d in ipairs(dents) do
    local dx, dy = x - d[1], y - d[2]
    local r = sqrt(dx * dx + dy * dy)
    if r <= d[3] + 0.3 then local f = 0.9 * (r / (d[3] + 0.5)) nx, ny = nx - dx / (r + 0.01) * f, ny - dy / (r + 0.01) * f end
  end
  n[k] = { A.norm(nx, ny, nz) }
end
local rtok = { r = { name = "rock" } }
local bias = {}
X.ao(bias, rock, bowl, 1, -1)
local ridx = A.shade(c, rock, n, ROCK, { amb = 0.1, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, bias = bias, tok = rtok })
-- crust crackle + nickel-iron flecks
rock:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 5)
  if h < 0.05 then c:put(x, y, ROCK[max(1, ridx[k] - 1)], rtok)
  elseif h > 0.975 and ridx[k] >= 3 then c:put(x, y, METAL, rtok) end end)
-- polished facet (specular streak) upper-left
for _, q in ipairs{ { 17, 33, METAL }, { 18, 33, SPEC }, { 19, 33, SPEC }, { 16, 34, METAL }, { 17, 34, METAL } } do c:put(q[1], q[2], q[3], rtok) end
-- cool bounce light along the lower-right rim
rock:edge():each(function(x, y) if x > 40 and y > 44 and y < 54 then c:put(x, y, "#5d5f8a", rtok) end end)

-- crater soil + its lit far lip
local stok = { r = { name = "soil" } }
bowl:each(function(x, y) local i = (y <= 29) and 1 or ((X.hash(x, y, 9) < 0.3) and 3 or 2) c:put(x, y, SOIL[i], stok) end)
for x = 25, 39 do if bowl:has(x, 34) or bowl:has(x, 33) then local yy = bowl:has(x, 34) and 34 or 33 c:put(x, yy + 1, ROCK[6], rtok) end end

-- moss cushion in the crater (bumpy little balls, AO between)
local mtok = { r = { name = "moss" } }
local moss = HP.mask()
for _, b in ipairs{ { 26, 30, 2.4 }, { 30, 29, 2.6 }, { 37, 30, 2.2 }, { 40, 31, 1.6 }, { 23, 31, 1.5 } } do
  local m = HP.ellipse(b[1], b[2], b[3], b[3] - 0.6)
  local nn = X.sphere(b[1], b[2], b[3], m)
  local mb = {}
  X.ao(mb, m, moss, 1, -1)
  m:cut(moss)
  X.tone(c, m, X.light(nn, { amb = 0.1, wrap = 0.3 }), MOSS, { cuts = { 0.25, 0.45, 0.65, 0.85 }, bias = mb, tok = mtok })
  moss:add(m)
end
moss:each(function(x, y) if X.hash(x, y, 4) < 0.12 then c:put(x, y, MOSS[5], mtok) end end)

-- sprout stem
local sp = { { 33, 28 }, { 35, 23 }, { 31, 19 }, { 33, 15 } }
local sm = A.stem(c, sp, function(t) return 0.95 - 0.25 * t end, { "#2f6c46", "#5c9a52", "#8cc46a", "#c4e290" }, { tok = { r = { name = "stem" } }, cuts = { 0.3, 0.55, 0.8 } })
-- two leaves
A.leaf(c, 34, 23, 39, 19, 45, 19, 2.2, LEAF, { cut = sm, vs = 2.6 })
A.leaf(c, 32, 20, 27, 17, 21, 18, 2.0, LEAF, { cut = sm, vs = 2.6 })

-- quirk: five-point gold star bloom
local ttok = { r = { name = "star" } }
local scx, scy = 33, 11
local star = HP.mask()
for y = scy - 5, scy + 5 do for x = scx - 5, scx + 5 do
  local dx, dy = x - scx, y - scy + 0.3
  local a = math.atan(dy, dx) + pi / 2
  local r = sqrt(dx * dx + dy * dy)
  local f = (a / (2 * pi / 5)) % 1
  local R = 2.0 + 2.6 * (1 - abs(f - 0.5) * 2) ^ 2.2
  if f < 0.5 then R = 2.0 + 2.6 * (1 - f * 2) ^ 2.2 else R = 2.0 + 2.6 * ((f - 0.5) * 2) ^ 2.2 end
  if r <= R then star:set(x, y) end
end end
star:each(function(x, y)
  local dx, dy = x - scx, y - scy
  local i = (dx + dy < -1) and 4 or ((dx + dy <= 1) and 3 or 2)
  if dx + dy > 3 then i = 1 end
  c:put(x, y, STAR[i], ttok)
end)
c:put(scx, scy, "#c96a1e", ttok)

A.save(c, NAME)
