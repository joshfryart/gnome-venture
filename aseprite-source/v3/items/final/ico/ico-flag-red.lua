local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-flag-red: red swallowtail pennant on a pole planted in a dirt mound.
-- quirk: a cream star is sewn on the flag, off-centre, a little crooked.
local c = D.new("ico-flag-red")
local mound = c:ellipse(19, 56, 11, 4)
D.lit(mound, D.BRN, 5)
c:part(c:rect(18, 8, 20, 56), "wood", { band = 1 })
D.lit(D.disc(19, 6, 3), D.GOLD, 3)
local fm = HP.mask()
for x = 21, 56 do
  local off = floor(2.6 * sin((x - 21) / 6) + .5)
  local notch = x > 48 and (x - 48) * 1.6 or 0
  for y = 11, 36 do
    local mid = 23.5
    if not (x > 48 and abs(y - mid) < notch) then fm:set(x, y + off) end
  end
end
D.lit(fm, D.RED, 10, { amb = 0.05 })
local st = c:poly{ {31,19},{33,25},{39,25},{34,29},{36,35},{31,31},{26,35},{28,29},{23,25},{29,25} }
D.fill(st:shift(1,-4):clip(fm), "#ffe08a")
D.fin()
