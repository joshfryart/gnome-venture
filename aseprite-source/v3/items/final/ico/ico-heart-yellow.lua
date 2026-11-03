-- ico-heart-yellow (final, Opus). A cut honey-topaz gem in the shape of a heart, leaning slightly right: a flat
-- table in the middle, a ring of crown facets round it and a steeper ring of girdle facets to the outline, so it reads
-- as faceted glass instead of a soft pillow (unlike the red and green hearts).
-- Material: flat per-facet light from a convex polyhedron height field on a 6-tone yellow ramp, a bright line on the
-- lit facet edges and a dark one on the shaded edges, inner glow (inverted refraction) on two lower-right facets,
-- a cream sparkle on a table corner, a pale rim on the upper-left girdle.
-- quirk: a tiny gnat is caught inside, seen through the table.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.pi
local c = A.new("ico-heart-yellow")
local Y = { "#6b3520", "#a65a1c", "#d88a20", "#f4b72c", "#ffd955", "#fff09c" }
local tok = A.tok("gem")

local TILT = 0.08
local CX, CY = 32, 31
local h = A.heart(CX, CY, 19, 1.02, TILT)
-- facets: smooth dome normals snapped to 8 azimuth sectors x 3 tilt rings (table / crown / girdle)
local dn, dist = A.dome(h, 15, 1.1, 2)
local NS = 8
local planes = { { k = 0, dx = 0, dy = 0 } }
local pid = {}
local id, nrm = {}, {}
h:each(function(x, y)
  local k = K(x, y)
  local q = dn[k]
  local sl = sqrt(q[1] * q[1] + q[2] * q[2]) / max(q[3], 0.05)
  local ring = (dist[k] > 8.6) and 0 or (dist[k] > 3.6 and 1 or 2)
  local bi
  if ring == 0 then bi = 1 else
    local az = math.atan(q[2], q[1]) - TILT + (ring == 2 and pi / NS or 0)
    local sec = floor((az / (2 * pi)) * NS + 0.5) % NS
    local key = ring * 100 + sec
    if not pid[key] then
      local ang = (sec / NS) * 2 * pi + TILT - (ring == 2 and pi / NS or 0)
      planes[#planes + 1] = { k = ring == 1 and 0.5 or 1.25, dx = cos(ang), dy = sin(ang) }
      pid[key] = #planes
    end
    bi = pid[key]
  end
  local p = planes[bi]
  id[k] = bi
  nrm[k] = { A.norm(p.k * p.dx, p.k * p.dy, 1) }
end)
-- majority filter (two passes) so small slivers merge into their neighbours
for _ = 1, 4 do
  local id2 = {}
  h:each(function(x, y)
    local cnt, bestc, besti = {}, 0, id[K(x, y)]
    for dy = -1, 1 do for dx = -1, 1 do local j = id[K(x + dx, y + dy)]
      if j then cnt[j] = (cnt[j] or 0) + 1 if cnt[j] > bestc then bestc, besti = cnt[j], j end end end end
    id2[K(x, y)] = (cnt[id[K(x, y)]] or 0) >= 4 and id[K(x, y)] or besti
  end)
  id = id2
end
h:each(function(x, y) local k = K(x, y) local p = planes[id[k]] nrm[k] = { A.norm(p.k * p.dx, p.k * p.dy, 1) } end)
local v = A.val(nrm, { amb = 0.12, wrap = 0.15 })
-- each facet gets its own small brightness kick so neighbouring facets separate
for k, _ in pairs(v) do if id[k] > 1 then v[k] = max(0, min(1, v[k] + (X.hash(id[k], 7, 3) - 0.5) * 0.22)) end end
-- inner glow: light bounces back out of two lower-right girdle facets
for k, _ in pairs(v) do
  local p = planes[id[k]]
  if p.k > 1 and p.dx > 0.2 and p.dy > 0.55 and p.dx < 0.75 then v[k] = v[k] + 0.3 end
end
local idx = X.tone(c, h, v, Y, { cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, tok = tok })
-- table a touch darker than the brightest crown facets so the cut shows; keep it bright though
h:each(function(x, y) local k = K(x, y) if id[k] == 1 then
  local t = (x + y) - (CX + CY - 8)
  local col, i = Y[4], 4
  if t >= -6 and t <= -4 then col, i = Y[5], 5 elseif t >= -1 and t <= -1 then col, i = Y[5], 5
  elseif t >= 6 then col, i = Y[3], 3 end
  c:put(x, y, col, tok) idx[k] = i end end)

-- facet edges: bright line on lit boundaries, dark line on shaded boundaries
local edges = {}
h:each(function(x, y) local k = K(x, y)
  local a = id[k]
  local r, dn = id[K(x + 1, y)], id[K(x, y + 1)]
  if (r and r ~= a) or (dn and dn ~= a) then edges[#edges + 1] = { x, y } end
end)
for _, e in ipairs(edges) do
  local x, y = e[1], e[2]
  local k = K(x, y)
  local p = planes[id[k]]
  local lit = (p.dx * -0.6 + p.dy * -0.7) > 0.05 or id[k] == 1
  if not lit then A.step(c, idx, Y, x, y, -1, tok) elseif id[k] == 1 then A.step(c, idx, Y, x, y, 1, tok) end
end
-- pale rim on the upper-left girdle edge (glass rim)
h:edge():each(function(x, y) local k = K(x, y)
  local p = planes[id[k]]
  if (p.dx * -0.6 + p.dy * -0.7) > 0.45 then c:put(x, y, Y[6], tok) end
end)

-- quirk: a tiny gnat inside, seen through the table (muted, two wings)
local G = { k = "#5a2a1c", w = "#fff09c", b = "#a65a1c" }
A.map(c, {
  "ww.ww",
  ".wkw.",
  "b.k.b",
}, CX - 2, CY - 1, G, tok)

-- sparkle on the upper-left table corner + 2x1 pop
local tx0, ty0 = 1e9, 1e9
h:each(function(x, y) if id[K(x, y)] == 1 and x + y < tx0 + ty0 then tx0, ty0 = x, y end end)
c:put(tx0, ty0, "#fff4d6", tok) c:put(tx0 + 1, ty0, Y[6], tok) c:put(tx0, ty0 + 1, Y[6], tok)
-- cream plus on the left lobe crown facet
local sx, sy = 20, 20
c:put(sx, sy, "#fff4d6") c:put(sx - 1, sy, Y[6]) c:put(sx + 1, sy, Y[6]) c:put(sx, sy - 1, Y[6]) c:put(sx, sy + 1, Y[6])
A.save(c, "ico-heart-yellow")
