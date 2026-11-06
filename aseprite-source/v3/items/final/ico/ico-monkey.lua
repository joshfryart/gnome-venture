-- ico-monkey (Opus single pass). Front-facing monkey head: round fur skull with a widow's-peak tuft, cup ears set
-- behind the head, a heart-shaped peach face (two eye lobes + a raised muzzle). Fur: sphere/pillow per-pixel light on
-- a 6-tone brown ramp with radial strand strokes and a pale rim; face: 6-tone skin with a brow-ridge shadow row,
-- raised muzzle (own bevel, darker groove where it meets the cheeks), nose pad with ink nostrils and a lit bridge,
-- smile with a lit lower lip, inner ears in deep skin with AO where ears tuck behind the skull.
-- quirk: a single green leaf is caught in its hair from swinging through the trees.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.atan
local c = A.new("ico-monkey")
local FUR = { "#2a1520", "#45241f", "#663622", "#8a4e2a", "#ad6a37", "#cf8e52" }
local SK  = { "#7a3c38", "#ad6450", "#d38c6c", "#eeb289", "#ffd0a4", "#ffe6c4" }
local LF  = { "#24544a", "#3f9150", "#7cc35a", "#b4dc72" }
local INK = A.INK
local function blendN(a, b, wa)
  local x, y, z = a[1] * wa + b[1], a[2] * wa + b[2], a[3] * wa + b[3]
  local l = sqrt(x*x + y*y + z*z) return { x / l, y / l, z / l }
end
local HX, HY = 32, 31
local head = c:ellipse(HX, HY, 16, 15.5):add(c:ellipse(HX, HY + 4, 15, 12.5))
-- widow's peak tuft on top
local tuft = c:poly{ { 26, 17 }, { 29, 11 }, { 31, 15 }, { 34, 10 }, { 35, 15 }, { 39, 17 } }
head:add(tuft)
local earL = c:ellipse(13, 33, 6, 7)
local earR = c:ellipse(51, 33, 6, 7)
local ears = earL:copy():add(earR):cut(head)

-- ears (behind): pillow light, AO next to the skull
local en = X.pillow(ears, 3)
local eb = {}
X.ao(eb, ears, head, 2, -1)
local ftok = { r = { name = "fur" } }
A.litN(ears, en, FUR, { amb = 0.05, wrap = 0.2, bias = eb, tok = ftok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 } })
-- inner ears: deep skin cup with lit lower rim
for _, e in ipairs{ { 13, 33 }, { 51, 33 } } do
  local inner = c:ellipse(e[1], e[2] + 0.5, 3.5, 4.5):cut(head)
  local inN = X.pillow(inner, 2)
  -- concave: invert normal xy so the cup is lit on the lower-right
  for k, nn in pairs(inN) do inN[k] = { -nn[1], -nn[2], nn[3] } end
  A.litN(inner, inN, { SK[1], SK[2], SK[3], SK[4] }, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "ear" } } })
end

-- skull: sphere + pillow
local hn_s = X.sphere(HX - 1, HY - 1, 17, head)
local hn_p = X.pillow(head, 4)
local hn = {}
head:each(function(x, y) local k = K(x, y) hn[k] = blendN(hn_p[k], hn_s[k], 0.6) end)
local face = c:ellipse(25.5, 28.5, 6.5, 7):add(c:ellipse(38.5, 28.5, 6.5, 7)):add(c:ellipse(32, 40, 10.5, 7.5))
face:clip(head)
local hb = {}
-- AO ring on the fur around the face and darker fur at the bottom of the jaw
X.ao(hb, head, face, 2, -1)
local fidx = A.litN(head, hn, FUR, { amb = 0.03, wrap = 0.18, bias = hb, tok = ftok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 } })
-- fur strands: short radial strokes, one tone darker; a pale rim on the lit upper-left
head:each(function(x, y)
  if face:has(x, y) then return end
  local k = K(x, y)
  local dx, dy = x - HX, y - HY
  local h = X.hash(x, y, 4)
  if h > 0.86 then
    local l = sqrt(dx*dx + dy*dy) + 0.01
    local ux, uy = floor(dx / l + 0.5), floor(dy / l + 0.5)
    local i = fidx[k] or 3
    c:put(x, y, FUR[max(1, i - 1)], ftok)
    if head:has(x - ux, y - uy) and not face:has(x - ux, y - uy) then c:put(x - ux, y - uy, FUR[max(1, i - 1)], ftok) end
  end
end)
head:edge():each(function(x, y) local k = K(x, y)
  if (x - HX) + (y - HY) < -9 and (fidx[k] or 0) >= 4 then c:put(x, y, FUR[6], ftok) end end)
