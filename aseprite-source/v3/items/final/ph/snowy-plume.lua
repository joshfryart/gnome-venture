-- snowy-plume (lean D2o_2)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "snowy-plume" }
local function shade(m, ramp, R, bias, cuts) local n = X.pillow(m, R) return G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, cuts, bias) end
-- long frosted feather, lavender-white vane with barb grooves, bare tan quill, fluffy down at base; frost glint near tip (quirk)
local VANE = { "#5c5890", "#8a86b8", "#b4b0d8", "#d4d2ee", "#ecebfa", "#fafaff" }
local QUILL = { "#7a5a3a", "#a88050", "#d4ac70", "#f0d498" }
local ax, ay, bx, by = 47, 8, 17, 51
local len = sqrt((bx - ax)^2 + (by - ay)^2)
local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
  if t > 0.985 then return -1 end
  if t < 0.8 then
    local w = 7.4 * sin(pi * (0.07 + 0.6 * t / 0.8)) ^ 0.9
    return max(1, w * (0.9 + 0.1 * sin(t * len * 1.25)))
  end
  return 0.9
end)
local vm = HP.mask()
m:each(function(x, y) if T[K(x, y)] < 0.8 then vm:set(x, y) end end)
G.tone(c, m, X.light(n, { amb = 0.14, wrap = 0.3 }), VANE, { 0.2, 0.38, 0.55, 0.72, 0.88 })
m:each(function(x, y) local k = K(x, y)
  local s, t = S[k], T[k]
  if t >= 0.8 then c:put(x, y, s <= 0 and QUILL[3] or QUILL[2]) return end
  if abs(s) < 0.13 then c:px(x, y, s <= 0 and VANE[6] or VANE[3]) return end
  local d = (t * len - abs(s) * 2.2) % 3.2
  if d < 0.7 and abs(s) < 0.92 then c:px(x, y, s <= 0 and VANE[3] or VANE[2]) end
end)
-- fluffy down tufts at the base
for _, p in ipairs{ {26, 36}, {23, 39}, {28, 40}, {21, 43} } do shade(c:ellipse(p[1], p[2], 2, 1.5), VANE, 1.5) end
for _, p in ipairs{ {25, 35}, {22, 38} } do c:px(p[1], p[2], VANE[6]) end
-- quill tip + dark nib
c:px(bx, by, QUILL[1]) c:px(bx + 1, by - 1, QUILL[1])
-- frost glint near tip
c:sparkle(40, 12) c:px(36, 18, VANE[6]) c:px(33, 25, VANE[6])
G.fin(c, "snowy-plume")
