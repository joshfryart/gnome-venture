-- birdbath (final pass, Opus). A slim cast-stone birdbath: wide shallow bowl with a thick bevelled rim (bright lip
-- edge, inner wall in shadow), still water (sky reflection, ripple rings, one glint), a slender turned baluster
-- stem with collars and a bulb, a two-step plinth, sparse stone speckle and a little lichen; ambient shading under
-- the bowl and collars, 2-tone ground shadow.
-- quirk: a single red autumn leaf is floating on the water, spreading ripples.
local NAME = "birdbath"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new(NAME)
local ST = { "#3a3a54", "#575874", "#7a7b94", "#9e9eb2", "#c2c1ce", "#e4e2e8" }
local WAT = { "#2a4a7a", "#335f98", "#3a82b0", "#5aaecc", "#86d0da", "#b8eee2" }
local LEAFR = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local LICH = { "#5e8a4a", "#9cbc62" }
local CX = 32

c:groundShadow(CX, 55, 16, 2)

-- plinth (two steps)
local p2 = c:rect(19, 51, 45, 54)
local p1 = c:rect(23, 48, 41, 50)
local function block(m, x0, x1, y0, y1, tok)
  local n = A.vnorm(m, x0, x1, function(x, y) return y == y0 and -1.6 or 0.15 end)
  local idx = A.shade(c, m, n, ST, { tok = tok, amb = 0.15, wrap = 0.3 })
  return idx
end
local t2, t1 = { r = { name = "p2" } }, { r = { name = "p1" } }
local i2 = block(p2, 19, 45, 51, 54, t2)
local i1 = block(p1, 23, 41, 48, 50, t1)
for x = 24, 40 do A.step(c, i2, ST, x, 51, -2, t2) end            -- ambient under the upper step
for x = 20, 44 do A.step(c, i2, ST, x, 54, -1, t2) end

-- baluster stem: collar, neck, bulb, neck, collar
local function wfn(y)
  if y <= 31 then return 4.5 end
  if y <= 33 then return 2.6 end
  if y >= 46 then return 4.5 end
  if y >= 44 then return 2.4 end
  local t = (y - 34) / 9
  return 2.2 + 1.4 * math.sin(math.pi * math.min(1, t * 1.15)) ^ 1.2
end
local stem = HP.mask()
for y = 30, 47 do local w = wfn(y) for x = floor(CX - w), floor(CX + w - 0.01) do stem:set(x, y) end end
local stok = { r = { name = "stem" } }
local sidx = A.shade(c, stem, A.vnorm(stem, CX - 4.5, CX + 3.5, function(x, y) if y == 30 or y == 46 then return -1.2 end return 0 end), ST, { tok = stok, amb = 0.12, wrap = 0.3 })
for x = 27, 37 do A.step(c, sidx, ST, x, 31, -1, stok) end            -- under the top collar
for x = 28, 36 do A.step(c, sidx, ST, x, 32, -2, stok) A.step(c, sidx, ST, x, 45, -1, stok) end

-- bowl underside
local under = c:ellipse(CX, 24, 20, 7):cut(c:rect(0, 0, 63, 23))
under:add(c:rect(CX - 20, 22, CX + 20, 24))
local utok = { r = { name = "under" } }
local uidx = A.shade(c, under, A.vnorm(under, CX - 20.5, CX + 20.5, function(x, y) return 0.25 + (y - 24) * 0.12 end), ST, { tok = utok, amb = 0.12, wrap = 0.35 })
under:each(function(x, y) if not under:has(x, y + 1) and y > 26 then A.step(c, uidx, ST, x, y, -1, utok) end end)
-- moulded band on the bowl underside
for x = CX - 18, CX + 18 do if under:has(x, 27) then A.step(c, uidx, ST, x, 27, -1, utok) end
  if under:has(x, 26) then A.step(c, uidx, ST, x, 26, 1, utok) end end

-- rim (top surface ring) and water
local rimO = c:ellipse(CX, 21, 21, 5.5)
local inner = c:ellipse(CX, 21.5, 17.5, 3.8)
local water = inner:copy():clip(inner:shift(0, 1))
local wall = inner:copy():cut(water)
local rim = rimO:copy():cut(inner)
local rtok = { r = { name = "rim" } }
rim:each(function(x, y)
  local u, v = (x - CX) / 21.5, (y - 21) / 6
  local i = 5
  if v > 0.2 then i = 4 end                   -- front lip top in slight shade (faces up-forward)
  if u > 0.55 then i = i - 1 end
  if u < -0.5 and v < 0.1 then i = 6 end
  if not rimO:has(x, y - 1) and u < 0.3 then i = 6 end   -- bright outer edge on the far lip
  if not rimO:has(x, y + 1) then i = 3 end                -- front edge rolls under
  c:put(x, y, ST[i], rtok)
end)
-- rim front edge: thickness row above the underside
for x = CX - 20, CX + 20 do if under:has(x, 22) and not rimO:has(x, 22) then c:put(x, 22, ST[3], utok) end end
wall:each(function(x, y) c:put(x, y, (x < CX + 4) and ST[2] or ST[3], rtok) end)
local wtok = { r = { name = "water" } }
water:each(function(x, y)
  local u, v = (x - CX) / 18, (y - 21.5) / 4.3
  local i = 4
  if v < -0.3 then i = 3 end                  -- far water under the rim wall (reflection of shade)
  if u < -0.55 then i = 3 end
  if u > 0.2 and v > -0.2 then i = 5 end      -- sky reflection band
  if u > 0.75 then i = 4 end
  c:put(x, y, WAT[i], wtok)
end)
-- ripple rings round the leaf
local LX, LY = 26, 22
for _, rr in ipairs{ { 4.5, 1.6 }, { 8, 2.6 } } do
  local ring = c:ellipse(LX, LY, rr[1], rr[2]):edge()
  ring:each(function(x, y) if water:has(x, y) then c:put(x, y, (y <= LY) and WAT[2] or WAT[6], wtok) end end)
end
c:put(40, 21, A.CREAM, wtok) c:put(41, 21, WAT[6], wtok)  -- glint
-- quirk: floating red leaf (midrib, stalk, tiny contact shadow on the water)
c:paint({
  "..ab..",
  ".abbc.",
  "addmcc",
  ".dcc.s",
}, LX - 3, LY - 2, { a = LEAFR[4], b = LEAFR[3], c = LEAFR[2], d = LEAFR[3], m = LEAFR[1], s = "#864c33" })
c:put(LX - 1, LY + 2, WAT[1], wtok) c:put(LX, LY + 2, WAT[1], wtok)

-- stone speckle + lichen
local function speck(m, idx, tok, seed, rate)
  m:each(function(x, y) if X.hash(x, y, seed) < rate and m:has(x - 1, y) and m:has(x + 1, y) then A.step(c, idx, ST, x, y, -1, tok) end end)
end
speck(p2, i2, t2, 3, 0.07) speck(p1, i1, t1, 4, 0.07) speck(stem, sidx, stok, 5, 0.05) speck(under, uidx, utok, 6, 0.05)
for _, q in ipairs{ { 20, 52, 1 }, { 21, 52, 2 }, { 20, 53, 1 }, { 22, 53, 1 }, { 24, 49, 2 } } do c:put(q[1], q[2], LICH[q[3]], t2) end

A.save(c, NAME)
