local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-rainbow: a fat four-band rainbow arch resting on two fluffy clouds.
-- quirk: a little gold coin glints at the end of the arch.
local c = D.new("ico-rainbow")
local bands = { D.RED, D.YEL, D.GRN, D.BLU }
local cx, cy = 32, 46
local arch = HP.mask()
for y = 6, 46 do for x = 4, 60 do
  local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
  if d >= 12 and d < 28 then
    local i = min(4, floor((28 - d) / 16 * 4) + 1)
    local rr = bands[i]
    local t = 4
    local sh = ((x - cx) + (y - cy)) / d
    local tone = sh < -0.5 and 5 or (sh > 0.6 and 2 or 4)
    c:px(x, y, rr[tone])
    arch:set(x, y)
  end
end end
local function cloud(x, y)
  local m = c:ellipse(x, y, 8, 5):add(c:ellipse(x + 7, y - 3, 6, 6)):add(c:ellipse(x - 6, y + 1, 5, 4)):add(c:rect(x - 9, y, x + 12, y + 5))
  D.lit(c, m, D.CRM, 6, { amb = 0.12 })
end
cloud(11, 52) cloud(52, 52)
c:fillMask(c:ellipse(56, 41, 3, 3), D.YEL[3]) c:px(55, 40, CREAM) c:px(56, 43, D.YEL[1]) c:px(57, 43, D.YEL[1])
D.fin()
