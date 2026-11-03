local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- snail-green: round moss-green shell with a deep spiral, a long raised neck and a fresh slime trail.
-- quirk: a little pink flower has taken root on top of the shell.
local c = D.new("snail-green")
local BODY = { "#5a6a48", "#8a9a68", "#aab888", "#c4d4a0", "#dce8b8", "#f0f4d4" }
local SH = { "#24544a", "#2e7646", "#3f9150", "#5cae58", "#7cc35a", "#c4e07a" }
c:groundShadow(30, 57, 26, 2)
local bm = D.sweep({ {5, 53}, {26, 55}, {47, 53}, {52, 28} }, function(t) return t < 0.25 and 1 + t * 11 or (t > 0.85 and 3.4 - (t - 0.85) * 4 or 3.4) end, 60)
bm:add(c:ellipse(52, 27, 4, 4))
D.lit(c, bm, BODY, 3, { amb = 0.15 })
for x = 10, 46 do if bm:has(x, 56) then D.shift(c, x, 56, BODY, -2) end end
D.stalk(c, 50, 24, 49, 14, BODY[2])
D.stalk(c, 55, 24, 57, 16, BODY[2])
c:px(56, 30, BODY[1]) c:px(57, 30, BODY[1])
local shm = c:ellipse(26, 37, 13, 13)
D.disc(c, 26, 37, 13, SH)
D.spiral(c, 26, 38, 11, 2.2, SH[1], shm, 0.5)
D.spiral(c, 25, 37, 10, 2.2, SH[6], shm, 0.5)
D.seam(c, bm, shm, BODY[1])
-- slime trail
for x = 2, 8, 2 do c:px(x, 58, "#b6f0e0") end
-- flower on shell
c:part(c:line({ {26, 24}, {26, 17} }, 1), "moss", { noshade = true, nopop = true })
local pet = c:ellipse(26, 14, 4, 4):cut(c:ellipse(26, 14, 1, 1))
D.lit(c, pet, "petal", 2)
c:fillMask(c:rect(25, 13, 27, 15), "#f5b82e") c:px(26, 14, "#8f4a1f")
c:px(20, 31, "#e0f4a0") c:px(20, 32, "#e0f4a0") c:px(21, 30, CREAM)
D.fin()
