-- sorrel (lean P1b_O9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local NAME = "sorrel"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local LEAF = { "#1e4a32", "#2c6c3a", "#44903f", "#68b448", "#94d058", "#c8ea84" }
local STEM = { "#4a1a30", "#7a2438", "#a83844", "#d05a56" }
local ltok = {}
c:groundShadow(32, 57, 9, 2)
-- stem
local sm, sn = G.tube({ {32, 55}, {32, 44}, {32, 34}, {32, 26} }, function(t) return 1.4 - 0.3 * t end)
G.toneN(c, sm, sn, { STEM[1], STEM[1], STEM[2], STEM[3], STEM[4], "#e88a74" }, { amb = 0.1 })
-- small side leaf
local lm, ln, lT, lS = G.blade(33, 46, 42, 38, 54, 40, function(t) return 3.6 * sin(pi * min(1, t * 1.02)) ^ 0.7 end)
G.toneN(c, lm, ln, LEAF, { amb = 0.1, wrap = 0.25 })
lm:each(function(x, y) local k = K(x, y) if abs(lS[k]) < 0.2 and lT[k] < 0.9 then c:px(x, y, LEAF[6]) end end)
for t = 0, 5 do c:px(35 + t, 45 - floor(t * 0.7), STEM[3]) end
-- arrowhead pieces: main blade + two lobes
local function wfn(t) return 6.4 * sin(pi * min(1, t * 1.02)) ^ 0.62 end
local mm, mn, mT, mS = G.blade(32, 30, 31, 16, 32, 3, function(t) return 7 * sin(pi * min(1, t * 1.02)) ^ 0.7 end)
local am, an, aT, aS = G.blade(32, 29, 22, 26, 11, 38, function(t) return 4.6 * sin(pi * min(1, t * 1.02)) ^ 0.55 end)
local bm, bn, bT, bS = G.blade(32, 29, 42, 26, 53, 38, function(t) return 4.6 * sin(pi * min(1, t * 1.02)) ^ 0.55 end)
for _, p in ipairs{ {mm, mn, mT, mS}, {am, an, aT, aS}, {bm, bn, bT, bS} } do
  local m, n, T, S = p[1], p[2], p[3], p[4]
  G.toneN(c, m, n, LEAF, { amb = 0.1, wrap = 0.25 })
  m:each(function(x, y)
    local k = K(x, y)
    if abs(S[k]) < 0.17 and T[k] < 0.92 then c:px(x, y, STEM[3])   -- red midrib
    elseif T[k] > 0.2 and T[k] < 0.85 and abs(S[k]) > 0.3 and abs(S[k]) < 0.7 and floor(T[k] * 26 + abs(S[k]) * 4) % 5 == 0 then c:px(x, y, S[k] < 0 and LEAF[5] or LEAF[2]) end
  end)
end
-- red junction + dewdrop (quirk)
c:px(32, 30, STEM[2]) c:px(31, 30, STEM[1]) c:px(33, 30, STEM[1])
local dm, dn = G.oval(37, 12, 1.8, 2.2, 0, 1)
G.toneN(c, dm, dn, { "#2a5a8a", "#3f86b8", "#74b8dc", "#aee0f0", "#dcf6fa", "#fbfffc" }, { amb = 0.1 })
c:px(36, 11, "#fbfffc")
G.save(c, NAME)
