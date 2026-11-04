-- finger-lime (aB31_4, Opus single pass). A slim, gently arched finger lime lying left-to-right: deep olive-to-plum
-- rind with raised oil-gland bumps, waxy bloom on the top, one cream specular, cool reflected light along the belly,
-- a dry stem nub with a thorn at the left. The right end is cut flat to show a pith ring and a face packed with
-- glossy pink citrus pearls (cell walls, a glint per pearl); three pearls have spilled onto the table.
-- quirk: one runaway pearl has climbed up and sits on top of the fruit.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.pi
local c = A.new("finger-lime")
local RIND  = { "#261c2e", "#2c3a2c", "#3c5432", "#56733a", "#7a9a48", "#a9c46a" }
local PEARL = { "#7a1f45", "#a8335a", "#d4566e", "#ef8590", "#fbb6b0", "#ffe6da" }
local PITH  = { "#c9c08a", "#ece6b4" }
local BLOOM, BOUNCE = "#9bb39a", "#4c5d7c"
local STEM  = { "#3a2a24", "#6a4a32", "#9a7448" }

local p = { { 9, 43 }, { 21, 33 }, { 37, 29 }, { 51, 26 } }
local function hw(t)
  if t < 0.16 then return 1.6 + 2.6 * sqrt(t / 0.16) end
  return 4.2 + 0.4 * sin(pi * (t - 0.16) / 0.84)
end
local m, n, T, S, sm, LEN = A.tube(p, hw, { flat1 = true })
local b = {}
m:each(function(x, y) local k = K(x, y) if T[k] > 0.97 then b[k] = -1 end end)
local idx = A.tone(c, m, n, RIND, { bias = b, amb = 0.08, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
local rt = A.tok("rind")
-- oil-gland bumps: lit dot with a dark pixel below-right
m:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 7) < 0.13 and T[k] > 0.06 and T[k] < 0.94 and abs(S[k]) < 0.8 then
    A.step(c, idx, RIND, x, y, 1, rt)
    if m:has(x + 1, y + 1) then A.step(c, idx, RIND, x + 1, y + 1, -1, rt) end
  end
end)
-- waxy bloom along the top
m:each(function(x, y) local k = K(x, y)
  if S[k] < -0.5 and S[k] > -0.8 and T[k] > 0.22 and T[k] < 0.85 and X.hash(x, y, 3) < 0.35 then c:put(x, y, BLOOM, rt) end end)
-- cool reflected light on the belly edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.75 and T[k] > 0.12 and T[k] < 0.93 then c:put(x, y, BOUNCE, rt) end end)
-- specular
do local s = sm[floor(0.38 * 160) + 1]
  local x, y = floor(s.x - s.px * s.w * 0.5 + .5), floor(s.y - s.py * s.w * 0.5 + .5)
  c:put(x, y, A.CREAM, rt) c:put(x + 1, y, RIND[6], rt) end
-- stem nub + thorn at the left tip
c:put(8, 43, STEM[2]) c:put(7, 43, STEM[3]) c:put(7, 44, STEM[1]) c:put(6, 42, STEM[2]) c:put(5, 41, STEM[3])

-- cut face: ellipse across the flat end, tilted toward the viewer
local e = sm[#sm]
local fm = A.rell(e.x + e.tx * 0.6, e.y + e.ty * 0.6, e.tx, e.ty, 2.6, 4.7)
local ft = A.tok("face")
fm:each(function(x, y) c:put(x, y, RIND[3], ft) end)
local core = A.rell(e.x + e.tx * 0.8, e.y + e.ty * 0.8, e.tx, e.ty, 1.7, 3.8)
fm:each(function(x, y) if not core:has(x, y) then
  local s = (x - e.x) * e.px + (y - e.y) * e.py
  c:put(x, y, s < 0 and PITH[2] or PITH[1], ft) end end)
fm:edge():each(function(x, y) local s = (x - e.x) * e.px + (y - e.y) * e.py
  if s > 1 then c:put(x, y, RIND[2], ft) end end)
-- pearls packed in the face: voronoi cells, dark wall, lit tone per cell, glint upper-left
local seeds = {}
core:each(function(x, y) if (x + 2 * y) % 3 == 0 and X.hash(x, y, 11) < 0.7 then seeds[#seeds + 1] = { x + 0.2, y + 0.1 } end end)
core:each(function(x, y)
  local d1, d2, bi = 1e9, 1e9, 1
  for i, s in ipairs(seeds) do local q = (x - s[1])^2 + (y - s[2])^2
    if q < d1 then d2 = d1 d1, bi = q, i elseif q < d2 then d2 = q end end
  local s = (x - e.x) * e.px + (y - e.y) * e.py
  local tone = s < -1 and 5 or (s < 1.5 and 4 or 3)
  if sqrt(d2) - sqrt(d1) < 0.55 then tone = 2 end
  c:put(x, y, PEARL[tone], ft)
end)
for _, s in ipairs(seeds) do local x, y = floor(s[1]), floor(s[2]) if core:has(x, y) and X.hash(x, y, 5) < 0.5 then c:put(x, y, PEARL[6], ft) end end

-- pearls: spilled on the table + one on top of the fruit (quirk)
local function pearl(cx, cy, r)
  local pm = c:ellipse(cx, cy, r, r)
  local pn = X.sphere(cx, cy, r, pm)
  A.tone(c, pm, pn, PEARL, { amb = 0.15 })
  c:put(floor(cx - r * 0.4 + .5), floor(cy - r * 0.4 + .5), PEARL[6])
end
pearl(53, 35, 1.5) pearl(49, 38, 1.5) pearl(55, 40, 1)
pearl(31, 25, 1.5)
A.save(c, "finger-lime")
