-- ico-boot (final pass, Opus). A single walking boot in side profile, toe to the right.
-- Structure: knitted wool cuff folded over the top, leather shaft with brass eyelets and red laces tied in a bow
-- that pokes out past the front edge, a stitched toe cap, a darker heel counter, a stacked heel and a treaded sole.
-- Material: per-pixel pillow light on the leather with grain and ankle creases, ribbed knit on the cuff,
-- brass bevel on the eyelets, twisted lace cord, AO under the cuff and above the welt, cool bounce on the toe.
-- quirk: a little heart-shaped patch darned onto the side of the shaft.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("ico-boot")
local LE, WO, SO, BR, RB, PE = R.leather, R.wool, R.sole, R.brass, R.ribbon, R.rose

-- masks
local upper = A.poly{ { 19, 13 }, { 34, 13 }, { 34.5, 30 }, { 37, 33.5 }, { 43, 35.5 }, { 48, 37.5 }, { 51, 40 },
  { 52.5, 43.5 }, { 52.5, 47 }, { 17.5, 47 }, { 17, 40 }, { 17.5, 32 }, { 18.5, 22 } }
local cuff = A.poly{ { 16.5, 7.5 }, { 36.5, 7.5 }, { 37.5, 9 }, { 37.5, 15.5 }, { 16, 15.5 }, { 15.5, 9 } }
local heelB = A.poly{ { 17, 48 }, { 27, 48 }, { 27, 54 }, { 17.5, 54 } }
local sole = A.poly{ { 26, 47.5 }, { 53, 47.5 }, { 54.5, 46 }, { 55, 48 }, { 54, 51 }, { 26, 51 } }

-- leather upper: pillow + cylinder on the shaft, rounded toe
local bias = {}
X.ao(bias, upper, cuff, 2, -1)
local welt = A.poly{ { 16, 47 }, { 56, 47 }, { 56, 49 }, { 16, 49 } }
X.ao(bias, upper, welt, 1, -1)
local nU = X.pillow(upper, 3.6)
upper:each(function(x, y)
  local k = K(x, y)
  local n = nU[k]
  -- shaft: true cylinder across x (lit left, shade right)
  local u = max(-0.95, min(0.95, (x - 25) / 9.5))
  local sx, sy, sz = u, -0.1, math.sqrt(1 - u * u)
  -- foot: ellipsoid dome around the vamp/toe, blended in below the ankle
  local du, dv = (x - 38) / 16, (y - 43) / 9
  local q = max(0.05, 1 - du * du - dv * dv)
  local fx, fy, fz = du, dv, math.sqrt(q)
  local w = max(0, min(1, (y - 31) / 7)) * max(0, min(1, (x - 24) / 8))
  local nx = sx * (1 - w) + fx * w + n[1] * 0.5
  local ny = sy * (1 - w) + fy * w + n[2] * 0.5
  local nz = sz * (1 - w) + fz * w
  nU[k] = { A.norm(nx, ny, nz) }
end)
-- grain speckle
upper:shrink(2):each(function(x, y)
  local h = X.hash(x, y, 31)
  local k = K(x, y)
  if h < 0.035 then bias[k] = (bias[k] or 0) - 1 elseif h > 0.975 then bias[k] = (bias[k] or 0) + 1 end
end)
local iU = A.shadeN(c, upper, nU, LE, { bias = bias, wrap = 0.15, cuts = { 0.14, 0.3, 0.46, 0.62, 0.95 } })
-- tongue strip behind the laces (darker, recessed)
for y = 15, 30 do for x = 32, 33 do if upper:has(x, y) then A.setI(c, iU, LE, x, y, (x == 32) and 2 or 3) end end end

-- cool bounce under the toe
upper:each(function(x, y)
  if not upper:has(x, y + 2) and x > 38 and x < 51 and (x % 3 ~= 0) and upper:has(x, y - 1) then
    c:put(x, y - 0, "#6a4a5a") end
end)

-- heel counter (separate leather panel, a tone darker, seam line)
local counter = A.poly{ { 17, 37 }, { 23, 38.5 }, { 27.5, 42 }, { 28.5, 47 }, { 17, 47 } }
counter:each(function(x, y) if upper:has(x, y) then A.step(c, iU, LE, x, y, -1) end end)
A.seg(18, 37, 23, 38):add(A.seg(23, 38, 27, 41)):add(A.seg(27, 41, 28, 46)):each(function(x, y)
  if upper:has(x, y) then A.setI(c, iU, LE, x, y, 2)
    if upper:has(x, y - 1) and not counter:has(x, y - 1) then A.step(c, iU, LE, x, y - 1, 1) end end end)

