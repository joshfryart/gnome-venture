-- pickled-green-beans (C34, Opus single pass). Tall slim straight jar with a knurled gold screw cap (bevelled top,
-- vertical knurl ridges, specular), glass thread rings, rounded foot. Inside: whole green beans standing upright in
-- pale dill brine, each a per-pixel cylinder (6-tone green) with seed bumps, a dark seam on the shade side and a
-- pointed tip; a dill sprig with a yellow umbel, a garlic clove and peppercorns in the gaps; AO between beans.
-- Glass: wall rim, left highlight band, pale core, dark right band, cool bounce. Twisted twine round the neck.
-- quirk: a kraft-paper tag hangs from the twine with a tiny bean doodled on it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sin = math.floor, math.max, math.min, math.sin
local c = A.new("pickled-green-beans")
local CX = 31
local BEAN = { "#1d4434", "#2a6338", "#3d843c", "#58a444", "#80c254", "#b4e07a" }
local BRINE = { "#56703a", "#86a24a", "#acc462", "#c8dc82", "#e0eeaa", "#f4fad4" }
local GOLD = { "#5e2f22", "#8f4a1f", "#c9772a", "#f0a838", "#ffd067", "#fff0b0" }
local KRAFT = { "#6a4630", "#a8784e", "#cfa070", "#e8c690", "#f6e2b4" }
local TW = { "#7a5232", "#c89a5a", "#ead0a0" }

c:groundShadow(CX - .5, 55, 12, 1)

local function hwBody(y)
  if y < 16 or y > 53 then return nil end
  if y <= 18 then return 8.5 end
  if y == 19 then return 9.5 end
  if y == 52 then return 9.5 elseif y == 53 then return 8.5 end
  return 10
end
local body, bn, NX = A.lathe(CX, 16, 53, hwBody)
local inner = body:shrink(1)
local LEVEL = 22
local air, brine = HP.mask(), HP.mask()
inner:each(function(x, y) if y < LEVEL then air:set(x, y) else brine:set(x, y) end end)
local an = {} air:each(function(x, y) an[K(x, y)] = bn[K(x, y)] end)
A.tone(c, air, an, A.GLASS, { amb = .4, wrap = .5 })
local brn = {} brine:each(function(x, y) brn[K(x, y)] = bn[K(x, y)] end)

-- beans: {x top, x bottom, top y, half width}
local beans = { { 24, 23.5, 25, 1.2 }, { 27.5, 28.5, 23, 1.4 }, { 31.5, 31, 24, 1.3 }, { 35, 35.5, 22, 1.4 }, { 38.5, 38, 26, 1.2 } }
local bmaskAll = HP.mask()
local BM = {}
for i, b in ipairs(beans) do
  local m, n, T, S = X.cyl(b[1], b[3], b[2], 51, function(t) if t < .06 then return b[4] * (.35 + t / .06 * .65) end return b[4] end)
  m:clip(inner)
  BM[i] = { m = m, n = n, T = T, S = S, b = b }
  bmaskAll:add(m)
end
-- dill sprig (behind beans): thin stalk + feathery fronds + umbel
local dill = HP.mask()
local dl = HP.line({ { 33, 50 }, { 33, 40 }, { 34, 31 }, { 33, 26 } }, 1)
dill:add(dl)
for _, f in ipairs{ { 33, 44, -1 }, { 33, 38, 1 }, { 34, 33, -1 } } do
  dill:add(HP.line({ { f[1], f[2] }, { f[1] + f[3] * 2, f[2] - 2 }, { f[1] + f[3] * 3, f[2] - 4 } }, 1))
end
dill:clip(brine) dill:cut(bmaskAll)
-- brine with AO next to beans
local bb = {}
X.ao(bb, brine, bmaskAll, 1, -1)
local bmask = brine:copy():cut(bmaskAll)
A.tone(c, bmask, brn, BRINE, { amb = .3, wrap = .45, bias = bb })
dill:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and "#3f7a3a" or "#2e5e34") end)
for _, p in ipairs{ { 32, 24 }, { 34, 24 }, { 33, 23 } } do if bmask:has(p[1], p[2]) then c:put(p[1], p[2], "#e8c840") end end
c:put(33, 24, "#a88a2a")
for x = CX - 9, CX + 9 do if bmask:has(x, LEVEL) then c:put(x, LEVEL, BRINE[6]) end end
-- garlic clove + peppercorns on the floor
for _, p in ipairs{ { 25, 49, "#f4ecd8" }, { 26, 49, "#e0d2b8" }, { 25, 50, "#d2c0a4" }, { 26, 50, "#b8a090" }, { 25, 48, "#fffaf0" } } do
  if bmask:has(p[1], p[2]) then c:put(p[1], p[2], p[3]) end end
for _, p in ipairs{ { 30, 50 }, { 36, 49 }, { 40, 50 } } do
  if bmask:has(p[1], p[2]) then c:put(p[1], p[2], "#4a2a2a") if bmask:has(p[1] + 1, p[2]) then c:put(p[1] + 1, p[2], "#2e1c22") end end
