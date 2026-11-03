local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blue-poppy-seed")
-- blue-poppy-seed: a pinch of tiny slate-blue kidney seeds on a lobed hairy leaf scrap; sprout is a rosette of two deeply cut leaves. quirk: a seed pod lid sits tilted beside the heap.
D.scrap(6, 54, 56, 54, 9, D.LEAF)
local S = {"#10142e","#1c2850","#2a3e72","#3c5a96","#5e80b8","#92b0dc"}
for i = 0, 13 do local a = i * 2.4; D.seed(24 + (i % 5) * 4 + (i // 5) * 2, 55 - (i // 5) * 3 + (i % 2), 1.7, 1.2, a, S) end
D.P({{42,50},{50,48},{52,52},{44,54}}, D.TAN, 1.5) D.ln(44, 51, 50, 50, "#fae8c0") D.px(47, 52, "#6a4a38")
D.stem2(18, 46, 18, 34)
D.P({{18,34},{8,32},{4,24},{10,26},{14,20},{16,28}}, D.LEAF2, 2) D.P({{19,34},{28,32},{32,24},{26,26},{22,20},{20,28}}, D.LEAF2, 2)
D.ln(17, 33, 7, 26, "#bfe688") D.ln(20, 33, 29, 26, "#bfe688") D.px(12, 25, "#fff4d6")
D.fin()
