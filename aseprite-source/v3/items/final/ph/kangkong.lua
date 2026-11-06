-- kangkong (final pass, Opus single pass). A slim bunch of water spinach: four long hollow stems (pale jade
-- cylinders, a darker node ring each, AO where they cross) fanning up into five arrowhead leaves (sagittate, two
-- backward basal lobes, pale midrib, side veins, cool rim). A twisted raffia tie binds the bunch (two-tone twist,
-- AO above and below), and the fresh-cut stem ends at the bottom show the hollow tube: a pale ring round a dark core.
-- quirk: one round water drop clings to the tip of the left leaf, with a bright glint.
local NAME = "kangkong"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#123438", "#1c4e40", "#2a6c44", "#3f8c48", "#64ae56", "#9ad070" }
local COOL, VEIN = "#3a7078", "#c8e69a"
local STEM = { "#2e5a44", "#4a7e52", "#6ea464", "#98c67e", "#c4e2a2", "#ecf8d0" }
local RAF = { "#5a3424", "#8a5632", "#b9844a", "#dcae6a", "#f2d494" }
local WAT = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

-- stems: bottom (cut end) -> top (leaf base); drawn back to front
local stems = {
  { { 30, 56 }, { 29, 46 }, { 24, 37 }, { 19, 30 } },   -- back left
  { { 35, 56 }, { 35, 46 }, { 39, 37 }, { 44, 29 } },   -- back right
  { { 32, 57 }, { 32, 44 }, { 31, 32 }, { 31, 21 } },   -- centre
  { { 34, 57 }, { 34, 46 }, { 36, 39 }, { 38, 33 } },   -- front short
}
local leaves = {   -- base x, y, direction ux, uy, length, half width
  { 19, 30, -0.75, -0.66, 12, 3.2 },
  { 44, 29, 0.72, -0.7, 11, 3.1 },
  { 31, 21, 0.05, -1, 12, 3.2 },
  { 38, 33, 0.92, -0.38, 9, 2.8 },
  { 25, 38, -0.98, 0.2, 8, 2.6 },   -- side leaf off the back-left stem
}

local function arrow(L)
  local bx, by, ux, uy, len, w = L[1], L[2], L[3], L[4], L[5], L[6]
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local ex, ey = bx + ux * len, by + uy * len
  local mx, my = bx + ux * len * 0.5, by + uy * len * 0.5
  local m, n, T, S, bl = A.blade(bx, by, mx, my, ex, ey, function(t)
    if t > 0.985 then return -1 end
    if t < 0.08 then return max(0.6, w * 0.8) end
    return max(0.45, w * (1 - t) ^ 0.75 * (0.85 + 0.6 * t))
  end, { fold = 0.45 })
  -- backward basal lobes
  local px, py = -uy, ux
  for _, sd in ipairs{ -1, 1 } do
    local lx, ly = bx + px * sd * (w * 0.9) - ux * 1.6, by + py * sd * (w * 0.9) - uy * 1.6
    local dx, dy = -ux + px * sd * 0.7, -uy + py * sd * 0.7
    local dl = sqrt(dx * dx + dy * dy)
    local lobe = A.rell(lx, ly, dx / dl, dy / dl, 2.6, 1.3)
    lobe:each(function(x, y) if not m:has(x, y) then local k = K(x, y)
      m:set(x, y) T[k] = 0.02 local s = sd * 0.8 if px + py < 0 then s = -s end S[k] = s
      n[k] = { A.norm(px * s * 0.6, py * s * 0.6, 1) } end end)
  end
  return m, n, T, S, bl, ex, ey
end

local tok = { r = { name = "plant" } }
local all = HP.mask()
local stemM = {}
for i, p in ipairs(stems) do
  local m, n, T, S = A.tube(p, function(t) return 1.35 - 0.35 * t end)
  stemM[i] = { m = m, n = n, T = T, S = S }
end
local leafM = {}
for i, L in ipairs(leaves) do
  local m, n, T, S, bl, ex, ey = arrow(L)
  leafM[i] = { m = m, n = n, T = T, S = S, len = bl, ex = ex, ey = ey }
