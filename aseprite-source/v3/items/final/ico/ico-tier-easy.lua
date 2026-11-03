local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tier-easy: round teal badge with a single fresh sprout inside a cream ring.
-- quirk: a tiny ladybug sits on the right leaf.
local c = D.new("ico-tier-easy")
local disc = c:ellipse(32, 32, 24, 24)
D.lit(c, disc, D.TEAL, 8)
D.ring(c, 32, 32, 19, D.CRM[5]) D.ring(c, 32, 32, 18, D.CRM[3])
c:fillMask(c:rect(30, 33, 33, 47), D.GRN[3]) c:fillMask(c:rect(30, 33, 30, 47), D.GRN[5])
D.lit(c, D.ell(23, 28, 8, 4.5, -0.5), D.GRN, 3)
D.lit(c, D.ell(41, 26, 8, 4.5, 0.5), D.GRN, 3)
c:fillMask(c:ellipse(43, 24, 2, 2), D.RED[4]) c:px(43, 22, INK) c:px(43, 25, INK) c:px(42, 23, CREAM)
c:fillMask(c:rect(27, 48, 37, 48), D.TEAL[1])
D.fin()
