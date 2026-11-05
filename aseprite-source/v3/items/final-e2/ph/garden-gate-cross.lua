-- garden-gate-cross (lean E2_01)
local NAME = "garden-gate-cross"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, ceil = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.ceil
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function inter(a, b) local r = HP.mask() a:each(function(x, y) if b:has(x, y) then r:set(x, y) end end) return r end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local WOOD = { "#2e1c14", "#523222", "#7a4c30", "#a06a40", "#c88d58", "#e8b77c" }
local BRACE = { "#2c2a30", "#4e4a4c", "#7a7268", "#a49884", "#cbbf9e", "#e8dcb8" }
local IRON = { "#2a2630", "#4a4656", "#7a7888", "#a8a8b8", "#d4d4e0" }
local prev = HP.mask()
local function plank(m, ramp, tag, seed)
  local tok = { r = { name = tag } }
  local idx = X.tone(c, m, X.light(X.pillow(m, 2.5), { amb = 0.1, wrap = 0.2 }), ramp, { cuts = CUTS, tok = tok })
  m:each(function(x, y) local k = K(x, y)
    if X.hash(x, floor(y / 6), seed) > 0.84 then c:put(x, y, ramp[max(1, idx[k] - 1)], tok) end
    if prev:has(x - 1, y) or prev:has(x + 1, y) or prev:has(x, y - 1) or prev:has(x, y + 1) then c:put(x, y, ramp[1], tok) end
  end)
  prev:add(m)
end
c:groundShadow(32, 58, 24, 3)
local pl = c:rect(10, 12, 15, 57) pl:add(c:poly{ {10,12}, {12.5,6}, {16,12} })
local pr = c:rect(48, 12, 53, 57) pr:add(c:poly{ {48,12}, {50.5,6}, {54,12} })
plank(pl, WOOD, "postL", 3) plank(pr, WOOD, "postR", 4)
plank(c:rect(16, 19, 47, 23), WOOD, "rail1", 5) plank(c:rect(16, 45, 47, 49), WOOD, "rail2", 6)
local box = c:rect(16, 19, 47, 49)
plank(inter(c:line({ {16,21}, {47,47} }, 3), box), BRACE, "brace1", 7)
plank(inter(c:line({ {16,47}, {47,21} }, 3), box), BRACE, "brace2", 8)
-- iron ring latch at the crossing
local ring = c:ellipse(32, 34, 4.2, 4.2) ring:cut(c:ellipse(32, 34, 2, 2))
local itok = { r = { name = "latch" } }
X.tone(c, ring, X.light(X.pillow(ring, 2), { amb = 0.1, wrap = 0.2 }), IRON, { cuts = { 0.25, 0.5, 0.75, 0.9 }, tok = itok })
c:put(31, 31, IRON[5], itok)
-- vine up the right post with one flower
local vm, vn = G.tube({ {53,56}, {57,46}, {50,36}, {54,24} }, function(t) return 0.9 end)
local vtok = { r = { name = "vine" } }
X.tone(c, vm, X.light(vn, { amb = 0.15, wrap = 0.3 }), { "#1f553f", "#2b7046", "#3f8f4c", "#62ad55" }, { cuts = { 0.3, 0.55, 0.8 }, tok = vtok })
for i, p in ipairs{ {58,44,2.4,1.5}, {49,35,2.4,1.5}, {57,30,2.4,1.5}, {51,45,2.2,1.4} } do
  local lm = c:ellipse(p[1], p[2], p[3], p[4])
  X.tone(c, lm, X.light(X.pillow(lm, 2), { amb = 0.1, wrap = 0.25 }), { "#1f553f", "#3f8f4c", "#62ad55", "#93cb68" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "vl" .. i } } })
end
local ft = { r = { name = "flower" } }
for _, p in ipairs{ {54,21}, {53,22}, {55,22}, {54,23}, {54,20} } do c:put(p[1], p[2], "#f07a9a", ft) end
c:put(54, 22, "#ffd24a", ft) c:put(53, 21, "#ffb0c4", ft)
G.save(c, NAME)
