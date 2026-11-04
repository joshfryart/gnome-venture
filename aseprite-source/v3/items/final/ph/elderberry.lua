-- elderberry (first draft, Sonnet)
-- quirk: one berry in the cluster is still green
local NAME = "elderberry"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB25.lua")
local H, HP = D.H, D.HP
local X, K = D.X, D.K
local floor, sin, cos, max, min, abs, pi = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.pi
local c = D.new(NAME)
local RED = { "#4a1a2a", "#8a3a4a" }
-- stalks radiating from a thick stem
D.stem({ { 30, 58 }, { 30, 44 }, { 31, 32 } }, "#b86a5a", "#6a2a30", 2)
local tips = {}
for i = 0, 10 do local a = pi * (1.08 + i * .084) local r = 19 + (i % 2) * 3
  tips[#tips + 1] = { 31 + cos(a) * r * 1.05, 34 + sin(a) * r * .85 } end
for _, p in ipairs(tips) do D.stem({ { 31, 32 }, { (31 + p[1]) / 2, (32 + p[2]) / 2 - 1 }, { p[1], p[2] } }, "#c8786a", "#7a3a3a", 1) end
local BR = D.rp("#120a2a", "#2e1a5a", "#7a6ac8")
local GRN = D.rp("#2a5a2a", "#6ab04a", "#d0f090")
for i, p in ipairs(tips) do
  for k = 0, 2 do local ang = (i * 2.1 + k * 2.3)
    local bx, by = p[1] + cos(ang) * 3.2, p[2] + sin(ang) * 2.6 + 2
    D.bead(floor(bx), floor(by), 2.2, i == 7 and k == 1 and GRN or BR, i == 7 and k == 1 and "#fffbe0" or "#b8b0f0")
  end
end
D.leaf(18, 54, 8, 3, -0.6, D.LEAF, true) D.leaf(42, 53, 8, 3, 0.6 + pi, D.LEAF, true)
D.fin()
