-- cauliflower-seed (first draft, Sonnet). quirk: a pale curd bump peeks out at the leaf base
local NAME = "cauliflower-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local BN = { "#3a2418", "#5e3a26", "#82583a", "#a47a52", "#c8a070", "#e8c8a0" }
local BL = { "#1e4a50", "#2e6e70", "#44908a", "#62b0a2", "#88cebc", "#b4e8d4" }
D.scene(c, { leaf = BL, seeds = {
  { 14, 51, 2.8, 2.8, 0, BN }, { 21, 49, 2.8, 2.8, 0, BN }, { 28, 52, 2.8, 2.8, 0, BN }, { 20, 54, 2.4, 2.4, 0, BN }, { 34, 49, 2.8, 2.8, 0, BN } },
  stem = { 42, 47, 42, 32, leaves = { {34, 28, 7, 5, 0.3}, {50, 28, 7, 5, -0.3} }, ramp = BL },
  extra = function(c)
    for _, s in ipairs{ {14,51},{21,49},{28,52},{20,54},{34,49} } do c:px(s[1] - 1, s[2] - 1, "#fff4d6") end
    -- wavy edge on leaves
    local cd = B.ell(42, 33, 3, 2.4) B.lit(c, cd, { "#a89a6a", "#ccbe8a", "#e4d8a6", "#f4ecc4", "#fff8e0", "#ffffee" }, 1.8)
    for x = 28, 56, 4 do c:px(x, 21 + (x % 8) // 4, BL[6]) end
  end })
D.fin()