-- toe cap seam + gold stitch (the one stitch)
local seam = { { 41, 35 }, { 39, 38 }, { 39, 42 }, { 40, 46 } }
for i = 1, #seam - 1 do
  A.seg(seam[i][1], seam[i][2], seam[i + 1][1], seam[i + 1][2]):each(function(x, y)
    if upper:has(x, y) then A.setI(c, iU, LE, x, y, 2) if upper:has(x - 1, y) then A.step(c, iU, LE, x - 1, y, 1) end end end)
end
c:stitch{ { 42, 37 }, { 41, 39 }, { 41, 42 }, { 42, 45 } }

-- ankle creases on the front
for _, cr in ipairs{ { 34, 28, 30, 31 }, { 35, 31, 31, 34 }, { 37, 34, 34, 36 } } do
  A.seg(cr[1], cr[2], cr[3], cr[4]):each(function(x, y)
    if upper:has(x, y) then A.step(c, iU, LE, x, y, -2) if upper:has(x, y - 1) then A.step(c, iU, LE, x, y - 1, 1) end end end)
end

-- quirk: heart patch darned onto the shaft
local heart = {
  ".ab.bc.",
  "abbbbcd",
  "bbbbccd",
  ".bbccd.",
  "..ccd..",
  "...d...",
}
A.map(c, heart, 21, 23, { a = PE[6], b = PE[5], c = PE[4], d = PE[3] })
for _, p in ipairs{ { 21, 24 }, { 27, 24 }, { 22, 26 }, { 26, 26 }, { 24, 28 } } do c:put(p[1], p[2], PE[2]) end
c:put(22, 24, A.CREAM)

-- eyelets (brass) and red laces
local eyes = { 16, 20, 24, 28 }
for i, ey in ipairs(eyes) do
  local ex = 31
  c:put(ex, ey, BR[5]) c:put(ex + 1, ey, BR[4]) c:put(ex, ey + 1, BR[3]) c:put(ex + 1, ey + 1, BR[1])
  -- lace runs from eyelet up to the front edge, twisted (alternating tones)
  local pts = A.seg(ex + 2, ey, ex + 4, ey - 2)
  local j = 0
  pts:each(function(x, y) j = j + 1 end)
  for d = 0, 2 do
    c:put(ex + 2 + d, ey - d, d % 2 == 0 and RB[5] or RB[3])
    c:put(ex + 2 + d, ey - d + 1, RB[2])
  end
end
-- lace bow on top, looping out past the front of the shaft
A.map(c, {
  "..aab..",
  ".ab.bc.",
  "abbbbcd",
  ".bccdd.",
  "..c..d.",
  "..c...d",
  ".cc...d",
}, 33, 10, { a = RB[6], b = RB[5], c = RB[4], d = RB[2] })

-- knitted wool cuff: pillow + vertical ribs
local nC = X.pillow(cuff, 2.6)
local bC = {}
cuff:each(function(x, y) if (x % 3) == 0 then bC[K(x, y)] = -1 end end)
local iC = A.shadeN(c, cuff, nC, WO, { bias = bC, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- fold line across the cuff (lower turned edge)
for x = 16, 37 do if cuff:has(x, 13) then A.step(c, iC, WO, x, 13, -1) end end
-- knit "v" texture on the top roll
for x = 18, 35, 3 do if cuff:has(x + 1, 9) then A.step(c, iC, WO, x + 1, 9, 1) end end
c:put(19, 9, A.CREAM)

-- sole + heel (rubber, dark) with welt and tread
local nS = X.pillow(sole, 1.4)
local iS = A.shadeN(c, sole, nS, SO, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
local nH = X.pillow(heelB, 1.6)
local iH = A.shadeN(c, heelB, nH, SO, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- welt row: pale leather strip where upper meets sole
for x = 17, 54 do
  if sole:has(x, 48) or heelB:has(x, 48) then c:put(x, 48, (x < 24) and LE[5] or LE[4]) end
end
-- tread notches along the bottom
for x = 28, 52, 3 do c:put(x, 51, SO[1]) c:put(x + 1, 51, SO[1]) end
for x = 18, 26, 3 do c:put(x, 54, SO[1]) end
-- heel stack line
for x = 18, 26 do if heelB:has(x, 51) then c:put(x, 51, SO[2]) end end
-- AO where the heel meets the sole
for y = 49, 51 do c:put(27, y, SO[1]) end

-- leather specular on the toe and shaft
c:put(45, 39, LE[6]) c:put(46, 39, LE[6]) c:put(22, 18, LE[6]) c:put(22, 19, LE[6])

A.save(c, "ico-boot")
