-- noni (lean P1b_O5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c
local function gline(cc, pts, col, w) cc:fillMask(cc:line(pts, w or 1), col) end
local function solid(m, rp, R, o) local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, rp, o) return n, v end
local function cylN(m, cx, cy, r, horiz) local n = {} m:each(function(x, y) local t = horiz and (y - cy) / r or (x - cx) / r t = max(-0.97, min(0.97, t)) if horiz then n[K(x, y)] = { -0.35, t, sqrt(1 - t*t) } else n[K(x, y)] = { t, -0.35, sqrt(1 - t*t) } end end) return n end
local NAME = "nav-tasks"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local WOOD = { "#4a2a1c", "#6e4126", "#96602f", "#bc8240", "#dba856", "#f2cf80" }
local NAME = "noni"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local FR  = { "#6a7430", "#94a43c", "#bccc58", "#dce47c", "#f2f2a6", "#fffcd8" }
local EYE = { "#4a5228", "#6e7a30" }
local LEAF= { "#12382c", "#1c5a3a", "#2c8048", "#46a458", "#7cc86c", "#b4e48c" }
local BRN = { "#3a2218", "#5e3a22", "#8a5a30" }
c:groundShadow(32, 57, 14, 2)
-- leaves behind/above
local lm, ln = G.blade(32, 20, 20, 6, 10, 14, function(t) return 1.5 + 6 * sin(pi * t) ^ 0.8 end)
G.toneN(c, lm, ln, LEAF)
local lm2, ln2 = G.blade(33, 20, 44, 4, 56, 12, function(t) return 1.5 + 5.5 * sin(pi * t) ^ 0.8 end)
G.toneN(c, lm2, ln2, LEAF)
gline(c, {{31,19},{24,10},{16,9}}, LEAF[1]) gline(c, {{34,19},{43,9},{51,10}}, LEAF[1])
-- fruit: lumpy ovoid, slightly tilted
local fm, fn = G.oval(32, 38, 14.5, 18, 0.12, 0.9)
local bias = {}
-- bumpy eyes: polygon-ish facets of darker rim + light centre
local eyes = {}
for gy = 24, 56, 5 do for gx = 20, 46, 5 do
  local ex = gx + ((gy // 5) % 2) * 2 + floor(X.hash(gx, gy, 2) * 2)
  local ey = gy + floor(X.hash(gx, gy, 7) * 2)
  if fm:has(ex, ey) and fm:has(ex + 3, ey + 2) and fm:has(ex - 2, ey - 2) then eyes[#eyes + 1] = { ex, ey } end
end end
G.toneN(c, fm, fn, FR, { bias = bias })
for _, e in ipairs(eyes) do
  local x, y = e[1], e[2]
  c:px(x, y, EYE[1]) c:px(x + 1, y, EYE[1]) c:px(x + 1, y + 1, EYE[1]) c:px(x + 2, y + 1, EYE[1]) c:px(x, y + 1, EYE[2]) c:px(x + 2, y, EYE[2])
  c:px(x, y - 1, FR[5]) c:px(x - 1, y, FR[4])
end
-- bluish bloom rim lower-right
local rim = fm:edge()
rim:each(function(x, y) if x + y > 82 then c:px(x, y, "#8aa27a") end end)
-- specular
c:px(24, 28, FR[6]) c:px(25, 28, FR[6]) c:px(24, 29, FR[6]) c:px(26, 27, FR[5]) c:px(23, 30, FR[5])
-- calyx scar at bottom (dark star)
c:fillMask(c:rect(31, 54, 33, 55), BRN[2]) c:px(32, 56, BRN[1]) c:px(30, 55, BRN[3]) c:px(34, 54, BRN[3]) c:px(32, 53, BRN[1])
-- stem + crown
c:fillMask(c:rect(31, 17, 33, 21), BRN[3]) c:fillMask(c:rect(33, 17, 33, 21), BRN[1]) c:px(31, 17, "#b88850")
-- quirk: one ripe translucent brown blotch
c:fillMask(c:rect(38, 46, 41, 48), "#8a8a38") c:px(39, 47, "#6a6a2c") c:px(38, 46, "#a4a448")
G.save(c, NAME)
