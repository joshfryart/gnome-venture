-- ico-gnome-gardener (final, Opus). A whole little gnome standing: tall red felt hat with the tip flopping right,
-- low over the eyes; round face with 2x3 ink eyes, a rounded nose with a lit tip and a dark underside, petal cheeks;
-- a long cream beard to the belly; green tunic, brown belt with a gold buckle, tiny boots. He holds a garden trowel
-- upright in his right hand. Ground shadow under the boots.
-- Material: per-pixel pillow light on every part (6-tone ramps). Felt hat: two fold creases, a darker rolled band
-- with a gold stitch hem. Beard: wavy strand lines and curl tips. Trowel: steel blade with a raised spine (lit left,
-- dark right), bright edge, specular, a rivet on the ferrule; wood handle with grain. AO under the hat band, under the
-- beard on the tunic, where the hand grips the handle.
-- quirk: a seedling has sprouted from the hat band.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-gnome-gardener")
local HAT   = { "#5a1a2e", "#8e2236", "#c2303a", "#e8493b", "#ff7a55", "#ffb080" }
local SKIN  = { "#7a4036", "#a85e48", "#c98462", "#e6a47c", "#f6c39a", "#ffe0bd" }
local NOSE  = { "#7a3436", "#b0524a", "#d8786a", "#f09a84", "#ffc0a4", "#ffe0cc" }
local BEARD = { "#5e5672", "#8c829c", "#b9afc0", "#dcd4d6", "#f2ece2", "#fff8ea" }
local TUN   = { "#1a4838", "#24663e", "#36874a", "#58a850", "#88c75c", "#c2e380" }
local WOOD  = { "#3e2420", "#5e3729", "#864c33", "#a86a42", "#c98e5a", "#e8b982" }
local STEEL = { "#2f3048", "#444663", "#6e708a", "#a2a2b4", "#cfd0dc", "#eef0f6" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local T = function(n) return A.tok(n) end
local hatT, skT, bdT, tuT, wdT, stT = T("hat"), T("skin"), T("beard"), T("tunic"), T("wood"), T("steel")

c:groundShadow(30, 54, 13, 2)

-- trowel blade (behind the hat edge)
local blade = HP.poly{ { 41, 37.5 }, { 48.5, 37.5 }, { 48.5, 31 }, { 44.8, 21.5 }, { 41, 31 } }
local bn = {}
blade:each(function(x, y) local s = (x - 44.8) / 4 bn[K(x, y)] = { s * 0.9, -0.15, sqrt(max(0.05, 1 - s * s * 0.8)) } end)
for k, v in pairs(bn) do local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) bn[k] = { v[1]/l, v[2]/l, v[3]/l } end
local sidx = A.shade(c, blade, bn, STEEL, { tok = stT, amb = 0.1, wrap = 0.3 })
for y = 25, 36 do c:put(44, y, STEEL[5], stT) c:put(45, y, STEEL[2], stT) end    -- raised spine
blade:edge():each(function(x, y) if x <= 43 and y < 36 then c:put(x, y, STEEL[6], stT) end end)  -- bright edge
c:put(43, 28, "#fff4d6", stT)
-- ferrule
local fer = HP.rect(43, 37, 46, 39)
local fn = {}
fer:each(function(x, y) local s = (x - 44.5) / 2 fn[K(x, y)] = { s, 0, sqrt(max(0.05, 1 - s * s)) } end)
A.shade(c, fer, fn, STEEL, { tok = stT, amb = 0.12, wrap = 0.3 })
c:put(44, 38, STEEL[1], stT)
-- handle: 3 px wood with grain
local hdl = HP.rrect(43, 40, 45, 52, 1)
local hn = {}
hdl:each(function(x, y) local s = (x - 44) / 1.5 hn[K(x, y)] = { s, 0, sqrt(max(0.05, 1 - s * s)) } end)
local hidx = A.shade(c, hdl, hn, WOOD, { tok = wdT, amb = 0.12, wrap = 0.3 })
for _, p in ipairs{ { 44, 46 }, { 44, 47 }, { 45, 50 } } do A.step(c, hidx, WOOD, p[1], p[2], -1, wdT) end
c:put(43, 52, WOOD[6], wdT) c:put(44, 52, WOOD[5], wdT)    -- pale end grain

-- boots
for _, bx in ipairs{ 22, 32 } do
  local b = HP.rrect(bx, 47, bx + 6, 52, 2)
  local idx = A.pill(c, b, 2, WOOD, { tok = wdT, amb = 0.1, wrap = 0.3 })
  for x = bx, bx + 6 do A.step(c, idx, WOOD, x, 52, -1, wdT) end
  c:put(bx + 1, 48, WOOD[6], wdT)
end
-- tunic + arms
local tun = HP.rrect(19, 31, 41, 48, 5)
local tidx = A.pill(c, tun, 4, TUN, { tok = tuT, amb = 0.1, wrap = 0.3, tilt = { 30, 40, 12, 0.06 } })
for x = 22, 38 do A.step(c, tidx, TUN, x, 48, -1, tuT) end
local larm = A.ell(18.5, 40, 2.5, 5)
A.pill(c, larm, 2, TUN, { tok = tuT, amb = 0.1, wrap = 0.3 })
for y = 37, 44 do if tidx[K(21, y)] then A.step(c, tidx, TUN, 21, y, -1, tuT) end end
local rarm = A.ell(40.5, 39, 2.5, 4.5)
A.pill(c, rarm, 2, TUN, { tok = tuT, amb = 0.1, wrap = 0.3 })
-- left hand (skin) at the bottom of the left arm
local lh = A.ell(18.5, 45.5, 2, 1.6)
A.pill(c, lh, 1.5, SKIN, { tok = skT, amb = 0.12, wrap = 0.3 })
-- belt + buckle (visible either side of the beard)
for x = 19, 41 do for y = 43, 44 do if tun:has(x, y) then c:put(x, y, y == 43 and WOOD[3] or WOOD[2], wdT) end end end

