-- travel-cloak-b-lined: Lined rank of the cut-b Travel Cloak (batch5 opus3). 64x64.
-- Starts from the finished cut-a Lined (art-2701-batch3/wear/opus3/travel-cloak-lined.png, read only: fleece ruff,
-- fleece facings with blanket-stitch, twill, rim, bounce) and grafts in the exact cut-b patch, hole and moth of
-- travel-cloak-b. The Lined darn on the left skirt is unpicked (one mend story per icon: the tartan patch).
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local baseT, baseB = O.cutb()
local img = O.load(O.OP3 .. "travel-cloak-lined.png")
for y = 43, 47 do for x = 11, 15 do img:putPixel(x, y, baseT:getPixel(x, y)) end end
O.graftB(img, baseT, baseB)
O.reink(img)
O.antennae(img)
O.save4(img, "travel-cloak-b-lined")
