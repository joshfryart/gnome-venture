-- bitter-melon: a long warty ridged bitter gourd, gently curved, tapering to a pointed tip, with a short stem and a curling tendril. quirk: the warts are arranged in neat rows and one has popped to show a tiny orange seed.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bitter-melon")
local G = { "#10361e", "#1a5230", "#2a7a3c", "#42a04a", "#7acc58", "#c0ec90" }
local m, n, T, S = D.tube({ {12,50}, {22,30}, {38,36}, {52,14} }, function(t) return max(.8, 6.2 * sin(pi * min(1, t * .95 + .04)) ^ .55) end)
D.tn(m, n, G, { .2, .38, .54, .7, .86 }, { wrap = .3 })
-- long ridges + warts
m:each(function(x, y)
  local k = K(x, y) local s, t = S[k], T[k]
  if t > .08 and t < .94 then
    if abs(s - .35) < .08 or abs(s + .45) < .08 then c:px(x, y, G[2]) end
    local u = floor(t * 34)
    if u % 3 == 0 and (abs(s) < .08 or abs(s - .55) < .09 or abs(s + .6) < .09) then c:px(x, y, G[6]) end
    if u % 3 == 1 and (abs(s) < .08 or abs(s - .55) < .09 or abs(s + .6) < .09) then c:px(x, y, G[1]) end
  end
end)
-- popped wart with seed
c:px(30, 38, "#ff9a3c") c:px(31, 38, "#ee6c22") c:px(30, 39, "#c25a24")
-- stem
for _, p in ipairs{ {53,13}, {54,11}, {55,9}, {55,7} } do c:px(p[1], p[2], "#6a8a3a") c:px(p[1] + 1, p[2], "#4a6a30") end
-- tendril
for a = 0, 9, .5 do c:px(floor(56 + cos(a * .7) * (1 + a * .4) + .5), floor(10 - a * .6 + sin(a * .7) * 2 + .5), "#86b86c") end
c:px(15, 49, G[6])
D.fin()
