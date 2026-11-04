-- ico-gem (final, Opus): a tall cut sapphire seen face-on, crown of five facets over a thin girdle band,
-- long pavilion of six facets tapering to a sharp culet. Slim: 33 x 49 px.
-- Material (glass/gem): every facet a flat plane lit from the upper left on a 6-tone blue ramp, each with a slight
-- gradient; bright bevel lines between lit crown facets, dark seams between pavilion facets; girdle band lit
-- left-to-right; a pale core (internal reflection) in the pavilion, a bright left rim, specular streak + cream sparkle.
-- quirk: a tiny rainbow "fire" fleck caught in the right pavilion facet.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_5.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min = math.max, math.min
local c = A.new("ico-gem")
local R = { "#16264f", "#1d4380", "#2867ab", "#3a8fcc", "#67bde3", "#aee6f4" }
local SPEC = "#effcff"
local tok = { r = { name = "gem" } }

local T0, TM, T1 = 24.5, 32, 39.5        -- table x
local TY, GY, GB, CY = 9, 19, 21, 58      -- table top, girdle top, girdle bottom, culet
local GL, GR = 15.5, 48.5
local facets = {
  { pts = { { GL, GY }, { T0, TY }, { 23.5, GY } },        v = 0.9,  gx = 0.0,    gy = 0.004, crown = true },
  { pts = { { T0, TY }, { TM, GY }, { 23.5, GY } },        v = 0.72, gx = 0.0,    gy = 0.0,   crown = true },
  { pts = { { T0, TY }, { T1, TY }, { TM, GY } },          v = 0.84, gx = -0.012, gy = -0.01, crown = true },
  { pts = { { T1, TY }, { 40.5, GY }, { TM, GY } },        v = 0.5,  gx = 0.0,    gy = -0.006, crown = true },
  { pts = { { T1, TY }, { GR, GY }, { 40.5, GY } },        v = 0.34, gx = 0.0,    gy = -0.008, crown = true },
  { pts = { { GL, GB }, { 21, GB }, { 32, CY } },          v = 0.78, gx = 0.0,    gy = -0.008 },
  { pts = { { 21, GB }, { 26.5, GB }, { 32, CY } },        v = 0.56, gx = 0.0,    gy = -0.006 },
  { pts = { { 26.5, GB }, { 32, GB }, { 32, CY } },        v = 0.7,  gx = 0.0,    gy = -0.01 },
  { pts = { { 32, GB }, { 37.5, GB }, { 32, CY } },        v = 0.4,  gx = 0.0,    gy = -0.005 },
  { pts = { { 37.5, GB }, { 43, GB }, { 32, CY } },        v = 0.5,  gx = 0.0,    gy = -0.009 },
  { pts = { { 43, GB }, { GR, GB }, { 32, CY } },          v = 0.22, gx = 0.0,    gy = -0.004 },
}
local fid, idx, all = {}, {}, HP.mask()
for i, f in ipairs(facets) do
  local m = HP.poly(f.pts)
  m:cut(all)
  f.m = m
  local x0, y0 = m:bbox()
  local vv = {}
  m:each(function(x, y) vv[K(x, y)] = f.v + f.gx * (x - x0) + f.gy * (y - y0) end)
  local id = X.tone(c, m, vv, R, { cuts = A.CUTS, tok = tok })
  for k, v in pairs(id) do idx[k] = v end
  m:each(function(x, y) fid[K(x, y)] = i end)
  all:add(m)
end
-- girdle band (2 rows), lit from the left
local gird = HP.rect(16, GY, 48, GB - 1)
gird:cut(all)
gird:each(function(x, y)
  local t = (x - 16) / 32
  local i = (y == GY) and (t < 0.35 and 6 or t < 0.7 and 5 or 4) or (t < 0.3 and 4 or t < 0.75 and 3 or 2)
  c:put(x, y, R[i], tok) idx[K(x, y)] = i fid[K(x, y)] = 0
end)
all:add(gird)
-- fill any seam gaps inside the hull with the neighbour tone
local hull = HP.poly{ { T0, TY }, { T1, TY }, { GR, GY }, { GR, GB }, { 32, CY }, { GL, GB }, { GL, GY } }
hull:each(function(x, y) if not all:has(x, y) then
  local k2 = K(x - 1, y) local i = idx[k2] or idx[K(x + 1, y)] or 3
  c:put(x, y, R[i], tok) idx[K(x, y)] = i fid[K(x, y)] = fid[k2] or 0 all:set(x, y) end end)

