-- raccoon-pelt (lean E2_05)
local NAME = "raccoon-pelt"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function P(x, y, col) c:put(x, y, col) end
local function RC(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function dome(m, ramp, R, name, o) local n = X.pillow(m, R) local t = { tok = { r = { name = name } }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 } if o then for k, v in pairs(o) do t[k] = v end end G.toneN(c, m, n, ramp, t) return n end
local W = { "#4e4e78", "#7c7ca4", "#aeaecb", "#d4d4e6", "#ecebf4", "#fbfaff" }
local D = { "#3a2418", "#5e3a22", "#8a5a30", "#ae7a40", "#cf9c58", "#e8c07c" }
local FR = { "#2a2838", "#4a4a5e", "#74768a", "#9ea0b2", "#c4c6d2", "#e6e6ee" }
local DK = { "#18141e", "#2a2230", "#443c4e" }
c:groundShadow(32, 56, 24, 3)
-- tail (ringed), curling out lower-right
local tm, tn, TT = G.tube({ { 38, 48 }, { 50, 60 }, { 60, 50 }, { 54, 36 } }, function(t) return 3.6 + 1.6 * sin(pi * min(1, t * 0.9)) ^ 0.6 - (t > 0.9 and 2 or 0) end)
local tv = X.light(tn, { amb = 0.1, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y)
  local ring = floor(TT[k] * 8)
  local dark = (ring % 2 == 1) or TT[k] > 0.92
  local lv = tv[k]
  local i = lv > 0.7 and 3 or lv > 0.4 and 2 or 1
  if dark then P(x, y, DK[i]) else P(x, y, FR[min(6, i + 2 + (lv > 0.8 and 1 or 0))]) end
end)
-- body (pelt laid flat, legs splayed)
local pelt = HP.mask()
pelt:add(c:poly{ { 22, 20 }, { 42, 20 }, { 47, 34 }, { 43, 48 }, { 21, 48 }, { 17, 34 } })
pelt:add(c:poly{ { 20, 22 }, { 8, 24 }, { 5, 31 }, { 12, 33 }, { 19, 31 } })
pelt:add(c:poly{ { 44, 22 }, { 56, 24 }, { 59, 31 }, { 52, 33 }, { 45, 31 } })
pelt:add(c:poly{ { 20, 42 }, { 10, 48 }, { 8, 55 }, { 16, 55 }, { 24, 49 } })
pelt:add(c:poly{ { 42, 42 }, { 50, 46 }, { 56, 52 }, { 48, 55 }, { 40, 49 } })
pelt:add(c:ellipse(32, 17, 9, 8))
pelt:add(c:ellipse(24, 10, 3, 3)) pelt:add(c:ellipse(40, 10, 3, 3))
local pn = X.pillow(pelt, 7)
local pv = X.light(pn, { amb = 0.3, wrap = 0.5 })
pelt:each(function(x, y)
  local lv = pv[K(x, y)]
  local i = lv > 0.82 and 5 or lv > 0.66 and 4 or lv > 0.5 and 3 or lv > 0.3 and 2 or 1
  local h = X.hash(x, y, 8)
  if h > 0.88 then i = min(6, i + 1) elseif h < 0.1 then i = max(1, i - 1) end
  if ((x + y * 2) % 7 == 0) and h > 0.4 then i = max(1, i - 1) end
  P(x, y, FR[i])
end)
-- inner ears
for _, e in ipairs{ { 24, 10 }, { 40, 10 } } do RC(e[1] - 1, e[2], e[1] + 1, e[2] + 1, "#a87888") P(e[1], e[2], "#d4a0a8") end
-- face mask
RC(23, 13, 41, 18, DK[2])
for x = 23, 41 do P(x, 13, DK[3]) P(x, 18, DK[1]) end
for _, x in ipairs{ 23, 41 } do P(x, 13, FR[3]) P(x, 18, FR[2]) end
P(28, 15, "#f4d060") P(29, 15, "#101018") P(36, 15, "#f4d060") P(35, 15, "#101018") P(28, 14, FR[6]) P(36, 14, FR[6])
-- white brow dashes
RC(27, 12, 30, 12, FR[6]) RC(34, 12, 37, 12, FR[6])
-- muzzle
RC(29, 19, 35, 23, FR[6]) RC(30, 24, 34, 24, FR[5]) RC(29, 23, 35, 23, FR[5])
RC(31, 20, 33, 21, DK[1]) P(32, 22, DK[2])
P(28, 20, FR[4]) P(36, 20, FR[4])
-- paw claws
for _, p in ipairs{ { 4, 30 }, { 6, 33 }, { 60, 30 }, { 58, 33 }, { 9, 56 }, { 14, 56 }, { 49, 56 }, { 54, 54 } } do P(p[1], p[2], DK[2]) end
-- stitches (quirk: patched belly)
for y = 30, 44, 3 do RC(31, y, 33, y, "#d8483c") P(32, y - 1, "#d8483c") P(32, y + 1, "#d8483c") end
RC(32, 29, 32, 45, DK[3])
for y = 30, 44, 3 do RC(31, y, 33, y, "#e86a50") P(32, y, "#ffb090") end
G.save(c, NAME)
