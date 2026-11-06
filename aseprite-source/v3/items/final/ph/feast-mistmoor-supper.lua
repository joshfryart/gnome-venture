-- feast-mistmoor-supper (Opus single pass, aB30_4). A slim speckled blue enamel stewpot with a dark rolled rim and
-- ring lugs; the domed lid is tipped up on the left so the brown stew (carrot coins, peas) shows in the gap, and moor
-- mist rolls out of it. A sprig of purple heather lies at the foot.
-- Material: per-pixel cylinder light on the enamel (6 tones), cream + navy speckle, specular streak, cool bounce on the
-- shade side, AO under the rim and at the base; ellipsoid lid with a dark lip and a turned wood knob; glossy stew in
-- the lid's cast shadow.
-- quirk: the mist curls up into a little question mark.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local NAME = "feast-mistmoor-supper"
local c = A.new2(NAME)
local EN   = { "#232c48", "#34486c", "#4d6b92", "#7194b6", "#a5c3d8", "#dbeaf2" }
local NAVY = { "#141a2c", "#1f2a44", "#2c3c5e", "#41567c", "#5d769c", "#8aa0c0" }
local STEW = { "#3a1c14", "#5e2f1c", "#874624", "#ad6532", "#cf8b48", "#ecb872" }
local OR   = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
local MIST = { "#7d7a9c", "#9a98b8", "#b8b7d0", "#d3d3e3", "#e8e8f0", "#f8f6ee" }
local WOOD = { "#3e2420", "#5e3626", "#864c33", "#a86a40", "#c98f58", "#e8b982" }

c:groundShadow(32, 54, 22, 2)
-- ring lugs (behind the body)
for _, lx in ipairs{ 13, 51 } do
  local ring = A.ell(lx, 38, 2.7, 2.7):cut(A.ell(lx, 38, 1.1, 1.1))
  A.pil(c, ring, NAVY, 1)
end
-- body
local body = HP.rrect(15, 30, 49, 52, 6):add(A.ell(32, 30, 17, 4.5))
local bias = {}
body:each(function(x, y) local k = K(x, y)
  if y >= 51 then bias[k] = -1 end
  if y <= 35 then bias[k] = (bias[k] or 0) - 1 end end)
local bidx = A.shadeN(c, body, A.vn(body, 15, 49, 0.1), EN, { bias = bias, wrap = 0.3 })
-- speckle (enamel), avoid the brightest band
body:each(function(x, y) local h = A.hash(x, y, 7) local i = bidx[K(x, y)]
  if y > 35 and y < 51 then
    if h > 0.95 and i <= 4 then c:put(x, y, "#e6eff4") elseif h < 0.035 and i >= 4 then c:put(x, y, "#2a3a5a") end
  end end)
-- specular streak + cool bounce
for y = 37, 48 do c:put(20, y, y < 44 and "#f2f8fb" or EN[6]) end
c:put(21, 38, "#f2f8fb")
for y = 38, 49 do c:put(48, y, "#6c84b0") end
-- rolled rim + mouth
local outer, inner = A.ell(32, 30, 17.5, 4.6), A.ell(32, 30.4, 15.5, 3.3)
A.pil(c, outer:copy():cut(inner), NAVY, 1)
A.fill(c, inner, "#2c3c5e")
A.fill(c, A.ell(32, 29.6, 15, 2.4):clip(inner), "#1f2a44")
-- lid (needed now for its cast shadow on the stew)
local lid, ln = A.oval(25, 23.5, 14.5, 4.6, -0.3, 0.55)
local stew = A.ell(32, 31.3, 14.5, 2.4):clip(inner)
local sb = {}
A.cast(sb, stew, lid, 1, 3, -2)
A.shadeN(c, stew, X.pillow(stew, 2), STEW, { bias = sb })
for _, p in ipairs{ { 38, 31 }, { 44, 31 }, { 34, 32 } } do
  local m = A.ell(p[1], p[2], 1.6, 0.9)
  A.pil(c, m, OR, 1)
  c:put(p[1] - 1, p[2], OR[6])
end
for _, p in ipairs{ { 41, 32 }, { 46, 30 }, { 36, 30 } } do c:put(p[1], p[2], "#5f9a3c") c:put(p[1] - 1, p[2], "#a8d06a") end
c:put(42, 30, "#fff1cf")
-- lid lip (thickness) then dome
local lip = lid:shift(0, 1):cut(lid)
A.fill(c, lip, NAVY[2])
lid:shift(0, 1):cut(lid):each(function(x, y) if x < 22 then c:put(x, y, NAVY[1]) end end)
local lidx = A.shadeN(c, lid, ln, EN, { wrap = 0.3 })
lid:edge():each(function(x, y) if y >= 23 then c:put(x, y, NAVY[3]) end end)
lid:each(function(x, y) if A.hash(x, y, 3) > 0.94 and (lidx[K(x, y)] or 6) <= 4 then c:put(x, y, "#e6eff4") end end)
-- wood knob on a short stem (tilted with the lid)
A.pil(c, HP.rect(24, 17, 25, 19), NAVY, 1)
local knob = A.ell(24.6, 16, 3, 1.8)
A.pil(c, knob, WOOD, 1.2)
c:put(23, 15, WOOD[6]) c:put(24, 15, "#fff1cf")
c:put(18, 21, "#f2f8fb") c:put(19, 21, "#f2f8fb")
-- mist rolling out of the gap
local mist = A.ell(44, 25.5, 3.4, 2.2):add(A.ell(41.5, 21, 4, 2.8)):add(A.ell(46, 17, 3.3, 2.4)):add(A.ell(43, 13, 2.2, 1.8))
A.pil(c, mist, MIST, 1.6, { wrap = 0.4, amb = 0.2 })
-- quirk: question mark curl
A.map(c, 49, 8, {
  ".abb.",
  "ab.cc",
  "...cc",
  "..cd.",
  "..d..",
  ".....",
  "..c..",
}, { a = MIST[6], b = MIST[5], c = MIST[4], d = MIST[3] })
-- heather sprig at the foot
local ST = "#5a3a30"
for i = 0, 10 do c:put(8 + i, 54 - floor(i * 0.9), i < 5 and ST or "#7a5038") end
local HE = { "#5a2a72", "#8a44a6", "#c070d0", "#eaa8ec" }
for _, p in ipairs{ { 10, 50 }, { 13, 49 }, { 12, 46 }, { 15, 46 }, { 14, 43 }, { 17, 43 }, { 17, 40 } } do
  c:put(p[1], p[2], HE[2]) c:put(p[1] + 1, p[2], HE[1]) c:put(p[1], p[2] - 1, HE[3]) c:put(p[1] + 1, p[2] - 1, HE[2])
end
c:put(17, 39, HE[4]) c:put(12, 45, HE[4])
c:put(9, 52, "#4f8a3a") c:put(11, 53, "#4f8a3a") c:put(15, 48, "#6aa448")
A.save2(c, NAME)
