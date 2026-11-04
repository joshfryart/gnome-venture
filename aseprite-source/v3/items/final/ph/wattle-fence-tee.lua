-- wattle-fence-tee (lean D3o_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }
local NAME = "wattle-fence-tee"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, ramp, R, amb, bias) local n = X.pillow(m, R or 4); G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local ROD  = { "#4a2e24", "#6e4630", "#936040", "#b98050", "#d9a468", "#f0cc8c" }
local STK  = { "#33261f", "#52392b", "#74503a", "#946a48", "#b58a5c", "#d3ac7c" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 56, 14, 3)
-- woven band: rods run along u, stakes (3 wide, pitch 7) cross them; over/under checker
local function weave(x0, y0, len, wid, tr)
  for u = 0, len - 1 do for v = 0, wid - 1 do
    local si, so = floor(u / 7), u % 7
    local j, ro = floor(v / 3), v % 3
    local onStake = so <= 2
    local stakeOver = (si + j) % 2 == 0
    local col
    if onStake and stakeOver then
      col = STK[({5, 4, 2})[so + 1]]
      if ro == 2 then col = STK[2] end
    else
      local base = ROD[({5, 4, 2})[ro + 1]]
      col = base
      if (j % 2) == 1 then col = ROD[({4, 3, 1})[ro + 1]] end
      -- shadow where a stake passes over next to us
      local nu = so == 3 and (si + j) % 2 == 0
      local pu = so == 6 and ((si + 1 + j) % 2 == 0)
      if onStake then col = ROD[({3, 2, 1})[ro + 1]] end
      if nu or pu then col = ROD[1] end
      if u > 0 and not onStake and X.hash(u, v, 5) > 0.88 then col = ROD[6] end
    end
    local x, y = x0 + u, y0 + v
    if tr then x, y = x0 + v, y0 + u end
    c:px(x, y, col)
  end end
end
weave(26, 28, 26, 12, true)
weave(13, 15, 38, 12, false)
-- rope lashing at the junction
local lash = c:ellipse(32, 27, 7, 5)
tone(lash, { "#5a4630", "#8a6e46", "#b89868", "#d8bc88", "#ecd8a8", "#f8ecc8" }, 4)
for i = -6, 6, 3 do c:px(32 + i, 24, "#5a4630") c:px(32 + i, 30, "#5a4630") c:px(31 + i, 27, "#5a4630") end
c:px(30, 25, "#f8ecc8") c:px(31, 25, "#f8ecc8")
-- loose rope tail
G.line(c, { {35, 31}, {36, 33}, {35, 35} }, "#b89868")
-- quirk: a living willow shoot sprouting from the left end stake
G.line(c, { {13, 15}, {12, 12}, {13, 9} }, "#5b8d5a")
local l1 = c:ellipse(15, 9, 3, 1.5) local l2 = c:ellipse(10, 10, 3, 1.5)
tone(l1, LEAF, 2, 0.15) tone(l2, LEAF, 2, 0.15)
G.fin(c, NAME)
