-- silverfish-scales (lean P1b_O9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local NAME = "silverfish-scales"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local SIL = { "#2f3858", "#4f5f8a", "#7587ae", "#a2b3d0", "#cfdbea", "#f4f8fb" }
local VIO = { "#3a2d5c", "#5b4a8c", "#8672b8", "#ae9ad8", "#d4c6ee", "#f6f0fb" }
c:groundShadow(32, 55, 21, 3)
local sc = {
  {23, 20}, {41, 20},
  {15, 31}, {32, 31}, {49, 31},
  {24, 42}, {41, 42, "v"},
}
for i, s in ipairs(sc) do
  local ramp = s[3] and VIO or SIL
  -- scale: wide rounded shape pointing down
  local m = HP.mask()
  local cx, cy = s[1], s[2]
  for y = cy - 8, cy + 9 do for x = cx - 9, cx + 9 do
    local u, v = (x - cx) / 8.6, (y - cy) / 8.6
    local w = v < 0 and 1 or (1 - v * 0.55)
    if v >= -1 and v <= 1.05 and abs(u) <= w * sqrt(max(0, 1 - (v < 0 and v * v * 0.9 or 0))) then m:set(x, y) end
  end end
  local n = X.pillow(m, 6)
  local bias = {}
  local v = X.light(n, { amb = 0.08, wrap = 0.2 })
  local idx = X.tone(c, m, v, ramp, { cuts = { 0.22, 0.4, 0.58, 0.74, 0.88 }, bias = bias })
  -- radial ridges + growth arcs
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local r = sqrt(dx * dx + dy * dy * 0.9)
    if dy > 0 and abs(dx) > 1 and (dx + 100) % 3 == 0 and r > 3 and r < 8 then c:px(x, y, ramp[2]) end
    if abs(r - 5.5) < 0.5 and dy > 1 and X.hash(x, y, i) > 0.2 then c:px(x, y, ramp[5]) end
  end)
  -- dark rim line along the lower edge for separation + bright upper-left rim
  m:edge():each(function(x, y)
    if y >= cy + 2 or x > cx + 4 then c:px(x, y, ramp[1]) elseif x < cx - 2 or y < cy - 5 then c:px(x, y, ramp[5]) end
  end)
  c:px(cx - 3, cy - 4, ramp[6]) c:px(cx - 2, cy - 5, ramp[6])
end
c:sparkle(41, 38)
c:px(8, 18, SIL[5]) c:px(56, 46, SIL[5])
G.save(c, NAME)
