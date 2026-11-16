-- travel-cloak-b-fine: Fine rank of the cut-b Travel Cloak (batch5 opus3). 64x64.
-- Starts from the finished cut-a Fine (art-2701-batch3/wear/opus3/travel-cloak-fine.png, read only: gold brooch
-- with garnet, gold-piped facings and hem, filigree curls, twill, rim, bounce) and grafts in the exact cut-b patch,
-- hole and moth of travel-cloak-b. The gold bee is unpicked: it sat where the patch goes, and the moth is the insect here.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local baseT, baseB = O.cutb()
local img = O.load(O.OP3 .. "travel-cloak-fine.png")
for y = 30, 34 do for x = 39, 46 do img:putPixel(x, y, baseT:getPixel(x, y)) end end
O.graftB(img, baseT, baseB)
O.reink(img)
O.antennae(img)
O.save4(img, "travel-cloak-b-fine")
