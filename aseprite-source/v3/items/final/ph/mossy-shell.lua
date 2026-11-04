-- mossy-shell (final pass, Opus). An old whelk shell lying on its side, spire to the upper right: six overlapping
-- whorls with dark sutures and AO, curved growth lines, one rust spiral band, a pearly pink flared aperture lower
-- left (deep throat, cream lip). A lumpy moss cushion grows over the lit top of the body whorl, with contact shadow
-- and two short strands hanging down the shell.
-- quirk: a tiny fern fiddlehead uncurls out of the moss.
local NAME = "mossy-shell"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.atan
local c = A.new(NAME)
local SHELL = { "#4a2c40", "#7a5262", "#a8807c", "#cfae98", "#ecd8bc", "#fff2dc" }
local RUST  = { "#3e1f2a", "#6a3034", "#94493c", "#b86a42", "#d99262", "#f0bc8a" }
local NACRE = { "#5a2048", "#8a3462", "#c25a86", "#eb8fac", "#ffc6d6", "#fff0f4" }
local MOSS  = { "#1d4a3a", "#2a6b40", "#3f8f45", "#62b04c", "#93cf62", "#c8ec8a" }

local ang = -0.58
local ux, uy = cos(ang), sin(ang)
local px, py = -uy, ux                      -- across, +ve toward lower-right (shade side)
local Bx, By = 22, 38
local R = { 13.5, 9.8, 7.0, 5.0, 3.6, 2.5, 1.7 }
local W = {}
do local cx, cy = Bx, By
  for i, r in ipairs(R) do
    if i > 1 then local d = 0.74 * R[i - 1] cx, cy = cx + ux * d, cy + uy * d end
    local m, n = A.oval(cx, cy, r * 0.82, r, ang, 0.9)
    W[i] = { m = m, n = n, cx = cx, cy = cy, r = r }
  end
end
local shell = HP.mask() for _, w in ipairs(W) do shell:add(w.m) end

-- aperture: flared, lower-left of the body whorl
local Ax, Ay = Bx - ux * 3.6 + px * 4.6, By - uy * 3.6 + py * 4.6
local ap = A.rell(Ax, Ay, ux, uy, 6.6, 4.4)
shell:add(ap)

-- moss region: lit upper-left side of the first three whorls, wobbly edge, lumps overhanging the outline
local moss = HP.mask()
local function along(x, y) return (x - Bx) * ux + (y - By) * uy end
local function across(x, y) return (x - Bx) * px + (y - By) * py end
shell:grow(1):each(function(x, y)
  local a, s = along(x, y), across(x, y)
  local edge = -5.6 + 1.8 * sin(a * 0.7) + 1.2 * X.hash(floor(a), 0, 3)
  if a > -12 and a < 17 - 0.25 * abs(s) and s < edge and not ap:has(x, y) then
    if shell:has(x, y) or X.hash(x, y, 11) > 0.35 then moss:set(x, y) end
  end
end)
-- clean single stray pixels
local lone = {}
moss:each(function(x, y) local nb = 0
  for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if moss:has(x + d[1], y + d[2]) then nb = nb + 1 end end
  if nb <= 1 then lone[#lone + 1] = { x, y } end end)
for _, p in ipairs(lone) do moss.s[K(p[1], p[2])] = nil end

-- shell whorls: apex first, body last; growth lines, rust band, AO + suture line under the next whorl
local stok = { r = { name = "shell" } }
for i = #W, 1, -1 do
  local w = W[i]
  local bias = {}
  if i > 1 then X.ao(bias, w.m, W[i - 1].m, 1, -1) end
  A.cast(bias, w.m, moss, 1, 1, -1)
  local v = X.light(w.n, { amb = 0.16, wrap = 0.4 })
  local nl = max(5, floor(w.r * 1.6))
  w.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - w.cx, y - w.cy
    local a, b = (dx * ux + dy * uy) / (w.r * 0.82 + 0.45), (dx * px + dy * py) / (w.r + 0.45)
    local i2 = 1
    for j, cu in ipairs(A.CUTS) do if v[k] >= cu then i2 = j + 1 end end
    -- growth lines: curved ribs across the whorl (bent toward the aperture)
    local g = (a + 0.35 * b * b) * nl * 0.5
    if (g - floor(g)) < 0.22 and abs(b) < 0.9 then i2 = i2 - 1 end
    if bias[k] then i2 = i2 + bias[k] end
    i2 = max(1, min(6, i2))
    local band = b > 0.22 and b < 0.4
    c:put(x, y, (band and RUST or SHELL)[i2], stok)
  end)
  if i > 1 then -- suture: deep line on this whorl right against the next (bigger) whorl
    W[i - 1].m:grow(1):cut(W[i - 1].m):each(function(x, y) if w.m:has(x, y) then c:put(x, y, SHELL[1], stok) end end)
  end
end

-- aperture: cream lip rim, pink nacre, deep throat toward the inside
local atok = { r = { name = "aperture" } }
local throat = A.rell(Ax + ux * 1.3 - px * 0.6, Ay + uy * 1.3 - py * 0.6, ux, uy, 3.8, 2.4)
local lip = ap:edge()
ap:each(function(x, y) local k = K(x, y)
  local dx, dy = x - Ax, y - Ay
  local a, b = dx * ux + dy * uy, dx * px + dy * py
  local col
  if lip:has(x, y) then col = (b > 1.5 and a < 2) and SHELL[4] or SHELL[6]
  elseif throat:has(x, y) then col = (throat:edge():has(x, y) and a < 0) and NACRE[2] or NACRE[1]
  else col = (a < -0.5 and b < 1) and NACRE[5] or (b > 1.2 and NACRE[3] or NACRE[4]) end
  c:put(x, y, col, atok)
end)
c:put(floor(Ax - ux * 2 + 0.5), floor(Ay - uy * 2 - 1 + 0.5), NACRE[6], atok)
-- deep line where the lip meets the body whorl
ap:grow(1):cut(ap):each(function(x, y) if W[1].m:has(x, y) then c:put(x, y, SHELL[2], stok) end end)

-- moss
local mtok = { r = { name = "moss" } }
A.moss(c, moss, MOSS, { size = 3.2, seed = 4, tok = mtok, R = 2.5 })
-- two strands hanging down over the shell (lit tip, dark root)
for _, st in ipairs{ { 5, 3 }, { 12, 2 } } do
  local a = st[1]
  -- find the lowest moss pixel along this line across
  local bx, by
  for s = -12, 6, 0.5 do local x, y = floor(Bx + ux * a + px * s + 0.5), floor(By + uy * a + py * s + 0.5)
    if moss:has(x, y) then bx, by = x, y end end
  if bx then for j = 1, st[2] do c:put(bx, by + j, j == st[2] and MOSS[4] or MOSS[2], mtok) end end
end

-- quirk: fern fiddlehead (stem + curl) rising out of the moss top
local top
moss:each(function(x, y) local a = along(x, y) if a > 3 and a < 7 and (not top or y < top[2]) then top = { x, y } end end)
local fx, fy = top[1], top[2]
local FERN = { o = MOSS[2], g = MOSS[4], l = MOSS[5], h = MOSS[6] }
A.map(c, fx - 1, fy - 6, {
  ".gl.",
  "g..h",
  "g.o.",
  ".l..",
  ".g..",
  ".o..",
}, FERN, mtok)
-- sparkle on the nacre lip side
A.save(c, NAME)
