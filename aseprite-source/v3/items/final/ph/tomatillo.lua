-- tomatillo (lean P1b_O17)
-- quirk: the papery husk is torn open on the left, peeking the lime fruit.
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
c:groundShadow(33, 55, 17, 3)
local function hw(y)
  if y <= 36 then return 1.5 + 13.5 * sin((y - 12) / 24 * pi / 2) ^ 0.8 end
  return 15 - (y - 36) * 0.25
end
local husk = HP.mask()
for y = 12, 49 do
  local h = hw(y)
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do
    local endy = 45 + 3 * abs(cos((x - 32) * pi / 6.5))
    if y <= endy then husk:set(x, y) end
  end
end
local fruit, fn = G.oval(32, 42, 10, 9, 0, 1)
local hn = X.pillow(husk, 10)
-- tear
local tear = HP.mask():add(c:poly{ {18, 27}, {22, 24}, {26, 28}, {22, 35} })
tear:clip(husk)
local bias = {}
for _, o in ipairs{ -12, -6, 0, 6, 12 } do
  husk:each(function(x, y)
    local xc = 32 + o * hw(y) / 15
    if abs(x - xc) < 0.55 then bias[K(x, y)] = -1 elseif abs(x - xc - 1) < 0.5 then bias[K(x, y)] = 1 end
  end)
end
husk:each(function(x, y) if (x + y) % 5 == 0 and hash(x, y, 9) > 0.5 and not bias[K(x, y)] then bias[K(x, y)] = -1 end end)
G.cast(bias, husk, fruit, 1, 1, -1)
local _, v = G.toneN(c, husk, hn, ST, { bias = bias, tok = tk("husk"), cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 } })
-- scalloped tips darker edge
husk:edge():each(function(x, y) if y > 42 then c:px(x, y, ST[2]) end end)
-- torn window showing fruit
local tn = X.pillow(tear, 4)
G.toneN(c, tear, tn, FR, { tok = tk("fruit") })
tear:edge():each(function(x, y) c:px(x, y, ST[1]) end)
c:px(21, 28, FR[6]) c:px(22, 28, FR[6])
-- fruit
local fm = fruit:copy()
G.toneN(c, fm, fn, FR, { tok = tk("fruit2"), bias = G.cast({}, fruit, husk:copy():cut(fruit), 0, -1, -1) })
local sx, sy = G.specAt(fruit, fn, 30)
c:px(sx, sy, "#f6ffd8") c:px(sx + 1, sy, "#f6ffd8") c:px(sx, sy + 1, FR[6])
fruit:edge():each(function(x, y) if y > 46 then c:px(x, y, FR[1]) end end)
-- stem
local st, sn = G.tube({ { 32, 13 }, { 32, 10 }, { 33, 8 }, { 36, 7 } }, function(t) return 1.8 - 0.4 * t end)
X.tone(c, st, X.light(sn, { amb = 0.12, wrap = 0.3 }), { "#4a3a22", "#6e5a30", "#9a8444", "#c4b060" }, { cuts = { 0.3, 0.55, 0.8 }, tok = tk("stem") })
G.save(c, NAME)
