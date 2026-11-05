-- nav-villagers (lean P1b_O5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c
local function gline(cc, pts, col, w) cc:fillMask(cc:line(pts, w or 1), col) end
local function solid(m, rp, R, o) local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, rp, o) return n, v end
local function cylN(m, cx, cy, r, horiz) local n = {} m:each(function(x, y) local t = horiz and (y - cy) / r or (x - cx) / r t = max(-0.97, min(0.97, t)) if horiz then n[K(x, y)] = { -0.35, t, sqrt(1 - t*t) } else n[K(x, y)] = { t, -0.35, sqrt(1 - t*t) } end end) return n end
local NAME = "nav-villagers"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local WOOD = { "#3e2418", "#5e3a22", "#8a5a30", "#b27e44", "#d6a45c", "#f0cc88" }
local HAT  = { "#5a0f2a", "#8e1c3a", "#c23048", "#e85a5a", "#ff8e7c", "#ffc8a8" }
local HAT2 = { "#12304a", "#1e5a80", "#2e86b0", "#52b4d2", "#8ae0e6", "#c8f6f0" }
local MOSS = { "#1c4a30", "#2c7440", "#4ca050", "#88c864" }
c:groundShadow(32, 57, 15, 2)
-- post
local post = c:rect(29, 18, 35, 56)
solid(post, WOOD, 6, { amb = 0.15 })
for y = 20, 55, 4 do c:px(31, y, WOOD[2]) c:px(32, y + 1, WOOD[2]) end
-- mossy base
for _, p in ipairs{ {28,55},{29,54},{30,53},{31,54},{35,55},{34,54},{33,55} } do c:px(p[1], p[2], MOSS[2]) end
c:px(29, 55, MOSS[3]) c:px(30, 54, MOSS[4]) c:px(34, 55, MOSS[3])
-- arrow boards
local function board(x0, y0, x1, y1, dir, rp)
  local pts = (dir > 0) and { {x0,y0},{x1-5,y0},{x1,(y0+y1)//2},{x1-5,y1},{x0,y1} } or { {x1,y0},{x0+5,y0},{x0,(y0+y1)//2},{x0+5,y1},{x1,y1} }
  local m = c:poly(pts)
  solid(m, rp, 8, { amb = 0.12 })
  for x = x0 + 2, x1 - 6, 3 do local y = y0 + 1 + floor(X.hash(x, y0, 5) * 3) c:px(x, y, rp[2]) c:px(x + 1, y, rp[2]) end
  return m
end
board(14, 24, 50, 33, 1, WOOD)
board(20, 36, 56, 45, -1, WOOD)
-- paw/boot marks on boards: little 3-px creature prints
for _, p in ipairs{ {22,27},{30,28},{38,27} } do c:px(p[1], p[2], WOOD[1]) c:px(p[1]+1, p[2]-1, WOOD[1]) c:px(p[1]+1, p[2]+1, WOOD[1]) end
for _, p in ipairs{ {44,40},{36,39},{28,40} } do c:px(p[1], p[2], WOOD[1]) c:px(p[1]-1, p[2]-1, WOOD[1]) c:px(p[1]-1, p[2]+1, WOOD[1]) end
-- nails
c:px(32, 28, WOOD[6]) c:px(32, 40, WOOD[6])
-- gnome hat on top (quirk), plus a smaller blue hat peeking out of the base
local hat = c:poly{ {26,19},{32,6},{33,6},{38,19} }
solid(hat, HAT, 5, { amb = 0.1 })
c:fillMask(c:rect(24, 19, 40, 21), HAT[2])
c:fillMask(c:rect(24, 19, 40, 19), HAT[4])
c:fillMask(c:rect(24, 21, 40, 21), HAT[1])
c:px(30, 12, HAT[5]) c:px(30, 13, HAT[4]) c:px(31, 9, HAT[5]) c:px(36, 17, HAT[1])
c:fillMask(c:rect(32, 5, 33, 6), HAT[3]) c:px(32, 5, HAT[6])
local hat2 = c:poly{ {44,56},{47,47},{48,47},{51,56} }
solid(hat2, HAT2, 3, { amb = 0.1 })
c:fillMask(c:rect(42, 55, 53, 56), HAT2[2]) c:fillMask(c:rect(42, 55, 53, 55), HAT2[4])
G.save(c, NAME)
