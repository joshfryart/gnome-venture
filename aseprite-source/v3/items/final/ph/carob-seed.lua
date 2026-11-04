-- carob-seed (first draft, Sonnet). quirk: a thin slice of pod still wraps one seed
local NAME = "carob-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local CS = { "#2a1410", "#4a2418", "#74401e", "#a06a2e", "#c8923e", "#ecbc66" }
D.scene(c, { leaf = { "#173f36", "#21593f", "#2e7646", "#3e8a44", "#5ea450", "#8cc468" }, seeds = {
  { 14, 50, 3.6, 4.4, 0.2, CS }, { 25, 49, 3.6, 4.4, -0.1, CS }, { 36, 47, 3.6, 4.4, 0.3, CS } },
  stem = { 36, 43, 36, 30, leaves = { {30, 32, 4.4, 2.6, 0.3}, {42, 30, 4.4, 2.6, -0.3}, {29, 25, 4, 2.4, 0.3}, {43, 24, 4, 2.4, -0.3}, {36, 20, 3, 2, 1.57} }, ramp = LEAF },
  extra = function(c)
    for _, s in ipairs{ {14,50},{25,49},{36,47} } do c:fillMask(B.ell(s[1] + .5, s[2] + 1, 2, 2.4), CS[4]) c:fillMask(B.ell(s[1] - .5, s[2] - 1, 1.2, 1.4), CS[5]) end
    -- pod slice
    local sl = H.sweep({ {44, 56}, {48, 52}, {52, 54}, {58, 50} }, function(t) return 2.6 end)
    H.lit(c, sl, { "#2a1410", "#4a2418", "#6e3a22", "#8e5430", "#b0743e", "#d09a5c" }, { R = 2 })
  end })
D.fin()
