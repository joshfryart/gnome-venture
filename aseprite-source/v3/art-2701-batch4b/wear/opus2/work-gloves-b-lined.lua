-- work-gloves-b-lined: lined rank of the work-gloves cut b (stitched patch), Opus second pass, batch4b. 64x64.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local img, M = O.graft(O.OP3 .. "work-gloves-lined.png", O.V3 .. "/art-2701-opus/wear/work-gloves-b.png", O.PH .. "work-gloves.png")
O.save4(img, "work-gloves-b-lined")
