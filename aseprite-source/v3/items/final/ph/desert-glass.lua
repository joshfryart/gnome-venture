-- desert-glass (final, Opus single pass). A slim upright shard of lemon-green natural desert glass: chipped into
-- flat conchoidal facets (each lit from its own normal), facet edges as 1 px lines in the darker neighbour tone,
-- curved ripple marks on the big front scoop, darker thick-glass edges with a pale see-through core, a bright rim on
-- the lit edge, pitted bubble holes and a cream sparkle. Stands on a 2-tone ground shadow.
-- quirk: a little chain of frozen bubbles rises inside the core, like fizz caught mid-climb.
local NAME = "desert-glass"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local GL = { "#2f4a2c", "#4f7536", "#7aa042", "#a8c955", "#d2e67f", "#f2f8c0" }
local RIM, CORE = "#fbfde4", "#e9f4a6"

c:groundShadow(32, 56, 13, 2)
-- silhouette: tall leaning shard with a chipped shoulder
local sh = c:poly{ {27, 10}, {33, 8}, {37, 12}, {41, 20}, {43, 31}, {41, 43}, {37, 52}, {31, 57}, {25, 56}, {21, 49}, {20, 37}, {21, 25}, {23, 15} }
-- facets: voronoi cells, each with its own tilted normal
local seeds = {
  { 30, 12, -0.5, -0.6 }, { 38, 20, 0.55, -0.35 }, { 25, 24, -0.7, -0.15 }, { 32, 30, -0.1, -0.05 },
  { 40, 36, 0.7, 0.15 }, { 24, 42, -0.55, 0.35 }, { 33, 46, 0.15, 0.4 }, { 30, 54, -0.1, 0.8 },
}
local cell, n = {}, {}
sh:each(function(x, y)
  local best, bi, second = 1e9, 1, 1e9
  for i, s in ipairs(seeds) do
    local q = (x - s[1])^2 + ((y - s[2]) * 0.8)^2
    if q < best then second = best best, bi = q, i elseif q < second then second = q end
  end
  local k = K(x, y)
  cell[k] = bi
  local s = seeds[bi]
  -- slight scoop inside each facet (conchoidal): bend normal toward cell centre
  local dx, dy = (x - s[1]) * 0.03, (y - s[2]) * 0.03
  local nx, ny = s[3] - dx, s[4] - dy
  local l = sqrt(nx*nx + ny*ny + 1)
  n[k] = { nx / l, ny / l, 1 / l }
end)
local v = X.light(n, { amb = 0.12, wrap = 0.2 })
-- thick-glass edges darker, pale core (translucency)
local d = X.dist(sh)
local bias = {}
sh:each(function(x, y) local k = K(x, y)
  local dd = d[k]
  if dd < 1.6 then v[k] = v[k] - 0.18 elseif dd > 5 then v[k] = v[k] + 0.12 end
end)
local idx = A.toneV(c, sh, v, GL, { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias, "glass")
local tok = { r = { name = "glass" } }
-- facet edges: darker neighbour tone where cells meet (lit side of the edge gets hi)
sh:each(function(x, y) local k = K(x, y)
  local a = cell[k]
  local r, b = cell[K(x + 1, y)], cell[K(x, y + 1)]
  if (r and r ~= a) or (b and b ~= a) then
    local i = idx[k]
    c:put(x, y, GL[max(1, i - 1)], tok)
    -- bright ridge just up-left of edges that face the light
    local ul = K(x - 1, y - 1)
    if sh:has(x - 1, y - 1) and cell[ul] == a and (idx[ul] or 1) >= 4 and d[ul] > 1.5 then c:put(x - 1, y - 1, GL[6], tok) end
  end
end)
-- conchoidal ripple arcs on the big front facet (cell 4), centred off the chipped edge
sh:each(function(x, y) local k = K(x, y)
  if cell[k] == 4 or cell[k] == 6 then
    local r = sqrt((x - 21)^2 + ((y - 34) * 1.2)^2)
    local f = r % 4
    if f < 0.9 and r > 5 and r < 16 then c:put(x, y, GL[max(1, idx[k] - 1)], tok) end
  end
end)
-- pale core streak (see-through) and the bright rim on the lit edge
for _, p in ipairs{ {30, 22}, {31, 23}, {30, 24}, {31, 25}, {31, 26}, {32, 27} } do c:put(p[1], p[2], CORE, tok) end
sh:edge():each(function(x, y)
  if sh:has(x + 1, y + 1) and not sh:has(x - 1, y - 1) and (x + y) < 66 then c:put(x, y, RIM, tok) end
end)
-- cool reflected light on the lower-right edge
sh:edge():each(function(x, y)
  if not sh:has(x + 1, y + 1) and (x + y) > 76 and y < 54 then c:put(x, y, "#5f9a7a", tok) end
end)
-- pitted bubble holes (dark pit, lit lower rim)
for _, b in ipairs{ {37, 41}, {26, 47}, {35, 14} } do
  c:put(b[1], b[2], GL[1], tok) c:put(b[1] + 1, b[2], GL[2], tok) c:put(b[1], b[2] + 1, GL[5], tok)
end
-- quirk: frozen fizz, a rising chain of tiny bubbles in the core (ring of base tone with pale centre)
for i, b in ipairs{ {33, 49, 1}, {34, 45, 1}, {33, 41, 0}, {34, 38, 0}, {33, 35, 0} } do
  local x, y, big = b[1], b[2], b[3]
  if big == 1 then
    c:put(x, y, CORE, tok) c:put(x + 1, y, GL[3], tok) c:put(x, y + 1, GL[3], tok) c:put(x + 1, y + 1, GL[2], tok)
  else c:put(x, y, CORE, tok) c:put(x + 1, y + 1, GL[3], tok) end
end
-- spec + sparkle
c:put(26, 13, RIM, tok) c:put(27, 13, RIM, tok)
c:sparkle(28, 18)
A.save(c, A.here(), NAME)
