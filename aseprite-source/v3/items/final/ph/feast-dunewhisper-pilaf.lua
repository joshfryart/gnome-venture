-- feast-dunewhisper-pilaf (lean W2_2)
-- Desert pilaf: a tall bell-shaped mound of saffron rice on a round brass tray; raisins, pistachio, carrot flecks.
-- quirk: a cinnamon stick poked in the peak and a lemon wedge resting on the tray rim.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "feast-dunewhisper-pilaf"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, sin, pi, sqrt, max, min = math.floor, math.sin, math.pi, math.sqrt, math.max, math.min
local RICE = { "#8a4f1c", "#b8741f", "#dea23a", "#f2c653", "#fbe08a", "#fff4c0" }
local BRASS = { "#4a2a1c", "#7a4426", "#a8602e", "#cf8440", "#ebaa5c", "#fbd08a" }
local CINN = { "#3a1c14", "#5e2e1c", "#8a4a28", "#b06a38", "#d08a4c", "#e8aa6c" }
local LEM = { "#a8841a", "#d2aa22", "#efcb3a", "#f9e164", "#fdf0a0", "#fffad0" }

c:groundShadow(32, 54, 24, 3)
-- tray foot + tray + inner dish
local m, n = G.oval(32, 50, 17, 4, 0, 1) G.toneN(c, m, n, BRASS, {})
m, n = G.oval(32, 45, 25, 9, 0, 3)
local bias = {}
G.toneN(c, m, n, BRASS, { bias = bias })
local rim = m:copy():shrink(1)
local dm, dn = G.oval(32, 45, 21, 6.6, 0, 3.5)
local dv = X.light(dn, { amb = 0.1, wrap = 0.2 })
local dbias = {}
dm:each(function(x, y) dbias[K(x, y)] = -1.2 + (y - 40) * 0.12 end)
X.tone(c, dm, dv, BRASS, { cuts = { 0.3, 0.5, 0.68, 0.82, 0.93 }, bias = dbias })
-- tray rim glint
for x = 14, 24 do c:px(x, 39 + floor((24 - x) * 0.0), BRASS[6]) end

-- lemon wedge on the right rim
local lm, ln = G.oval(51, 48, 5, 3.2, 0.35, 1)
G.toneN(c, lm, ln, LEM, {})
for x = 48, 54 do c:px(x, 48 + floor((x - 51) * 0.35), LEM[6]) end
c:px(50, 47, LEM[5]) c:px(52, 49, LEM[2])

-- rice mound
local mound = HP.mask()
for y = 15, 46 do
  local t = (y - 15) / 31
  local h = 17 * (t ^ 0.62) + 0.4
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do mound:set(x, y) end
end
mound:add(c:ellipse(32, 45, 17, 4))
local mn = X.pillow(mound, 12)
local mv = X.light(mn, { amb = 0.08, wrap = 0.2 })
local mb = {}
mound:each(function(x, y) if y > 42 then mb[K(x, y)] = -0.6 end end)
X.tone(c, mound, mv, RICE, { cuts = { 0.22, 0.4, 0.58, 0.74, 0.88 }, bias = mb })
-- grains and garnish
local inner = mound:copy():shrink(1)
inner:each(function(x, y)
  local h = X.hash(x, y, 5)
  local k = K(x, y)
  local lit = mv[k] or 0.5
  if h > 0.86 and inner:has(x + 1, y) then
    local col = lit > 0.55 and RICE[6] or RICE[4]
    c:px(x, y, col) c:px(x + 1, y, col)
  elseif h < 0.07 and inner:has(x + 1, y) then
    c:px(x, y, RICE[2]) c:px(x + 1, y, RICE[2])
  end
  local g = X.hash(x, y, 9)
  if g > 0.985 then c:px(x, y, "#5a2a52") c:px(x + 1, y, "#7c3a70") c:px(x, y + 1, "#3e1a3a") elseif g > 0.972 then c:px(x, y, "#78b04a") c:px(x + 1, y, "#4e8a38") elseif g > 0.962 then c:px(x, y, "#ee6a26") c:px(x, y + 1, "#c04a1c") end
end)
-- dune ripple line: a few shaded rows on the mound
for _, r in ipairs{ {27, 21, 25}, {33, 17, 24}, {39, 15, 22} } do
  for x = r[2], r[3] do if mound:has(x, r[1]) then c:px(x, r[1], RICE[2]) end end
end
-- spec
c:px(26, 27, RICE[6]) c:px(27, 27, RICE[6]) c:px(26, 28, RICE[5])

-- cinnamon stick in the peak
local sm, sn = G.tube({ { 33, 24 }, { 36, 18 }, { 40, 13 }, { 46, 8 } }, function(t) return 1.8 - 0.3 * t end)
G.toneN(c, sm, sn, CINN, {})
sm:each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, CINN[2]) end end)
c:px(45, 8, CINN[6]) c:px(46, 7, CINN[1])
G.save(c, NAME)
