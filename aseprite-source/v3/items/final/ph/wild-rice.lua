-- wild-rice (lean D3o_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wild-rice" }
-- slim wild rice stalk: curved culm with node, two arching leaf blades, drooping panicle of long dark grains with awns. quirk: one grain has split open to show white kernel.
local STEM = { "#4a6a3a", "#6f9448", "#9cbc62", "#cbdc88" }
local LEAF = { "#1f4a35", "#2f6b40", "#46904a", "#6cb455", "#9ccd6c" }
local GR = { "#3a2a22", "#5b4330", "#85613c", "#b08650", "#d6b072" }
local ltok = { r = { name = "leaf" } }
-- leaf blades
local function blade(pts, wmax)
  local m, n = G.tube(pts, function(t) return wmax * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.7 + 0.4 end)
  shade(c, m, LEAF, 3, { amb = 0.12, wrap = 0.3, tok = ltok })
  local mid = G.tube(pts, function(t) return 0.5 end)
  mid:each(function(x, y) c:px(x, y, LEAF[5]) end)
end
blade({ {30, 54}, {16, 50}, {10, 40}, {8, 30} }, 2.4)
blade({ {33, 54}, {46, 49}, {54, 42}, {55, 31} }, 2.2)
-- culm
local sm, sn = G.tube({ {32, 58}, {31, 46}, {33, 32}, {35, 15} }, function(t) return 1.8 - 0.5 * t end)
shade(c, sm, STEM, 2, { amb = 0.2, wrap = 0.3 })
c:fillMask(c:rect(30, 45, 33, 45), STEM[1]) c:px(30, 44, STEM[4])
-- panicle
local function grain(x, y, ux, uy, split)
  local m = G.rell(x, y, ux, uy, 3.6, 1.5)
  shade(c, m, GR, 2, { amb = 0.15, wrap = 0.3 })
  c:px(floor(x - ux * 1.5), floor(y - uy * 1.5 - 1), GR[5])
  -- awn
  local ex, ey = x + ux * 3.8, y + uy * 3.8
  G.line(c, { {floor(ex), floor(ey)}, {floor(ex + ux * 4), floor(ey + uy * 4)} }, GR[3])
  if split then c:px(floor(x), floor(y), "#f4ecd2") c:px(floor(x + ux), floor(y + uy), "#f4ecd2") end
end
local br = {
  { {35, 15}, {30, 12}, {26, 17}, {24, 24} }, { {35, 15}, {38, 10}, {43, 14}, {45, 21} },
  { {35, 18}, {33, 18}, {31, 24}, {30, 31} }, { {35, 20}, {40, 20}, {42, 26}, {41, 32} },
}
for _, b in ipairs(br) do
  local m = G.tube(b, function(t) return 0.5 end)
  m:each(function(x, y) c:px(x, y, STEM[2]) end)
end
grain(24, 27, -0.1, 1, false) grain(26, 20, -0.5, 0.85, false) grain(45, 24, 0.1, 1, false) grain(43, 17, 0.5, 0.85, false)
grain(30, 34, -0.1, 1, true) grain(41, 35, 0.1, 1, false) grain(35, 8, 0.1, -1, false) grain(33, 24, 0, 1, false)
G.fin(c, "wild-rice")
