-- Snowcrag Halo (pl-owl-5), perch sprite 36x36. Hand-built at this size.
-- quirk: a short aurora arc hangs over the hollow.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-5-perch", 36)

local SNW = { "#6e86ac", "#8aa0c0", "#a8bcd8", "#c4d4e8", "#dce8f4", "#eef4fa" }
local AUR = { "#3f9150", "#62b05a", "#93cc6a", "#7e58b8", "#a486d8" }

for i = 0, 180 do
  local a = math.pi * (i / 180)
  local x = math.floor(18 + 13 * math.cos(a) + .5)
  local y = math.floor(22 - 11 * math.sin(a) + .5)
  if y >= 2 and y <= 17 then
    local col = (i % 16 < 8) and AUR[2] or AUR[4]
    O.dot(c, x, y, col)
  end
end

local mound = c:ellipse(18, 25, 13, 9)
mound:cut(c:rect(0, 0, 35, 17))
O.shade(c, mound, SNW, { sphere = { 16, 22, 12 }, amb = .2, wrap = .3, sep = SNW[1] })
O.flat(c, c:ellipse(18, 19, 7, 2), SNW[2], "hollow")

c:eyeSmall(14, 24) c:eyeSmall(20, 24)
O.dots(c, { { 16, 29 }, { 17, 29 }, { 18, 29 } }, SNW[1])

O.done(c, "pl-owl-5-perch")
