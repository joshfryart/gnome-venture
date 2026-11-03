local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- acanthus-seed: grey-brown oval seeds with a pale ridge, beside a spiny capsule husk, on a lobed acanthus leaf; sprout is a toothed lobed seedling. quirk: a husk spine pricks a seed.
local c = D.new("acanthus-seed")
local m = D.scrap(5, 52, 56, 46, 10, D.LEAF2, {})
local SD = { "#3a3030", "#58463e", "#7c6652", "#a08666", "#c4aa84", "#e6d2a8" }
local seeds = {{20,50,4,3,0.3},{32,51,4.2,3.2,-0.2},{43,49,3.8,2.8,0.1}}
for _, s in ipairs(seeds) do local sm = D.seed(s[1], s[2], s[3], s[4], s[5], SD) D.ln(s[1]-2, s[2]+1, s[1]+2, s[2]-1, "#e6d2a8", sm) end
-- husk with spine
local husk = D.ell(52, 46, 3, 5, 0.3) D.lit(husk, D.TAN, 2) D.ln(50,42,47,39,"#b88c5c") D.ln(54,43,57,41,"#b88c5c")
-- sprout
D.stem(32, 48, 32, 30, "#7aa860") D.stem(33, 48, 33, 30, "#5a8848")
for _, L in ipairs{{26,32,5,2,-0.5},{39,32,5,2,0.5},{28,26,4,1.8,-0.9},{37,26,4,1.8,0.9},{32,21,2.2,4.5,0}} do
  local lm = D.lf(L[1], L[2], L[3], L[4], L[5], D.LEAF)
end
for _, p in ipairs{{23,31},{22,33},{42,31},{43,33},{27,26},{38,26}} do c:px(p[1], p[2], "#9dd06c") end
D.fin()
