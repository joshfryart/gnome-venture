-- nav-tasks (lean P1b_O5)
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
local PAP  = { "#8c8aa6", "#b7b4c6", "#dcd8de", "#f2eee6", "#fffaf0", "#fffef4" }
local STEEL= { "#3c4660", "#5c6a88", "#8696b0", "#b4c2d4", "#dce8f2", "#fffef4" }
local GRN  = { "#1c5a34", "#2c8a46", "#4cbc5c", "#8ae070" }
local PEN  = { "#a83a12", "#d86a1c", "#f09a30", "#ffd060" }
c:groundShadow(32, 57, 15, 2)
local board = c:rrect(16, 9, 47, 56, 3)
solid(board, WOOD, 18)
for y = 12, 54, 3 do for x = 18, 45 do if board:has(x, y) and X.hash(x, y, 8) > 0.55 then c:px(x, y, WOOD[2]) end end end
local paper = c:rect(20, 16, 43, 52)
solid(paper, PAP, 14, { amb = 0.3, wrap = 0.5 })
c:fillMask(c:rect(43, 17, 43, 52), PAP[1])
c:fillMask(c:rect(21, 52, 43, 52), PAP[1])
-- rows: checkbox + line
local ys = { 22, 30, 38, 46 }
for i, y in ipairs(ys) do
  c:fillMask(c:rect(22, y, 27, y + 5), PAP[6])
  gline(c, {{22,y},{27,y},{27,y+5},{22,y+5},{22,y}}, STEEL[2])
  c:fillMask(c:rect(30, y + 1, 40 - (i % 2) * 4, y + 2), STEEL[1])
  c:fillMask(c:rect(30, y + 4, 36 + (i % 3) * 2, y + 4), STEEL[3])
  if i < 4 then
    gline(c, {{23,y+3},{24,y+4},{27,y-1}}, GRN[2])
    c:px(24, y + 3, GRN[3]) c:px(26, y, GRN[4]) c:px(23, y+3, GRN[4])
  end
end
-- clip
local clip = c:rrect(25, 5, 38, 14, 2)
solid(clip, STEEL, 8)
c:fillMask(c:rect(28, 9, 35, 10), STEEL[1])
c:px(27, 7, STEEL[6]) c:px(28, 7, STEEL[6]) c:px(26, 8, STEEL[5])
-- pencil tucked at right (quirk), diagonal
gline(c, {{51,22},{51,50}}, PEN[2], 3)
c:fillMask(c:rect(50, 22, 50, 50), PEN[3]) c:fillMask(c:rect(52, 22, 52, 50), PEN[1]) c:px(50, 24, PEN[4])
c:fillMask(c:rect(50, 20, 52, 21), STEEL[3]) c:fillMask(c:rect(50, 20, 50, 21), STEEL[5]) c:fillMask(c:rect(52, 20, 52, 21), STEEL[1])
c:fillMask(c:rect(50, 17, 52, 19), "#f09aa0") c:px(50, 17, "#ffd0d4") c:px(52, 19, "#b4586a")
c:px(50, 51, "#f0d8a8") c:px(51, 51, "#f0d8a8") c:px(52, 51, "#c0a070") c:px(51, 52, "#3a2a30")
G.save(c, NAME)
