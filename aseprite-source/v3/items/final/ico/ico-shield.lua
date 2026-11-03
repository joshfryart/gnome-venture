-- ico-shield (final, Opus single pass). Heater shield: a domed field of four vertical oak planks painted ember red
-- (dark plank seams, grain streaks, two worn chips where pale wood shows through), a bevelled steel rim band with a
-- bright inner edge and round rivets, a dark AO row where the field tucks under the rim, and a raised steel boss
-- (flange ring with four rivets, spherical dome with specular) casting a contact shadow on the paint.
-- quirk: one split plank has been mended with a crooked leather patch held by two nails.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-shield")
local ST = { "#2e2c47", "#464766", "#686a88", "#9294ad", "#bec0d2", "#e6e8f2" }
local RD = { "#5a1830", "#86233a", "#b5323c", "#d9473d", "#f06a48", "#ff9a6a" }
local WD = { "#4a2a28", "#6e3f2e", "#935a36", "#b97a4a", "#d89c62", "#f0c286" }
local LE = { "#4a2a20", "#7a4a2a", "#a86e3e", "#cf9a5e" }
local stok, ptok, wtok, ltok = A.tok("steel"), A.tok("paint"), A.tok("wood"), A.tok("leather")

-- outline shape
local TOP, MID, BOT, HW, CXs = 9, 29, 57, 20, 32
local shield = HP.mask()
for y = TOP, BOT do
  local hw = HW
  if y < TOP + 2 then hw = HW - (TOP + 2 - y) * 0.6 end
  if y > MID then hw = HW * (1 - ((y - MID) / (BOT - MID + 0.6)) ^ 1.75) end
  for x = floor(CXs - hw + 0.5), floor(CXs + hw - 0.5) do shield:set(x, y) end
end
local field = shield:shrink(3)
local rim = shield:copy():cut(field)

-- rim: pillowed steel band, bright inner lip, darker outer underside
local rn = X.pillow(rim, 1.5)
A.bulge(rn, CXs, 32, 24, 26, 0.35)
local ri = A.shade(c, rim, rn, ST, { amb = 0.08, wrap = 0.25, tok = stok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.9 } })
field:grow(1):cut(field):each(function(x, y)
  if rim:has(x, y) and (x <= CXs + 4 and y <= 38) then A.step(c, ri, ST, x, y, 1, stok) end end)
-- rivets on the rim: 2x2 heads, lit corner + dark underside
local mid = shield:shrink(1):cut(field:grow(1))
local function rivet(x, y, ramp, tok)
  c:put(x, y, ramp[6], tok) c:put(x + 1, y, ramp[4], tok) c:put(x, y + 1, ramp[4], tok) c:put(x + 1, y + 1, ramp[2], tok)
end
for _, p in ipairs{ { 14, 11 }, { 32, 10 }, { 50, 11 }, { 13, 22 }, { 51, 22 }, { 15, 36 }, { 49, 36 }, { 23, 48 }, { 41, 48 } } do
  local best, bx, by
  mid:each(function(x, y) local d = (x - p[1]) ^ 2 + (y - p[2]) ^ 2 if not best or d < best then best, bx, by = d, x, y end end)
  rivet(bx, by, ST, stok) c:put(bx + 1, by + 1, ST[1], stok)
end
-- specular streak along the upper-left rim
for y = 14, 22 do c:put(13, y, ST[6], stok) end

-- field: domed painted planks
local fn = {}
field:each(function(x, y) fn[K(x, y)] = { 0, 0, 1 } end)
A.bulge(fn, CXs, 30, 20, 26, 0.55)
local fb = {}
local seams = { 23, 32, 41 }
local boss = A.ellM(CXs, 31, 6.5, 6.5)
local flange = A.ellM(CXs, 31, 8.5, 8.5)
X.ao(fb, field, rim, 1, -1)
A.cast(fb, field, flange, 1, 1, -1)
A.cast(fb, field, flange, 2, 2, -1)
field:each(function(x, y) local k = K(x, y)
  for _, sx in ipairs(seams) do
    if x == sx then fb[k] = (fb[k] or 0) - 2 end
    if x == sx + 1 then fb[k] = (fb[k] or 0) + 1 end
  end
  -- grain streaks (one darker run per plank, wavy)
  local pl = x < 23 and 0 or (x < 32 and 1 or (x < 41 and 2 or 3))
  local gx = ({ 18, 27, 36, 46 })[pl + 1] + floor(math.sin(y * 0.35 + pl) * 1.3 + 0.5)
  if x == gx and X.hash(x, y, 7) > 0.3 then fb[k] = (fb[k] or 0) - 1 end
end)
local fi = A.shade(c, field, fn, RD, { amb = 0.12, wrap = 0.3, bias = fb, tok = ptok, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
-- worn chips: pale wood showing through on two plank edges
for _, p in ipairs{ { 42, 18, { "ab", "b." } }, { 22, 42, { ".a", "ab" } } } do
  A.map(c, p[3], p[1], p[2], { a = WD[5], b = WD[3] }, wtok)
end

-- boss: flange ring (pillow) then the dome (sphere), specular + glint
local fl = flange:copy():cut(boss)
local fln = X.pillow(fl, 1.2)
A.bulge(fln, CXs, 31, 8, 8, 0.5)
A.shade(c, fl, fln, ST, { amb = 0.1, wrap = 0.3, tok = stok })
local bb = {}
X.ao(bb, boss, fl, 1, -1)
local bi = A.shade(c, boss, X.sphere(CXs - 0.5, 30.5, 6.5, boss), ST, { amb = 0.1, wrap = 0.25, bias = bb, tok = stok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
c:put(29, 28, ST[6], stok) c:put(30, 28, ST[6], stok) c:put(29, 27, A.CREAM, stok)
for _, p in ipairs{ { 31, 22 }, { 23, 30 }, { 39, 30 }, { 31, 38 } } do rivet(p[1], p[2], ST, stok) end
-- cool bounce on the dome's lower right
for _, p in ipairs{ { 36, 33 }, { 35, 35 }, { 37, 32 } } do if boss:has(p[1], p[2]) then c:put(p[1], p[2], "#8b8fb8", stok) end end

-- quirk: crooked leather patch over a split plank (lower right), two nails
A.map(c, {
  "..aab",
  "aabbbc",
  "abbbbc",
  "bbbbcd",
  "bcccd.",
  ".dd...",
}, 36, 41, { a = LE[4], b = LE[3], c = LE[2], d = LE[1] }, ltok)
c:put(37, 42, ST[5], stok) c:put(40, 45, ST[5], stok)
c:put(38, 42, ST[2], stok) c:put(41, 45, ST[2], stok)
-- the split itself, running out from under the patch
for _, p in ipairs{ { 36, 47 }, { 35, 48 }, { 35, 49 } } do if field:has(p[1], p[2]) then c:put(p[1], p[2], RD[1], ptok) end end
A.save(c, "ico-shield")
