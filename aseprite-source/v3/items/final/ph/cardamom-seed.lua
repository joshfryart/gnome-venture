-- cardamom-seed (first draft, Sonnet). quirk: a fat green pod sits among the seeds
local NAME = "cardamom-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local SD = { "#2a1410", "#4a1e18", "#6a2c1e", "#8e4228", "#b06034", "#d08a50" }
D.scene(c, { leaf = { "#1e4a34", "#2c6e48", "#3e9060", "#5ab078", "#82ce94", "#b0e8bc" }, a = {6, 54}, b = {58, 46}, w = 6, seeds = {
  { 14, 50, 3, 2.5, 0.8, SD }, { 19, 47, 3, 2.5, -0.6, SD }, { 24, 51, 3, 2.5, 0.2, SD }, { 30, 49, 3, 2.5, -0.9, SD } },
  stem = { 46, 46, 46, 28, leaves = { {38, 28, 9, 2.2, -0.5}, {55, 25, 9, 2.2, 0.5}, {46, 17, 2.4, 9, 1.57} }, ramp = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" } },
  extra = function(c)
    for _, s in ipairs{ {14,50},{19,47},{24,51},{30,49} } do B.ln(c, s[1] - 2, s[2], s[1] + 2, s[2] + 1, SD[1]) c:px(s[1] - 1, s[2] - 1, SD[6]) end
    local pd = B.ell(36, 55, 5.4, 3, -0.1) B.lit(c, pd, { "#24442a", "#3a6a34", "#5a9444", "#7cb450", "#a4cf66", "#d0e890" }, 2.4)
    B.ln(c, 32, 54, 40, 54, "#3a6a34", pd)
  end })
D.fin()
