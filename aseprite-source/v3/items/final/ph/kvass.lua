-- kvass (final, Opus single pass). A slim glass bottle of dark rye kvass: cork stopper with grain and pale end,
-- thick glass lip, empty green-tint neck (bright rim, pale core), a collar of tan foam, the brew lit per pixel
-- (6-tone amber-brown) with a long glass specular, cool bounce on the shade side and rising bubbles; a kraft paper
-- label with a printed rye ear; twisted twine round the neck; ground shadow + AO at the base.
-- quirk: a sprig of rye tucked into the neck twine, ears nodding over the cork.
local NAME = "kvass"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local KV    = { "#2a1216", "#4a1d1c", "#6e2d1f", "#954622", "#bf6c2c", "#e39e48" }
local GLASS = { "#2c4648", "#466a68", "#709a90", "#a2c6b6", "#cfe8d6", "#eefaee" }
local FOAM  = { "#a48562", "#cdb08a", "#ead5ae", "#fff4d6" }
local PAPER = { "#5a3a2c", "#875838", "#b28252", "#d6aa72", "#edcd98", "#fae5bc" }
local CORK  = { "#5e3f28", "#86603c", "#ad8452", "#d0a872", "#ead0a0" }
local TW    = { "#7a5230", "#b5884e", "#e0bf7e" }
local RYE   = { "#7c4a1c", "#b77b2a", "#e2b04a", "#f8dc86" }
local SPEC, BOUNCE = "#fff0cc", "#6a3a52"
local CX = 32

local function hw(y)
  if y <= 10 then return 2.0 end            -- cork
  if y <= 12 then return 4.0 end            -- glass lip
  if y <= 19 then return 3.0 end            -- neck
  if y <= 28 then local t = (y - 19) / 9 return 3.0 + 6.0 * sin(t * pi / 2) ^ 1.3 end -- shoulder
  if y <= 48 then return 9.0 end
  if y == 49 then return 8.6 end
  return 7.8
end
local Y0, Y1 = 7, 50
c:groundShadow(CX, 51, 12, 1)

local m = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = CX - 10, CX + 10 do if abs(x + 0.5 - CX) <= h then m:set(x, y) end end end
-- normals: vertical cylinder; shoulder tilts up
local n = {}
m:each(function(x, y)
  local h = hw(y)
  local sn = max(-0.96, min(0.96, (x + 0.5 - CX) / (h + 0.5)))
  local ny = 0
  if y > 19 and y <= 28 then ny = -0.55 * cos((y - 19) / 9 * pi / 2) end
  if y >= 49 then ny = 0.4 end
  local nz = sqrt(max(0.02, 1 - sn * sn))
  local l = sqrt(sn * sn + ny * ny + nz * nz)
  n[K(x, y)] = { sn / l, ny / l, nz / l }
end)
local v = X.light(n, { amb = 0.05, wrap = 0.25 })

local cork, glass, foam, brew = HP.mask(), HP.mask(), HP.mask(), HP.mask()
m:each(function(x, y)
  if y <= 10 then cork:set(x, y) elseif y <= 19 then glass:set(x, y) elseif y <= 21 then foam:set(x, y) else brew:set(x, y) end
end)
-- brew: AO under the foam collar and at the base
local bb = {}
brew:each(function(x, y) local k = K(x, y)
  if y == 22 then bb[k] = -1 end
  if y >= 49 then bb[k] = (bb[k] or 0) - 1 end
end)
local btok = { r = { name = "brew" } }
local bidx = X.tone(c, brew, v, KV, { cuts = { 0.16, 0.3, 0.46, 0.64, 0.82 }, bias = bb, tok = btok })
-- glass wall: thin bright rim on the lit edge, cool bounce on the shade edge
brew:edge():each(function(x, y)
  if y < 48 then
    if x + 0.5 < CX then c:put(x, y, (y % 7 == 3) and KV[6] or KV[5], btok) else c:put(x, y, BOUNCE, btok) end
  end
end)
-- glass specular streak (long, broken once) + a short second streak
for y = 25, 46 do if y ~= 31 and y ~= 32 then c:put(CX - 6, y, (y < 29 or y > 43) and KV[6] or SPEC, btok) end end
for y = 27, 30 do c:put(CX - 4, y, KV[6], btok) end
-- base: thick glass punt line
for x = CX - 7, CX + 7 do if brew:has(x, 48) then c:put(x, 48, KV[2], btok) end end
-- rising bubbles
for _, b in ipairs{ { 35, 46 }, { 36, 43 }, { 35, 31 }, { 36, 28 }, { 29, 45 }, { 30, 25 } } do c:put(b[1], b[2], KV[5], btok) end

