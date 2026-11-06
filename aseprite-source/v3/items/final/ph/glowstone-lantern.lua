-- glowstone-lantern (final pass, Opus). A slim garden stone lantern: knob finial, a swept pagoda roof with upturned
-- eaves and moss on its ridge, a firebox with a square window where a faceted glowstone crystal burns lime-gold,
-- a sill, a thin shaft and a stepped plinth on a ground shadow. Stone: chiselled bevels (pillow light), speckle
-- grain, dark ambient rows under the roof and the sill, warm light spill on the window frame and sill.
-- quirk: a fern sprout has pushed out of a crack in the plinth.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("glowstone-lantern")
local ST   = { "#363452", "#545470", "#76768e", "#9a98ac", "#bebcca", "#e2e0e6" }
local GLOW = { "#7a5a1a", "#b48a20", "#e2be2e", "#f6e264", "#fdf6a8", "#fffbe6" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local tS = { r = { name = "stone" } }

c:groundShadow(32, 55, 14, 2)

local function stone(m, R, bias)
  local n = X.pillow(m, R or 2)
  local idx = A.shade(c, m, n, ST, { tok = tS, bias = bias, amb = 0.08, wrap = 0.25 })
  -- speckle grain
  m:each(function(x, y) local h = X.hash(x, y, 7)
    local i = idx[K(x, y)]
    if h < 0.09 and i and i > 2 then A.step(c, idx, ST, x, y, -1, tS)
    elseif h > 0.95 and i and i < 6 then A.step(c, idx, ST, x, y, 1, tS) end end)
  return idx
end

-- plinth (two steps) and shaft
local plinth = c:rect(21, 52, 43, 54)
local pb = {} for x = 21, 43 do pb[K(x, 52)] = -1 end
stone(plinth, 2, pb)
local step2 = c:rect(25, 49, 39, 51)
local s2b = {} for x = 25, 39 do s2b[K(x, 49)] = -1 end
stone(step2, 2, s2b)
local shaft = c:rect(29, 38, 35, 48)
local shn = A.vcylN(shaft, 28.5, 35.5)
local shb = {} for x = 29, 35 do shb[K(x, 38)] = -2 shb[K(x, 39)] = -1 shb[K(x, 48)] = -1 end
local shi = A.shade(c, shaft, shn, ST, { tok = tS, bias = shb })
for y = 40, 47, 3 do c:put(30 + (y % 2), y, ST[3], tS) end -- chisel marks
c:put(34, 44, ST[2], tS) c:put(33, 46, ST[2], tS)
-- crack in plinth + fern (quirk)
for _, p in ipairs{ { 37, 52 }, { 38, 53 }, { 38, 54 } } do c:put(p[1], p[2], ST[1], tS) end

-- sill under firebox
local sill = c:rect(20, 35, 44, 37)
local sb = {} for x = 20, 44 do sb[K(x, 37)] = -1 end
local si = stone(sill, 1.5, sb)
-- firebox
local box = c:rect(23, 22, 41, 34)
local bxb = {} for x = 23, 41 do bxb[K(x, 22)] = -2 bxb[K(x, 23)] = -1 end
local bi = stone(box, 2, bxb)
-- window opening (dark recess) + glowstone crystal
local win = c:rect(27, 25, 37, 33)
local wv = {}
win:each(function(x, y) local d = sqrt((x - 32) ^ 2 + (y - 29.5) ^ 2) wv[K(x, y)] = max(0, 0.7 - d / 9) end)
X.tone(c, win, wv, { "#2a1c2a", "#4a3020", "#6e4a1e", "#9a6e20" }, { cuts = { 0.12, 0.3, 0.5 } })
-- inner frame: deep row top/left (recess shadow)
for x = 27, 37 do c:put(x, 25, "#2a1c2a") end
for y = 25, 33 do c:put(27, y, "#2a1c2a") end
-- crystal: faceted hexagonal prism, standing
local cr = c:poly{ { 32, 26 }, { 35, 28 }, { 35, 32 }, { 32, 33 }, { 29, 32 }, { 29, 28 } }
cr:each(function(x, y)
  local face
  if y <= 28 and abs(x - 32) <= (y - 26) * 1.5 then face = (x <= 32) and 6 or 5      -- top facets
  elseif x <= 30 then face = 4 elseif x <= 32 then face = 5 elseif x <= 33 then face = 4 else face = 3 end
  if y >= 32 then face = max(2, face - 1) end
  c:put(x, y, GLOW[face])
end)
c:put(31, 27, A.CREAM) c:put(32, 27, GLOW[6])
-- light spill: window frame and sill pick up warm light
for x = 26, 38 do
  local k = K(x, 34) c:put(x, 34, x > 28 and x < 36 and "#d6b46a" or "#b2a088", tS)
  c:put(x, 35, (x > 28 and x < 36) and "#e6d8a6" or "#c8c0a8", tS)
end
for y = 26, 33 do c:put(38, y, y > 27 and y < 32 and "#c8b080" or "#a8a090", tS) end

-- roof
local roof = c:poly{ { 30, 11 }, { 34, 11 }, { 42, 16 }, { 47, 18 }, { 48, 17 }, { 48, 20 }, { 16, 20 }, { 16, 17 }, { 17, 18 }, { 22, 16 } }
local rn = X.pillow(roof, 2.5)
roof:each(function(x, y) local k = K(x, y) local a = rn[k]
  local sx = (x - 32) / 16
  rn[k] = { A.norm(a[1] + sx * 0.9, a[2] - 0.6, a[3]) } end)
local rb = {} for x = 16, 48 do rb[K(x, 20)] = -1 end
local ri = A.shade(c, roof, rn, ST, { tok = tS, bias = rb })
-- tiles: ribs down the slopes
for _, x0 in ipairs{ 24, 28, 36, 40 } do
  for y = 14, 19 do local x = x0 + floor((x0 - 32) / 8 * (y - 14) * 0.6 + 0.5)
    if roof:has(x, y) then A.step(c, ri, ST, x, y, -1, tS) end end
end
-- eave lip highlight row
for x = 18, 46 do if roof:has(x, 19) then A.step(c, ri, ST, x, 19, 1, tS) end end
-- moss on ridge and lit slope
for _, p in ipairs{ { 29, 12, 3 }, { 30, 11, 4 }, { 31, 11, 3 }, { 32, 11, 3 }, { 28, 13, 2 }, { 27, 13, 3 }, { 26, 14, 2 }, { 33, 11, 2 }, { 35, 12, 2 }, { 24, 15, 2 }, { 25, 14, 3 } } do
  c:put(p[1], p[2], MOSS[p[3]], tS) end
c:put(30, 10, MOSS[3], tS) c:put(27, 12, MOSS[2], tS)
-- finial
local fin = c:ellipse(32, 8, 2, 2)
A.shade(c, fin, X.sphere(31.5, 7.5, 2.5, fin), ST, { tok = tS })
local neck = c:rect(31, 10, 33, 10)
for x = 31, 33 do c:put(x, 10, x == 33 and ST[2] or ST[3], tS) end
c:put(31, 7, A.CREAM, tS)

-- fern sprout from the crack
local FERN = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
for _, p in ipairs{ { 39, 51, 2 }, { 40, 50, 2 }, { 41, 49, 3 }, { 42, 48, 3 }, { 43, 48, 4 },
  { 40, 49, 3 }, { 39, 49, 4 }, { 42, 47, 3 }, { 41, 47, 4 }, { 43, 49, 2 }, { 44, 49, 2 }, { 39, 52, 1 } } do
  c:put(p[1], p[2], FERN[p[3]]) end
c:put(43, 47, FERN[4]) -- curled tip

A.save(c, "glowstone-lantern")
