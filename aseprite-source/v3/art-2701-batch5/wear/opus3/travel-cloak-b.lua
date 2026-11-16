-- travel-cloak-b: cut-b Travel Cloak (Opus redraw, batch5 opus3). 64x64.
-- The hanging cloak on its wooden peg (art-2701-opus/wear/travel-cloak.png, read only) with the opus3 family
-- texture (twill fleck, yellow-green rim light, teal bounce), plus the cut-b mark: a stitched rust tartan patch
-- (ochre stripe, plum over-check, cream running stitch, one lifted corner) on the shaded right skirt.
-- quirk: a moth-nibbled hole in the lit left skirt, and the moth itself fluttering off the edge.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local _, img = O.cutb()
O.save4(img, "travel-cloak-b")
