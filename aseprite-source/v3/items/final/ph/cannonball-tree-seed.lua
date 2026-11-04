-- cannonball-tree-seed (first draft, Sonnet). quirk: fuzzy fibres cling to every seed
local NAME = "cannonball-tree-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local FB = { "#4a3420", "#6e5030", "#92704a", "#b8946a", "#d8b88a", "#f0dcae" }
D.scene(c, { leaf = { "#2a4a1c", "#3e6a26", "#58882e", "#78a83c", "#9cc85a", "#c4e482" }, seeds = {
  { 16, 50, 4.4, 3, 0.3, FB }, { 28, 48, 4.6, 3.2, -0.2, FB }, { 40, 46, 4.2, 3, 0.1, FB } },
  stem = { 40, 43, 40, 28, leaves = { {33, 26, 6, 3.4, 0.3}, {47, 24, 6, 3.4, -0.3}, {40, 19, 3.4, 4.6, 1.57} }, ramp = LEAF },
  extra = function(c) for _, s in ipairs{ {13,47},{19,46},{25,45},{31,45},{37,43},{43,43},{40,48},{24,52} } do c:px(s[1], s[2], FB[5]) c:px(s[1]-1, s[2]-1, FB[4]) end end })
D.fin()