end
-- draw order: stem1, leaf1, leaf5, stem2, leaf2, stem3, leaf3, stem4, leaf4
local order = { { "s", 1 }, { "l", 1 }, { "l", 5 }, { "s", 2 }, { "l", 2 }, { "s", 3 }, { "l", 3 }, { "s", 4 }, { "l", 4 } }
local painted = HP.mask()
local function paintStem(i)
  local s = stemM[i]
  local b = {}
  X.ao(b, s.m, painted, 1, -1)
  -- AO is wrong where this part is in front, so only darken the pixels the *later* parts will shade: none here;
  -- instead give the stem's own lower-right contact on what lies behind it
  painted:each(function() end)
  local idx = A.shade(c, s.m, s.n, STEM, { tok = tok, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  -- node ring partway up
  s.m:each(function(x, y) local k = K(x, y) if abs(s.T[k] - 0.62) < 0.012 then c:put(x, y, STEM[max(1, idx[k] - 2)], tok) end end)
  -- contact shadow on what is behind
  s.m:shift(1, 1):each(function(x, y) if painted:has(x, y) and not s.m:has(x, y) then c:put(x, y, LEAF[1], tok) end end)
  painted:add(s.m)
end
local function paintLeaf(i)
  local L = leafM[i]
  local m = L.m:copy()
  local idx = A.leaf(c, m, L.n, L.T, L.S, { ramp = LEAF, vein = VEIN, cool = COOL, per = 3.2, sweep = 2.5, len = L.len,
    tok = tok, t0 = 0.02, t1 = 0.9, amb = 0.16 })
  m:shift(1, 1):each(function(x, y) if painted:has(x, y) and not m:has(x, y) then c:put(x, y, STEM[1], tok) end end)
  painted:add(m)
end
for _, o in ipairs(order) do if o[1] == "s" then paintStem(o[2]) else paintLeaf(o[2]) end end

-- raffia tie around the bunch at y 47-49
do
  local rtok = { r = { name = "raffia" } }
  local tm = HP.mask()
  for y = 47, 49 do for x = 28, 38 do
    local inside = false
    for i = 1, 4 do if stemM[i].m:has(x, y) or stemM[i].m:has(x - 1, y) or stemM[i].m:has(x + 1, y) then inside = true end end
    if inside then tm:set(x, y) end
  end end
  local x0, y0, x1, y1 = tm:bbox()
  -- AO rows above and below on the stems
  for x = x0, x1 do
    for _, yy in ipairs{ y0 - 1, y1 + 1 } do
      for i = 1, 4 do if stemM[i].m:has(x, yy) then c:put(x, yy, STEM[2], tok) end end
    end
  end
  tm:each(function(x, y)
    local tw = (x - y * 2) % 4
    local i = (y == y0) and 4 or (y == y1 and 2 or 3)
    if tw == 0 then i = i + 1 elseif tw == 2 then i = i - 1 end
    if x == x1 then i = i - 1 end
    c:put(x, y, RAF[max(1, min(5, i))], rtok)
  end)
  -- loose tail end hanging out to the right
  for _, q in ipairs{ { x1 + 1, 48, 3 }, { x1 + 2, 49, 2 }, { x1 + 2, 50, 3 }, { x1 + 3, 51, 2 } } do c:put(q[1], q[2], RAF[q[3]], rtok) end
end

-- hollow cut ends at the bottom of each stem
for i, p in ipairs(stems) do
  local x, y = p[1][1], p[1][2]
  c:put(x - 1, y, STEM[5], tok) c:put(x, y, STEM[1], tok) c:put(x + 1, y, STEM[4], tok)
  c:put(x, y + 1, STEM[3], tok)
end

-- quirk: water drop on the left leaf tip
do local wtok = { r = { name = "drop" } }
  local L = leafM[1]
  local dx, dy = floor(L.ex + 0.5) - 1, floor(L.ey + 0.5) + 1
  local dm = A.oval(dx, dy, 1.6, 1.6, 0, 1)
  local dn = X.sphere(dx, dy, 1.6, dm)
  A.shade(c, dm, dn, WAT, { tok = wtok, amb = 0.2, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
  c:put(dx - 1, dy - 1, "#fff4d6", wtok)
  c:put(dx + 1, dy + 1, WAT[4], wtok)
end

A.save(c, NAME)
