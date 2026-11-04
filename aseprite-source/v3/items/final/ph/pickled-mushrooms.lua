-- pickled-mushrooms (C34, Opus single pass). Round-bellied apothecary jar with a short neck, capped by a lid shaped like
-- a porcini cap (brown dome, pale freckles, a gill skirt underneath); inside, golden button mushrooms (domed caps on
-- cream stems), a bay leaf and peppercorns in amber brine.
-- Material: lathe glass with band highlights and cool bounce; sphere-lit caps with a spec dot, pale gill rim and AO
-- under each cap; cylinder stems; lid dome 6-tone with suede freckles and radial gill lines.
-- quirk: a tiny red toadstool has sprouted on the lid's shoulder.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("pickled-mushrooms")

local BRINE = { "#7a4a2a", "#b8782e", "#dca24a", "#f0c66c", "#fae0a0", "#fff4d0" }
local CAP = { "#3a1a1a", "#5e2e20", "#86482a", "#ac6a34", "#cc8e48", "#eab872" }
local STEMR = { "#8a7058", "#c0a882", "#e4d4b0", "#f6ecd2", "#fff8e8" }
local LID = { "#3a2020", "#5e3424", "#86502e", "#a8703a", "#c8924c", "#e6b66a" }
local GILL = { "#8a6a50", "#c8a882", "#ead6b4" }
local BAY = { "#2a3a1e", "#4a5e2a", "#6e8238", "#98a84e", "#c2ca78", "#dee2a4" }

c:groundShadow(32, 56, 13, 2)

-- jar: neck 20..23, round belly
local function hw(y)
  if y < 20 then return nil end
  if y <= 23 then return 7.5 end
  local t = (y - 23) / (55 - 23)
  return 7.5 + 6 * sin(min(1, t * 1.15) * pi * .62) ^ .9 - (t > .85 and (t - .85) * 30 or 0)
end
local J = A.jar(c, 32, 20, 55, hw, 27, BRINE)

local occ = HP.mask()
local function shroom(cx, cy, r, tilt)
  -- stem first (below the cap)
  local sm, sn = A.lathe(cx + tilt * 2, cy + 1, cy + r + 2, function(y) return r * .3 end)
  sm:clip(J.inner)
  local snn = {} sm:each(function(x, y) snn[K(x, y)] = sn[K(x, y)] end)
  A.piece(c, sm, snn, { STEMR[1], STEMR[1], STEMR[2], STEMR[3], STEMR[4], STEMR[5] }, occ, { amb = .2, wrap = .3 })
  -- cap: upper half-ellipse dome
  local cm = HP.mask()
  for y = floor(cy - r), floor(cy + 1) do for x = floor(cx - r - 1), floor(cx + r + 1) do
    local dx, dy = x + .5 - cx - tilt * (cy - y) * .3, (y + .5 - cy) / 1.05
    if dx * dx + dy * dy <= r * r and y <= cy + 1 then cm:set(x, y) end end end
  cm:clip(J.inner)
  local cn = X.sphere(cx - .5, cy - .5, r, cm)
  for k, v in pairs(cn) do if not cm.s[k] then cn[k] = nil end end
  cm:each(function(x, y) if not cn[K(x, y)] then cn[K(x, y)] = { A.norm((x + .5 - cx) / r, .3, .5) } end end)
  local ci = A.piece(c, cm, cn, CAP, occ, { amb = .1, wrap = .28, sep = 1 })
  -- pale gill rim along the bottom, spec dot
  cm:each(function(x, y) if not cm:has(x, y + 1) then c:put(x, y, (x < cx) and GILL[3] or GILL[2]) end end)
  local gx, gy = floor(cx - r * .4), floor(cy - r * .55)
  if cm:has(gx, gy) then c:put(gx, gy, A.SPEC) end
  if cm:has(gx + 1, gy) then c:put(gx + 1, gy, CAP[6]) end
