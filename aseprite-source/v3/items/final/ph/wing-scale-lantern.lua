-- wing-scale-lantern (lean P1b_O19)
local NAME = "wing-scale-lantern"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, n, ramp, o) return G.toneN(c, m, n, ramp, o) end
local function ball(cx, cy, rx, ry, ang, ramp, o) local m, n = G.oval(cx, cy, rx, ry, ang, o and o.flat) tone(m, n, ramp, o) return m, n end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, vein)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) return w * sin(pi * min(1, t)) ^ 0.7 + 0.3 end)
  tone(m, n, ramp)
  if vein then m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.17 and T[k] > 0.08 and T[k] < 0.92 then c:put(x, y, vein) end end) end
  return m
end
local function tube(p, w, ramp) local m, n = G.tube(p, function(t) return type(w) == "function" and w(t) or w end) tone(m, n, ramp) return m end
local function cylrect(x0, y0, x1, y1, ramp)
  local m, n = HP.mask(), {}
  local hw, cx = (x1 - x0 + 1) / 2, (x0 + x1) / 2
  for y = y0, y1 do for x = x0, x1 do m:set(x, y) local nx = max(-0.95, min(0.95, (x - cx) / (hw + 0.3))) n[K(x, y)] = { G.norm(nx, 0, sqrt(1 - nx * nx)) } end end
  tone(m, n, ramp) return m
end

-- wing scale lantern: brass lantern whose panes are monarch-style butterfly wing, glowing from within, antenna finial
local BR = { "#3b2410", "#6a421a", "#9a6a26", "#c99436", "#ecc258", "#fff0a0" }
local OR = { "#5a1c10", "#a63a14", "#e0641c", "#f59a2a", "#ffc84a", "#fff0a0" }
local DK = "#2a1418"
-- handle
tube({ {24, 14}, {24, 4}, {40, 4}, {40, 14} }, 1.3, BR)
-- antennae finial
tube({ {32, 12}, {31, 7}, {28, 5}, {26, 7} }, 0.55, BR)
tube({ {32, 12}, {33, 7}, {36, 5}, {38, 7} }, 0.55, BR)
ball(26, 8, 1.4, 1.4, 0, BR) ball(38, 8, 1.4, 1.4, 0, BR)
-- roof
local roof = c:poly{ {32, 12}, {47, 23}, {17, 23} }
tone(roof, X.pillow(roof, 5), BR)
c:fillMask(c:rect(17, 23, 47, 24), BR[1])
-- panes (wing)
local pane = c:rect(21, 25, 43, 47)
pane:each(function(x, y)
  local dx, dy = (x - 32) / 11.5, (y - 36) / 12.5
  local d = sqrt(dx * dx + dy * dy) + (X.hash(x, y, 3) - 0.5) * 0.18
  local i = d < 0.3 and 6 or d < 0.5 and 5 or d < 0.72 and 4 or d < 0.95 and 3 or d < 1.2 and 2 or 1
  c:put(x, y, OR[i])
end)
-- wing veins fanning from lower centre
local function vein(x0, y0, x1, y1)
  local steps = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, steps do c:put(floor(x0 + (x1 - x0) * i / steps + 0.5), floor(y0 + (y1 - y0) * i / steps + 0.5), DK) end
end
vein(32, 47, 32, 26) vein(32, 47, 24, 27) vein(32, 47, 40, 27) vein(32, 47, 22, 36) vein(32, 47, 42, 36)
-- dark margin with pale spots
for y = 25, 47 do for x = 21, 43 do
  if x <= 23 or x >= 41 or y >= 45 then c:put(x, y, DK) end
end end
for y = 28, 44, 4 do c:px(22, y, "#fff0d0") c:px(42, y, "#fff0d0") end
for x = 25, 40, 4 do c:px(x, 46, "#fff0d0") end
-- frame posts and bands
for _, x in ipairs{ 19, 20 } do for y = 25, 47 do c:put(x, y, x == 19 and BR[5] or BR[3]) end end
for _, x in ipairs{ 44, 45 } do for y = 25, 47 do c:put(x, y, x == 44 and BR[3] or BR[1]) end end
for x = 19, 45 do c:put(x, 25, BR[1]) c:put(x, 26, BR[2]) end
-- base
local base = c:rrect(16, 48, 48, 54, 2)
tone(base, X.pillow(base, 4), BR)
ball(32, 57, 2.6, 2.4, 0, BR)
c:px(31, 56, BR[6])

G.save(c, NAME)
