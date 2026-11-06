-- ico-book-green (final pass, Opus). A slim green leather book standing upright, cover to the viewer.
-- Structure: rounded spine on the left with four raised bands, hinge groove, bevelled board with a gold-tooled frame
-- and an embossed gold leaf, brass corner caps, page block + back board showing on the right, satin ribbon hanging below.
-- Material: per-pixel pillow light (6-tone green, violet shade), leather grain, page lines with AO under the cover,
-- brass bevel + rivet + glint, ribbon weave (diagonal).
-- quirk: a pressed four-leaf clover pokes out between the pages.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local max, min = math.max, math.min
local c = A.new("ico-book-green")
local GR, GO, BR, PG, RD, MO = R.green, R.gold, R.brass, R.page, R.red, R.moss

-- quirk first (pages and boards paint over its tucked end)
A.map(c, {
  "..ab..",
  "..bc..",
  "abddab",
  "bcddbc",
  "..ab..",
  "..bc..",
}, 47, 15, { a = MO[6], b = MO[5], c = MO[3], d = MO[2] })
c:put(47, 21, MO[3]) c:put(46, 22, MO[2])

-- back board + page block on the right
local back = c:rect(43, 10, 46, 52)
back:each(function(x, y) c:put(x, y, (x == 46 or y == 52) and GR[1] or GR[2]) end)
for y = 11, 50 do for x = 43, 45 do
  local t = (y % 2 == 0) and PG[3] or PG[5]
  if y == 11 then t = PG[6] end
  if x == 43 then t = (y % 2 == 0) and PG[2] or PG[3] end
  if x == 45 and y % 2 == 0 then t = PG[2] end
  c:put(x, y, t)
end end

-- ribbon (hangs from the page block bottom)
for y = 51, 57 do for x = 34, 36 do
  local t = ((x + y) % 3 == 0) and RD[3] or RD[4]
  if x == 34 then t = RD[5] end
  if x == 36 then t = RD[2] end
  if y == 57 and x == 35 then t = nil end
  if y == 51 then t = RD[1] end
  if t then c:put(x, y, t) end
end end

-- cover board
local cover = c:rrect(18, 9, 42, 51, 2)
local SPX = 23
local idx = A.face(c, cover, GR, {
  R = 2.2, grain = 0.045, seed = 3,
  nfn = function(x, y, n)
    if x <= SPX then local u = (x - SPX) / (SPX - 18 + 0.6) return u * 0.95 + n[1] * 0.3, n[2] * 0.6, 0.75 end
    return n[1] + (x - 31) / 60, n[2] + (y - 28) / 90, n[3]
  end,
})
-- hinge groove + lit lip
for y = 10, 50 do A.step(c, idx, GR, SPX + 1, y, -2) A.step(c, idx, GR, SPX + 2, y, 1) end
-- raised bands across the spine
for _, by in ipairs{ 14, 22, 38, 46 } do
  for x = 18, SPX do
    if cover:has(x, by) then A.step(c, idx, GR, x, by, 2) A.step(c, idx, GR, x, by + 1, -2) end
  end
end
c:put(19, 14, A.CREAM)  -- glint on the top band

-- gold-tooled frame (lit top/left, shade bottom/right)
local fx0, fy0, fx1, fy1 = 28, 13, 39, 47
for x = fx0, fx1 do c:put(x, fy0, GO[5]) c:put(x, fy1, GO[3]) c:put(x, fy0 + 1, GR[2]) end
for y = fy0, fy1 do c:put(fx0, y, GO[4]) c:put(fx1, y, GO[2]) end
c:put(fx1, fy0, GO[3]) c:put(fx0, fy1, GO[3])

-- embossed gold leaf emblem (curved blade with a folded midrib)
local lm, ln, LT, LS = A.blade(31.5, 41, 30.5, 30, 36, 18, function(t) return 4.1 * math.sin(math.pi * t) ^ 0.75 - 0.2 end, { fold = 0.45 })
local lv = X.light(ln, { amb = 0.1, wrap = 0.3 })
local lidx = X.tone(c, lm, lv, GO, { cuts = { 0.14, 0.27, 0.4, 0.56, 0.74 } })
-- sunk shadow lower-right of emblem
lm:shift(1, 1):each(function(x, y) if not lm:has(x, y) and idx[K(x, y)] then A.step(c, idx, GR, x, y, -2) end end)
lm:shift(-1, -1):each(function(x, y) if not lm:has(x, y) and idx[K(x, y)] then A.step(c, idx, GR, x, y, 1) end end)
-- midrib + paired veins
lm:each(function(x, y) local k = K(x, y) local t, sn = LT[k], LS[k]
  if math.abs(sn) < 0.2 and t > 0.06 and t < 0.92 then c:put(x, y, GO[2]) end
  local ph = (t * 6.2 - math.abs(sn) * 1.1) % 1
  if math.abs(sn) > 0.3 and math.abs(sn) < 0.85 and ph < 0.17 and t > 0.12 and t < 0.85 then c:put(x, y, sn < 0 and GO[3] or GO[2]) end
end)
c:put(32, 42, GO[3]) c:put(32, 43, GO[2])
c:put(33, 22, GO[6])
-- brass corner caps on the fore-edge corners
local function corner(pts, rivx, rivy)
  local m = A.poly(pts)
  A.face(c, m, BR, { R = 1.2, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  c:put(rivx, rivy, BR[2])
  return m
end
corner({ { 38, 9 }, { 43, 9 }, { 43, 14 } }, 41, 10)
corner({ { 43, 46 }, { 43, 52 }, { 37, 52 } }, 41, 50)
c:put(42, 10, A.CREAM)

A.save(c, "ico-book-green")
