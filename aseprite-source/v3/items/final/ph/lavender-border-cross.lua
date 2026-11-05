-- lavender-border-cross (lean E2_02)
local NAME = "lavender-border-cross"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, nm, o)
  o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = CUTS, tok = { r = { name = nm or "p" } } })
  return idx, n
end
local function px(x, y, col, nm) c:put(x, y, col, { r = { name = nm or "d" } }) end
local function spec(m, n, col)
  local x, y = G.specAt(m, n, 30)
  if x then px(x, y, col or "#fff4dc", "spec") end
end
c:groundShadow(32, 56, 24, 3)
local ST = { "#3a3e48", "#555c68", "#74808c", "#96a2ac", "#b8c2c8", "#d8e0e2" }
local SO = { "#2a1810", "#46281a", "#5e3a22", "#7e5230", "#a07040", "#c29058" }
local PU = { "#2c1a4a", "#4a2e7a", "#6c48a6", "#8c68c8", "#b090e0", "#dcc4f8" }
local cross = HP.mask(); cross:add(c:rect(24, 16, 40, 54)); cross:add(c:rect(10, 28, 54, 42))
local stones = cross:grow(2)
shade(stones, ST, 6, "stone")
stones:each(function(x, y) if not cross:has(x, y) and ((x + y * 3) % 7 == 0 or (x * 2 + y) % 9 == 0) then px(x, y, ST[2], "joint") end end)
-- inner soil
local soil = cross:shrink(1)
shade(soil, SO, 6, "soil", { amb = 0.2 })
soil:each(function(x, y) if X.hash(x, y, 4) > 0.9 then px(x, y, SO[2], "cl") end end)
-- spikes
local function spike(x, y)
  for t = 0, 3 do px(x, y - t, "#5a8a48", "stalk") end
  px(x - 2, y, "#7fa66a", "lf"); px(x + 2, y, "#4a7a3c", "lf"); px(x - 1, y - 1, "#7fa66a", "lf"); px(x + 1, y - 1, "#4a7a3c", "lf")
  local m = c:rrect(x - 1, y - 12, x + 1, y - 4, 1)
  local idx = shade(m, PU, 2, "sp" .. x .. y, { amb = 0.15 })
  for r = 0, 3 do px(x - 1 + (r % 2), y - 11 + r * 2, PU[6], "bud") end
  px(x + 1, y - 7, PU[2], "bud"); px(x, y - 5, PU[2], "bud")
end
local pts = { {28,24},{36,23},{30,33},{40,34},{16,36},{22,39},{46,38},{52,40},{27,44},{36,46},{29,52},{37,51} }
table.sort(pts, function(a, b) return a[2] < b[2] end)
for _, p in ipairs(pts) do spike(p[1], p[2]) end
-- bee quirk
for _, p in ipairs{ {47,22},{48,22},{49,22},{50,22} } do px(p[1], p[2], ((p[1] % 2 == 0) and "#2a1c14" or "#f4c82a"), "bee") end
px(47, 23, "#f4c82a", "bee"); px(48, 23, "#f4c82a", "bee"); px(49, 23, "#2a1c14", "bee"); px(50, 23, "#2a1c14", "bee")
px(48, 20, "#dcecf4", "wing"); px(49, 20, "#dcecf4", "wing"); px(48, 21, "#b8d0e0", "wing"); px(49, 21, "#b8d0e0", "wing")
G.save(c, NAME)
