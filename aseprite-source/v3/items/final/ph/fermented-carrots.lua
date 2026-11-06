-- fermented-carrots (B31, Opus single pass). A slim clip-top glass jar: domed glass lid on an orange rubber gasket,
-- steel wire bail and lever, thick glass base. Inside, upright carrot sticks (round-shaded, growth rings) and a dill
-- sprig standing in cloudy golden brine, a pale headspace above, fermentation bubbles clinging to the glass.
-- Glass: bright rim on the lit left edge, a broken vertical specular streak, cool shade edge on the right.
-- quirk: a little kraft paper tag on twine hangs from the bail lever, a tiny carrot doodled on it.
local NAME = "fermented-carrots"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_1.lua")
local HP, X, K, P = G.HP, G.X, G.K, G.P
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local BRINE = { "#8a5a3a", "#b47a40", "#d29a4e", "#e6b866", "#f2d48a", "#fbe8b4" }
local AIR   = { "#6a8aa8", "#8cb0c4", "#b4d4dc", "#d4ecea", "#eaf8f2", "#f6fff8" }
local OR    = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
local GASK  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local WIRE  = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local DILL  = { "#24544a", "#3f9150", "#7cc35a" }
local KRAFT = { "#864c33", "#b97a4a", "#d8a874", "#ecc896" }
local RIMHI, RIMSH, SPEC = "#f4fffc", "#4c6a96", "#fff4d6"

local cx, x0, x1 = 31, 20, 42          -- body spans x0..x1 (23 wide)
local yTop, yBot, yBrine = 19, 54, 25

c:groundShadow(31, 56, 14, 1)

-- body
local body = HP.rrect(x0, yTop, x1, yBot, 4)
local bn = G.vcylN(body, x0, x1, 0)
local inner = body:shrink(1)
local brine = inner:copy():clip(HP.rect(0, yBrine, 63, 63))
local air = inner:copy():cut(brine)
local glassEdge = body:copy():cut(inner)
local btok = { r = { name = "brine" } }
G.shade(c, brine, bn, BRINE, { tok = btok, amb = 0.2, wrap = 0.4 })
G.shade(c, air, bn, AIR, { tok = btok, amb = 0.3, wrap = 0.4 })
-- brine surface: meniscus line + darker band under it
for x = x0 + 1, x1 - 1 do
  if brine:has(x, yBrine) then c:put(x, yBrine, x < cx + 4 and BRINE[6] or BRINE[4], btok) end
  if brine:has(x, yBrine + 1) then c:put(x, yBrine + 1, BRINE[3], btok) end
end

