local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("bok-choy-seed")
-- bok-choy-seed: five tiny round dark-brown mustard seeds on a broad white-ribbed bok choy leaf scrap; sprout is two spoon-shaped cotyledon leaves with a pale rib. quirk: one seed has rolled right off onto its own shadow.
D.E(30, 50, 25, 7, -0.1, D.LEAF2, 3)
D.ln(7, 52, 52, 48, "#e6f0c0") D.ln(8, 52, 20, 47, "#bfe688") D.ln(30, 50, 40, 44, "#bfe688") D.ln(18, 51, 26, 55, "#5a9a50")
local S = {"#1a0c08","#341a10","#522a18","#744024","#965c34","#c08450"}
for i, p in ipairs({{14,50},{22,49},{30,51},{38,49},{46,50}}) do D.seed(p[1], p[2], 2.4, 2.4, 0, S) end
D.stem2(30, 46, 30, 32)
D.lf(23, 28, 6, 4, -0.4, D.LEAF) D.lf(38, 27, 6, 4, 0.4, D.LEAF)
D.ln(18, 30, 29, 27, "#e6f0c0") D.ln(43, 29, 33, 26, "#e6f0c0")
D.fin()
