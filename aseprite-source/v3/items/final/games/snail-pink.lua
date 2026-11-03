local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- snail-pink: a scalloped candy-swirl shell (frilled rim, pink with cream spiral), peachy body, jaunty.
-- quirk: a gold-edged ribbon bow is tied around the left eyestalk.
local c = D.new("snail-pink")
local BODY = { "#9a5a5a", "#c88a78", "#e4a894", "#f4c4aa", "#fcdcc4", "#fff0e0" }
local SH = { "#7d2c5e", "#a83c78", "#c94f84", "#e8688e", "#f5809f", "#ffc4d8" }
c:groundShadow(30, 57, 26, 2)
local bm = D.sweep({ {6, 53}, {26, 56}, {46, 54}, {54, 40} }, function(t) return t < 0.25 and 1 + t * 11 or (t > 0.8 and 3.6 - (t - 0.8) * 4 or 3.6) end, 60)
bm:add(c:ellipse(54, 39, 4, 4))
D.lit(c, bm, BODY, 3, { amb = 0.15 })
for x = 12, 48 do if bm:has(x, 57) then D.shift(c, x, 57, BODY, -2) end end
D.stalk(c, 51, 36, 49, 25, BODY[2])
D.stalk(c, 56, 36, 58, 27, BODY[2])
c:px(57, 42, BODY[1]) c:px(58, 42, BODY[1])
-- scalloped shell
local shm = HP.mask()
for y = 14, 56 do for x = 8, 48 do
  local dx, dy = x - 28, y - 38
  local a = math.atan(dy, dx)
  if sqrt(dx * dx + dy * dy) <= 13 + 1.6 * sin(a * 8) then shm:set(x, y) end
end end
D.lit(c, shm, SH, 7, { amb = 0.08 })
D.seam(c, bm, shm, BODY[1])
D.spiral(c, 28, 38, 12, 2.6, CREAM, shm, 0.8)
D.spiral(c, 28, 39, 12, 2.6, SH[1], shm, 0.8)
c:px(20, 28, "#ffe8f0") c:px(21, 28, "#ffe8f0") c:px(19, 30, "#ffe8f0")
-- bow on left stalk
c:paint({ "gg.gg", "gKKKg", "gg.gg" }, 46, 28, { g = "#f5b82e", K = "#d98322" })
c:paint({ "ee.ee", "eKKKe", "ee.ee" }, 46, 27, { e = "#e8493b", K = "#6e2038" })
D.fin()
