local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-finish: waving black-and-cream chequered flag on a wooden pole.
-- quirk: a golden ball on top and one square is missing (flag gnawed).
local c = D.new("ico-finish")
c:groundShadow(16, 58, 8, 2)
c:part(c:rect(14, 10, 16, 57), "wood", { band = 1 })
D.lit(D.disc(15, 8, 3), D.GOLD, 3)
local fm = HP.mask()
for x = 18, 54 do
  local off = floor(2.4 * sin((x - 18) / 5.5) + .5)
  for y = 12, 37 do fm:set(x, y + off) end
end
fm:cut(c:ellipse(53, 38, 3, 3))
c:fillMask(fm, CR)
fm:each(function(x, y)
  local off = floor(2.4 * sin((x - 18) / 5.5) + .5)
  local cx, cy = floor((x - 18) / 6), floor((y - off - 12) / 6)
  if (cx + cy) % 2 == 0 then c:px(x, y, "#3a2a48") elseif cy >= 3 or (x - 18) % 6 == 5 then c:px(x, y, "#e6cfa8") end
end)
D.fin()
