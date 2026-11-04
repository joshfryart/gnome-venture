-- chestnut (lean W2_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function egg(cx, y0, y1, w, pw) local m = HP.mask() for y = y0, y1 do local t = (y - y0) / (y1 - y0); local h = w * sin(pi * t ^ pw) ^ 0.8 + 0.5; for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do m:set(x, y) end end return m end
local function shade(c, m, R, ramp, bias, o) local n = X.pillow(m, R); return n, G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp, nil, bias) end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "chestnut" }
local BR = { "#2e1612", "#4f2418", "#74361e", "#9a4e28", "#c06f3a", "#e09a58" }
local HU = { "#2f4a22", "#43692a", "#5f8c32", "#86ae45", "#b3cf63" }
local LIN = { "#8d6f4a", "#b9976a", "#dcc392", "#f2e6c4" }
c:groundShadow(32, 56, 22, 3)
-- open husk flaps (back), cream lining
for _, f in ipairs{ {-1}, {1} } do
  local s = f[1]
  local m = G.rell(32 + s * 15, 41, s * 0.62, -0.78, 12, 4.6)
  shade(c, m, 4, LIN)
  local rim = m:copy():shrink(1)
end
-- chestnut
local nut = egg(32, 9, 47, 12.5, 0.72)
local n, idx = shade(c, nut, 11, BR, nil, { amb = 0.08, wrap = 0.2 })
local streak = HP.mask()
nut:each(function(x, y) if (x * 3 + floor(y * 0.15 * (x - 32))) % 5 == 0 and y > 18 and y < 43 and X.hash(x, y, 7) > 0.35 then c:px(x, y, BR[x < 32 and 2 or 1]) end end)
c:fillMask(c:rect(30, 6, 30, 11), "#b89a62") c:fillMask(c:rect(34, 6, 34, 11), "#b89a62")
c:px(31, 12, "#e8d6a0") c:px(33, 12, "#e8d6a0") c:px(31, 11, BR[2]) c:px(32, 12, "#d9c48a") c:px(32, 11, "#d9c48a")
-- spec
for _, p in ipairs{ {26, 22}, {26, 23}, {27, 21}, {27, 22}, {26, 24} } do c:px(p[1], p[2], "#fff1d8") end
c:px(28, 20, BR[6]) c:px(25, 25, BR[6])
-- husk bowl front
local bowl = HP.mask()
for y = 43, 56 do local t = (y - 43) / 13; local h = 22 * (1 - t ^ 2.2) ^ 0.5 + 1; for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do bowl:set(x, y) end end
local bn = X.pillow(bowl, 8)
G.tone(c, bowl, X.light(bn, { amb = 0.1, wrap = 0.3 }), HU, nil, nil)
-- spines
bowl:edge():each(function(x, y)
  if (x * 7 + y) % 4 == 0 and (y < 54 or x % 2 == 0) then
    local dx = (x - 32) / 22; local dy = (y - 46) / 10
    local l = sqrt(dx * dx + dy * dy) + 0.01; dx, dy = dx / l, dy / l
    c:line({ {x, y}, {floor(x + dx * 3 + 0.5), floor(y + dy * 3 + 0.5)} }, 1):each(function(a, b) c:px(a, b, HU[1]) end)
    c:px(floor(x + dx * 3 + 0.5), floor(y + dy * 3 + 0.5), "#d9c860")
  end
end)
for _, p in ipairs{ {18, 49}, {24, 52}, {30, 53}, {38, 52}, {44, 49}, {34, 47}, {26, 46} } do c:px(p[1], p[2], HU[5]) end
-- quirk: nut peeks with a pale hilum scar over the husk lip
c:fillMask(c:ellipse(32, 44, 4, 1.3), "#d9bf86") c:px(31, 44, "#f2e4b8") c:px(34, 45, BR[2])
G.fin(c, "chestnut")
