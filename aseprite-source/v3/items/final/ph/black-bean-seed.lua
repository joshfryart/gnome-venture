-- black-bean-seed: glossy black kidney beans on a heart-shaped leaf scrap; the sprout has a hooked stem, two fat split seed-halves and a pair of heart-shaped primary leaves. quirk: one bean has split and a white root is poking out.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("black-bean-seed")
local BK = { "#120d16", "#1d1523", "#2c2030", "#3e2f44", "#58475e", "#7c6a82" }
D.scrap(4, 56, 58, 50, 8, D.GRN, {})
local function bean(cx, cy, a)
  c:fillMask(D.ell(cx + 1, cy + 1.4, 6, 3.8, a), "#1f4a3a")
  local m = D.ell(cx, cy, 5.8, 3.6, a)
  D.lit(m, BK, 3, { wrap = .3 })
  c:px(floor(cx - 3), floor(cy - 2), "#e6e0f0") c:px(floor(cx - 2), floor(cy - 2), BK[6])
  c:px(floor(cx + 1), floor(cy + 1), "#f4efe6") c:px(floor(cx + 2), floor(cy + 1), "#c8c0b8")
end
-- sprout
D.ln(39, 45, 39, 30, "#e2f2bc") D.ln(40, 45, 40, 30, "#b8dc92")
for _, p in ipairs{ {39,29}, {40,28}, {41,28} } do c:px(p[1], p[2], "#e2f2bc") end
-- heart leaves
local function heart(cx, cy, a)
  local m = D.ell(cx - 2 * cos(a), cy - 2 * sin(a), 3.2, 3.2, 0):add(D.ell(cx + 2 * cos(a), cy + 2 * sin(a), 3.2, 3.2, 0)):add(D.ell(cx, cy + 3, 3, 3, 0))
  return m
end
local l1 = D.ell(32, 20, 7, 4.2, -.4) l1:add(D.ell(28, 23, 3, 3, 0)) l1:add(D.ell(30, 17, 3, 3, 0))
D.lit(l1, D.LEAF2, 3) D.ln(38, 28, 27, 17, "#c8e898")
local l2 = D.ell(48, 19, 7, 4.2, .4) l2:add(D.ell(51, 22, 3, 3, 0)) l2:add(D.ell(50, 16, 3, 3, 0))
D.lit(l2, D.LEAF2, 3) D.ln(41, 28, 52, 17, "#c8e898")
-- seed halves at the base of the sprout
D.lit(D.ell(36, 46, 3.2, 3.6, .3), BK, 2) D.lit(D.ell(43, 46, 3.2, 3.6, -.3), BK, 2)
bean(14, 51, .25) bean(27, 53, -.15)
-- split bean with root
bean(41, 51, .05) c:paint({ "xxxxx" }, 38, 50, { x = "#2c2030" })
for _, p in ipairs{ {46,50}, {48,51}, {49,53}, {48,55} } do c:px(p[1], p[2], "#fff4d6") c:px(p[1], p[2] + 1, "#e6dfc8") end
D.fin()
