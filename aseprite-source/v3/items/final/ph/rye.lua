-- rye (first draft, Sonnet). Three slim rye stalks tied with a straw band: long bearded ears (paired grains plus
-- long pale awns), jointed straw, ribbon leaves at the base.
-- quirk: the right-hand ear is so heavy it droops over, pointing its awns at the ground.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rye")
local floor, sin, cos = math.floor, math.sin, math.cos
local function ear(x, y, ux, uy)
  local px, py = -uy, ux
  local g = A.R("#c9a050")
  for j = 0, 5 do
    local bx, by = x + ux * j * 2.3, y + uy * j * 2.3
    for s = -1, 1, 2 do
      local gx, gy = bx + px * s * 1.7, by + py * s * 1.7
      A.ell(gx, gy, 1.3, 2.2, math.atan(uy, ux) - 1.57) A.lit(c, A.ell(gx, gy, 1.2, 2.1, math.atan(uy, ux) - 1.57), g, 1, { amb = .1 })
      local ex, ey = gx + ux * 8 + px * s * 1.5, gy + uy * 8 + py * s * 1.5
      A.ln(c, floor(gx + ux * 2), floor(gy + uy * 2), floor(ex), floor(ey), (j % 2 == 0) and "#e8d090" or "#f4e6b0")
    end
  end
end
-- leaves
A.blade(c, 30, 57, 17, 36, 2.4, "#8fae60", { veins = {}, slant = 2 })
A.blade(c, 31, 57, 48, 38, 2.4, "#7a9a56", { veins = {}, slant = 2 })
-- stalks
local st = { { 28, 57, 22, 38 }, { 31, 57, 32, 30 }, { 34, 57, 44, 36 } }
for _, s in ipairs(st) do A.rod(c, s[1], s[2], s[3], s[4], .8, "#b8a45a", { amb = .1 }) end
-- nodes
for _, s in ipairs(st) do local x, y = s[1] + (s[3] - s[1]) * .55, s[2] + (s[4] - s[2]) * .55 c:px(floor(x), floor(y), "#6e5a30") c:px(floor(x) + 1, floor(y), "#e8d890") end
-- drooping third stalk top
A.ln(c, 44, 36, 47, 30, "#b8a45a") A.ln(c, 47, 30, 51, 30, "#b8a45a")
ear(22, 36, .08, -1) ear(32, 28, 0, -1) ear(52, 32, .35, .94)
-- straw band
for x = 27, 36 do c:px(x, 44, "#d98322") c:px(x, 45, "#f5b82e") end
c:px(28, 46, "#d98322") c:px(35, 46, "#d98322")
A.fin()
