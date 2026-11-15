-- Palm Fidget (ss-palm-fidget), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: fronds mid-flutter with motion dashes.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("ss-palm-fidget-perch", 36)

local MOSS = { "#24544a", "#3f9150", "#5aa657", "#7cc35a", "#c4e07a", "#e4f2a0" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982", "#f3d2a0", "#f8e4c0" }
local COCO = { "#3a2630", "#573a35", "#77553c", "#967046", "#b48e58", "#d1af76" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local INK  = P.ink

c:groundShadow(17, 33, 10, 2)

local trunk = c:rrect(12, 13, 23, 32, 3)
O.shade(c, trunk, WOOD, { R = 3 })
O.shade(c, c:ellipse(27, 30, 2, 2), COCO, { R = 1, sep = COCO[1] })

local fronds = {
  { {17,14}, {10,8}, {4,9}, {1,12} },
  { {17,14}, {24,8}, {31,9}, {34,12} },
  { {17,17}, {10,18}, {4,17}, {2,20} },
  { {17,17}, {24,18}, {31,17}, {33,20} },
}
for _, f in ipairs(fronds) do
  local m, n = O.tube(f, function(t) return 2.2 * (1 - t * 0.8) end)
  O.shadeN(c, m, n, MOSS, { amb = .2, wrap = .4 })
end

O.dots(c, { {6,22},{5,23},{5,24} }, SEA[4])
O.dots(c, { {29,22},{30,23},{30,24} }, SEA[4])

c:eyeSmall(15, 20)
c:eyeSmall(20, 20)
O.dot(c, 18, 23, "#c94f84")
O.dots(c, { {15,25},{16,26},{17,26},{18,26},{19,25} }, "#51302b")

O.done(c, "ss-palm-fidget-perch")
