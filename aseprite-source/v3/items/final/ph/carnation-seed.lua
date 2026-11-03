-- carnation-seed (first draft, Sonnet). quirk: a single frilly pink petal lies on the leaf
local NAME = "carnation-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local BK = { "#0e0a12", "#1e1620", "#322634", "#4e3e50", "#72607a", "#a090a8" }
D.scene(c, { leaf = { "#2a5a58", "#38807a", "#4ea090", "#6cc0a8", "#92dcc0", "#c0f0dc" }, a = {6, 53}, b = {58, 48}, w = 5, seeds = {
  { 14, 50, 3.4, 2.6, 0.2, BK }, { 22, 52, 3.4, 2.6, -0.4, BK }, { 30, 48, 3.4, 2.6, 0.5, BK } },
  stem = { 34, 46, 34, 26, leaves = { {26, 30, 8, 1.4, -0.8}, {42, 26, 8, 1.4, 0.8}, {30, 19, 7, 1.2, -1.1}, {38, 17, 7, 1.2, 1.1} }, ramp = { "#2a5a58", "#38807a", "#4ea090", "#6cc0a8", "#92dcc0", "#c0f0dc" } },
  extra = function(c)
    for _, s in ipairs{ {14,50},{22,52},{30,48} } do c:px(s[1] - 1, s[2] - 1, BK[6]) c:px(s[1], s[2] + 1, BK[1]) end
    local pt = B.ell(48, 51, 5, 3, -0.3)
    local fr = HP.mask() pt:each(function(x, y) if y > 50 or (x % 2 == 0) or y > 49 then fr:set(x, y) end end)
    B.lit(c, pt, "petal", 2) for i = 0, 3 do c:px(44 + i * 2, 48 + (i % 2), "#ffc4d8") end
  end })
D.fin()
