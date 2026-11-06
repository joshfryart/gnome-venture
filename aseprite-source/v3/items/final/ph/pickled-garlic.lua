-- pickled-garlic (C34, Opus single pass). Pot-bellied glass jar with a short neck, covered with a red gingham cloth
-- cap: pillowed dome over the lid, gathered at the neck by twisted twine, skirt with fold lines, a scalloped hem and
-- a gold running stitch. Inside: peeled garlic cloves (pillow-lit teardrops, 6-tone ivory with a violet-pink root
-- end and a pale ridge), a slim red chilli and peppercorns in clear pale brine; AO between cloves.
-- Glass: wall rim, left highlight band, pale core, dark right band, cool bounce.
-- quirk: one clove has sprouted, and its green shoot reaches straight up to the brine surface.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("pickled-garlic")
local CX = 32
local GAR = { "#6e4c6a", "#9a7c92", "#c8b4b4", "#e4d8c4", "#f4ecda", "#fffaee" }
local BRINE = { "#7a5a2a", "#b08640", "#d0a858", "#e4c47a", "#f2dca4", "#fcf0cc" }
local CLOTH = { "#5e1a30", "#9a2a38", "#d0443c", "#ea6a4c", "#f89a72", "#ffc8a0" }
local CHILI = { "#5e1a2a", "#a02a2e", "#e04a36", "#ff8a5c" }
local TW = { "#7a5232", "#c89a5a", "#ead0a0" }
local LEAFC = { "#2e7646", "#6ab455", "#9dd06c" }

c:groundShadow(CX - .5, 55, 12, 1)

local function hwBody(y)
  if y < 20 or y > 53 then return nil end
  if y <= 24 then return 7.5 end
  if y == 25 then return 8.5 end
  if y == 26 then return 9.8 end
  if y == 27 then return 10.6 end
  if y == 53 then return 8.5 elseif y == 52 then return 10 elseif y == 51 then return 10.8 end
  return 11.2
end
local body, bn, NX = A.lathe(CX, 20, 53, hwBody)
local inner = body:shrink(1)
local LEVEL = 27
local brine = HP.mask() inner:each(function(x, y) if y >= LEVEL then brine:set(x, y) end end)
local brn = {} brine:each(function(x, y) brn[K(x, y)] = bn[K(x, y)] end)
local air = inner:copy():cut(brine)
local an = {} air:each(function(x, y) an[K(x, y)] = bn[K(x, y)] end)
A.tone(c, air, an, A.GLASS, { amb = .4, wrap = .5 })

-- cloves: {cx, cy, tilt ux, uy (toward tip), len, width}
local cloves = {
  { 26, 36, -.35, -1, 4.6, 2.6 }, { 33, 35, .15, -1, 4.8, 2.8 }, { 39, 38, .6, -1, 4.2, 2.5 },
  { 24.5, 46, -.2, -1, 4.6, 2.7 }, { 31, 45, .3, -1, 4.8, 3.0 }, { 38.5, 47, .4, -1, 4.2, 2.6 },
}
local solid = HP.mask()
local CM = {}
for i, q in ipairs(cloves) do
  local l = sqrt(q[3] ^ 2 + q[4] ^ 2) local ux, uy = q[3] / l, q[4] / l
  -- teardrop: ellipse + tip triangle
  local m = A.rell(q[1], q[2], ux, uy, q[5], q[6])
  local tx, ty = q[1] + ux * (q[5] + 1.6), q[2] + uy * (q[5] + 1.6)
  m:add(HP.poly{ { q[1] + ux * q[5] * .3 - uy * q[6] * .8, q[2] + uy * q[5] * .3 + ux * q[6] * .8 },
                 { tx, ty },
                 { q[1] + ux * q[5] * .3 + uy * q[6] * .8, q[2] + uy * q[5] * .3 - ux * q[6] * .8 } })
  m:clip(inner)
  CM[i] = { m = m, ux = ux, uy = uy, q = q }
  solid:add(m)
end
-- chilli: slim curved pod between cloves
local chili = HP.mask()
local cp = { { 41, 29 }, { 41, 34 }, { 43, 39 }, { 42, 44 } }
for j = 0, 40 do local x, y = A.bez(cp, j / 40) chili:set(floor(x + .5), floor(y + .5)) if j < 34 then chili:set(floor(x + .5) + 1, floor(y + .5)) end end
chili:clip(inner) chili:cut(solid)
-- sprout from clove 2 tip up to the surface
local sprout = HP.line({ { 34, 29 }, { 34, 27 }, { 35, 25 } }, 1)
local bb = {}
local occ = solid:copy():add(chili)
X.ao(bb, brine, occ, 1, -1)
local bmask = brine:copy():cut(occ)
A.tone(c, bmask, brn, BRINE, { amb = .3, wrap = .45, bias = bb })
for x = CX - 11, CX + 11 do if bmask:has(x, LEVEL) then c:put(x, LEVEL, BRINE[6]) end end
for _, p in ipairs{ { 28, 51 }, { 35, 51 }, { 22, 40 } } do
  if bmask:has(p[1], p[2]) then c:put(p[1], p[2], "#4a2a2a") if bmask:has(p[1] + 1, p[2]) then c:put(p[1] + 1, p[2], "#2e1c22") end end
