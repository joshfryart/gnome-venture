-- cantuta-seed (first draft, Sonnet). quirk: a tiny crimson trumpet bud on the stem
local NAME = "cantuta-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local WG = { "#6a5a3a", "#9a8a5a", "#c0b078", "#d8cc98", "#ece4b8", "#fbf6dc" }
D.scene(c, { leaf = { "#2e4a2a", "#44683a", "#5e8a48", "#80aa5a", "#a4c878", "#cce4a0" }, seeds = {
  { 14, 51, 5, 3.4, 0.4, WG }, { 26, 49, 5, 3.4, -0.3, WG }, { 38, 47, 5, 3.4, 0.2, WG } },
  stem = { 38, 44, 38, 30, leaves = { {33, 33, 3, 1.8, 0.4}, {43, 31, 3, 1.8, -0.4}, {33, 26, 3, 1.8, 0.3}, {43, 25, 3, 1.8, -0.3} }, ramp = LEAF },
  extra = function(c)
    for _, s in ipairs{ {14,51},{26,49},{38,47} } do c:fillMask(c:rect(s[1] - 1, s[2] - 1, s[1] + 1, s[2] + 1), "#5a3a1c") c:px(s[1], s[2], "#2a1a10") end
    local fl = H.sweep({ {38, 24}, {42, 18}, {46, 14}, {50, 12} }, function(t) return 1.2 + t end)
    H.lit(c, fl, "ember", { R = 1.4 }) c:px(51, 11, "#ffe38a")
  end })
D.fin()
