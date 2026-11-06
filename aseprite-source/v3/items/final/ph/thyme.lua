-- thyme (lean D3o_2)
-- Woody sprig: gnarled stem, four thin side shoots, pairs of tiny grey-green oval leaves, lilac blossom heads. Quirk: ladybird on a leaf.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "thyme" }
local sqrt, max = math.sqrt, math.max
local LEAF = { "#1f3d3a", "#2d5a49", "#44784f", "#68966a", "#8fb383", "#bcd2a0" }
local WOOD = { "#3a2a2e", "#5a4036", "#7c5b45", "#a07c5a", "#c4a07a", "#dcc39c" }
local FL   = { "#5b3a82", "#7d52a3", "#a276c4", "#c49be0", "#e0c2f2", "#f6e6fb" }
local function blob(m, ramp, R)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp)
end
local branches = {
  { {31,58},{29,46},{34,32},{32,14}, 1.5, 0.6 },
  { {30,46},{24,44},{16,38},{12,28}, 0.9, 0.5 },
  { {31,41},{38,42},{47,36},{51,25}, 0.9, 0.5 },
  { {32,30},{26,28},{22,22},{20,13}, 0.8, 0.5 },
  { {33,25},{39,24},{43,18},{45,10}, 0.8, 0.5 },
}
for _, b in ipairs(branches) do
  local r0, r1 = b[5], b[6]
  local m, n = G.tube({ b[1], b[2], b[3], b[4] }, function(t) return r0 + (r1 - r0) * t end)
  blob(m, WOOD, 1.6)
end
-- small root flare
for _, p in ipairs{ {29,59},{28,60},{33,59},{34,60},{30,60},{32,60} } do c:px(p[1], p[2], WOOD[2]) end
-- leaves
local lad
for bi, b in ipairs(branches) do
  local P = { b[1], b[2], b[3], b[4] }
  local t = (bi == 1) and 0.3 or 0.22
  local k = 0
  while t <= 1.0 do
    local x, y = G.bez(P, t)
    local x2, y2 = G.bez(P, math.min(1, t + 0.02))
    local ux, uy = x2 - x, y2 - y
    local l = sqrt(ux*ux + uy*uy); if l < 1e-6 then ux, uy, l = 0, -1, 1 end
    ux, uy = ux / l, uy / l
    for _, s in ipairs{ -1, 1 } do
      -- leaf axis rotated ~55 deg off stem
      local ca, sa = 0.57, 0.82 * s
      local lx, ly = ux * ca - uy * sa, uy * ca + ux * sa
      local m = G.rell(x + lx * 2.0, y + ly * 2.0, lx, ly, 2.6, 1.5)
      blob(m, LEAF, 1.6)
      if bi == 3 and k == 2 and s == 1 then lad = { x + lx * 2.6, y + ly * 2.6 } end
    end
    k = k + 1
    t = t + 0.15
  end
  local x, y = G.bez(P, 1)
  local tipm = G.rell(x, y - 1, 0, -1, 2.6, 1.4)
  blob(tipm, LEAF, 1.6)
end
-- blossom heads at tips
local function head(cx, cy)
  for _, d in ipairs{ {0,0,4},{-2,1,3},{2,1,3},{0,-2,5},{-1,2,2},{1,-1,6},{3,-1,2},{-3,-1,3} } do
    c:px(cx + d[1], cy + d[2], FL[d[3]])
    c:px(cx + d[1], cy + d[2] + 1, FL[max(1, d[3] - 2)])
  end
  c:px(cx - 1, cy - 1, FL[6])
end
head(32, 11) head(45, 8) head(20, 11)
c:px(51, 23, FL[4]) c:px(52, 23, FL[3]) c:px(51, 24, FL[2]) c:px(12, 26, FL[4]) c:px(11, 26, FL[3]) c:px(12, 27, FL[2])
-- ladybird quirk
if lad then
  local lx, ly = math.floor(lad[1] + 0.5), math.floor(lad[2] + 0.5)
  c:px(lx, ly, "#d8402e") c:px(lx + 1, ly, "#e8604a") c:px(lx, ly + 1, "#a82a28") c:px(lx + 1, ly + 1, "#a82a28")
  c:px(lx, ly - 1, "#2b1c26")
  c:px(lx + 1, ly, "#2b1c26")
end
G.fin(c, "thyme")