-- carrot sticks, upright, slightly fanned; drawn back to front
local sticks = {
  { 23.5, 29, 24.5, 52, 1.6 }, { 27.5, 27, 27.5, 52, 1.7 }, { 35.5, 28, 34.8, 52, 1.7 }, { 39, 30, 38.6, 51, 1.5 },
  { 31.5, 26, 31.2, 52, 1.8 },
}
local stickMasks = {}
for i, s in ipairs(sticks) do
  local m, n, T, S = X.cyl(s[1], s[2], s[3], s[4], function(t) return s[5] * (t < 0.06 and 0.75 or 1) end)
  m:clip(inner)
  local tok = { r = { name = "stick" .. i } }
  local bias = {}
  -- AO where it sits behind/against neighbours drawn later
  local idx = X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), OR, { cuts = { 0.18, 0.34, 0.5, 0.68, 0.84 }, bias = bias, tok = tok })
  -- growth rings: short dark ticks across the stick
  m:each(function(x, y) local k = K(x, y)
    if ((y + i * 3) % 8 == 0) and S[k] > -0.2 then c:put(x, y, OR[max(1, (idx[k] or 3) - 2)], tok) end
    if y >= 50 then c:put(x, y, OR[max(1, (idx[k] or 3) - 1)], tok) end        -- sunk in the base: darker
  end)
  -- cut top: paler core disc
  local tx, ty = floor(s[1] + .5), floor(s[2] + .5)
  c:put(tx, ty, OR[6], tok) c:put(tx - 1, ty, OR[5], tok)
  -- edge line against earlier sticks
  for _, o in ipairs(stickMasks) do G.touch(m, o):each(function(x, y) c:put(x, y, OR[1], tok) end) end
  stickMasks[#stickMasks + 1] = m
end
-- dill sprig between the sticks: a thin stalk with feathery fronds
local dtok = { r = { name = "dill" } }
G.pline(c, { { 33, 51 }, { 33, 41 }, { 34, 33 }, { 33, 28 } }, DILL[2], dtok)
for _, f in ipairs{ { 33, 29, -1 }, { 34, 32, 1 }, { 33, 35, -1 }, { 34, 38, 1 } } do
  local x, y, d = f[1], f[2], f[3]
  c:put(x + d, y - 1, DILL[3], dtok) c:put(x + 2 * d, y - 2, DILL[2], dtok) c:put(x + d, y, DILL[1], dtok)
end

-- glass: edge ring, lit rim left, cool rim right, specular streak, base
glassEdge:each(function(x, y)
  local t = (x - x0) / (x1 - x0)
  local col = t < 0.3 and RIMHI or (t > 0.7 and RIMSH or AIR[4])
  if y >= yBot - 1 then col = t < 0.5 and AIR[3] or AIR[1] end
  c:put(x, y, col, btok)
end)
-- thick glass base: two rows of pale glass with a dark seam above
for x = x0 + 1, x1 - 1 do
  if body:has(x, yBot - 2) then c:put(x, yBot - 2, x < cx and AIR[4] or AIR[2], btok) end
  if body:has(x, yBot - 3) then c:put(x, yBot - 3, BRINE[1], btok) end
end
-- specular streak (broken) and a short second one
for y = yTop + 3, yBot - 6 do if (y % 9) < 6 then c:put(x0 + 2, y, SPEC, btok) end end
for y = yTop + 6, yTop + 10 do c:put(x0 + 4, y, AIR[6], btok) end
-- shoulder shade under the gasket (ambient where parts meet)
for x = x0 + 1, x1 - 1 do if body:has(x, yTop) then c:put(x, yTop, AIR[1], btok) end end
-- bubbles clinging to the glass in the brine
for _, b in ipairs{ { 37, 33 }, { 25, 40 }, { 38, 44 }, { 29, 46 } } do
  c:put(b[1], b[2], BRINE[6], btok) c:put(b[1] + 1, b[2] + 1, BRINE[2], btok)
end

-- gasket (rubber ring) and domed glass lid
local gm = HP.rrect(x0 - 1, yTop - 2, x1 + 1, yTop - 1, 1)
local gtok = { r = { name = "gasket" } }
gm:each(function(x, y) local t = (x - x0) / (x1 - x0)
  local col = (y == yTop - 2) and (t < 0.3 and GASK[4] or GASK[3]) or (t > 0.7 and GASK[1] or GASK[2])
  c:put(x, y, col, gtok) end)
local lid = HP.ellipse(cx, yTop - 3, 11, 4):clip(HP.rect(0, 0, 63, yTop - 3))
local ln = X.pillow(lid, 2.2)
local ltok = { r = { name = "lid" } }
G.shade(c, lid, ln, AIR, { tok = ltok, amb = 0.25, wrap = 0.35 })
lid:edge():each(function(x, y) if y == yTop - 3 then c:put(x, y, AIR[2], ltok) end end)
c:put(25, yTop - 6, SPEC, ltok) c:put(26, yTop - 6, SPEC, ltok) c:put(24, yTop - 5, AIR[6], ltok)

-- wire bail: a loop over the lid down to the lugs, lever on the right
local wtok = { r = { name = "wire" } }
G.pline(c, { { x0 + 1, yTop + 2 }, { x0 + 1, yTop - 2 } }, WIRE[3], wtok)
G.pline(c, { { x0 + 2, yTop - 4 }, { cx - 4, yTop - 7 }, { cx + 4, yTop - 7 }, { x1 - 1, yTop - 4 } }, WIRE[3], wtok)
G.pline(c, { { cx - 3, yTop - 8 }, { cx + 3, yTop - 8 } }, WIRE[4], wtok)
G.pline(c, { { x1 - 1, yTop - 3 }, { x1 + 2, yTop }, { x1 + 3, yTop + 6 } }, WIRE[2], wtok)
G.pline(c, { { x1 + 1, yTop - 1 }, { x1 + 2, yTop + 5 } }, WIRE[3], wtok)
c:put(x1 + 3, yTop + 7, WIRE[1], wtok)
-- lug on the neck
c:put(x1, yTop + 1, WIRE[1], wtok) c:put(x1 - 1, yTop + 1, WIRE[2], wtok)

-- quirk: kraft tag on twine from the lever
local ttok = { r = { name = "tag" } }
G.pline(c, { { x1 + 3, yTop + 8 }, { x1 + 4, yTop + 10 } }, KRAFT[2], ttok)
local tag = HP.poly{ { x1 + 2, yTop + 11 }, { x1 + 7, yTop + 11 }, { x1 + 8, yTop + 19 }, { x1 + 3, yTop + 19 } }
tag:each(function(x, y)
  local col = KRAFT[3]
  if not tag:has(x - 1, y) or not tag:has(x, y - 1) then col = KRAFT[4] end
  if not tag:has(x + 1, y) or not tag:has(x, y + 1) then col = KRAFT[2] end
  c:put(x, y, col, ttok) end)
c:put(x1 + 4, yTop + 12, KRAFT[1], ttok)     -- punched hole
-- tiny carrot doodle
c:put(x1 + 5, yTop + 15, OR[4], ttok) c:put(x1 + 5, yTop + 16, OR[4], ttok) c:put(x1 + 6, yTop + 15, OR[3], ttok)
c:put(x1 + 5, yTop + 17, OR[3], ttok) c:put(x1 + 6, yTop + 14, DILL[2], ttok) c:put(x1 + 5, yTop + 14, DILL[3], ttok)

G.save(c, NAME)