end
-- beans
for i, s in ipairs(BM) do
  local bias = {}
  local idx = A.tone(c, s.m, s.n, BEAN, { amb = .1, wrap = .3, bias = bias })
  -- seed bumps: lit bulge pixel on the lit half, dark pinch row between seeds
  local x0, y0, x1, y1 = s.m:bbox()
  local ph = floor(X.hash(i, 7) * 4)
  s.m:each(function(x, y)
    local k = K(x, y)
    local rel = (y - y0 + ph) % 5
    if s.S[k] < -.1 and s.S[k] > -.75 and rel == 1 and y > y0 + 2 then c:put(x, y, BEAN[min(6, idx[k] + 1)]) end
    if rel == 3 and y > y0 + 2 and s.S[k] > .2 then c:put(x, y, BEAN[max(1, idx[k] - 1)]) end
    -- seam on the shade side
    if s.S[k] > .7 and y > y0 + 3 then c:put(x, y, BEAN[2]) end
  end)
  -- pointed tip
  c:put(floor(s.b[1] + .5), y0 - 0, BEAN[4])
  local sub = s.m:copy() sub:each(function(x, yy) if yy <= LEVEL then sub.s[K(x, yy)] = nil end end)
  A.tint(c, sub, BRINE[3], .1)
end
c:put(27, 26, A.SPEC)

-- glass overlay + walls
local lower = HP.mask() body:each(function(x, y) if y >= 19 then lower:set(x, y) end end)
A.glass(c, lower, inner, bn, NX, { ys = 19 })
-- neck with glass thread rings (rows 16..18)
local neck = HP.mask() body:each(function(x, y) if y <= 18 then neck:set(x, y) end end)
local nn = {} neck:each(function(x, y) nn[K(x, y)] = bn[K(x, y)] end)
A.tone(c, neck, nn, A.GLASS, { amb = .3, wrap = .4 })
for x = CX - 8, CX + 8 do if neck:has(x, 17) then c:put(x, 17, A.GLASS[2]) end end

-- screw cap: knurled band rows 10..15, bevelled top rows 8..9
local cap, cn, CNX = A.lathe(CX, 10, 15, function() return 9.5 end)
local cidx = A.tone(c, cap, cn, GOLD, { amb = .08, wrap = .25 })
cap:each(function(x, y)
  local k = K(x, y)
  if (x - CX) % 2 == 0 and y >= 11 and y <= 14 then c:put(x, y, GOLD[max(1, cidx[k] - 1)])
  elseif y >= 11 and y <= 14 and cidx[k] >= 4 then c:put(x, y, GOLD[min(6, cidx[k] + 1)]) end
  if y == 15 then c:put(x, y, GOLD[max(1, cidx[k] - 2)]) end
  if y == 10 then c:put(x, y, GOLD[min(6, cidx[k] + 1)]) end
end)
local top, tn = A.lathe(CX, 8, 9, function(y) return y == 8 and 7.5 or 9 end, 2)
local tidx = A.tone(c, top, tn, GOLD, { amb = .2, wrap = .3 })
for x = CX - 7, CX + 7 do if top:has(x, 8) then c:put(x, 8, x < CX + 2 and GOLD[5] or GOLD[4]) end end
c:put(CX - 5, 8, GOLD[6]) c:put(CX - 4, 8, GOLD[6]) c:put(CX - 6, 12, A.SPEC)

-- twine twisted round the neck (row 18-19)
for x = CX - 9, CX + 10 do
  local t = (x % 3)
  c:put(x, 19, t == 0 and TW[1] or (t == 1 and TW[3] or TW[2]))
end
-- hanging string to the tag
local str = HP.line({ { CX + 10, 19 }, { CX + 12, 22 }, { CX + 13, 25 } }, 1)
str:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and TW[2] or TW[1]) end)
-- kraft tag (rows 26..36, x 40..48), clipped top corners, punched hole, folded corner
local tag = HP.poly{ { CX + 10, 28 }, { CX + 12, 26 }, { CX + 15, 26 }, { CX + 17, 28 }, { CX + 17, 37 }, { CX + 10, 37 } }
local tgn = X.pillow(tag, 1.2)
local tidx2 = A.tone(c, tag, tgn, KRAFT, { amb = .3, wrap = .4 })
c:put(CX + 13, 27, TW[1]) c:put(CX + 14, 27, KRAFT[1])
c:put(CX + 13, 26, TW[2])
-- doodled bean
for _, p in ipairs{ { 12, 34 }, { 13, 33 }, { 14, 32 }, { 15, 31 }, { 15, 30 } } do c:put(CX + p[1], p[2], "#3d843c") end
c:put(CX + 13, 32, "#80c254")
-- underside shadow of the tag on glass
for y = 27, 37 do if body:has(CX + 9, y) then c:put(CX + 9, y, A.GLASS[1]) end end
A.fin(c, "pickled-green-beans")