-- pale core: an inner reflected triangle in the left-centre pavilion facet, darker echo on the right
local core = HP.poly{ { 27.5, 23 }, { 31.5, 23 }, { 31.5, 42 } }
core:each(function(x, y) if fid[K(x, y)] == 8 then A.step(c, idx, R, x, y, 1, tok) end end)
local core2 = HP.poly{ { 28.5, 24 }, { 31.5, 24 }, { 31.5, 32 } }
core2:each(function(x, y) if fid[K(x, y)] == 8 then A.step(c, idx, R, x, y, 1, tok) end end)
local echo = HP.poly{ { 33, 24 }, { 37, 24 }, { 33, 38 } }
echo:each(function(x, y) if fid[K(x, y)] == 9 then A.step(c, idx, R, x, y, -1, tok) end end)
local echo2 = HP.poly{ { 18, 23.5 }, { 21.5, 23.5 }, { 27, 38 } }
echo2:each(function(x, y) if fid[K(x, y)] == 6 then A.step(c, idx, R, x, y, 1, tok) end end)

-- facet seams: bright bevel between crown facets, dark seam between pavilion facets
local seam = {}
all:each(function(x, y)
  local a = fid[K(x, y)]
  if a and a > 0 then
    for _, d in ipairs{ { 1, 0 }, { 0, 1 } } do
      local b = fid[K(x + d[1], y + d[2])]
      if b and b > 0 and b ~= a then seam[#seam + 1] = { x, y, facets[a].crown and facets[b].crown } break end
    end
  end
end)
for _, s in ipairs(seam) do
  local k = K(s[1], s[2])
  if s[3] then
    if s[1] < 38 then A.step(c, idx, R, s[1], s[2], 2, tok) else A.step(c, idx, R, s[1], s[2], -1, tok) end
  else A.step(c, idx, R, s[1], s[2], -1, tok) end
end
-- crown/girdle meeting: dark row under the crown on the right half (ambient), lit on the left
for x = 16, 48 do if all:has(x, GY - 1) and x > 34 then A.step(c, idx, R, x, GY - 1, -1, tok) end end
-- top table edge bevel and bright left rim
for x = 25, 39 do A.step(c, idx, R, x, TY, x < 35 and 1 or 0, tok) end
all:edge():each(function(x, y)
  if x < 30 and y > TY then A.step(c, idx, R, x, y, 1, tok) end
  if x > 34 and y > GB + 2 then A.step(c, idx, R, x, y, -1, tok) end
end)
-- cool reflected light: a lighter row just inside the lower-right pavilion edge
for y = 30, 50 do
  local xs
  for x = 48, 32, -1 do if all:has(x, y) then xs = x break end end
  if xs then A.step(c, idx, R, xs - 1, y, 1, tok) end
end
-- specular streak on the big lit crown facet + glint, one cream sparkle
for _, p in ipairs{ { 20, 17 }, { 21, 16 }, { 22, 15 }, { 23, 14 } } do c:put(p[1], p[2], R[6], tok) end
c:put(21, 17, SPEC, tok) c:put(22, 16, SPEC, tok)
c:sparkle(28, 12)
-- glint on the girdle
c:put(19, GY, SPEC, tok) c:put(20, GY, SPEC, tok)

-- quirk: a rainbow fire fleck in the right pavilion facet
local fire = { { 41, 26, "#f5809f" }, { 40, 27, "#ffb84a" }, { 39, 28, "#ffe38a" }, { 38, 29, "#9ed86a" }, { 37, 30, "#7fe0e0" } }
for _, f in ipairs(fire) do c:put(f[1], f[2], f[3], tok) end
A.save(c, "ico-gem")
