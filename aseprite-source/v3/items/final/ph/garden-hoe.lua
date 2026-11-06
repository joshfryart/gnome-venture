-- garden-hoe (final pass, Opus single pass). A slim draw hoe on the diagonal: 3 px ash handle (per-pixel cylinder
-- light, long grain streaks, pale end grain on the butt), an iron ferrule, a 2 px gooseneck curling over into a
-- squarish steel blade that flares slightly toward a honed bright edge. Blade: bevelled pillow light, specular streak,
-- rivet, a few rust freckles, contact shadow under the neck.
-- quirk: an earthworm is draped over the blade's edge, not at all pleased.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("garden-hoe")
local ASH = { "#4a2a26", "#74452f", "#a06a42", "#c8925a", "#e6b878", "#fbe0a8" }
local I = A.IRON

-- blade first (neck and handle overlap it)
local blade = c:poly{ { 49, 19 }, { 58, 18 }, { 60, 29 }, { 48, 30 } }
local neckM, nn, NT, NS = A.tube({ { 44, 17 }, { 47, 10 }, { 54, 9 }, { 54, 19 } }, function(t) return 1.05 end)
local bb = {}
A.cast(bb, blade, neckM, 1, 1, -2)
A.cast(bb, blade, neckM, 1, 2, -1)
local btok = { r = { name = "blade" } }
local bidx = A.board(c, blade, I, { R = 2.2, grain = false, bias = bb, tok = btok, amb = 0.12 })
-- honed edge: bright bevel along the bottom two rows
blade:each(function(x, y)
  if not blade:has(x, y + 1) then c:put(x, y, x < 55 and I[6] or I[5], btok)
  elseif not blade:has(x, y + 2) then c:put(x, y, I[4], btok) end
end)
-- specular streak (diagonal, upper-left of the face) + glint
for _, p in ipairs{ { 51, 21 }, { 51, 22 }, { 52, 23 } } do c:put(p[1], p[2], I[6], btok) end
c:put(51, 21, A.CREAM, btok)
-- rust freckles
local RU = { "#7a3a26", "#a8562c" }
c:put(57, 24, RU[2], btok) c:put(58, 25, RU[1], btok) c:put(56, 26, RU[2], btok)

-- gooseneck (iron rod, 2 px)
local nv = X.light(nn, { amb = 0.1, wrap = 0.25 })
local ntok = { r = { name = "neck" } }
X.tone(c, neckM, nv, I, { cuts = A.CUTS, tok = ntok })
-- rivet where the neck meets the blade
c:put(54, 20, I[2], btok) c:put(53, 20, I[5], btok) c:put(54, 21, I[1], btok)

-- handle
local hb = {}
local hm, hidx, HT, HS, htok = A.pole(c, 13, 56, 44, 17, function(t) return t < 0.03 and 1.2 or 1.5 end, ASH, { name = "handle", amb = 0.1 })
local len = sqrt(31 * 31 + 39 * 39)
hm:each(function(x, y)
  local k = K(x, y)
  local i = hidx[k]
  local band = floor((HS[k] + 1) * 1.5 + 0.5)
  local seg = floor(HT[k] * len / 5 + band * 2)
  if X.hash(band, seg, 9) > 0.66 and i > 2 then c:put(x, y, ASH[i - 1], htok) end
end)
-- butt end grain
c:put(13, 56, ASH[6], htok) c:put(12, 55, ASH[5], htok) c:put(14, 56, ASH[4], htok)
-- iron ferrule near the top of the handle
local fer, fn, FT, FS = X.cyl(41.5, 20.2, 45, 15.8, function() return 1.9 end)
local fv = X.light(fn, { amb = 0.1, wrap = 0.25 })
X.tone(c, fer, fv, I, { cuts = A.CUTS, tok = ntok })
fer:each(function(x, y) if (FT[K(x, y)] or 0) < 0.12 then c:put(x, y, I[2], ntok) end end) -- shadow lip

-- quirk: grumpy earthworm draped over the blade edge
local W = { "#7d2c4e", "#c25a78", "#f08aa0", "#ffc0cc" }
local wtok = { r = { name = "worm" } }
A.map(c, {
  ".bc...",
  "ab.dc.",
  "a..cb.",
  "a..cb.",
  ".a.ba.",
  "....a.",
}, 50, 27, { a = W[1], b = W[2], c = W[3], d = W[4] }, wtok)

A.save(c, "garden-hoe")
