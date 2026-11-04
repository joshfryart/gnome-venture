-- grilled-sardines (dC10 first draft): a plate of three sardines, the first two grilled with cross marks and bright eyes, the third
-- eaten down to its skeleton. Lemon wedge at the side.
-- quirk: a bare fish skeleton, spine and tail, lies on the plate.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('grilled-sardines')
c:groundShadow(32, 56, 26, 3)
local pm = c:ellipse(32, 40, 28, 16)
B.lit(c, pm, { '#8a8aa0', '#b8b8c8', '#dcdce6', '#eeeef4', '#fff4d6', '#fffaf0' }, 6)
c:fillMask(c:ellipse(32, 39, 22, 11), '#f4efe8')
local FISH = { '#4a5a7a', '#6a7e9a', '#98aac0', '#c0cede', '#e0e8f0', '#fbfdff' }
local function fish(cx, cy, ang)
  local m = B.ell(cx, cy, 11, 3.2, ang)
  B.lit(c, m, FISH, 2.2)
  local ca, sa = cos(ang), sin(ang)
  -- tail
  local tx, ty = cx + ca * 11, cy + sa * 11
  local t = c:poly{ {tx - ca, ty - sa}, {tx + ca * 5 - sa * 4, ty + sa * 5 + ca * 4}, {tx + ca * 5 + sa * 4, ty + sa * 5 - ca * 4} }
  B.lit(c, t, FISH, 1.2)
  -- grill marks
  for u = -6, 5, 4 do for v = -2, 2 do
    local x, y = floor(cx + ca * (u + v) - sa * v + .5), floor(cy + sa * (u + v) + ca * v + .5)
    if m:has(x, y) then c:px(x, y, '#51302b') end end end
  -- eye + gill
  local ex, ey = floor(cx - ca * 8 + .5), floor(cy - sa * 8 - 1 + .5)
  c:px(ex, ey, '#2b1c26') c:px(ex - 1, ey - 1, D.CREAM)
  c:px(floor(cx - ca * 5 + .5), floor(cy - sa * 5 + .5), FISH[2])
end
fish(27, 31, -0.12) fish(28, 39, -0.06)
-- skeleton
local BN = '#fff4d6'
B.ln(c, 15, 47, 40, 47, BN) B.ln(c, 15, 48, 40, 48, '#d9b48e')
for x = 19, 37, 3 do B.ln(c, x, 47, x + 1, 44, BN) B.ln(c, x, 48, x + 1, 51, BN) end
c:px(14, 46, BN) c:px(13, 47, BN) c:px(14, 48, BN) c:px(15, 46, '#2b1c26')
c:px(41, 46, BN) c:px(42, 45, BN) c:px(42, 49, BN) c:px(41, 48, BN) c:px(43, 44, BN) c:px(43, 50, BN)
-- lemon wedge
local lw = c:ellipse(51, 30, 7, 5):clip(c:rect(44, 25, 62, 33)):add(c:rect(46, 27, 56, 31))
local lm = c:poly{ {44, 31}, {58, 31}, {55, 24}, {47, 24} }
B.lit(c, lm, 'gold', 2)
B.ln(c, 46, 29, 55, 29, '#fff4d6') B.ln(c, 48, 26, 51, 31, '#fff4d6')
-- smoke
D.steam(c, 12, 22, 8, '#e2e0e6') D.steam(c, 40, 19, 7, '#e2e0e6')
D.fin()
