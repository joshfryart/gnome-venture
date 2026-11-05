-- raccoon-pelt (lean P1b_O7)
-- A raccoon skin spread flat like a rug: grey-silver fur (6 tones, streaked), black bandit mask with pale brow,
-- cream muzzle, ringed bushy tail, splayed paws with dark mitts, pinned-flat leather edge. quirk: notched left ear.
local NAME = "raccoon-pelt"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local FUR  = { "#3c3648", "#5e5868", "#827c8e", "#a6a2b0", "#c8c6d0", "#e8e6ee" }
local DARK = { "#16121c", "#28222e", "#3c3644", "#585264" }
local CREAM = { "#9c9088", "#c4baac", "#e4dcd0", "#f8f2e6" }
local function limb(ax, ay, cx, cy, bx, by, w0, w1)
  return G.blade(ax, ay, cx, cy, bx, by, function(t) return w0 + (w1 - w0) * t end)
end
local pelt = HP.mask()
pelt:add(c:ellipse(32, 31, 11, 13))
pelt:add(c:ellipse(32, 15, 10, 7)):add(c:ellipse(32, 19, 6, 4))
pelt:add(c:ellipse(23, 8, 3, 3)):add(c:ellipse(41, 8, 3, 3))
local legs = {
  { 25, 24, 17, 24, 12, 30, 4.2, 3.4 }, { 39, 24, 47, 24, 52, 30, 4.2, 3.4 },
  { 26, 40, 19, 43, 15, 50, 4.6, 3.6 }, { 38, 40, 45, 43, 49, 50, 4.6, 3.6 } }
local mitts = HP.mask()
for _, l in ipairs(legs) do
  local m = limb(table.unpack(l))
  pelt:add(m)
  mitts:add(c:ellipse(l[5], l[6], 3.6, 3.2))
end
pelt:add(mitts)
-- tail
local tm, tn, T = G.tube({ { 32, 40 }, { 38, 48 }, { 25, 53 }, { 33, 57 } }, function(t) return 4.2 - 1.6 * t end)
pelt:add(tm)
-- notch in left ear
local notch = HP.mask() notch:set(21, 6) notch:set(22, 5) notch:set(22, 6) notch:set(21, 5)
pelt:cut(notch)
-- body shading: pillow over whole pelt, streaky fur
local n = X.pillow(pelt, 9, 0.8)
local v = X.light(n, { amb = 0.3, wrap = 0.5 })
local bias = {}
pelt:each(function(x, y)
  local k = K(x, y)
  local h = X.hash(x, floor(y / 2), 4)
  if h > 0.8 then bias[k] = 1 elseif h < 0.2 then bias[k] = -1 end
  if pelt:has(x + 1, y + 1) == false or pelt:has(x - 1, y - 1) == false then bias[k] = (bias[k] or 0) - 1 end
end)
X.tone(c, pelt, v, FUR, { cuts = { 0.3, 0.48, 0.64, 0.78, 0.9 }, bias = bias })
-- dark mitts
mitts:each(function(x, y) local k = K(x, y) c:put(x, y, (v[k] or 0) > 0.6 and DARK[3] or ((v[k] or 0) > 0.4 and DARK[2] or DARK[1])) end)
for _, l in ipairs(legs) do
  for i = -1, 1 do c:px(l[5] + i * 2, l[6] + 3, CREAM[3]) end
end
-- tail rings
tm:each(function(x, y)
  local k = K(x, y)
  local t = T[k]
  local ring = floor(t * 7)
  local val = v[k] or 0.5
  if t > 0.88 then c:put(x, y, val > 0.5 and DARK[2] or DARK[1])
  elseif ring % 2 == 1 then c:put(x, y, val > 0.6 and DARK[4] or (val > 0.35 and DARK[3] or DARK[2])) end
end)
-- face: bandit mask, brow, muzzle, nose, eyes, ears
c:fillMask(c:rect(24, 12, 40, 16), DARK[2])
c:fillMask(c:rect(25, 11, 39, 11), DARK[3])
for _, p in ipairs{ {24,12},{40,12},{24,16},{40,16} } do c:px(p[1], p[2], FUR[3]) end
c:fillMask(c:rect(26, 9, 30, 10), CREAM[3]) c:fillMask(c:rect(34, 9, 38, 10), CREAM[3])
c:fillMask(c:rect(28, 17, 36, 21), CREAM[3])
c:fillMask(c:rect(29, 21, 35, 22), CREAM[2])
c:fillMask(c:rect(31, 18, 33, 19), DARK[1]) c:px(32, 20, DARK[1])
for _, p in ipairs{ {28,13},{29,13},{35,13},{36,13} } do c:px(p[1], p[2], "#f4d048") end
c:px(28, 14, DARK[1]) c:px(36, 14, DARK[1]) c:px(29, 14, DARK[1]) c:px(35, 14, DARK[1])
c:fillMask(c:ellipse(23, 8, 1, 1), DARK[2]) c:fillMask(c:ellipse(41, 8, 1, 1), DARK[2])
c:px(23, 8, CREAM[2]) c:px(41, 8, CREAM[2])
-- shoulder highlight
for _, p in ipairs{ {28,26},{29,27},{27,28},{30,25},{26,31} } do c:px(p[1], p[2], FUR[6]) end
-- belly seam stitches
for y = 28, 42, 3 do c:px(32, y, "#c04844") c:px(32, y + 1, "#8a2e34") end
G.save(c, NAME)
