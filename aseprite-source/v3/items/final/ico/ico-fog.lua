local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fog: three stacked drifting fog banks in cool blue-grey.
-- quirk: two small eyes peek out of the middle bank.
local c = D.new("ico-fog")
local function bank(x0, x1, y, h, bumps)
  local m = c:rrect(x0, y, x1, y + h, h // 2)
  for _, b in ipairs(bumps) do m:add(c:ellipse(b[1], y + 1, b[2], b[3])) end
  return m
end
local b1 = bank(8, 44, 14, 9, { {22,7,6},{34,5,5} })
D.lit(b1, D.FOG, 6, { amb = 0.05 })
local b3 = bank(16, 56, 42, 9, { {30,7,5},{44,6,6} })
D.lit(b3, D.FOG, 6, { amb = 0.05 })
local b2 = bank(6, 52, 27, 10, { {20,8,6},{34,6,5},{44,7,5} })
D.lit(b2, D.FOG, 6, { amb = 0.05 })
c:eyeSmall(24, 28) c:eyeSmall(32, 28)
D.fill(c:rect(27, 34, 29, 34), D.FOG[1])
D.fin()
