local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-grapes: plump purple grape bunch with a leaf and curly stem. quirk: one unripe green grape in the bunch.
local c = D.new("ico-grapes")
local rows = { { 22, { 18, 27, 36, 45 } }, { 31, { 22.5, 31.5, 40.5 } }, { 40, { 27, 36 } }, { 49, { 31.5 } } }
local green = D.GREEN
D.c:groundShadow(32, 58, 5, 1)
for ri, r in ipairs(rows) do
  for ci, x in ipairs(r[2]) do
    local g = D.ell(x, r[1], 4.6, 4.6)
    local ramp = (ri == 2 and ci == 3) and D.GREEN or D.PURP
    D.lit(g, ramp, 4.6, { amb = 0.06 })
    D.px(fl(x - 2), fl(r[1] - 2), D.CR) D.px(fl(x - 1), fl(r[1] - 3), D.CR)
    D.fill(D.rect(fl(x + 1), fl(r[1] + 3), fl(x + 2), fl(r[1] + 3)), ramp[1])
  end
end
D.ln(32, 17, 33, 11, D.BRN[3]) D.ln(33, 17, 34, 10, D.BRN[4])
D.ln(34, 10, 38, 8, D.BRN[4])
D.leaf(33, 15, 53, 7, 6, "moss", { 5, 9 })
D.fin()
