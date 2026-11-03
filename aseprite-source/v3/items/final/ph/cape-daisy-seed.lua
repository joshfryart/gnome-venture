-- cape-daisy-seed (first draft, Sonnet). quirk: a miniature daisy blooms on a short stalk
local NAME = "cape-daisy-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local DK = { "#1e1618", "#2e2428", "#463a3c", "#645456", "#8a7678", "#b8a6a4" }
local seeds = {}
D.scene(c, { leaf = { "#2a5030", "#3a7040", "#4e9050", "#6eb064", "#92cc80", "#bce6a4" }, seeds = {
  { 14, 51, 4, 1.8, 0.7, DK }, { 22, 49, 4, 1.8, -0.5, DK }, { 30, 51, 4, 1.8, 0.2, DK }, { 38, 47, 4, 1.8, -0.7, DK } },
  stem = { 46, 48, 46, 28, leaves = { {40, 34, 5, 1.8, 0.5}, {52, 36, 5, 1.8, -0.5}, {40, 42, 4, 1.6, 0.4} }, ramp = LEAF },
  extra = function(c)
    for _, s in ipairs{ {14,51,0.7},{22,49,-0.5},{30,51,0.2},{38,47,-0.7} } do
      c:px(floor(s[1] - 3 * cos(s[3]) + .5), floor(s[2] - 3 * sin(s[3]) + .5), "#fff4d6") end
    for i = 0, 7 do local a = i * pi / 4 local m = B.ell(46 + cos(a) * 4, 21 + sin(a) * 4, 2.2, 1.2, a) B.lit(c, m, "petal", 1) c:fillMask(m, i % 2 == 0 and "#ffc4d8" or "#f5809f") end
    c:fillMask(c:ellipse(46, 21, 2, 2), "#f5b82e") c:px(45, 20, "#ffe38a")
  end })
D.fin()
