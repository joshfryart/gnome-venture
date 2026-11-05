-- lucuma (lean P1b_O4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "lucuma" }
local PEEL = { "#274a22", "#3c6e2c", "#5c9a36", "#86c244", "#b5dc5e", "#e0f090" }
local FLESH = { "#a8481c", "#d06e1c", "#ee9a20", "#f8c030", "#fde070", "#fff4b0" }
local SEED = { "#2a140e", "#4a2616", "#6e3a1c", "#94562a", "#bc7a3e", "#e0a468" }
c:groundShadow(32, 54, 16, 3)
local body = c:ellipse(31, 33, 17, 18)
body:cut(c:poly{ {14,50},{22,56},{31,57},{40,56},{48,50},{48,60},{14,60} }) -- trim to a slightly pointed base
local tip = c:poly{ {26,48},{31,56},{36,48} } body:add(tip)
local n = X.pillow(body, 15)
G.toneN(c, body, n, PEEL, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- cut-open window (flesh)
local win = c:ellipse(38, 36, 10, 12)
win:clip(body)
win:cut(c:ellipse(25, 28, 12, 14))
local wn = X.pillow(win, 9)
-- wall rim = peel thickness: shrink flesh
local fl = win:shrink(1)
c:fillMask(win, PEEL[5])
G.toneN(c, fl, wn, FLESH, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
-- seed
local sd = c:ellipse(39, 38, 5, 7)
G.toneN(c, sd, X.pillow(sd, 4), SEED, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
c:px(37, 34, SEED[6]) c:px(38, 34, "#fff0d8") c:px(37, 35, SEED[5])
-- peel bumps
for _, p in ipairs{ {18,40},{22,46},{14,30},{20,22},{30,50},{26,16} } do if body:has(p[1], p[2]) and not win:has(p[1], p[2]) then c:px(p[1], p[2], PEEL[2]) end end
c:px(21, 20, PEEL[6]) c:px(22, 19, PEEL[6]) c:px(20, 21, PEEL[5])
-- stem + leaf
for y = 11, 15 do c:px(31, y, "#6a4a22") c:px(32, y, "#8a6a34") end
local lf = G.blade(32, 12, 40, 4, 54, 8, function(t) return 4.2 * sin(pi * t) ^ 0.7 end)
local LF = { "#1b4a30", "#26663a", "#368a40", "#52ac48", "#7ccc58", "#aee27a" }
G.toneN(c, lf, X.pillow(lf, 4), LF)
-- quirk: tiny ladybird-like brown speck bite on peel -> moth nibble on leaf
c:px(46, 7, "#2a140e") c:px(47, 7, "#2a140e")
G.save(c, "lucuma")
