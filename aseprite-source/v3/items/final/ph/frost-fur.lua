-- frost-fur (lean E2_01)
local NAME = "frost-fur"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, ceil = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.ceil
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function inter(a, b) local r = HP.mask() a:each(function(x, y) if b:has(x, y) then r:set(x, y) end end) return r end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local FUR = { "#4a5a8c", "#7088b8", "#a4bbdc", "#cfe0f2", "#e0f0fa", "#eaf8ff" }
local ICE = { "#2a7ea0", "#5cc0e0", "#9ae8f8", "#dffaff" }
local LEA = { "#3a241c", "#5e3a2a", "#8a5a3a", "#b07c4c" }
local m = HP.mask()
m:add(c:ellipse(32, 28, 18, 12))
local tips = {}
for i = 0, 9 do
  local x = 16 + i * 3.6
  local len = 9 + floor(X.hash(i, 3, 7) * 7)
  local jit = (i - 4.5) * 0.35
  m:add(c:poly{ {x - 2.4, 34}, {x + 2.4, 34}, {x + jit, 38 + len} })
  tips[#tips + 1] = { floor(x + jit), 37 + len }
end
local tok = { r = { name = "fur" } }
local idx = X.tone(c, m, X.light(X.pillow(m, 5), { amb = 0.12, wrap = 0.28 }), FUR, { cuts = CUTS, tok = tok })
m:each(function(x, y) local k = K(x, y)
  local s = X.hash(x, floor(y / 3), 9)
  if s > 0.7 then c:put(x, y, FUR[min(6, idx[k] + 1)], tok) elseif s < 0.22 then c:put(x, y, FUR[max(1, idx[k] - 1)], tok) end
end)
-- icy tips
for i, t in ipairs(tips) do if i % 2 == 1 then
  for dy = 0, 1 do if m:has(t[1], t[2] - dy) then c:put(t[1], t[2] - dy, dy == 0 and ICE[3] or ICE[2], tok) end end
end end
-- frost crystals
local function crystal(cx, cy, w, h, tag)
  local cm = c:poly{ {cx, cy - h}, {cx + w, cy}, {cx, cy + h}, {cx - w, cy} }
  local t = { r = { name = tag } }
  X.tone(c, cm, X.light(X.pillow(cm, 2), { amb = 0.1, wrap = 0.2 }), ICE, { cuts = { 0.3, 0.55, 0.8 }, tok = t })
  c:put(cx - 1, cy - 1, ICE[4], t)
end
crystal(21, 27, 2, 4, "c1") crystal(44, 25, 2, 3, "c2") crystal(40, 36, 2, 3, "c3")
-- snowflake
local st = { r = { name = "flake" } }
for d = -4, 4 do c:put(32 + d, 28, ICE[3], st) c:put(32, 28 + d, ICE[3], st) end
for d = -2, 2 do c:put(32 + d, 28 + d, ICE[4], st) c:put(32 + d, 28 - d, ICE[4], st) end
c:put(32, 28, ICE[4], st)
-- leather strap + loop across the top
local ring = c:ellipse(32, 11, 6, 5)
ring:cut(c:ellipse(32, 11, 3.6, 3))
local ltok = { r = { name = "strap" } }
X.tone(c, ring, X.light(X.pillow(ring, 2), { amb = 0.1, wrap = 0.2 }), LEA, { cuts = { 0.3, 0.55, 0.8 }, tok = ltok })
local band = c:rect(18, 15, 46, 18)
X.tone(c, band, X.light(X.pillow(band, 2), { amb = 0.1, wrap = 0.2 }), LEA, { cuts = { 0.3, 0.55, 0.8 }, tok = ltok })
for _, x in ipairs{ 22, 32, 42 } do c:put(x, 16, LEA[4], ltok) c:put(x, 17, LEA[1], ltok) end
G.save(c, NAME)
