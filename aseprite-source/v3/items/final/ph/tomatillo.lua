-- tomatillo (lean P1b_O20)
-- quirk: the papery husk is nibbled on the left; the big lime fruit shows through the open front.
local NAME = "tomatillo"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local hash = X.hash
local function tk(n) return { r = { name = n } } end
local function clamp(i, n) return max(1, min(n, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ST = { "#5c4426", "#8c7236", "#b89a48", "#d8be62", "#eeda8c", "#fcf2c0" }
local FR = { "#16462c", "#287034", "#4a9c3a", "#7cc440", "#aae45e", "#e4fa94" }
c:groundShadow(33, 55, 19, 3)
local function hw(y)
  if y <= 34 then return 1.5 + 14.5 * sin((y - 12) / 22 * pi / 2) ^ 0.8 end
  return 16 - (y - 34) * 0.3
end
local husk = HP.mask()
for y = 12, 50 do
  local h = hw(y)
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do
    local endy = 46 + 3 * abs(cos((x - 32) * pi / 6))
    if y <= endy then husk:set(x, y) end
  end
end
local fruit, fn = G.oval(32, 38, 13, 13, 0, 1)
local window = HP.mask():add(c:poly{ {26,22},{30,25},{33,21},{37,25},{41,23},{44,33},{43,45},{21,45},{20,33} }):clip(husk)
local vis = fruit:copy()
local covered = husk:copy():cut(window)
vis:cut(covered)
local hn = X.pillow(husk, 10)
local bias = {}
for _, o in ipairs{ -13, -7, 7, 13 } do
  husk:each(function(x, y)
    local xc = 32 + o * hw(y) / 15
    if abs(x - xc) < 0.55 then bias[K(x, y)] = -1 elseif abs(x - xc - 1) < 0.5 then bias[K(x, y)] = 1 end
  end)
end
husk:each(function(x, y) if (x * 3 + y) % 7 == 0 and hash(x, y, 9) > 0.5 and not bias[K(x, y)] then bias[K(x, y)] = -1 end end)
G.toneN(c, husk:copy():cut(window), hn, ST, { bias = bias, tok = tk("husk"), cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 } })
-- fruit seen through the open front and below the husk
G.toneN(c, vis, fn, FR, { tok = tk("fruit"), bias = G.cast({}, vis, covered, 1, 1, -2), cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
vis:edge():each(function(x, y) if x > 36 and y > 40 then c:px(x, y, "#2a8a50") end end)
-- sticky dark spots on fruit
for _, p in ipairs{ {28,38},{36,41},{31,43} } do c:px(p[1], p[2], FR[2]) end
c:px(25, 32, "#f6ffd8") c:px(26, 31, "#f6ffd8") c:px(25, 33, "#f6ffd8") c:px(27, 31, FR[6])
-- husk rim: darker outline of the opening and scalloped tips
window:edge():each(function(x, y) if husk:has(x, y) and not window:has(x, y) then c:px(x, y, ST[2]) end end)
husk:edge():each(function(x, y) if y > 40 then c:px(x, y, ST[2]) end end)
-- quirk: a nibble out of the left husk, showing the dark inside
for _, p in ipairs{ {17,36},{18,37},{17,38},{18,39} } do c:px(p[1], p[2], ST[1]) end
-- stem
local st, sn = G.tube({ { 32, 13 }, { 32, 10 }, { 33, 7 }, { 37, 7 } }, function(t) return 1.8 - 0.4 * t end)
X.tone(c, st, X.light(sn, { amb = 0.12, wrap = 0.3 }), { "#3a4a22", "#5e7a30", "#8aa43e", "#bcd060" }, { cuts = { 0.3, 0.55, 0.8 }, tok = tk("stem") })
G.save(c, NAME)
