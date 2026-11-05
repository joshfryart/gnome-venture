-- reindeer-lichen (lean P1b_O7)
-- A bushy cushion of pale grey-green reindeer lichen: thick forked antler-like branches (6 tones, lit upper-left,
-- dark inside), sitting on a mossy dark-earth mound with pebbles. quirk: a few tips carry tiny red spore caps.
local NAME = "reindeer-lichen"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local LICH = { "#3c5650", "#5c7c6c", "#82a48c", "#a8c8a8", "#cce4c4", "#f0f8e4" }
local DIRT = { "#22141a", "#3c2424", "#5a3a2c", "#7e5636" }
local MOSS = { "#1e4a32", "#2e6c3c", "#4c9444", "#7cbc54" }
local RED  = { "#7a1c2c", "#c0343c", "#f0645c" }
-- mound
local mound = c:ellipse(32, 52, 21, 6)
local mn = X.pillow(mound, 5, 0.9)
G.toneN(c, mound, mn, DIRT, { amb = 0.2, wrap = 0.4, cuts = { 0.3, 0.55, 0.8 } })
mound:each(function(x, y) if y < 50 and X.hash(x, y, 2) > 0.45 then c:px(x, y, MOSS[2 + floor(X.hash(x, y, 5) * 2.9)]) end end)
for _, p in ipairs{ {16,54,2},{47,55,2} } do c:fillMask(c:ellipse(p[1], p[2], 2, 1), "#8a8aa0") c:px(p[1] - 1, p[2] - 1, "#c8c8d8") end
-- lichen: recursive thick forks
local lich, dep = HP.mask(), {}
local tips = {}
local function branch(x, y, a, len, d, seed)
  local x2, y2 = x + cos(a) * len, y + sin(a) * len
  local w = (d <= 1) and 3 or ((d == 2) and 2 or 2)
  local m = c:line({ { floor(x + 0.5), floor(y + 0.5) }, { floor(x2 + 0.5), floor(y2 + 0.5) } }, (d >= 3) and 1 or 2)
  m:each(function(px, py) lich:set(px, py) dep[K(px, py)] = d end)
  if d >= 4 then tips[#tips + 1] = { floor(x2 + 0.5), floor(y2 + 0.5) } return end
  local nb = (d == 0) and 3 or 2
  for i = 1, nb do
    local spread = 0.55 + 0.25 * X.hash(seed, i, d)
    local da = (i - (nb + 1) / 2) * spread + (X.hash(seed, d, i + 3) - 0.5) * 0.35
    branch(x2, y2, a + da, len * (0.68 + 0.1 * X.hash(seed + 1, i, d)), d + 1, seed * 3 + i)
  end
  if d >= 1 and d <= 2 then   -- short side twig
    local sa = a + ((X.hash(seed, d, 9) > 0.5) and 1 or -1) * 1.1
    local tx, ty = x + (x2 - x) * 0.55, y + (y2 - y) * 0.55
    local tm = c:line({ { floor(tx + 0.5), floor(ty + 0.5) }, { floor(tx + cos(sa) * 3.5 + 0.5), floor(ty + sin(sa) * 3.5 + 0.5) } }, 1)
    tm:each(function(px, py) if not lich:has(px, py) then lich:set(px, py) dep[K(px, py)] = 4 end end)
  end
end
for i, ang in ipairs{ -2.35, -1.95, -1.57, -1.2, -0.8 } do
  branch(32 + (i - 3) * 2.5, 50, ang, 11 - abs(i - 3) * 1.3, 0, i * 7 + 1)
end
-- thicken trunk base
lich:add(c:rect(28, 46, 36, 49)):add(c:rect(30, 43, 34, 46))
lich:cut(mound:copy():cut(c:rect(0, 0, 63, 49)))
local pn = X.pillow(lich, 2.2)
local v = X.light(pn, { amb = 0.15, wrap = 0.3 })
local bias = {}
lich:each(function(x, y)
  local k = K(x, y)
  local h = (50 - y) / 40
  bias[k] = (h > 0.55 and 1 or 0) + ((x + y) % 2 == 0 and X.hash(x, y, 6) > 0.7 and 1 or 0) - ((y > 44) and 1 or 0)
  if lich:has(x + 1, y) and lich:has(x - 1, y) and lich:has(x, y + 1) and lich:has(x, y - 1) then bias[k] = bias[k] - 1 end
  if (dep[k] or 0) >= 4 and (x - y) % 3 == 0 then bias[k] = bias[k] + 1 end
end)
X.tone(c, lich, v, LICH, { cuts = { 0.25, 0.42, 0.58, 0.74, 0.88 }, bias = bias })
-- lit-edge sparks
lich:each(function(x, y) if not lich:has(x - 1, y - 1) and X.hash(x, y, 12) > 0.55 and y < 44 then c:px(x, y, LICH[6]) end end)
-- red spore caps (quirk)
for _, i in ipairs{ 2, 7, 12 } do
  local t = tips[min(#tips, i * 2 + 1)]
  if t then
    c:fillMask(c:ellipse(t[1], t[2] - 1, 1, 1), RED[2]) c:px(t[1] - 1, t[2] - 2, RED[3]) c:px(t[1] + 1, t[2], RED[1])
  end
end
G.save(c, NAME)
