-- ico-activity (final pass, Opus single pass). Bold icon: a slim gnome in full sprint to the right, leaning into
-- it: tall red hat swept back by the wind (soft felt: fold crease, rolled brim), round face with a designed nose
-- (lit tip, dark underside), beard streaming back, green tunic with a belt and brass buckle, brown breeches, back
-- boot kicked up showing its sole, front boot striking forward. Per-pixel pillow light, 5-6 tones per material,
-- contact shadows where limbs cross the body, two dust puffs behind the heel.
-- quirk: a bead of sweat flicks off his brow.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA0_3.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = T.new("ico-activity")
local SKIN  = { "#7a4036", "#c98462", "#f0b98d", "#ffd6ae", "#ffe8cc" }
local NOSE  = { "#7a2c36", "#b8545a", "#e88272", "#ffaa8c", "#ffd2b4" }
local HAT   = { "#5c1a30", "#8e2236", "#c22c38", "#e8493b", "#ff7a54", "#ffa878" }
local TUNIC = { "#1c4a3a", "#26623f", "#3f9150", "#62b058", "#9ed06a" }
local PANTS = { "#3a2226", "#5e3a30", "#865436", "#b07a4a", "#d4a06a" }
local BOOT  = { "#24141c", "#3e2426", "#62382c", "#8c5638", "#b47c50" }
local BEARD = { "#7c7290", "#aaa0b8", "#d2cad8", "#ece6e6", "#fff4d6" }
local DUST  = { "#8a879c", "#b4b2c2", "#d8d6e0" }
local parts = {}
local function tk(n) return { r = { name = n } } end
-- paint a pillow-lit part and remember it for contact shadows
local function part(name, m, ramp, R, o)
  o = o or {}
  local tok = tk(name)
  local idx = T.pil(c, m, ramp, R, { amb = o.amb or 0.06, wrap = o.wrap or 0.22, bias = o.bias, tok = tok, cuts = o.cuts })
  local p = { m = m, idx = idx, ramp = ramp, tok = tok }
  parts[name] = p
  return p
end
-- contact shadow: pixels of part p just below/right of mask m (and not covered by it) go a tone darker
local function contact(p, m, dx, dy)
  m:shift(dx or 1, dy or 1):each(function(x, y)
    if p.m:has(x, y) and not m:has(x, y) and c:get(x, y) == p.ramp[p.idx[K(x, y)] or 0] then
      T.step(c, p.idx, p.ramp, x, y, -1, p.tok) end end)
end

-- dust puffs behind the kicked heel
for _, d in ipairs{ { 9, 51, 3 }, { 14.5, 53, 2.2 } } do
  local dm = c:ellipse(d[1], d[2], d[3], d[3] * 0.8)
  T.pil(c, dm, DUST, 1.5, { amb = 0.25, wrap = 0.4, tok = tk("dust") })
end

-- back arm (swung back, bent) and hand
local bArm = c:line({ { 31, 35 }, { 25, 40 }, { 21, 37 } }, 4)
part("barm", bArm, { TUNIC[1], TUNIC[2], TUNIC[3], TUNIC[4] }, 1.5)
part("bhand", c:ellipse(19.5, 36.5, 2.5, 2.5), { SKIN[1], SKIN[2], SKIN[3], SKIN[4] }, 1.5)
-- back leg: thigh back, shin kicked up, boot sole showing
local bLeg = c:line({ { 31, 46 }, { 25, 50 }, { 19, 45 } }, 4)
part("bleg", bLeg, { PANTS[1], PANTS[2], PANTS[3], PANTS[4] }, 1.5)
local bBoot = T.rell(15, 44, 0.55, -0.83, 4.2, 3.2)
part("bboot", bBoot, BOOT, 1.5)
-- sole: dark strip on the back edge with nail dots
for _, p in ipairs{ { 12, 43 }, { 12, 44 }, { 13, 41 }, { 12, 45 }, { 13, 46 }, { 14, 47 } } do
  if bBoot:has(p[1], p[2]) then c:put(p[1], p[2], BOOT[1]) end end
c:put(13, 44, BOOT[4])
-- front leg: thigh forward, shin down, boot striking
local fLeg = c:line({ { 35, 46 }, { 41, 48 }, { 41, 52 } }, 4)
part("fleg", fLeg, PANTS, 1.5)
local fBoot = c:ellipse(44, 53.5, 5, 2.8):add(c:rect(39, 50, 43, 55))
local fb = part("fboot", fBoot, BOOT, 2)
for x = 39, 49 do if fBoot:has(x, 56) then c:put(x, 56, BOOT[1]) elseif fBoot:has(x, 55) then c:put(x, 55, BOOT[1]) end end
c:put(46, 52, BOOT[5]) c:put(47, 52, BOOT[5])

-- tunic: leaning forward, flared hem
local tun = T.oval(33.5, 40, 6.2, 7.8, 0.32):add(c:poly{ { 27, 44 }, { 39, 44 }, { 41, 48 }, { 27, 48 } })
local tp = part("tunic", tun, TUNIC, 3)
contact(parts.bleg, tun, 0, 1)
-- belt + brass buckle
local belt = HP.mask()
tun:each(function(x, y) local yy = 44 - floor((x - 27) * 0.18 + .5) if y == yy or y == yy + 1 then belt:set(x, y) end end)
belt:each(function(x, y) c:put(x, y, (y == 44 - floor((x - 27) * 0.18 + .5)) and PANTS[3] or PANTS[1]) end)
T.map(c, { "ggg", "gdg", "ggd" }, 35, 41, { g = "#f5b82e", d = "#8f4a1f" }, tk("buckle"))
c:put(35, 41, "#ffe38a")
-- hem fold lines
for _, x in ipairs{ 30, 34 } do c:put(x, 47, TUNIC[1]) c:put(x, 46, TUNIC[2]) end

