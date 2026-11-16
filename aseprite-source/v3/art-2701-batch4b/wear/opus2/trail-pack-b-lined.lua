-- trail-pack-b-lined: lined rank of the trail-pack cut b (stitched patch), Opus second pass, batch4b. 64x64.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local img, M = O.graft(O.OP3 .. "trail-pack-lined.png", O.V3 .. "/art-2701-next8/opus3/trail-pack-b.png", O.PH .. "trail-pack.png")
O.save4(img, "trail-pack-b-lined")