end
-- chilli tone: lit left
chili:each(function(x, y) c:put(x, y, chili:has(x - 1, y) and CHILI[2] or CHILI[3]) end)
c:put(41, 30, CHILI[4]) c:put(41, 28, "#3f9150") c:put(42, 28, "#24544a")
-- cloves
for i, s in ipairs(CM) do
  local n = X.pillow(s.m, 2.2)
  local idx = A.tone(c, s.m, n, GAR, { amb = .12, wrap = .3 })
  local q = s.q
  s.m:each(function(x, y)
    local k = K(x, y)
    local dx, dy = x + .5 - q[1], y + .5 - q[2]
    local a = dx * s.ux + dy * s.uy      -- along (tip +)
    local b = -dx * s.uy + dy * s.ux     -- across
    -- flat root end: violet-pink band
    if a < -q[5] + 1.3 then c:put(x, y, idx[k] >= 4 and "#d8a4b4" or "#a87890") end
    -- ridge: the clove's inner edge, pale line slightly off-centre
    if abs(b + .9) < .5 and a > -q[5] + 1.5 and a < q[5] and idx[k] >= 3 then c:put(x, y, GAR[min(6, idx[k] + 1)]) end
    if abs(b - .2) < .5 and a > -q[5] + 2 and a < q[5] - 1 and idx[k] >= 3 then c:put(x, y, GAR[max(1, idx[k] - 1)]) end
  end)
  local sub = s.m:copy()
  A.tint(c, sub, BRINE[3], .08)
end
c:put(31, 32, A.SPEC) c:put(24, 33, GAR[6])
-- sprout over the clove tip
sprout:each(function(x, y) c:put(x, y, y > 27 and LEAFC[1] or LEAFC[2]) end)
c:put(35, 25, LEAFC[3]) c:put(36, 25, LEAFC[2])

-- glass overlay + walls
A.glass(c, body, inner, bn, NX, { ys = 26 })

-- cloth: skirt rows 19..28 flaring, gather at 17..18, dome 9..16
local cloth = HP.mask()
local function hwC(y)
  if y < 9 or y > 28 then return nil end
  if y == 9 then return 5 elseif y == 10 then return 7.5 elseif y == 11 then return 8.8 end
  if y <= 15 then return 9.5 end
  if y == 16 then return 9 end
  if y <= 18 then return 8.2 end
  return 9 + (y - 19) * .45
end
local cm, cn, CNX = A.lathe(CX, 9, 28, hwC, 1.3)
-- scalloped hem: drop pixels in a wave on the last 2 rows
cm:each(function(x, y)
  local ph = (x - CX + 40) % 5
  if (y == 28 and ph ~= 2) or (y == 27 and (ph == 0 or ph == 4) and abs(x - CX) > 2) then cm.s[K(x, y)] = nil end
end)
-- folds in the skirt and gathers on the dome
local bias = {}
cm:each(function(x, y)
  local k = K(x, y)
  if y >= 19 then
    local f = (x - CX + 40) % 5
    if f == 0 then bias[k] = -1 elseif f == 1 then bias[k] = 1 end
  elseif y == 16 or y == 15 then
    if (x - CX + 40) % 3 == 0 then bias[k] = -1 end
  end
end)
local cidx = A.tone(c, cm, cn, CLOTH, { amb = .1, wrap = .3, bias = bias })
-- gingham: pale weave checks (2x2) mixed toward cream
cm:each(function(x, y)
  local k = K(x, y)
  local gx, gy = (x // 2) % 2, (y // 2) % 2
  local h = c:get(x, y)
  if gx == 1 and gy == 1 then c.pix[y * c.w + x] = A.mix(h, "#fff4d6", .55)
  elseif gx == 1 or gy == 1 then c.pix[y * c.w + x] = A.mix(h, "#fff4d6", .25) end
end)
-- gold running stitch along the hem (2 on, 1 off), row 26
local st = 0
for x = CX - 11, CX + 11 do
  if cm:has(x, 26) then st = st + 1 if st % 3 ~= 0 then c:put(x, 26, "#f5b82e") end end
end
-- twine gather at rows 17..18, twisted, with a bow tail on the right
for x = CX - 9, CX + 9 do
  local t = (x + 1) % 3
  c:put(x, 17, t == 0 and TW[1] or (t == 1 and TW[3] or TW[2]))
  c:put(x, 18, t == 0 and TW[2] or TW[1])
end
for _, p in ipairs{ { 10, 18, 2 }, { 11, 19, 1 }, { 11, 20, 2 }, { 12, 21, 1 }, { 10, 16, 3 }, { 11, 15, 2 }, { 12, 15, 1 } } do
  c:put(CX + p[1], p[2], TW[p[3]])
end
-- dome highlight
c:put(CX - 4, 11, CLOTH[6]) c:put(CX - 3, 11, CLOTH[6])
A.fin(c, "pickled-garlic")