-- beard
local beard = HP.poly{ { 20, 29 }, { 40, 29 }, { 41, 35 }, { 37, 42 }, { 30.5, 48.5 }, { 24, 42 }, { 19.5, 35 } }
local bidx = A.pill(c, beard, 4, BEARD, { tok = bdT, amb = 0.12, wrap = 0.35, tilt = { 30, 36, 12, 0.08 } })
-- wavy strands
beard:each(function(x, y)
  local w = floor(x + 1.5 * math.sin(y * 0.7))
  if y > 31 and w % 4 == 0 and (bidx[K(x, y)] or 0) >= 2 then A.step(c, bidx, BEARD, x, y, -1, bdT) end
end)
-- AO on the tunic just right of / below the beard
A.touch(tun:copy():cut(beard), beard):each(function(x, y) A.step(c, tidx, TUN, x, y, -1, tuT) end)
-- buckle over the beard tip edge
c:paint({ "GGG", "GdG", "GGG" }, 35, 42, { G = GOLD[3], d = GOLD[1] })
c:put(35, 42, GOLD[4])

-- face
local face = A.ell(30, 27, 7.5, 4.6)
local fidx = A.pill(c, face, 3, SKIN, { tok = skT, amb = 0.12, wrap = 0.35 })
-- moustache over the beard top
local mous = HP.poly{ { 23, 30.5 }, { 30, 28.5 }, { 37, 30.5 }, { 35, 32.5 }, { 30, 31.5 }, { 25, 32.5 } }
local midx = A.pill(c, mous, 1.5, BEARD, { tok = bdT, amb = 0.15, wrap = 0.35 })
-- eyes, cheeks
c:eyeSmall(25, 24) c:eyeSmall(34, 24)
c:cheek(23, 28) c:cheek(36, 28)
-- nose: rounded, lit tip, dark underside row, nostril shadow
local nose = A.ell(30.5, 27.5, 2.2, 1.8)
local nn = X.sphere(30.5, 27.5, 2.2, nose)
A.shade(c, nose, nn, NOSE, { tok = skT, amb = 0.12, wrap = 0.3 })
c:put(29, 26, NOSE[6], skT)
for x = 29, 32 do c:put(x, 29, NOSE[1], skT) end
c:put(30, 29, "#5a2a2e", skT)

-- hat: cone, tip flopping to the right
local hat = HP.poly{ { 17, 24.5 }, { 43.5, 24.5 }, { 40, 16 }, { 38, 10 }, { 41, 5 }, { 37, 3.5 }, { 31, 8 }, { 22, 17 } }
local hidx2 = A.pill(c, hat, 4, HAT, { tok = hatT, amb = 0.08, wrap = 0.3, tilt = { 30, 16, 14, 0.12 } })
-- fold creases (dark line + lit lip above)
for _, f in ipairs{ { { 27, 15 }, { 33, 18 } }, { { 33, 9 }, { 37, 12 } } } do
  A.seg(f[1][1], f[1][2], f[2][1], f[2][2]):each(function(x, y)
    A.step(c, hidx2, HAT, x, y, -2, hatT) A.step(c, hidx2, HAT, x, y - 1, 1, hatT) end)
end
-- rolled band: darker, AO row on the face under it, gold hem stitch
local band = HP.rrect(17, 21, 43, 24, 2)
local bandn = {}
band:each(function(x, y) local s = (y - 22.5) / 2.2 bandn[K(x, y)] = { (x - 30) / 30, s, sqrt(max(0.05, 1 - s * s)) } end)
for k, v in pairs(bandn) do local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) bandn[k] = { v[1]/l, v[2]/l, v[3]/l } end
local bdx = A.shade(c, band, bandn, HAT, { tok = hatT, amb = 0.06, wrap = 0.25, cuts = { 0.25, 0.45, 0.62, 0.78, 0.95 } })
for x = 18, 42 do if fidx[K(x, 25)] then A.step(c, fidx, SKIN, x, 25, -1, skT) end end
c:stitch{ { 19, 23 }, { 41, 23 } }
c:put(23, 21, HAT[6], hatT) c:put(24, 21, HAT[6], hatT)
c:put(25, 13, HAT[6], hatT) c:put(26, 12, HAT[6], hatT)

-- right hand gripping the handle (in front), AO on the handle above/below the fist
local rh = HP.rrect(42, 41, 46, 44, 1)
A.pill(c, rh, 1.5, SKIN, { tok = skT, amb = 0.12, wrap = 0.3 })
c:put(43, 42, SKIN[6], skT)
for x = 43, 45 do if hidx[K(x, 45)] then A.step(c, hidx, WOOD, x, 45, -1, wdT) end end
for x = 42, 46 do c:put(x, 44, SKIN[2], skT) end

-- quirk: a seedling sprouting from the hat band on the left
local SP = { s = "#3f9150", S = "#24544a", l = "#7cc35a", L = "#c4e07a", d = "#2e7646" }
A.map(c, {
  "LLl..ll",
  "llds.dl",
  ".d.sd..",
  "....s..",
  "....S..",
}, 15, 16, SP, T("sprout"))
A.save(c, "ico-gnome-gardener")
