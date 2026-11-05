-- pluot-jam (lean E2_05)
local NAME = "pluot-jam"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function P(x, y, col) c:put(x, y, col) end
local function RC(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function dome(m, ramp, R, name, o) local n = X.pillow(m, R) local t = { tok = { r = { name = name } }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 } if o then for k, v in pairs(o) do t[k] = v end end G.toneN(c, m, n, ramp, t) return n end
local W = { "#4e4e78", "#7c7ca4", "#aeaecb", "#d4d4e6", "#ecebf4", "#fbfaff" }
local D = { "#3a2418", "#5e3a22", "#8a5a30", "#ae7a40", "#cf9c58", "#e8c07c" }
local JM = { "#2a0c2e", "#5a1646", "#8a2258", "#b8386a", "#dc5a7c", "#f58aa0" }
local GL = { "#4c4a78", "#8a92b4", "#bcc8de", "#e4eef8", "#ffffff" }
local CL = { "#b8742c", "#e09a3a", "#f4c460", "#fae090", "#fff2bc" }
local TW = { "#5a3a1e", "#8e6034", "#c08c50" }
c:groundShadow(32, 56, 22, 3)
-- jar glass body
local jar = c:rrect(13, 28, 51, 55, 7)
local neck = c:rect(19, 22, 45, 30)
local gl = HP.mask() gl:add(jar) gl:add(neck)
dome(gl, JM, 9, "jam", { amb = 0.05, wrap = 0.35 })
-- jam speckle (fruit bits)
gl:each(function(x, y) if y > 29 and X.hash(x, y, 11) > 0.93 then P(x, y, JM[5]) elseif y > 29 and X.hash(x, y, 12) > 0.95 then P(x, y, JM[1]) end end)
-- glass rim + highlight streaks
gl:edge():each(function(x, y) end)
for y = 33, 50 do P(16, y, GL[3]) P(17, y, y % 5 == 0 and GL[5] or GL[4]) end
P(18, 32, GL[5]) P(17, 51, GL[3])
for y = 34, 44 do P(47, y, GL[2]) end
RC(15, 53, 49, 54, JM[1])
-- label: cream oval with plum-apricot half
local lb = c:rrect(22, 36, 42, 49, 4)
dome(lb, { "#a88a60", "#cdb080", "#e8d4a4", "#f6e8c0", "#fff6d8", "#fffbe8" }, 6, "label", { amb = 0.3, wrap = 0.4 })
local fr = c:ellipse(32, 43, 4, 4)
G.toneN(c, fr, X.pillow(fr, 3.5), { "#4a1a50", "#7a2a74", "#a8458c", "#e0743a", "#f8a050", "#ffd080" }, { tok = { r = { name = "pluot" } }, cuts = { .2, .38, .54, .7, .86 } })
for i = 1, 2 do P(32 - 4 + i, 40 + i, "#4a1a50") end
P(31, 41, "#fff0d0")
P(32, 38, "#3a7a3a") P(33, 38, "#58a048") P(33, 37, "#58a048")
-- cloth cover with scalloped skirt
local cl = c:poly{ { 16, 14 }, { 20, 8 }, { 44, 8 }, { 48, 14 }, { 50, 24 }, { 14, 24 } }
dome(cl, CL, 7, "cloth", { amb = 0.3, wrap = 0.5 })
for y = 9, 24 do for x = 14, 50 do if cl:has(x, y) then
  if (floor((x - 14) / 4) + floor((y - 8) / 4)) % 2 == 0 then P(x, y, y > 17 and CL[3] or CL[4]) end
end end end
for x = 15, 49, 5 do for dy = 0, 2 do P(x + dy % 2, 24 + dy, CL[2]) P(x + 2 - dy % 2, 24 + dy, CL[2]) end end
for x = 15, 49 do P(x, 24, CL[1]) end
-- twine
RC(19, 21, 45, 22, TW[2]) RC(19, 22, 45, 22, TW[1]) for x = 19, 45, 3 do P(x, 21, TW[3]) end
P(40, 22, TW[2]) P(41, 23, TW[2]) P(40, 24, TW[1]) P(43, 23, TW[3]) P(44, 24, TW[2])
-- drip quirk down the side
for y = 24, 36 do P(48, y, JM[3]) P(49, y, JM[2]) end
RC(47, 37, 50, 39, JM[3]) P(48, 38, JM[5]) P(49, 39, JM[2]) P(48, 36, JM[4])
P(46, 24, JM[3]) P(47, 25, JM[4])
-- sparkle on cloth
P(24, 12, CL[5]) P(25, 12, CL[5])
G.save(c, NAME)
