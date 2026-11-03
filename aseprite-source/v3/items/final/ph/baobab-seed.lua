local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- baobab-seed: three kidney-shaped hard brown seeds, one dusted with chalky white pulp, on a palmate leaf scrap; sprout has five thin fingers. quirk: a bead of white pulp sits on one seed.
local c = D.new("baobab-seed")
D.scrap(6, 55, 57, 50, 6, D.LEAF2, {norib = false})
local SD = { "#2a1a14", "#44281e", "#643c2a", "#845238", "#a06c4a", "#c49468" }
for i, s in ipairs{{19, 52, 0.5}, {31, 53, -0.3}, {43, 52, 0.2}} do
  local m = D.ell(s[1], s[2], 5, 3.6, s[3]) m:cut(D.ell(s[1] + 1, s[2] - 4, 2.6, 2, 0))
  c:fillMask(m:shift(1, 1), "#1f4a3a") D.lit(m, SD, 2.6)
  c:px(s[1] - 3, s[2] - 1, "#ecd9b4")
end
for k = 0, 3 do c:px(29 + k, 49 - k % 2, "#fff4d6") end
D.stem(32, 49, 32, 34, "#86b86c") D.stem(33, 49, 33, 34, "#6a9a58")
for i, a in ipairs{-1.2, -0.6, 0, 0.6, 1.2} do
  local ex, ey = 33 + math.sin(a) * 11, 33 - math.cos(a) * 11
  D.lf((33 + ex) / 2, (33 + ey) / 2, 1.5, 5.5, a, D.LEAF2)
end
D.fin()
