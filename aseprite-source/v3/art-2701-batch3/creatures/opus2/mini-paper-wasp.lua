-- mini-paper-wasp (75x56 still, side view, faces right). Opus second pass.
-- Keeps the game picture's design (gold body, ink-violet bands, papery tan wing, red bow on the antenna)
-- and fixes the named defect: the legs were a dark brown tangle. Now three near legs and two far legs,
-- each a thick femur, a clear knee, a thin shin and a hooked foot. Also a real wasp waist (petiole)
-- and elbowed antennae. quirk: the wing is made of chewed paper (fibre flecks), the red bow stays.
local NAME = "mini-paper-wasp"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local GOLD = R("#fff0a8", "#ffd45a", "#f0a02e", "#a85a22")
local BAND = R("#6a58b0", "#3f3274", "#2f2556", "#241c40")
local PAPER = R("#f4dcb0", "#d8ad7c", "#b58258", "#7e5440")
local LEGN = R("#e8a640", "#c27a2a", "#8f4f22", "#5e3424") -- near legs
local LEGF = R("#9a5e2c", "#7a4628", "#5e3424", "#4a2a24") -- far legs, darker
local BOW = P.ember

local c = HP.canvas{ w = 75, h = 56, scale = 1, name = NAME }
c:groundShadow(38, 51, 27, 2.5)
-- trim the 1 px nubs at the top and bottom tips of the shadow ellipse
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

local function leg(pts, r, w1)
  -- femur (w1 px) to the knee, then a 1 px shin and a 2 px hooked foot
  c:part(c:line({ pts[1], pts[2] }, w1), r, { band = 1, nopop = true, inner = false })
  c:part(c:line({ pts[2], pts[3] }, 1), r, { band = 1, nopop = true, noshade = true, inner = false })
  c:put(pts[2][1], pts[2][2], r.hi) -- lit knee
  c:fillMask(c:line({ pts[3], pts[4] }, 1), r.shade)
end
-- far legs (behind the body)
leg({ { 43, 36 }, { 51, 41 }, { 55, 49 }, { 57, 49 } }, LEGF, 2)
leg({ { 37, 37 }, { 31, 42 }, { 29, 49 }, { 27, 49 } }, LEGF, 2)

-- papery wings, behind the body: hind wing low, fore wing tall
local hw = c:poly{ { 30, 27 }, { 13, 19 }, { 9, 14 }, { 14, 12 }, { 27, 18 }, { 36, 26 } }
c:part(hw, PAPER, { band = 1, nopop = true })
local fw = c:poly{ { 33, 27 }, { 18, 12 }, { 17, 5 }, { 24, 2 }, { 30, 4 }, { 41, 24 } }
c:part(fw, PAPER, { band = 2, pop = { x = 21, y = 5 }, sep = true })
-- veins and chewed-paper flecks
c:fillMask(c:line({ { 38, 25 }, { 22, 6 } }, 1):clip(fw:copy():shrink(1)), PAPER.shade)
c:fillMask(c:line({ { 33, 26 }, { 14, 15 } }, 1):clip(hw:copy():shrink(1)), PAPER.shade)
for _, q in ipairs{ { 25, 9 }, { 28, 14 }, { 31, 18 }, { 21, 11 }, { 33, 12 }, { 27, 20 }, { 17, 16 }, { 22, 18 }, { 35, 21 } } do
  if fw:has(q[1], q[2]) or hw:has(q[1], q[2]) then c:put(q[1], q[2], PAPER.hi) c:put(q[1] + 1, q[2] + 1, PAPER.shade) end
end

-- abdomen with stinger, petiole waist, thorax, head
local ab = c:ellipse(19.5, 34, 14, 8)
ab:add(c:poly{ { 8, 31 }, { 2, 39 }, { 9, 39 } })
c:part(ab, GOLD, { band = 2, pop = { x = 14, y = 28 } })
for _, b in ipairs{ { 11, 13 }, { 18, 20 }, { 25, 27 } } do
  local band = c:poly{ { b[1] + 1, 25 }, { b[2] + 2, 25 }, { b[2], 43 }, { b[1] - 1, 43 } }:clip(ab)
  c:part(band, BAND, { band = 1, nopop = true, inner = false })
end
c:fillMask(c:line({ { 2, 39 }, { 5, 38 } }, 1), BAND.deep) -- stinger tip
local pet = c:rect(33, 32, 35, 35)
c:part(pet, GOLD, { band = 1, nopop = true })
local th = c:ellipse(40, 32, 5.5, 6)
c:part(th, GOLD, { band = 2, pop = { x = 37, y = 28 } })
c:fillMask(c:line({ { 38, 27 }, { 37, 37 } }, 2):clip(th), BAND.base)
c:put(38, 28, BAND.hi)
local hd = c:ellipse(51.5, 31, 7, 6.5)
c:part(hd, GOLD, { band = 2, pop = { x = 48, y = 26 } })
-- mandibles (the mouth), brown with an ink gap
local MAND = R("#c98a52", "#8a5234", "#5e3428", "#3e2426")
c:paint({ "mmh.", "mmmm", "dmmd", ".d.m" }, 57, 34, { m = MAND.base, h = MAND.hi, d = MAND.shade })
c:put(58, 37, MAND.deep)
-- lit rim along the upper-left edges of abdomen, thorax and head (round, glossy)
for _, m in ipairs{ ab, th, hd } do
  local l = {}
  m:each(function(x, y) if not m:has(x, y - 1) and m:has(x + 1, y) and c:get(x, y) == GOLD.base then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], GOLD.hi) end
end
c:eyeSmall(53, 28)
c:put(52, 33, P.petal.base) c:put(53, 33, P.petal.base) -- cheek
-- near legs (in front of the body): front, mid, hind
leg({ { 45, 36 }, { 52, 41 }, { 54, 49 }, { 56, 49 } }, LEGN, 2)
leg({ { 40, 37 }, { 41, 43 }, { 39, 49 }, { 41, 49 } }, LEGN, 2)
leg({ { 35, 36 }, { 26, 41 }, { 22, 49 }, { 20, 49 } }, LEGN, 2)

-- elbowed antennae; the near one wears the red bow
local function ant(pts)
  c:fillMask(c:line({ pts[1], pts[2] }, 1), GOLD.deep)
  c:fillMask(c:line({ pts[2], pts[3] }, 1), GOLD.deep)
  c:put(pts[3][1], pts[3][2], GOLD.shade)
end
ant{ { 48, 25 }, { 48, 15 }, { 52, 11 } }
ant{ { 52, 25 }, { 56, 15 }, { 62, 12 } }
c:paint({ "r..r", "rkkr", "r..r" }, 54, 14, { r = "ember.base", k = "ember.deep" })
c:put(54, 14, BOW.hi)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
