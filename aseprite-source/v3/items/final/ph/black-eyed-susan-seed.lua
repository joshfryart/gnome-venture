-- black-eyed-susan-seed: slim black angular wedge seeds on a rough lance-leaf scrap; the sprout is a low rosette of hairy lance leaves. quirk: a tiny yellow petalled black-eyed flower bud already nods on top.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("black-eyed-susan-seed")
local BK = { "#14101c", "#201a2c", "#322a42", "#4a405e", "#6c6082", "#9a8eb4" }
D.scrap(4, 55, 58, 50, 7.5, D.LEAF2, { slant = 1.5 })
local function wedge(cx, cy, a)
  local m = D.ell(cx, cy, 4.2, 1.9, a)
  c:fillMask(D.ell(cx + 1, cy + 1.2, 4.4, 2, a), "#1f4a3a")
  D.lit(m, BK, 1.8, { wrap = .3 })
  c:px(floor(cx - 2), floor(cy - 1), "#e6e0f0")
  for i = -1, 1 do c:px(floor(cx + i * cos(a)), floor(cy + i * sin(a) + 1), BK[2]) end
end
for _, s in ipairs{ {13,52,.3}, {22,53,-.2}, {30,52,.5}, {20,47,-.4}, {34,56,.1} } do wedge(s[1], s[2], s[3]) end
-- rosette of lance leaves
D.ln(44, 46, 44, 24, "#86b86c") D.ln(45, 46, 45, 24, "#4a7a40")
for _, l in ipairs{ {-1.1, 9}, {-.5, 8}, {.5, 8}, {1.1, 9} } do
  local a = l[1] local ex, ey = 44 + sin(a) * l[2], 44 - cos(a) * l[2] * .8 - 4
  D.lf((44 + ex) / 2, (44 + ey) / 2, 1.9, l[2] / 2 + .8, a, D.LEAF2)
end
-- hairs
for _, p in ipairs{ {36,40}, {37,36}, {52,40}, {51,36} } do c:px(p[1], p[2], "#c8e898") end
-- flower bud
for _, p in ipairs{ {0,-5}, {4,-3}, {-4,-3}, {3,3}, {-3,3}, {5,0}, {-5,0} } do
  c:paint({ "x", "x" }, 44 + p[1], 14 + p[2], { x = "#f8d048" })
end
D.lit(D.ell(44, 14, 3, 2.6, 0), { "#120c10", "#1d1523", "#2c2030", "#3a2a2c", "#58475e", "#7c6a82" }, 2)
D.ln(44, 17, 44, 24, "#86b86c")
D.fin()
