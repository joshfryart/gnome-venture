-- berry-tart: a round fruit tart seen 3/4, crimped golden crust, glossy red and blue berries. quirk: one wedge has been bitten out, showing the flaky layers, and a steam curl rises.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("berry-tart")
local PA = { "#6a3a1c", "#8f5a24", "#b8822e", "#d8a448", "#eecb70", "#fbe8a4" }
local RD = { "#4a1630", "#7a2036", "#a82c3c", "#d4403a", "#ee6a50", "#ff9a78" }
D.sh(32, 52, 25, 3)
-- rim front thickness
local under = D.ell(32, 41, 25, 14, 0)
D.lit(under, PA, 4)
local top = D.ell(32, 37, 25, 13, 0)
D.lit(top, { PA[2], PA[3], PA[4], PA[5], PA[5], PA[6] }, 2.5, { wrap = .5 })
-- crimp
for a = 0, 6.28, .26 do
  local x, y = floor(32 + cos(a) * 24 + .5), floor(37 + sin(a) * 12.4 + .5)
  c:px(x, y, PA[2]) if sin(a) > -.3 then c:px(x, y + 1, PA[1]) end
end
-- filling
local fill = D.ell(32, 37, 19, 9.5, 0)
D.lit(fill, RD, 3.5)
-- berries
local pts = { {20,36,3.2,0}, {27,33,3.4,1}, {35,33,3.2,0}, {43,36,3.2,1}, {25,40,3.4,0}, {33,39,3.6,1}, {41,41,3,0}, {18,41,2.6,1}, {32,35,2.6,0} }
for i, p in ipairs(pts) do
  local b = D.ell(p[1], p[2], p[3], p[3] * .9, 0)
  D.lit(b, p[4] == 1 and D.INDG or { RD[1], RD[2], RD[3], RD[4], "#ff6a58", "#ffd2c0" }, 2.2)
  c:px(p[1] - 1, p[2] - 1, "#fff4d6")
end
-- bite out of the right side
local bite = D.ell(55, 39, 6.5, 8, 0):add(D.ell(52, 33, 3.5, 3.5, 0)):add(D.ell(53, 45, 4, 3, 0))
D.erase(bite)
-- flaky cut face
c:paint({ "xxxx" }, 48, 43, { x = PA[5] })
for y = 33, 45 do if not bite:has(46, y) and bite:has(47, y) then c:px(46, y, PA[5]) end end
-- steam
for _, p in ipairs{ {30,22}, {31,21}, {31,20}, {30,19}, {30,18}, {31,17}, {32,16} } do c:px(p[1], p[2], "#e8e4f0") end
for _, p in ipairs{ {31,22}, {32,21}, {32,20}, {31,19} } do c:px(p[1], p[2], "#b8b4c8") end
D.fin()