-- foam collar
local ftok = { r = { name = "foam" } }
X.tone(c, foam, v, FOAM, { cuts = { 0.25, 0.5, 0.75 }, tok = ftok })
for _, p in ipairs{ { 30, 20 }, { 33, 21 }, { 35, 20 } } do c:put(p[1], p[2], FOAM[2], ftok) end

-- empty neck glass: bright rim, pale core
local gtok = { r = { name = "glass" } }
local gb = {}
glass:each(function(x, y) local k = K(x, y)
  if y == 12 or (y == 11 and x + 0.5 > CX + 2) then gb[k] = -2 end      -- lip underside
end)
X.tone(c, glass, v, GLASS, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = gb, tok = gtok })
for y = 13, 19 do c:put(CX - 3, y, GLASS[6], gtok) c:put(CX + 2, y, GLASS[2], gtok) c:put(CX - 1, y, GLASS[5], gtok) c:put(CX, y, GLASS[4], gtok) end
c:put(CX - 3, 11, GLASS[6], gtok) c:put(CX - 2, 11, GLASS[6], gtok)

-- cork: pale end grain on top, speckles, lit left
local ctok = { r = { name = "cork" } }
local cidx = X.tone(c, cork, v, CORK, { cuts = { 0.25, 0.45, 0.65, 0.82 }, tok = ctok })
for x = CX - 2, CX + 1 do c:put(x, Y0, x < CX + 1 and CORK[5] or CORK[4], ctok) end
c:put(CX - 1, 9, CORK[2], ctok) c:put(CX, 8, CORK[3], ctok) c:put(CX + 1, 10, CORK[1], ctok)

-- label: kraft paper band, edges turned, printed rye ear + text dashes
local lab = HP.mask()
m:each(function(x, y) if y >= 31 and y <= 40 then lab:set(x, y) end end)
local lb = {}
lab:each(function(x, y) if y == 40 then lb[K(x, y)] = -1 end end)
local ltok = { r = { name = "label" } }
X.tone(c, lab, v, PAPER, { cuts = { 0.14, 0.28, 0.46, 0.64, 0.84 }, bias = lb, tok = ltok })
for x = CX - 9, CX + 8 do c:put(x, 30, KV[1], btok) end   -- shadow line above label
for x = CX - 9, CX + 8 do if (x % 2 == 0) then c:put(x, 32, PAPER[2], ltok) c:put(x, 39, PAPER[2], ltok) end end
local INKB = "#4a2420"
for _, p in ipairs{ { 32, 33, RYE[3] }, { 31, 34, RYE[2] }, { 33, 34, RYE[3] }, { 32, 35, RYE[3] }, { 31, 36, RYE[2] }, { 33, 36, RYE[3] },
  { 32, 37, INKB }, { 32, 38, INKB }, { 32, 34, INKB } } do c:put(p[1], p[2], p[3], ltok) end
for _, x in ipairs{ 26, 27, 28, 36, 37, 38 } do c:put(x, 35, PAPER[1], ltok) end
for _, x in ipairs{ 27, 28, 36, 37 } do c:put(x, 37, PAPER[2], ltok) end

-- twine: two twisted turns round the neck, knot + tail on the right
local ttok = { r = { name = "twine" } }
for x = CX - 3, CX + 2 do
  c:put(x, 15, ((x % 2 == 0) and TW[3] or TW[2]), ttok)
  c:put(x, 16, ((x % 2 == 1) and TW[2] or TW[1]), ttok)
end
c:put(CX - 3, 15, TW[3], ttok)
for _, p in ipairs{ { 35, 15, 2 }, { 35, 16, 1 }, { 36, 17, 2 }, { 36, 18, 1 }, { 37, 19, 2 } } do c:put(p[1], p[2], TW[p[3]], ttok) end

-- quirk: rye sprig tucked under the twine, ears nodding up-left over the cork
local rtok = { r = { name = "rye" } }
local stalk = { { 35, 16 }, { 36, 13 }, { 36, 10 }, { 35, 7 } }
for i = 0, 20 do local x, y = A.bez(stalk, i / 20) c:put(floor(x + .5), floor(y + .5), RYE[2], rtok) end
-- ear: alternating grains up the top of the stalk, awns flicking out
for _, g in ipairs{ { 36, 8, 4 }, { 34, 7, 3 }, { 36, 6, 3 }, { 34, 5, 3 }, { 35, 4, 4 }, { 35, 5, 2 }, { 35, 6, 2 }, { 37, 9, 3 } } do
  c:put(g[1], g[2], RYE[g[3]], rtok) end
for _, a in ipairs{ { 37, 6 }, { 38, 5 }, { 33, 6 }, { 33, 4 }, { 36, 3 } } do c:put(a[1], a[2], RYE[2], rtok) end

A.save(c, NAME)
