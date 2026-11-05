-- sprinkler-can (lean P1b_O10)
-- Teal watering can: round cylinder body with brass rim bands, tall arched handle, long diagonal spout ending in a brass rose that sprays drops. Quirk: a riveted tin patch over a dent.
local NAME = "sprinkler-can"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, vf, nm, adj)
  local tok = { r = { name = nm } }
  local nr = #ramp
  m:each(function(x, y)
    local v = vf(x, y)
    local i = 1 + floor(max(0, min(0.999, v)) * nr)
    if adj then i = adj(x, y, i, v) or i end
    c:put(x, y, ramp[max(1, min(nr, i))], tok)
  end)
end
local function T(nm) return { r = { name = nm } } end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local TEAL = { "#0f3040", "#16505a", "#1f7870", "#33a088", "#5cc8a0", "#a0ecc0" }
local BRASS = { "#4a2c14", "#7a4a1e", "#a8742c", "#d4a444", "#f0cc66", "#fff0a0" }
local STEEL = { "#3a3a58", "#5c6488", "#8a98b8", "#b8c8dc", "#e4eef8" }
c:groundShadow(28, 57, 20, 3)
local CX, RX = 26, 13
-- handle arch (behind/over the top), thin bent strap
local hm, hn = G.tube({ {14, 30}, {13, 8}, {40, 8}, {38, 30} }, function(t) return 1.4 end)
paint(c, hm, BRASS, function(x, y) local k = K(x, y) return 0.2 + 0.8 * max(0, -(hn[k] and (hn[k][1] or hn[k].x or 0) or 0)) end, "handle")
-- spout (diagonal tube from low on the body)
local sm, sn = G.tube({ {37, 48}, {46, 44}, {52, 34}, {56, 24} }, function(t) return 2.6 - 1.2 * t end)
paint(c, sm, TEAL, function(x, y) local k = K(x, y) return 0.2 + 0.8 * max(0, -((sn[k] and (sn[k][1] or sn[k].x)) or 0) * 0.7 + 0.45) end, "spout")
-- rose head (tilted disc) with holes
local rose = G.oval(57, 22, 5, 3.4, -1.1, 0.8)
local rm = rose
paint(c, rm, BRASS, function(x, y) return 0.35 + 0.65 * max(0, min(1, (57 - x) * 0.12 + (22 - y) * 0.1 + 0.5)) end, "rose")
for _, p in ipairs{ {58,19},{57,21},{56,23},{59,22},{58,24} } do c:put(p[1], p[2], BRASS[1], T"rose") end
-- body
local body = c:rect(CX - RX, 27, CX + RX, 51)
body:add(c:ellipse(CX, 51, RX, 3))
paint(c, body, TEAL, function(x, y)
  local nx = (x - CX) / (RX + 0.5)
  local nz = sqrt(max(0, 1 - nx * nx))
  return 0.12 + 0.88 * max(0, -nx * 0.7 + nz * 0.55) * (y > 49 and 0.85 or 1)
end, "body", function(x, y, i) if y >= 50 and y <= 52 then return i - 1 end end)
-- opening
local top = c:ellipse(CX, 27, RX, 3.4)
paint(c, top, TEAL, function(x, y) return 0.04 + 0.1 * (x < CX and 1 or 0) end, "mouth")
c:fillMask(c:ellipse(CX - 2, 27, 6, 1), STEEL[3])
c:put(CX - 5, 27, STEEL[5], T"mouth")
-- brass rim bands
paint(c, c:rect(CX - RX, 29, CX + RX, 31), BRASS, function(x, y) local nx = (x - CX) / RX return 0.9 - (y - 29) * 0.25 - max(0, nx) * 0.5 end, "band")
paint(c, c:rect(CX - RX, 46, CX + RX, 48), BRASS, function(x, y) local nx = (x - CX) / RX return 0.9 - (y - 46) * 0.25 - max(0, nx) * 0.5 end, "band")
-- teal glint streak
for y = 34, 43 do c:put(CX - 8, y, TEAL[6], T"body") end
c:put(CX - 8, 44, TEAL[5], T"body")
-- quirk: tin patch with rivets over a dent
local patch = c:rrect(CX + 1, 35, CX + 9, 42, 1)
paint(c, patch, STEEL, function(x, y) return 0.85 - (x - CX) * 0.04 - (y - 35) * 0.06 end, "patch")
for _, p in ipairs{ {CX+2,36},{CX+8,36},{CX+2,41},{CX+8,41} } do c:put(p[1], p[2], STEEL[1], T"rivet") end
for _, p in ipairs{ {CX+3,38},{CX+4,38},{CX+5,39} } do c:put(p[1], p[2], STEEL[2], T"patch") end
-- water drops
for _, p in ipairs{ {60,28},{61,32},{58,34},{62,38} } do
  c:put(p[1], p[2], "#e0f8ff", T"drop") c:put(p[1], p[2] + 1, "#58b0e0", T"drop")
end
G.save(c, NAME)
