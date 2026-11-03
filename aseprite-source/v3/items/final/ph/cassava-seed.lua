-- cassava-seed (first draft, Sonnet). quirk: the sprout stem is bright pink-red
local NAME = "cassava-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local MT = { "#3a2a22", "#5a4034", "#7e5e48", "#a48466", "#c8aa8a", "#e8d2b2" }
D.scene(c, { leaf = { "#2a4a1c", "#3e6a26", "#58882e", "#78a83c", "#9cc85a", "#c4e482" }, seeds = {
  { 14, 51, 3.8, 3, 0.4, MT }, { 25, 49, 3.8, 3, -0.4, MT }, { 36, 50, 3.8, 3, 0.1, MT } },
  stem = { 36, 47, 36, 26, hex = "#e0405a", leaves = {}, ramp = LEAF },
  extra = function(c)
    for _, s in ipairs{ {14,51},{25,49},{36,50} } do c:px(s[1] - 1, s[2] - 1, "#fff4d6") c:px(s[1] + 1, s[2], MT[1]) c:px(s[1], s[2] + 1, MT[2]) c:px(s[1] - 2, s[2] + 1, MT[1]) end
    B.ln(c, 37, 47, 37, 26, "#b02e4a")
    -- palmate leaf, 5 fingers
    for i = -2, 2 do
      local a = -pi / 2 + i * 0.5
      local m, n, T, S = X.cyl(36, 26, 36 + cos(a) * 12, 26 + sin(a) * 12, function(t) if t > .96 then return -1 end return max(.5, 2.2 * sin(pi * min(1, t * 1.1)) ^ 0.7) end)
      X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), H.ramp({ "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }), { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
    end
  end })
D.fin()
