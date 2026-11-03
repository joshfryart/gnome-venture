local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-cog: bold steel gear, eight chunky teeth, hub ring groove, open axle hole.
-- quirk: a tiny green sprout grows up out of the axle hole.
local c = D.new("ico-cog")
local m = D.disc(32, 32, 17)
for i = 0, 7 do
  local a = i * pi / 4 + pi / 8
  m:add(c:line({ { 32 + cos(a) * 14, 32 + sin(a) * 14 }, { 32 + cos(a) * 24, 32 + sin(a) * 24 } }, 7))
end
m:cut(D.disc(32, 32, 6))
D.lit(m, D.STEEL, 6)
D.radial(m, 32, 32, 10.4, 11.6, D.STEEL[2])
D.radial(m, 32, 32, 11.6, 12.4, D.STEEL[5])
for i = 0, 3 do local a = i * pi / 2 + pi / 4 c:fillMask(c:rect(floor(32 + cos(a) * 14.5) - 1, floor(32 + sin(a) * 14.5) - 1, floor(32 + cos(a) * 14.5), floor(32 + sin(a) * 14.5)), D.STEEL[2]) end
D.radial(m, 32, 32, 5.5, 8, D.STEEL[1])
-- sprout in the hole
D.fill(c:rect(31, 33, 32, 37), "#3fa862")
D.lit(D.ell(29, 32, 2.6, 1.5, -0.6), "moss", 1.5)
D.lit(D.ell(35, 31, 2.6, 1.5, 0.6), "moss", 1.5)
D.fin()
