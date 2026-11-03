local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-telescope: brass spyglass of three telescoping sections on a wooden tripod, aimed up-right.
-- quirk: a small star sticker is stuck on the big tube, and the lens catches a glint.
local c = D.new("ico-telescope")
D.cyl(c, 30, 36, 18, 58, function() return 2 end, D.BRN, { amb = 0.1 })
D.cyl(c, 30, 36, 44, 58, function() return 2 end, D.BRN, { amb = 0.1 })
D.cyl(c, 30, 36, 30, 56, function() return 1.5 end, D.BRN, { amb = 0.1 })
D.cyl(c, 8, 44, 24, 34, function() return 4.2 end, D.YEL, { amb = 0.08 })
D.cyl(c, 24, 34, 40, 24, function() return 5.2 end, D.ORG, { amb = 0.08 })
D.cyl(c, 40, 24, 54, 14, function() return 6.8 end, D.YEL, { amb = 0.08 })
D.cyl(c, 23, 35, 26, 33, function() return 5 end, D.BRN, { amb = 0.1 })
D.cyl(c, 39, 25, 42, 23, function() return 6 end, D.BRN, { amb = 0.1 })
D.disc(c, 56, 12, 5, D.BLU) c:px(54, 10, D.CRM[6]) c:px(55, 10, D.CRM[6]) c:px(54, 11, D.CRM[6])
D.rect(c, 31, 17, 35, 21, D.RED[4]) D.rect(c, 32, 16, 34, 22, D.RED[4]) D.rect(c, 31, 22, 35, 22, D.RED[2]) c:px(32, 18, D.CRM[6])
D.fin()
