-- broken-garden-hoe (aB11_3, Opus single pass). Slim ash handle on the diagonal, brass ferrule, thin steel goose-neck
-- and a flat draw blade with a bevelled, bright cutting edge. Per-pixel cylinder light on handle/neck, pillow light on blade.
-- broken: the handle has snapped (jagged gap with pale end grain and a long splinter, upper half knocked out of line),
-- a notch is bitten out of the blade edge and the steel chip flies off to the right. Colours unchanged.
-- quirk: a clod of soil still stuck on the blade with a tiny two-leaf sprout growing out of it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local W, S, B = A.WOOD, A.STEEL, A.BRASS
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("broken-garden-hoe")
local tok = { r = { name = "wood" } }

local function shaft(p, w, trim)
  local m, n, T, Sd = A.tube(p, w)
  local cut = HP.mask()
  m:each(function(x, y) local k = K(x, y) if trim(T[k], Sd[k]) then cut:set(x, y) end end)
  m:cut(cut)
  local bias = {}
  local idx = A.tone(c, m, n, W, { bias = bias, tok = tok })
  -- grain: two broken dark lines running along the shaft
  m:each(function(x, y) local k = K(x, y)
    local s, t = Sd[k], T[k]
    for _, g in ipairs{ -0.3, 0.38 } do
      if abs(s - g - 0.12 * math.sin(t * 9)) < 0.17 and X.hash(floor(t * 14), floor(g * 10), 3) > 0.25 then
        c:put(x, y, W[max(1, idx[k] - 1)], tok) end
    end
  end)
  return m, T, Sd
end
-- upper half (knocked 1 px out of line); jagged end: lit side runs longer (splinter)
local up, uT, uS = shaft(A.lineP(48.6, 11.2, 39.5, 23.2), 1.75, function(t, s) return t > 0.93 + (s < -0.2 and 0.07 or 0) - (s > 0.4 and 0.04 or 0) end)
-- lower half
local lo, lT, lS = shaft(A.lineP(37.2, 26.4, 26, 41.2), 1.75, function(t, s) return t < 0.06 - (s > 0.3 and 0.06 or 0) end)
-- pale end grain on both broken faces
up:each(function(x, y) local k = K(x, y) if uT[k] > 0.86 and uT[k] <= 1 and not up:has(x - 1, y + 1) then c:put(x, y, W[6], tok) end end)
lo:each(function(x, y) local k = K(x, y) if lT[k] < 0.16 and not lo:has(x + 1, y - 1) then c:put(x, y, W[5], tok) end end)
-- long splinter off the lower piece + a fibre hair
c:put(37, 24, W[5], tok) c:put(38, 23, W[6], tok)
c:put(40, 25, W[3], tok)
-- hang hole near the top end
c:put(46, 15, W[1]) c:put(47, 15, W[2])
-- brass ferrule
local fm, fn = A.tube(A.lineP(28.2, 38.4, 25.4, 42.2), 2.15)
local fi = A.tone(c, fm, fn, B, { tok = { r = { name = "brass" } } })
fm:each(function(x, y) local k = K(x, y) if (x + y) % 4 == 0 and fi[k] then c:put(x, y, B[max(1, fi[k] - 2)]) end end)
-- AO row where the wood enters the ferrule
for _, p in ipairs{ { 29, 37 }, { 30, 37 }, { 28, 37 } } do if lo:has(p[1], p[2]) then c:put(p[1], p[2], W[1]) end end
-- goose-neck (thin steel)
local nm, nn = A.tube({ { 25.6, 42 }, { 23, 46 }, { 19.5, 44.5 }, { 17, 47.6 } }, 1.05)
A.tone(c, nm, nn, S, { tok = { r = { name = "steel" } } })
-- blade
local bm = c:poly{ { 6, 48 }, { 25, 46 }, { 27, 55 }, { 8, 58 } }
local bias = {}
X.ao(bias, bm, nm, 1, -2)
local bn = X.pillow(bm, 1.6)
local bi = A.tone(c, bm, bn, S, { bias = bias, tok = { r = { name = "steel" } } })
-- bevelled cutting edge: bright line two rows above the bottom, darker last row
bm:each(function(x, y)
  if not bm:has(x, y + 1) then c:put(x, y, S[3])
  elseif not bm:has(x, y + 2) then c:put(x, y, S[6]) end end)
-- socket rivet
c:put(16, 49, S[1]) c:put(17, 49, S[2]) c:put(16, 48, S[5])
-- specular streak on the blade face
for x = 9, 13 do c:put(x, 50 - floor((x - 9) / 4), S[6]) end
c:put(10, 50, A.SPEC)
-- broken: notch bitten from the edge
A.erase(c, c:poly{ { 17, 59 }, { 22, 59 }, { 20, 55 }, { 19, 55 } })
for _, p in ipairs{ { 18, 56 }, { 21, 56 }, { 19, 54 } } do if bm:has(p[1], p[2]) then c:put(p[1], p[2], S[2]) end end
-- the flying chip
c:paint({ "ab.", "bcd", ".dd" }, 30, 54, { a = S[6], b = S[5], c = S[4], d = S[2] })
-- quirk: soil clod with a sprout on the blade's top edge
c:paint({ ".abb.", "abccd", "bccdd" }, 9, 45, { a = A.SOIL[4], b = A.SOIL[3], c = A.SOIL[2], d = A.SOIL[1] })
c:paint({ "lL.mM", ".lsm.", "..s..", "..s.." }, 9, 41, { l = A.LEAF[6], L = A.LEAF[4], m = A.LEAF[5], M = A.LEAF[3], s = A.LEAF[3] })
A.save(c)
