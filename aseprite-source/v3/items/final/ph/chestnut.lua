-- chestnut (lean P1pilot)
local NAME = "chestnut"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = { r = { name = nm } } if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local NUT = { "#2a120f", "#4e2216", "#7a3a1c", "#a5582a", "#c97a3a", "#e8a460" }
local BUR = { "#16341f", "#245a2a", "#3a8034", "#5ea23c", "#8cc352", "#c4e47a" }
local TAN = { "#9a7a4e", "#c4a46c", "#e6cc92" }
-- nut (egg, tip up)
local nut = HP.mask()
for y = 14, 46 do local t = (y - 14) / 32; local h = 12.5 * sin(min(1, t * 1.15 + 0.05) * pi / 2 + 0) ^ 0.7 * (t < 0.15 and (0.5 + t * 3.3) or 1)
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do nut:set(x, y) end end
local n = ball(nut, 12, NUT, "nut", { amb = 0.08, wrap = 0.2 })
-- tiger stripes
local idx = {}
nut:each(function(x, y) local w = (x - 32) * 0.9 + sin(y * 0.35) * 1.2
  if floor((w + 40) / 3) % 2 == 0 and y > 22 and y < 41 and (x + y) % 2 == 0 and X.hash(x, y, 3) > 0.25 then c:put(x, y, NUT[2], { r = { name = "nut" } }) end end)
local bx, by = G.specAt(nut, n, 24)
for _, p in ipairs{ {23,24},{24,23},{23,25},{24,24},{25,23} } do if nut:has(p[1], p[2]) then c:put(p[1], p[2], p[1]+p[2] < 48 and "#fff0d0" or NUT[6], { r = { name = "nut" } }) end end
-- tassel tip
for _, p in ipairs{ {32,13},{32,12},{31,11},{33,11},{32,14} } do c:put(p[1], p[2], NUT[1], { r = { name = "tuft" } }) end
c:put(31,12,"#7a5a38") c:put(33,12,"#7a5a38")
-- pale matte hilum patch at the bottom
local hil = c:ellipse(32, 42, 8, 3):clip(nut)
G.toneN(c, hil, X.pillow(hil, 3), TAN, { tok = { r = { name = "hil" } }, cuts = {0.3,0.65}, amb = 0.15, wrap = 0.3 })
-- burr bowl: lower half, in front
local bowl = c:ellipse(32, 44, 19, 13)
bowl:cut(c:rect(0, 0, 63, 43))
-- ragged lip
local lip = HP.mask() bowl:each(function(x, y) if y == 44 and (x % 3 == 1) then lip:set(x, y) end end) bowl:cut(lip)
ball(bowl, 12, BUR, "bowl", { amb = 0.05, wrap = 0.2 })
-- inner rim shadow + soft lining
for x = 15, 49 do if bowl:has(x, 45) then c:put(x, 45, BUR[1], { r = { name = "bowl" } }) end end
-- spikes radiating
local cx, cy = 32, 43
for i = 0, 15 do
  local a = -0.12 + pi * 1.24 * i / 15
  local rx, ry = 19, 13
  local x0, y0 = cx + cos(a) * (rx - 1), cy + sin(a) * (ry - 1)
  local x1, y1 = cx + cos(a) * (rx + 5 + (i % 2) * 2), cy + sin(a) * (ry + 5 + (i % 2) * 2)
  if y1 >= 40 then
    local m = c:line({ {floor(x0 + 0.5), floor(y0 + 0.5)}, {floor(x1 + 0.5), floor(y1 + 0.5)} }, 1)
    m:each(function(x, y) if not bowl:has(x, y) then local d = sqrt((x - x1)^2 + (y - y1)^2) c:put(x, y, d < 1.6 and BUR[6] or BUR[4], { r = { name = "spike" } }) end end)
  end
end
-- highlights on bowl
for _, p in ipairs{ {20,50},{21,50},{22,51},{25,53},{26,54} } do if bowl:has(p[1], p[2]) then c:put(p[1], p[2], BUR[5], { r = { name = "bowl" } }) end end
G.save(c, NAME)
