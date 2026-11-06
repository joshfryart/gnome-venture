-- tahini (lean D2o_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "tahini"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias)
  return n, v
end
local function tub(pts, wfn, ramp, o) o = o or {}
  local m, n, T, S = G.tube(pts, wfn)
  G.tone(c, m, X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.3 }), ramp, o.cuts)
  return m, T, S
end
local TAH = { "#6b4a2a", "#946a3a", "#b98a4e", "#d6a965", "#ecc784", "#f8e2ac" }
local BRASS = { "#4a3a1e", "#7a6230", "#a88a42", "#cfb064", "#ebd488", "#fbf0b8" }
local PAPER = { "#8a7a68", "#b9a88e", "#dccdb0", "#f0e4c8", "#fbf3dc", "#fffaec" }
c:groundShadow(32, 55, 15, 2)
-- jar body (glass full of paste)
local body = c:poly{ {19, 28}, {45, 28}, {46, 33}, {46, 51}, {43, 54}, {21, 54}, {18, 51}, {18, 33} }
sh(body, TAH, 12, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 } })
-- glass rim light left, cool bounce right
for y = 31, 51 do c:px(19, y, "#e8f0e4") c:px(20, y, TAH[5]) c:px(45, y, "#8a7aa0") end
c:px(19, 31, "#fbfdfd") c:px(19, 32, "#fbfdfd") c:px(21, 30, "#fbfdfd")
-- label
local lab = c:rect(24, 37, 40, 49)
sh(lab, PAPER, 6, { amb = 0.3, wrap = 0.5 })
for _, p in ipairs{ {26, 45}, {30, 46}, {34, 45}, {38, 46} } do c:px(p[1], p[2], PAPER[1]) c:px(p[1] + 1, p[2], PAPER[1]) end
c:fillMask(c:rect(26, 47, 38, 47), TAH[2])
-- sesame seed on label: big seed icon
local sd = G.rell(32, 41, 0.8, 0.6, 3.2, 1.8)
c:fillMask(sd, "#7a5230") c:px(31, 40, "#e8d4a0") c:px(32, 40, "#e8d4a0") c:px(34, 42, "#4a3020")
-- lid
local lid = c:rrect(20, 22, 44, 28, 2)
sh(lid, BRASS, 5)
for x = 22, 42, 2 do c:px(x, 26, BRASS[2]) end
c:px(23, 23, BRASS[6]) c:px(24, 23, BRASS[6])
-- poured tahini over lid + drips down the glass
local pool = c:ellipse(34, 22, 8, 2.4):add(c:rect(26, 23, 41, 24))
sh(pool, TAH, 4, { amb = 0.3, wrap = 0.4 })
for _, d in ipairs{ {28, 29, 1}, {35, 33, 1}, {39, 31, 1} } do
  local dm = c:rrect(d[1], 24, d[1] + 1 + d[3], d[2], 1)
  sh(dm, TAH, 2, { amb = 0.35, wrap = 0.4 })
end
c:px(35, 33, TAH[6]) c:px(28, 29, TAH[6])
c:px(31, 20, TAH[6]) c:px(32, 20, TAH[5])
-- sesame seeds sprinkled on the lid pool + stuck on rim (quirk)
for _, p in ipairs{ {30, 21}, {36, 20}, {40, 22}, {26, 24}, {47, 49} } do c:px(p[1], p[2], "#f6ecd0") c:px(p[1] + 1, p[2], "#c9b48a") end
-- falling drop (quirk)
c:fillMask(c:ellipse(49, 38, 1.6, 2.4), TAH[3]) c:px(49, 36, TAH[5]) c:px(48, 38, TAH[6])
G.fin(c, NAME)
