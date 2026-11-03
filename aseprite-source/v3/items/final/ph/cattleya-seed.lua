-- cattleya-seed (first draft, Sonnet). quirk: a violet orchid blossom nods from the sprout
local NAME = "cattleya-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
D.scene(c, { leaf = { "#3a4a24", "#586c30", "#78903c", "#98b04e", "#bccc70", "#dce8a0" }, a = {6, 54}, b = {58, 48}, w = 6, seeds = {},
  stem = { 20, 48, 20, 30, leaves = {}, ramp = LEAF },
  extra = function(c)
    -- pinch of dust seeds
    for i = 0, 26 do local x, y = 14 + (i * 7) % 20, 49 + (i * 5) % 5 c:px(x, y, i % 3 == 0 and "#e8c88c" or "#b08a50") end
    for _, p in ipairs{ {16,52},{30,51},{24,47} } do c:px(p[1], p[2], "#fff4d6") end
    -- pseudobulb + strap leaf
    local pb = B.ell(22, 33, 2.6, 6.6, 0.1) B.lit(c, pb, { "#4a5a20", "#6a8030", "#8aa840", "#a8c658", "#c8e078", "#e4f4a0" }, 2.6)
    local lf = B.blade(c, 23, 28, 38, 12, 3.2, LEAF, {})
    -- orchid
    local ox, oy = 40, 24
    for _, p in ipairs{ {-6,-5,3.4,2,-0.6}, {6,-5,3.4,2,0.6}, {0,-8,2,3.4,1.57} } do local m = B.ell(ox + p[1], oy + p[2], p[3], p[4], p[5]) B.lit(c, m, "dusk", 1.4) end
    for _, p in ipairs{ {-5,2,4,3,0.4}, {5,2,4,3,-0.4} } do local m = B.ell(ox + p[1], oy + p[2], p[3], p[4], p[5]) B.lit(c, m, "dusk", 1.8) end
    local lip = B.ell(ox, oy + 5, 3.4, 3.2) B.lit(c, lip, "petal", 1.6) c:fillMask(c:rect(ox - 1, oy + 3, ox + 1, oy + 4), "#ffe38a")
    B.ln(c, 28, 30, 36, 25, "#78903c")
  end })
D.fin()
