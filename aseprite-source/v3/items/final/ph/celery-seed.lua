-- celery-seed (v3 first draft, dB15). quirk: the sprout's leaflet has a tiny bite
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("celery-seed")
D.scrap(c, "moss")
local SEED = { "#3a2418", "#5a3a22", "#7c5430", "#9c7040", "#bc9058", "#dcb478" }
for _, s in ipairs{ {13, 51, 0.3}, {19, 54, -0.4}, {25, 50, 0.8}, {32, 54, 0.1}, {40, 51, -0.6}, {47, 53, 0.5} } do
  local m = D.seed(c, s[1], s[2], 2.6, 1.8, s[3], SEED)
  c:px(floor(s[1]), floor(s[2]) + 1, SEED[2])
end
D.stem(c, { {40, 49}, {40, 42}, {39, 34}, {38, 26} }, 0.9, 0.8, "moss")
local LF = { "#1f5a3a", "#2f7a46", "#47a052", "#68bc5c", "#90d672", "#bcee94" }
for _, L in ipairs{ {28, 28, 4.5, 3.4, -0.3}, {48, 27, 4.5, 3.4, 0.3}, {38, 17, 5, 4, 0} } do
  local m = B.ell(L[1], L[2], L[3], L[4], L[5])
  if L[1] == 28 then m:cut(B.ell(24, 25, 1.6, 1.6, 0)) end
  H.lit(c, m, LF, { R = 1.8 })
  B.ln(c, L[1] - 2, L[2] + 1, L[1] + 2, L[2] - 1, LF[6], m)
end
B.ln(c, 38, 26, 29, 28, LF[3]) B.ln(c, 38, 26, 47, 27, LF[3]) B.ln(c, 38, 26, 38, 18, LF[3])
D.fin()
