local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-wind: three fat curling gusts in pale sky blue, streaming left to right.
-- quirk: a leaf tumbles along in the top gust.
local c = D.new("ico-wind")
local function gust(p, w, curl)
  local pts = D.bez(p, 16)
  local m = D.swept(c, pts, function(t) return w * (0.6 + 0.4 * sin(t * pi * 0.9 + 0.3)) end)
  D.lit(c, m, D.ICE, 2)
  if curl then
    local e = p[4]
    local sp = D.arc(e[1], e[2] + curl[2] * -5, 5, curl[1], curl[1] + curl[2] * 270, 14)
    D.lit(c, D.swept(c, sp, function() return 1.8 end), D.ICE, 1)
  end
end
gust({ {6, 20}, {24, 14}, {38, 26}, {48, 20} }, 3.2, { 90, -1 })
gust({ {8, 34}, {24, 40}, {44, 28}, {54, 36} }, 3.2, { -90, 1 })
gust({ {6, 49}, {18, 54}, {32, 44}, {42, 50} }, 3.2, { -90, 1 })
D.leaf(c, 18, 12, 30, 6, 4, "moss", { 3 })
D.fin()
