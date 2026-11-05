-- ginseng (lean P1b_O2)
local NAME = "ginseng"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local drawn = HP.mask()
-- lit(mask, normals, ramp, opts): tone with normals; opts.seam = colour for the border where it overlaps earlier art
local function lit(m, n, ramp, o)
  o = o or {}
  local prior = drawn:copy()
  local _, v = G.toneN(c, m, n, ramp, o)
  if o.seam then m:edge():each(function(x, y) if prior:has(x, y) then c:px(x, y, o.seam) end end) end
  drawn:add(m)
  return v
end
local function pil(m, ramp, R, o) return lit(m, X.pillow(m, R), ramp, o) end
local function hx(x, y, s) return X.hash(x, y, s or 1) end
-- ginseng root-man: ringed pale root body, whiskery legs, one waving arm, palmate five-leaflet crown with red berries
local R = { "#5c3b2a", "#8a6140", "#b88c5a", "#d9b27a", "#efd09a", "#fff0cc" }
local LF = { "#17402e", "#1f5e3a", "#2f8040", "#4da44c", "#7cc660", "#b0e284" }
local BR = { "#4a0e22", "#7a1530", "#b02438", "#d8402f", "#f06a44", "#ffb080" }
local function tube(pts, w, ramp, o) local m, n, T, S = G.tube(pts, w) lit(m, n, ramp, o) return m, T, S end
-- legs (behind), arms, body
tube({ {29, 38}, {25, 46}, {21, 50}, {19, 58} }, function(t) return 3.2 - 2.4 * t end, R, { seam = R[1] })
tube({ {35, 38}, {38, 46}, {45, 49}, {47, 57} }, function(t) return 3.2 - 2.4 * t end, R, { seam = R[1] })
tube({ {27, 30}, {20, 31}, {15, 31}, {9, 28} }, function(t) return 2.6 - 1.8 * t end, R, { seam = R[1] })
tube({ {37, 30}, {44, 29}, {49, 25}, {52, 18} }, function(t) return 2.6 - 1.8 * t end, R, { seam = R[1] })
local bm, bt = tube({ {32, 24}, {32, 30}, {32, 34}, {32, 41} }, function(t) return 6.4 - 1.8 * t + 0.8 * sin(pi * t) end, R, { seam = R[1] })
bm:each(function(x, y)
  local rr = (y + 0.07 * (x - 32) ^ 2) % 3.6
  if rr < 0.9 and y > 26 and y < 40 and hx(x, y, 3) > 0.25 then c:px(x, y, x < 33 and R[3] or R[2]) end
end)
-- whiskers
for _, w in ipairs{ { {19, 57}, {17, 59} }, { {20, 55}, {17, 56} }, { {47, 56}, {50, 58} }, { {46, 53}, {49, 53} }, { {10, 28}, {7, 30} }, { {23, 49}, {20, 47} } } do
  c:fillMask(c:line(w, 1), R[2])
end
-- stem + palmate leaflets
tube({ {32, 25}, {32, 21}, {32, 17}, {32, 14} }, function() return 1.3 end, { "#2f6a3c", "#4d8c4c", "#86b868", "#bde096" }, { seam = LF[1] })
local function leaflet(bx, by, cx, cy, ex, ey, w)
  local m, n, T, S = G.blade(bx, by, cx, cy, ex, ey, function(t) return t > 0.98 and -1 or w * sin(pi * min(1, t * 1.05 + 0.04)) ^ 0.7 end, { fold = 0.6 })
  lit(m, n, LF, { seam = LF[1] })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.13 and T[k] > 0.1 and T[k] < 0.9 then c:px(x, y, S[k] < 0 and LF[6] or LF[3]) end end)
end
leaflet(32, 14, 14, 12, 15, 17, 3.2)
leaflet(32, 14, 50, 12, 49, 17, 3.2)
leaflet(32, 14, 18, 7, 22, 4, 3.6)
leaflet(32, 14, 46, 7, 42, 4, 3.6)
leaflet(32, 14, 32, 8, 32, 3, 3.4)
-- berries
for _, b in ipairs{ {29, 12, 2.6}, {35, 12, 2.6}, {32, 9, 2.8} } do
  local m, n = G.oval(b[1], b[2], b[3], b[3], 0, 1)
  lit(m, n, BR, { seam = BR[1] })
  c:px(floor(b[1] - 1), floor(b[2] - 1), BR[6])
end
G.save(c, NAME)
