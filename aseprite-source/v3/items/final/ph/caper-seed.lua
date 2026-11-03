-- caper-seed (first draft, Sonnet). quirk: a round caper bud rests beside the seeds
local NAME = "caper-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local KD = { "#3a2a1c", "#5a4228", "#7e5e36", "#a4804c", "#c8a468", "#e8c88c" }
D.scene(c, { leaf = { "#24483a", "#34705a", "#4a9068", "#68b078", "#8cce92", "#b8e8b4" }, seeds = {
  { 13, 52, 3.4, 3.4, 0, KD }, { 22, 49, 3.4, 3.4, 0, KD }, { 31, 51, 3.4, 3.4, 0, KD } },
  stem = { 40, 46, 40, 30, leaves = { {34, 28, 4.6, 3.8, 0.3}, {46, 26, 4.6, 3.8, -0.3}, {40, 20, 4, 3.4, 0} }, ramp = { "#173f36", "#21593f", "#3a7a50", "#5a9a5e", "#80ba70", "#a8d890" } },
  extra = function(c)
    -- notch in each seed (kidney)
    for _, s in ipairs{ {13,52},{22,49},{31,51} } do c:px(s[1] + 2, s[2] - 1, KD[1]) c:px(s[1] + 2, s[2], KD[2]) end
    local bud = B.ell(50, 52, 3.6, 3.2) B.lit(c, bud, "moss", 2.4) c:px(49, 51, "#e4f6a8") B.ln(c, 50, 49, 52, 46, "#3f9150")
  end })
D.fin()
