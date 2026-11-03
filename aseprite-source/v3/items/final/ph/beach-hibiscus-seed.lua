local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- beach-hibiscus-seed: three kidney seeds with fine fuzz, plus a split brown capsule husk, on a heart-shaped leaf scrap; sprout has a pair of heart leaves. quirk: a yellow petal scrap clings to the capsule.
local c = D.new("beach-hibiscus-seed")
D.scrap(6, 55, 58, 50, 8, D.LEAF2, {norib = false})
local SD = { "#2e2018", "#4a3424", "#6e4e34", "#8e6a46", "#b08a5e", "#d4b088" }
for i, s in ipairs{{19, 52, 0.4}, {29, 53, -0.4}, {38, 52, 0.2}} do
  local m = D.ell(s[1], s[2], 4.4, 3, s[3]) m:cut(D.ell(s[1] + 1, s[2] - 3.6, 2.2, 1.6, 0))
  c:fillMask(m:shift(1, 1), "#1f4a3a") D.lit(m, SD, 2.2)
  for k = 1, 3 do c:px(s[1] - 3 + k * 2, s[2] + 2, "#d4b088") end
end
local cap = c:poly{ {44, 54}, {54, 54}, {55, 46}, {49, 42}, {43, 46} } D.lit(cap, { "#3a2a24", "#5a4030", "#7a5a40", "#9a7650", "#b89464", "#d8b884" }, 2.6)
D.ln(49, 43, 49, 52, "#3a2a24") D.lit(D.ell(46, 47, 2.2, 1.6, 0.5), D.YEL, 1.2)
D.stem(30, 50, 30, 33, "#86b86c") D.stem(31, 50, 31, 33, "#6a9a58")
for _, sd in ipairs{-1, 1} do
  local cx = 31 + sd * 6
  D.lf(cx, 28, 5, 4.4, sd * 0.4, D.LEAF2) D.lf(cx - sd * 2, 25, 2.4, 2.4, 0, D.LEAF2)
end
D.fin()
