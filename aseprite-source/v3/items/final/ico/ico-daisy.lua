local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-daisy: white daisy with a round gold heart, slim green stem and two leaves.
-- quirk: one petal is missing and lies on the ground below.
local c = D.new("ico-daisy")
D.fill(c:line({ { 32, 34 }, { 31, 58 } }, 3), "#3fa862") D.fill(c:line({ { 33, 36 }, { 32, 58 } }, 1), "#1f5a44")
D.H.leaf(c, 31, 52, 15, 40, 4.5, "moss", { 4 })
D.H.leaf(c, 32, 46, 50, 38, 4.5, "moss", { 4 })
local PET = { "#8a8aa8", "#b6b8d4", "#d8dcee", "#eef0fa", "#fbfbff", "#ffffff" }
PET[6] = "#fffdf4"
for i = 0, 9 do
  if i ~= 3 then
    local a = i * pi / 5 - pi / 2
    D.lit(D.ell(32 + cos(a) * 12, 22 + sin(a) * 12, 7, 3.6, a), PET, 2.4)
  end
end
D.lit(D.disc(32, 22, 6), D.GOLD, 4)
D.px(30, 20, D.GOLD[6]) D.px(31, 20, D.GOLD[6])
-- fallen petal
D.lit(D.ell(47, 57, 6, 3, -0.3), PET, 2.4)
D.fin()
