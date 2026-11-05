-- hollowheart-tree (lean P1b_O3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local function dot(c, x, y, h) c:px(x, y, h) end
local c = HP.canvas{ w=64, h=64, scale=1, name="hollowheart-tree" }
local LEAF = { "#183a34", "#235a3c", "#388046", "#58a64c", "#86c85a", "#bbe47e" }
local BARK = { "#2a1a1c", "#4a2c26", "#6e4430", "#946444", "#b8875a", "#d8aa78" }
c:groundShadow(32, 58, 14, 3)
-- trunk: flared tube
local tm, tn = G.tube({{32,58},{31,50},{33,40},{32,30}}, function(t) return 8.2 - 4.2 * t end)
tm:add(c:poly{{20,58},{28,50},{36,50},{45,58}}):add(c:ellipse(32,56,13,3))
local bias = {}
local ti = G.toneN(c, tm, X.pillow(tm, 8), BARK, { bias = bias })
tm:each(function(x, y) if (x % 4 == 1 or (x + y) % 9 == 0) and X.hash(x, y, 2) > 0.3 and y > 33 then c:px(x, y, BARK[2]) end end)
-- hollow: heart-shaped glowing cavity
local heart = HP.mask()
heart:add(c:ellipse(29, 44, 3, 3)):add(c:ellipse(35, 44, 3, 3)):add(c:poly{{26,45},{38,45},{32,53}})
local rimm = heart:copy():grow(1)
c:fillMask(rimm, BARK[1])
shade(c, heart, 5, { "#7a2a1c", "#b8481e", "#e0762a", "#f6a63c", "#ffd36a", "#fff0a0" }, { cuts = {0.2,0.4,0.6,0.8,0.92} })
c:px(28, 42, "#fff6c0") c:px(29, 42, "#fff6c0")
-- canopy: cluster of blobs
local can = HP.mask()
for _, b in ipairs{ {32,18,13,10},{20,24,9,8},{44,24,9,8},{26,12,9,7},{39,12,9,7},{32,26,12,6} } do can:add(c:ellipse(b[1], b[2], b[3], b[4])) end
local n = X.pillow(can, 9)
local cb = {}
can:each(function(x, y) local h = X.hash(floor(x / 3), floor(y / 3), 5) if h > 0.72 then cb[K(x, y)] = 1 elseif h < 0.2 then cb[K(x, y)] = -1 end end)
G.toneN(c, can, n, LEAF, { bias = cb, cuts = {0.2,0.38,0.55,0.72,0.88} })
-- tuft notches at edge
can:edge():each(function(x, y) if X.hash(x, y, 8) > 0.82 then c:px(x, y, LEAF[1]) end end)
-- branch fork under canopy
c:line({{32,31},{27,27}}, 2):each(function(x, y) c:px(x, y, BARK[3]) end)
c:line({{32,31},{37,27}}, 2):each(function(x, y) c:px(x, y, BARK[3]) end)
-- quirk: single floating heart-leaf
c:px(50, 12, "#e86a8a") c:px(52, 12, "#e86a8a") c:px(49, 13, "#e86a8a") c:px(50, 13, "#f8a0b8") c:px(51, 13, "#e86a8a") c:px(52, 13, "#e86a8a") c:px(53, 13, "#e86a8a") c:px(50, 14, "#e86a8a") c:px(51, 14, "#e86a8a") c:px(52, 14, "#e86a8a") c:px(51, 15, "#c84a6a")
G.save(c, "hollowheart-tree")