end
-- bay leaf behind
do
  local p = { { 22, 51 }, { 21, 44 }, { 23, 37 }, { 26, 31 } }
  local m = HP.mask()
  for i = 0, 40 do local t = i / 40 local x, y = A.bez(p, t) local w = 2.6 * sin(pi * t) ^ .8 + .3
    for yy = floor(y - w), floor(y + w) do for xx = floor(x - w), floor(x + w) do
      if (xx + .5 - x) ^ 2 + (yy + .5 - y) ^ 2 <= w * w then m:set(xx, yy) end end end end
  m:clip(J.inner)
  local n = X.pillow(m, 1.5)
  A.piece(c, m, n, BAY, occ, { amb = .15, wrap = .3 })
  for i = 4, 36 do local x, y = A.bez(p, i / 40) if m:has(floor(x + .5), floor(y + .5)) then c:put(floor(x + .5), floor(y + .5), BAY[5]) end end
end
shroom(37, 33, 5, .2)
shroom(27, 38, 5.5, -.2)
shroom(39, 45, 5.5, .1)
shroom(28, 49, 5, 0)
shroom(33, 41, 4, .3)
for _, p in ipairs{ { 25, 30 }, { 41, 39 }, { 22, 45 }, { 35, 52 }, { 43, 51 } } do
  if J.inner:has(p[1], p[2]) then c:put(p[1], p[2], "#3a1e1e") c:put(p[1] + 1, p[2], "#2a1620") c:put(p[1], p[2] - 1, "#7a4a3a") end
end

A.glass(c, J.body, J.inner, J.n, J.NX, { ys = 22 })
for x = 22, 42 do if J.body:has(x, 54) then c:put(x, 54, x < 30 and A.GLASS[5] or A.GLASS[3]) end end

-- porcini-cap lid: gill skirt + dome
local gill = HP.mask()
for x = 18, 45 do for y = 18, 20 do if abs(x + .5 - 32) <= 14 - (y - 18) * 1.5 then gill:set(x, y) end end end
gill:each(function(x, y)
  local col = ((x - 32) % 2 == 0) and GILL[1] or GILL[2]
  if y == 18 then col = GILL[3] end
  if x > 40 then col = GILL[1] end
  c:put(x, y, col)
end)
local dome = HP.mask()
for y = 6, 18 do for x = 16, 47 do
  local dx, dy = (x + .5 - 32) / 15.5, (y + .5 - 18.5) / 12.5
  if dx * dx + dy * dy <= 1 and y <= 17 then dome:set(x, y) end end end
local dn = X.sphere(31.5, 18, 15.5, dome)
for k, v in pairs(dn) do dn[k] = { A.norm(v[1], v[2] * 1.2 - .1, v[3]) } end
local li = A.tone(c, dome, dn, LID, { amb = .08, wrap = .25 })
-- rolled lower edge of the cap, freckles, gloss
dome:each(function(x, y) if not dome:has(x, y + 1) then c:put(x, y, x < 26 and LID[4] or LID[2]) end end)
dome:each(function(x, y) local h = X.hash(x, y, 11)
  if h > .9 and y < 16 then local i = li[K(x, y)] or 3 c:put(x, y, i >= 4 and "#f6dcae" or "#c8a07a") end end)
for _, p in ipairs{ { 22, 10 }, { 23, 9 }, { 24, 9 }, { 25, 8 } } do c:put(p[1], p[2], LID[6]) end
c:put(23, 10, A.SPEC)

-- quirk: tiny red toadstool on the right shoulder of the lid
do
  c:put(42, 9, STEMR[4]) c:put(42, 10, STEMR[3]) c:put(43, 10, STEMR[2])
  for _, p in ipairs{ { 40, 8, "#c8302e" }, { 41, 7, "#f26a4a" }, { 42, 7, "#e8493b" }, { 43, 7, "#c8302e" }, { 44, 8, "#8a1e2e" },
    { 41, 8, "#e8493b" }, { 42, 8, "#c8302e" }, { 43, 8, "#a8243a" }, { 42, 6, "#e8493b" } } do c:put(p[1], p[2], p[3]) end
  c:put(41, 7, "#fff4d6") c:put(43, 8, "#ffe8d0")
end

A.fin(c, "pickled-mushrooms")
