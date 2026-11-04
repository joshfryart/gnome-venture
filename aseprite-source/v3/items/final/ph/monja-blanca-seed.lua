-- monja-blanca-seed: tiny golden-brown seeds on a broad pleated lanceolate orchid leaf scrap; sprout with a ribbed leaf and one small ivory bloom (Guatemala's white nun). quirk: the bloom wears a tiny purple lip.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC23.lua")
local B, R, P = D.B, D.R, D.P
local c = D.new("monja-blanca-seed")
D.scrap(c, { ax = 6, ay = 55, bx = 54, by = 44, w = 9.5, leaf = { "#1c4a30", "#2a6a40", "#3e8a50", "#62aa60", "#8cc87c", "#bce49c" }, veins = { 4, 8, 12, 16, 20, 24, 28, 32, 36, 40 }, slant = 0.8 })
D.seeds(c, { ramp = { "#5a3a1c", "#7e5428", "#a47436", "#c8964a", "#e8bc70", "#ffe0a0" }, seeds = { { 16, 50, 2.2, 1.5, 0.5 }, { 20, 52, 2.2, 1.5, -0.3 }, { 24, 49, 2.3, 1.5, 0.2 }, { 28, 52, 2.2, 1.5, 0.8 }, { 32, 49, 2.2, 1.5, -0.2 } } })
B.ln(c, 36, 46, 36, 30, "#4a8a50") B.ln(c, 37, 46, 37, 31, "#86c06a")
B.blade(c, 36, 40, 22, 20, 3.2, R.leaf, { veins = { 3, 6, 9, 12, 15 } })
B.blade(c, 37, 40, 50, 22, 3.2, R.leaf, { veins = { 3, 6, 9, 12, 15 } })
local W = { "#a89a8a", "#d0c4b2", "#ece4d2", "#f8f2e4", "#fffaf0", "#ffffff" }
W[6] = "#fffcf4"
for _, p in ipairs{ { 36, 24 }, { 31, 28 }, { 41, 28 }, { 33, 32 }, { 39, 32 } } do D.el(c, p[1], p[2], 3, 3, W, 1.5) end
c:fillMask(B.ell(36, 29, 2, 2), "#8a4a9a") c:px(36, 29, "#c8a0e0")
D.fin()
