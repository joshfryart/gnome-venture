-- Palm Fidget (ss-palm-fidget), yard 64x64. Haiku pass, c01.
-- bloomcaller, common. A little palm sapling with a trunk face and a fan of fronds, with a coconut at its foot.
-- quirk: it never sits still; the fronds are fanned out mid-flutter and motion dashes trail both sides.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("ss-palm-fidget-yard", 64)

local MOSS = { "#24544a", "#3f9150", "#5aa657", "#7cc35a", "#c4e07a", "#e4f2a0" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982", "#f3d2a0", "#f8e4c0" }
local COCO = { "#3a2630", "#573a35", "#77553c", "#967046", "#b48e58", "#d1af76" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local INK  = P.ink

c:groundShadow(31, 58, 13, 3)

-- trunk with ring marks
local trunk = c:rrect(22, 28, 41, 56, 6)
local tb = {}
trunk:each(function(x, y) if y % 5 == 0 then tb[K(x, y)] = -1 end end)
O.shade(c, trunk, WOOD, { R = 6, bias = tb })

-- coconut at the foot
O.shade(c, c:ellipse(47, 54, 4, 4), COCO, { R = 2, sep = COCO[1] })

-- fanned fronds (tapered tubes)
local fronds = {
  { {31,30}, {22,22}, {12,14}, {6,16} },
  { {31,30}, {40,22}, {50,14}, {58,16} },
  { {31,32}, {20,32}, {10,34}, {4,30} },
  { {31,32}, {42,32}, {52,34}, {60,30} },
}
for _, f in ipairs(fronds) do
  local m, n = O.tube(f, function(t) return 3.5 * (1 - t * 0.8) end)
  O.shadeN(c, m, n, MOSS, { amb = .2, wrap = .4 })
end

-- motion dashes either side
O.dots(c, { {15,40},{14,41},{14,42},{14,43},{15,44} }, SEA[4])
O.dots(c, { {47,40},{48,41},{48,42},{48,43},{47,44} }, SEA[4])

-- face: locked eyes, petal nose, grin
c:eyeLocked(24, 37)
c:eyeLocked(34, 37)
c:cheek(21, 44)
c:cheek(39, 44)
O.dots(c, { {30,42},{31,42},{30,43} }, "#c94f84")
O.dots(c, { {27,46},{28,47},{29,47},{30,47},{31,47},{32,47},{33,46} }, "#51302b")

O.done(c, "ss-palm-fidget-yard")
