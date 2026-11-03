-- cattail-fritters (first draft, Sonnet). quirk: a bright green cattail shoot is stuck in the stack
local NAME = "cattail-fritters"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local FR = { "#5a2a10", "#8a4a1c", "#b87028", "#d8923a", "#efb458", "#fbd488" }
c:groundShadow(32, 56, 22, 3)
c:fillMask(B.ell(32, 53, 23, 5), "#e4f6ff") c:fillMask(B.ell(32, 52, 18, 3.5), "#b9e2f5")
for _, p in ipairs{ {20, 46, 10, 5, 0.1}, {42, 47, 10, 5, -0.1}, {31, 40, 11, 5.4, 0.05}, {30, 33, 8, 4.4, -0.1} } do
  local m = B.ell(p[1], p[2], p[3], p[4], p[5]) B.lit(c, m, FR, 3)
  -- fibres + crisp specks
  for k = 0, 4 do c:px(floor(p[1] - 5 + k * 2.4), floor(p[2] - 1 + (k % 2) * 2), FR[1]) end
  c:px(floor(p[1] + 2), floor(p[2] - 1), "#fbd488")
end
-- steam
for _, s in ipairs{ {26, 24}, {38, 22} } do
  for i = 0, 7 do c:px(s[1] + floor(sin(i * 0.9) * 1.6 + .5), s[2] - i, "#f0eef6") end
end
-- cattail shoot
B.blade(c, 44, 40, 56, 14, 2.6, LEAF, { norib = false })
c:fillMask(c:rect(53, 13, 55, 17), "#ffffff") c:fillMask(c:rect(53, 13, 55, 17), "#6e3e22")
D.fin()
