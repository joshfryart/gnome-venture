local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-cherry")
local CR, INK = D.CR, D.INK
-- ico-cherry: two glossy cherries on thin stems that meet at a twig, one pointed leaf.
-- quirk: a ladybird sits on the leaf.
D.leaf(33, 11, 55, 17, 5, "moss", { 3, 6 })
D.poly(c, { {20, 38}, {24, 24}, {31, 13}, {33, 11} }, "#3f9150") D.poly(c, { {43, 40}, {40, 24}, {35, 14}, {33, 11} }, "#3f9150")
D.rect(32, 9, 34, 11, "#864c33")
D.lit(c:ellipse(19, 44, 11, 11), D.RED, 9, { amb = 0.06 })
D.lit(c:ellipse(43, 46, 11, 11), D.RED, 9, { amb = 0.06 })
D.fill(c:rect(16, 36, 22, 37), D.RED[2])
D.rect(15, 38, 16, 39, D.CR) D.rect(39, 40, 40, 41, D.CR) D.px(15, 40, D.CR)
D.fill(c:ellipse(19, 54, 4, 1), D.RED[1])
-- ladybird
D.fill(c:ellipse(47, 14, 2, 2), "#d4403a"); D.px(47, 12, INK) D.px(46, 14, INK) D.px(48, 14, INK) D.px(45, 12, INK) D.px(45, 13, INK)
D.fin()
