-- nav-passport (lean P1b_O5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c
local function gline(cc, pts, col, w) cc:fillMask(cc:line(pts, w or 1), col) end
local function solid(m, rp, R, o) local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, rp, o) return n, v end
local function cylN(m, cx, cy, r, horiz) local n = {} m:each(function(x, y) local t = horiz and (y - cy) / r or (x - cx) / r t = max(-0.97, min(0.97, t)) if horiz then n[K(x, y)] = { -0.35, t, sqrt(1 - t*t) } else n[K(x, y)] = { t, -0.35, sqrt(1 - t*t) } end end) return n end
local NAME = "nav-passport"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local NAVY = { "#14223f", "#1e3a68", "#2a5a96", "#3b7ec0", "#62a6dc", "#a4d4f0" }
local PAGE = { "#8a7a8c", "#b7a8a8", "#d9ccc0", "#efe6d4", "#fbf4e2", "#fffbee" }
local GOLD = { "#6b4417", "#a56a1c", "#d49a2a", "#f0c640", "#ffe27a", "#fff6c0" }
local RIB  = { "#6e1a2c", "#a02a3a", "#d4444c", "#f07a72" }
c:groundShadow(34, 56, 17, 2)
local pages = c:rrect(20, 12, 48, 54, 2)
solid(pages, PAGE, 12)
-- page lines at bottom/right edge
for y = 15, 51, 2 do c:px(47, y, PAGE[1]) c:px(46, y, PAGE[2]) end
for x = 23, 45, 2 do c:px(x, 53, PAGE[1]) end
local cover = c:rrect(16, 10, 45, 52, 3)
solid(cover, NAVY, 20)
-- spine strip
c:fillMask(c:rect(17, 12, 20, 50), NAVY[2])
c:fillMask(c:rect(17, 12, 17, 50), NAVY[3])
c:fillMask(c:rect(20, 12, 20, 50), NAVY[1])
for y = 16, 46, 10 do c:fillMask(c:rect(17, y, 20, y + 1), GOLD[3]) c:px(17, y, GOLD[5]) end
-- cloth weave
for y = 13, 50 do for x = 22, 43 do if (x + y) % 4 == 0 and X.hash(x, y, 3) > 0.35 and cover:has(x, y) then c:px(x, y, NAVY[(y < 30) and 4 or 2]) end end end
-- gold frame
local frame = c:rrect(23, 14, 41, 48, 2)
gline(c, {{24,14},{40,14},{41,15},{41,47},{40,48},{24,48},{23,47},{23,15},{24,14}}, GOLD[2])
c:fillMask(c:rect(24, 15, 40, 15), GOLD[4])
-- globe emblem
local gm = c:ellipse(32, 27, 7, 7)
solid(gm, GOLD, 6)
gline(c, {{25,27},{39,27}}, GOLD[1])
gline(c, {{32,20},{32,34}}, GOLD[1])
gline(c, {{28,22},{27,27},{28,32}}, GOLD[1])
gline(c, {{36,22},{37,27},{36,32}}, GOLD[1])
c:px(28, 23, GOLD[6]) c:px(29, 22, GOLD[6]) c:px(28, 24, GOLD[5])
-- title bars
c:fillMask(c:rect(26, 38, 38, 39), GOLD[4]) c:fillMask(c:rect(26, 40, 38, 40), GOLD[2])
c:fillMask(c:rect(28, 43, 36, 43), GOLD[3]) c:fillMask(c:rect(28, 44, 36, 44), GOLD[1])
-- red ribbon bookmark hanging out bottom (quirk)
c:fillMask(c:rect(37, 52, 40, 58), RIB[2]) c:fillMask(c:rect(37, 52, 37, 58), RIB[3]) c:fillMask(c:rect(40, 52, 40, 58), RIB[1])
c:px(38, 58, RIB[2]) c:px(39, 58, RIB[1]) c:px(38, 57, RIB[4])
c:fillMask(c:rect(38, 59, 39, 59), RIB[1])
c:px(37, 52, RIB[4]) 
c:px(18, 13, NAVY[6]) c:px(19, 13, NAVY[5])
G.save(c, NAME)
