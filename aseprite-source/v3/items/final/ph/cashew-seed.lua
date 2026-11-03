-- cashew-seed (first draft, Sonnet). quirk: a nut kidney curls beside a ripe red apple slice
local NAME = "cashew-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local NT = { "#2a2420", "#4a4036", "#6e6252", "#948670", "#b8aa8e", "#dccfb0" }
local function kidney(x, y, flip)
  local k = H.sweep({ {x - 5 * flip, y - 3}, {x - 2 * flip, y - 6}, {x + 4 * flip, y - 2}, {x + 1 * flip, y + 4} }, function(t) return 2.8 - abs(t - 0.5) end)
  H.lit(c, k, NT, { R = 2 }) c:px(x - 2 * flip, y - 4, NT[6])
end
D.scene(c, { leaf = { "#24483a", "#34705a", "#4a9068", "#68b078", "#8cce92", "#b8e8b4" }, seeds = {}, 
  stem = { 40, 44, 38, 28, leaves = { {31, 27, 6, 4.4, 0.2}, {47, 24, 6, 4.4, -0.3}, {38, 18, 5, 4, 0} }, ramp = { "#2a4a2a", "#3e6a34", "#588a40", "#78aa52", "#9cc872", "#c4e49c" } },
  extra = function(c)
    kidney(14, 52, 1) kidney(26, 50, -1) kidney(34, 52, 1)
    local ap = B.ell(52, 53, 4, 3.4, 0.2) B.lit(c, ap, { "#7a1c2a", "#b02e36", "#d84a30", "#f07a2e", "#fba83e", "#ffd878" }, 2.4) c:px(51, 52, "#fff4d6")
  end })
D.fin()