-- head
local head = c:ellipse(39, 25, 6, 6)
local hp = part("head", head, SKIN, 3)
-- ear
local ear = c:ellipse(34, 26, 1.5, 2)
part("ear", ear, { SKIN[1], SKIN[2], SKIN[3], SKIN[4] }, 1)
c:put(34, 26, SKIN[1])
-- beard streaming back from the chin
local beard = c:poly{ { 34, 26 }, { 37, 29 }, { 44, 29 }, { 45, 33 }, { 41, 38 }, { 34, 40 }, { 28, 39 }, { 23, 36 }, { 29, 33 }, { 32, 30 } }
local bp = part("beard", beard, BEARD, 2.5)
-- flowing strands (darker lines following the wind)
for _, s in ipairs{ { 43, 32, 31, 38 }, { 40, 36, 27, 37 }, { 37, 31, 29, 35 } } do
  local nn = max(abs(s[3] - s[1]), abs(s[4] - s[2]))
  for i = 0, nn do local x, y = floor(s[1] + (s[3] - s[1]) * i / nn + .5), floor(s[2] + (s[4] - s[2]) * i / nn + .5)
    if beard:has(x, y) and i % 4 ~= 3 then T.step(c, bp.idx, BEARD, x, y, -1, bp.tok) end end
end
contact(tp, beard, 0, 1) contact(hp, beard, 0, -1)

-- moustache sweeping back over the beard top
local mou = c:poly{ { 41, 29 }, { 46, 29 }, { 45, 31 }, { 40, 32 }, { 36, 31 } }
local mp = part("mous", mou, BEARD, 1.5)
-- nose: round, warmer than the face, lit tip, dark underside row and nostril
local nose = c:ellipse(45.5, 27.5, 2.6, 2.2)
part("nose", nose, NOSE, 2)
c:put(44, 26, NOSE[5]) c:put(45, 26, NOSE[5])
for x = 44, 47 do if nose:has(x, 29) then c:put(x, 29, NOSE[1]) end end
c:put(44, 28, NOSE[2])
-- eye + brow
c:eyeSmall(41, 21)
c:cheek(40, 25)

-- hat: tall felt cone swept back by the wind
local hatP = { { 39, 18 }, { 37, 12 }, { 30, 8 }, { 20, 11 } }
local hm, hn, HT, HS = T.tube(hatP, function(t) return 7.6 * (1 - t) ^ 0.9 + 0.9 end)
hm:each(function(x, y) if y > 19 then hm.s[K(x, y)] = nil end end)
local hb = {}
-- fold crease where the cone bends: a dark valley with a lit ridge after it
hm:each(function(x, y) local k = K(x, y) if HT[k] and HT[k] > 0.46 and HT[k] < 0.52 and HS[k] > -0.7 then hb[k] = -2 end
  if HT[k] and HT[k] >= 0.52 and HT[k] < 0.57 and HS[k] < 0.2 then hb[k] = 1 end end)
local htok = tk("hat")
local hidx = T.shade(c, hm, hn, HAT, { amb = 0.05, wrap = 0.2, bias = hb, tok = htok })
-- rolled brim band across the brow
local brim = T.rell(39.5, 18.5, 0.995, -0.1, 8.4, 2.0)
local brp = part("brim", brim, HAT, 1.5, { amb = 0.04 })
contact(hp, brim, 0, 1)
-- felt texture flecks
hm:each(function(x, y) local k = K(x, y) if hidx[k] and hidx[k] >= 3 and X.hash(x, y, 21) > 0.93 then T.step(c, hidx, HAT, x, y, -1, htok) end end)
-- hat specular
c:put(32, 10, HAT[6]) c:put(33, 10, HAT[6]) c:put(34, 11, HAT[6])

-- front arm: swinging forward, bent up at the elbow, fist forward
local fArm = c:line({ { 36, 35 }, { 41, 40 }, { 46, 36 } }, 4)
local fap = part("farm", fArm, TUNIC, 1.5)
contact(tp, fArm, 1, 1) contact(bp, fArm, 1, 1)
-- cuff + fist
for _, p in ipairs{ { 45, 35 }, { 46, 36 }, { 45, 36 }, { 44, 37 }, { 46, 34 } } do if fArm:has(p[1], p[2]) then c:put(p[1], p[2], TUNIC[2]) end end
local fist = c:ellipse(48, 34.5, 2.6, 2.6)
part("fist", fist, SKIN, 1.5)
c:put(48, 36, SKIN[2]) c:put(49, 35, SKIN[2])

-- quirk: a bead of sweat flicking off the brow
T.map(c, {
  ".h.",
  "hsb",
  "sbd",
  ".d.",
}, 49, 12, { h = "#e4f6ff", s = "#8bd6ee", b = "#4fa6d2", d = "#3a7cb4" }, tk("sweat"))
c:put(48, 16, "#b6f0e0")
T.save(c, "ico-activity", "ico")
