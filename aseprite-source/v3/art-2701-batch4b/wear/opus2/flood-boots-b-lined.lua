-- flood-boots-b-lined: lined rank of the flood-boots cut b (stitched patch), Opus second pass, batch4b. 64x64.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local img, M = O.graft(O.OP3 .. "flood-boots-lined.png", O.V3 .. "/art-2701-opus/wear/flood-boots-b.png", O.PH .. "flood-boots.png")
O.save4(img, "flood-boots-b-lined")
