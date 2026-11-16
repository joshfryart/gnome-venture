-- Snowcrag Halo (pl-owl-5), yard sprite 64x64. Rootwarden, uncommon. A round snowy hollow where the owlets nap under the aurora.
-- quirk: an aurora arc hangs over the hollow, green and violet.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-5-yard", 64)

local SNW = { "#6e86ac", "#8aa0c0", "#a8bcd8", "#c4d4e8", "#dce8f4", "#eef4fa" }
local AUR = { "#3f9150", "#62b05a", "#93cc6a", "#7e58b8", "#a486d8" }

-- aurora arc, behind the snow
for i = 0, 180 do
  local a = math.pi * (i / 180)
  local x = math.floor(32 + 26 * math.cos(a) + .5)
  local y = math.floor(34 - 24 * math.sin(a) + .5)
  if y >= 4 and y <= 30 then
    local col = (i % 16 < 8) and AUR[2] or AUR[4]
    O.dot(c, x, y, col)
  end
end

local mound = c:ellipse(32, 44, 24, 16)
mound:cut(c:rect(0, 0, 63, 27))
O.shade(c, mound, SNW, { sphere = { 30, 40, 22 }, amb = .2, wrap = .3, sep = SNW[1] })

-- round hollow sunk into the top of the snow
local hollow = c:ellipse(32, 31, 13, 4)
O.flat(c, hollow, SNW[2], "hollow")

c:eyeLocked(23, 37)
c:eyeLocked(36, 37)
O.dots(c, { { 29, 43 }, { 30, 44 }, { 31, 44 }, { 32, 44 }, { 33, 43 } }, SNW[1])

O.done(c, "pl-owl-5-yard")
