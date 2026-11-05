-- tomato (lean P1b_O20)
-- quirk: a little split near the shoulder with a bead of seed gel.
local NAME = "tomato"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local hash = X.hash
local function tk(n) return { r = { name = n } } end
local function clamp(i, n) return max(1, min(n, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local RED = { "#4a0f2e", "#7c1430", "#b81e2c", "#e03a28", "#f65e36", "#ffa56c" }
local GRN = { "#12342c", "#1c5a34", "#2c8038", "#4fa840", "#80cc4c", "#bcec74" }
c:groundShadow(33, 54, 19, 3)
local body, n = G.oval(32, 36, 21, 17, 0, 0.9)
-- sepals
local C = { 32, 22 }
local tips = { {15, 25}, {22, 31}, {32, 32}, {42, 31}, {49, 25} }
local sep, sepd = HP.mask(), {}
for i, t in ipairs(tips) do
  local m, nn = G.tube({ C, { C[1] + (t[1] - C[1]) * 0.4, C[2] - 3 }, { C[1] + (t[1] - C[1]) * 0.8, t[2] - 4 }, t },
    function(u) return 2.7 * (1 - u) ^ 0.8 + 0.5 end)
  sep:add(m) for k, v in pairs(nn) do sepd[k] = v end
end
local bias = {}
-- lobe creases + calyx AO
for _, o in ipairs{ -11, 11 } do
  body:each(function(x, y)
    local xc = 32 + o * sqrt(max(0, 1 - ((y - 36) / 17) ^ 2))
    if abs(x - xc) < 0.6 and y > 24 then bias[K(x, y)] = -1 end
  end)
end
G.cast(bias, body, sep, 1, 2, -2)
local _, v = G.toneN(c, body, n, RED, { bias = bias, tok = tk("fruit") })
local rim = X.rim(n)
body:edge():each(function(x, y) if x > 36 and y > 40 and (rim[K(x, y)] or 0) > 0.5 then c:px(x, y, "#d8505a") end end)
-- glossy spec
c:px(21, 29, "#fff2e6") c:px(22, 28, "#fff2e6") c:px(23, 27, "#fff2e6") c:px(21, 30, "#fff2e6") c:px(24, 27, RED[6]) c:px(20, 31, RED[6]) c:px(26, 26, RED[6])
-- quirk split + gel bead
for _, p in ipairs{ {41, 26}, {42, 27}, {42, 28}, {43, 29}, {43, 30} } do c:px(p[1], p[2], RED[1]) end
c:px(42, 28, "#f4d060") c:px(43, 29, "#ffe890")
-- sepals
local sv = X.light(sepd, { amb = 0.1, wrap = 0.3 })
X.tone(c, sep, sv, GRN, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, tok = tk("calyx") })
sep:each(function(x, y) if (x + y) % 5 == 0 and hash(x, y, 3) > 0.4 then c:px(x, y, GRN[2]) end end)
-- stem
local st, sn = G.tube({ { 32, 22 }, { 32, 15 }, { 34, 10 }, { 39, 9 } }, function(t) return 2.3 - 0.8 * t end)
X.tone(c, st, X.light(sn, { amb = 0.12, wrap = 0.3 }), { "#2c4a22", "#4e7a30", "#78a63e", "#b0d060" }, { cuts = { 0.3, 0.55, 0.8 }, tok = tk("stem") })
c:px(40, 9, "#6a5230") c:px(40, 10, "#6a5230")
G.save(c, NAME)