-- tuft strand lines
A.pts({ { 30, 15 }, { 31, 16 }, { 34, 14 }, { 33, 16 } }, FUR[3])

-- face: lobes + muzzle (muzzle raised, own bevel)
local muz = c:ellipse(32, 40, 10.5, 7.5):clip(head)
local lobes = face:copy():cut(muz)
local stok = { r = { name = "skin" } }
local ln = X.pillow(lobes, 3)
local lb = {}
-- brow ridge shadow: top rows of each lobe
lobes:each(function(x, y) if not lobes:has(x, y - 1) or not lobes:has(x, y - 2) then lb[K(x, y)] = -1 end end)
A.litN(lobes, ln, SK, { amb = 0.12, wrap = 0.3, bias = lb, tok = stok })
local mn_p = X.pillow(muz, 4)
local mn_s = X.sphere(31, 38, 10.5, muz)
local mn = {}
muz:each(function(x, y) local k = K(x, y) mn[k] = blendN(mn_p[k], mn_s[k], 0.8) end)
local mb = {}
-- groove where the muzzle meets the eye lobes
muz:each(function(x, y) if lobes:has(x, y - 1) and (x < 28 or x > 36) then mb[K(x, y)] = -1 end end)
A.litN(muz, mn, SK, { amb = 0.1, wrap = 0.25, bias = mb, tok = stok })

-- eyes: 3x4 ink pills with cream glint upper-left + a lit lower lid
for _, ex in ipairs{ 24, 38 } do
  local ey = 27
  A.fill(c:rect(ex, ey, ex + 2, ey + 3), INK)
  c:px(ex, ey + 3, SK[3]) c:px(ex + 2, ey + 3, SK[3])
  c:px(ex, ey + 1, A.CR)
  A.pts({ { ex, ey + 4 }, { ex + 1, ey + 4 }, { ex + 2, ey + 4 } }, SK[5])
end
-- nose: lit bridge, nose pad, ink nostrils with glint
A.pts({ { 32, 33 }, { 32, 34 }, { 31, 35 } }, SK[5])
A.fill(c:rect(29, 36, 35, 37), SK[3])
A.pts({ { 30, 38 }, { 31, 38 }, { 32, 38 }, { 33, 38 }, { 34, 38 } }, SK[2])
c:px(30, 37, INK) c:px(31, 37, INK) c:px(33, 37, INK) c:px(34, 37, INK)
c:px(32, 36, SK[6])
-- smile
A.pts({ { 26, 42 }, { 27, 43 }, { 28, 44 }, { 29, 44 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 45 }, { 35, 44 }, { 36, 44 }, { 37, 43 }, { 38, 42 } }, SK[1])
A.pts({ { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 }, { 34, 46 } }, SK[5])
A.pts({ { 25, 41 }, { 39, 41 } }, SK[2])
-- cheeks
c:cheek(20, 35) c:cheek(43, 35)

-- quirk: a leaf caught in the hair (top right), midrib + stem
local lm = c:poly{ { 38, 18 }, { 41, 14 }, { 46, 12 }, { 45, 16 }, { 40, 19 } }
local lnrm = X.pillow(lm, 1.5)
A.litN(lm, lnrm, LF, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "leaf" } } })
A.pts({ { 39, 18 }, { 40, 17 }, { 41, 16 }, { 42, 15 }, { 43, 14 }, { 44, 13 } }, LF[2])
c:px(41, 15, LF[4]) c:px(42, 14, LF[4])
c:px(37, 19, LF[1])
A.done()
