-- wind-chime (lean E2_18)
local NAME = "wind-chime"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function S(m, ramp, R, nm, amb)
  local n = X.pillow(m, R or 4)
  return X.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, { cuts = { .22, .4, .56, .72, .86 }, tok = { r = { name = nm or "p" } } })
end
local function E(x, y, rx, ry) return c:ellipse(x, y, rx, ry) end
local function P(m, col, nm) m:each(function(x, y) c:put(x, y, col, { r = { name = nm or "d" } }) end) end
local function L(pts, w, col, nm) P(c:line(pts, w), col, nm) end

local MET = { "#1c3f5c", "#2f6a86", "#4f97a8", "#7cc4c4", "#aee6dc", "#e6fff0" }
local WOOD = { "#4a2a20", "#6e4228", "#94603a", "#bc8a50", "#dcb070", "#f2d498" }
-- ring
local ring = E(32, 8, 4, 4) ring:cut(E(32, 8, 2, 2)) S(ring, { "#6a4a10", "#a87a1c", "#d8a82c", "#f2cc50", "#fff0a0", "#fff8c8" }, 1.5, "ring")
L({ {32, 12}, {32, 14} }, 1, "#3a2a20")
S(c:rrect(10, 14, 54, 19, 1), WOOD, 3, "bar")
local tubes = { {15, 41}, {24, 52}, {40, 47}, {49, 37} }
for i, t in ipairs(tubes) do
  L({ {t[1], 19}, {t[1], 22} }, 1, "#3a2a20")
  S(c:rect(t[1] - 2, 22, t[1] + 2, t[2]), MET, 2.5, "tube" .. i)
  P(c:rect(t[1] - 2, 22, t[1] + 2, 23), "#1c3f5c", "cap") c:put(t[1] - 1, 26, MET[6]) c:put(t[1] - 1, 27, MET[6]) c:put(t[1] - 1, 28, MET[5])
end
-- clapper + wooden strike disc + wind sail leaf (quirk: the sail is a leaf)
L({ {32, 19}, {32, 33} }, 1, "#3a2a20")
S(E(32, 36, 5, 3), WOOD, 3, "disc")
L({ {32, 39}, {32, 42} }, 1, "#3a2a20")
local lm, ln = G.blade(32, 42, 27, 48, 33, 56, function(t) return max(0.5, 4 * sin(pi * t) ^ 0.8) end, { fold = 0.4 })
G.toneN(c, lm, ln, { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }, { tok = { r = { name = "sail" } }, amb = 0.1, wrap = 0.2 })
c:sparkle(54, 46)
G.save(c, NAME)
