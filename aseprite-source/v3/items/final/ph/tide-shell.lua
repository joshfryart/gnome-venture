-- tide-shell (lean P1b_O16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function pick(r, v, cuts) cuts = cuts or {.22,.4,.56,.72,.86} local i = 1 for _, t in ipairs(cuts) do if v > t then i = i + 1 end end return r[min(i, #r)] end

local c = HP.canvas{ w=64, h=64, scale=1, name="tide-shell" }
local SH = { "#3e1f4f", "#6a2f78", "#a04594", "#cc66ae", "#ee92c4", "#ffc8dc" }
local IN = { "#a05a78", "#d889a4", "#f6b8c8", "#ffe6e0" }
c:groundShadow(32, 56, 22, 2)
local fan, lip = HP.mask(), HP.mask()
for y = 6, 50 do for x = 6, 58 do
  local dx, dy = x - 32, y - 49
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  if dy <= 0 then
    local p = (a + pi) / pi
    local R = 24 + 2.4 * abs(cos(p * 9 * pi))
    if r <= R and r > 1 then fan:set(x, y) end
  end
end end
for y = 47, 56 do for x = 8, 56 do
  local u, w = (x - 32) / 24.5, (y - 50.5) / 6.2
  if u * u + w * w <= 1 and y >= 47 then lip:set(x, y) end
end end
fan:each(function(x, y)
  local dx, dy = x - 32, y - 49
  local r = sqrt(dx * dx + dy * dy)
  local p = (atan(dy, dx) + pi) / pi
  local rib = sin(((p * 9) % 1) * pi)
  local v = 0.18 + 0.42 * rib + 0.22 * (1 - p) + 0.1 * (1 - r / 26)
  if (r % 7) < 0.9 then v = v - 0.2 end
  if r < 7 then v = v - 0.15 end
  c:px(x, y, pick(SH, v))
end)
lip:each(function(x, y)
  if not fan:has(x, y) or y >= 49 then
    local v = 0.85 - (y - 47) * 0.1 - (x - 8) * 0.004
    c:px(x, y, pick(IN, v, {.3,.55,.78}))
  end
end)
-- pearl
local pm, pn = G.oval(32, 49.5, 3.4, 3.2, 0, 1)
local pv = X.light(pn, { amb = 0.15, wrap = 0.3 })
pm:each(function(x, y) c:px(x, y, pick({ "#8a7aa8", "#b8aad0", "#e4dcee", "#fffaf0" }, pv[K(x, y)], {.35,.6,.8})) end)
c:px(31, 48, "#fffaf0")
-- hinge ears
for y = 44, 48 do for x = 26, 38 do if abs(x - 32) <= 6 - (48 - y) * 0.2 then c:px(x, y, SH[(y % 2) + 1]) end end end
-- drip (quirk)
c:px(50, 8, "#bfe8ff") c:px(50, 9, "#6cb8f0") c:px(50, 10, "#bfe8ff")
G.save(c, "tide-shell")
