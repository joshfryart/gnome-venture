-- acai (pass 3B, final). Drooping sprig of 7 small acai on thin orange pedicels, two slim folded leaves.
-- Realism (hpx.lua): per-pixel sphere light quantised to a 6-tone berry ramp, dusty waxy bloom on the lit side,
-- 1 px cream-violet specular + bloom halo, cool reflected light on the lower-right rim, calyx cap where each
-- pedicel enters, AO + directional contact shadow where a front berry overlaps a back one, leaf midrib + side
-- veins with a light/dark fold. History: acai.p1 (pass 1), acai.p2 (previous final).
-- quirk: the shy berry (paler, unripe, smaller) peeks out from under the right leaf.
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "acai" }

local BERRY = { "#2f2049", "#40295f", "#523779", "#664894", "#7e69a9", "#a093c2" }
local SHYR  = { "#5d4a85", "#74619f", "#8c78b6", "#a493c9", "#bdb0da", "#d6cdea" }
local SPEC, RIM = "#f6efff", "#5b5fa8"
local STEM  = { "#5a3026", "#7d4630", "#a8653a", "#d08f55" }
local LEAF  = { "#1f4540", "#2b6047", "#3a7d4f", "#559c54", "#79b95b", "#a2d06e" }
local VEIN  = "#c8e68e"

local DY = 4                                           -- whole drawing sits 4 px lower than the layout numbers
local function L(t) for _, p in ipairs(t) do p[2] = p[2] + DY end return t end

-- stems: rachilla (2 px, thins to 1 px) + 1 px pedicels; drawn first, berries hang over their ends
local stemM = c:line(L{ {38, 3}, {35, 7}, {33, 12} }, 1):add(c:line(L{ {33, 12}, {32, 17}, {32, 24} }, 2))
local peds = { { {32,17},{27,21} }, { {32,18},{39,22} }, { {32,22},{20,31} }, { {32,22},{32,31} },
               { {33,22},{44,33} }, { {32,26},{26,42} }, { {33,26},{38,42} } }
for _, p in ipairs(peds) do stemM:add(c:line(L(p), 1)) end
local stok = { r = { name = "stem" } }
X.tone(c, stemM, X.light(X.pillow(stemM, 1), { amb = 0.3 }), STEM, { tok = stok })
c:put(39, 2 + DY, STEM[3], stok) c:put(40, 2 + DY, STEM[2], stok) c:put(40, 3 + DY, STEM[2], stok)   -- curl

local berries = {}
local function berry(cx, cy, r, ramp, shy)
  berries[#berries + 1] = { m = c:ellipse(cx, cy + DY, r, r), cx = cx, cy = cy + DY, r = r, ramp = ramp, shy = shy }
end
berry(46, 14, 3.5, SHYR, true)                         -- shy one, tucked under the right leaf
berry(27, 24, 4.5, BERRY) berry(39, 25, 4.5, BERRY)
berry(19, 35, 5, BERRY) berry(32, 35, 5, BERRY) berry(45, 36, 5, BERRY)
berry(26, 46, 5, BERRY) berry(39, 47, 5, BERRY)

local function paintBerry(i)
  local b = berries[i]
  local n = X.sphere(b.cx - 0.4, b.cy - 0.4, b.r, b.m)
  local v = X.light(n, { amb = 0.06, wrap = 0.2 })
  local bias, vis = {}, b.m:copy()
  for j = i + 1, #berries do
    local o = berries[j].m
    vis:cut(o)
    X.ao(bias, b.m, o, 1, -1)                                       -- AO ring where they touch
    o:shift(1, 1):each(function(x, y) if b.m:has(x, y) and not o:has(x, y) then
      local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)       -- contact shadow falls lower-right
  end
  local idx = X.tone(c, vis, v, b.ramp, { bias = bias, cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 }, tok = { r = { name = "berry" .. i } } })
  -- cool reflected light: short arc on the lower-right edge, only where nothing sits in contact
  local rim = X.rim(n)
  b.m:edge():each(function(x, y) local k = K(x, y)
    if vis:has(x, y) and rim[k] > 0.7 and not bias[k] then c:put(x, y, b.shy and b.ramp[3] or RIM) end end)
  -- specular: brightest spec pixel + bloom halo (left + below)
  local sp, best, bx, by = X.spec(n, 40)
  vis:each(function(x, y) local s = sp[K(x, y)] if not best or s > best then best, bx, by = s, x, y end end)
  if bx then
    c:put(bx, by, b.shy and b.ramp[6] or SPEC)
    if not b.shy then c:put(bx + 1, by, b.ramp[6]) c:put(bx, by + 1, b.ramp[6]) c:put(bx - 1, by + 1, b.ramp[5]) end
  end
  -- calyx cap where the pedicel enters (small dark star)
  if not b.shy then
    local tx, ty = math.floor(b.cx + 0.5), math.floor(b.cy - b.r + 0.5)
    if vis:has(tx, ty) then c:put(tx, ty, STEM[2]) end
    if vis:has(tx, ty + 1) then c:put(tx, ty + 1, b.ramp[1]) end
    if vis:has(tx - 1, ty + 1) then c:put(tx - 1, ty + 1, STEM[1]) end
    if vis:has(tx + 1, ty + 1) then c:put(tx + 1, ty + 1, STEM[1]) end
  end
end

-- leaves: lanceolate, folded on the midrib (cylinder normals), midrib + 2 side veins per side
local function leaf(ax, ay, bx, by, w, veins)
  ay, by = ay + DY, by + DY
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.97 then return -1 end
    return math.max(0.5, w * math.sin(math.pi * math.min(1, t * 1.02 + 0.06)) ^ 0.7)
  end)
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  local tok = { r = { name = "leaf" } }
  X.tone(c, m, v, LEAF, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, tok = tok })
  local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if math.abs(s) < 0.2 and t > 0.06 and t < 0.86 then c:put(x, y, s <= 0 and VEIN or LEAF[3], tok) end
    for _, vt in ipairs(veins) do                                  -- side veins: angled toward the tip
      local d = t * len - (vt + math.abs(s) * 2.6)
      if d > -0.5 and d < 0.5 and math.abs(s) > 0.3 and math.abs(s) < 0.8 then
        c:put(x, y, s < 0 and LEAF[5] or LEAF[2], tok) end
    end
  end)
  return m
end

for i = 1, 3 do paintBerry(i) end
leaf(32, 15, 10, 11, 3.4, { 6, 11, 16 })                -- long leaf, out to the left
leaf(34, 14, 53, 7, 3.0, { 5, 10 })                   -- short leaf, up right, over the shy berry
for i = 4, #berries do paintBerry(i) end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "acai.aseprite", png = out .. "acai.png" }
