-- ico-party first draft (Sonnet). quirk: a streamer curls up into a little spiral and one confetti piece is a heart
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-party")
-- cone
local cone = c:poly{ {8, 58}, {14, 34}, {34, 40}, {16, 59} }
cone:add(c:poly{ {6, 58}, {14, 33}, {36, 41}, {16, 60} })
D.lit(cone, D.GOLD, 3, { amb = .1 })
for i, t in ipairs{ 0.22, 0.5, 0.78 } do
  local x0, y0 = 8 + (14 - 8) * 0 + t * 8, 58 - t * 24
  D.ln(floor(8 + t * 26), floor(58 - t * 23), floor(14 + t * 24), floor(34 + t * 7), i % 2 == 0 and "#d4403a" or "#8e4fa6")
end
D.fill(c:poly{ {13, 34}, {36, 41}, {32, 37} }, "#7a3f1c")
D.fill(D.ell(25, 37, 5, 4, 0.3), "#2b1c26")
D.fill(D.ell(25, 37, 4, 3, 0.3), "#4a2463")
-- burst streamers
D.fill(c:line({ {28, 34}, {34, 26}, {42, 24}, {48, 18} }, 2), "#f5809f")
D.fill(c:line({ {30, 36}, {40, 33}, {48, 34}, {55, 28} }, 2), "#5fc4c8")
D.fill(c:line({ {26, 33}, {26, 22}, {32, 14}, {30, 8} }, 2), "#f5b82e")
-- spiral
D.fill(c:line({ {54, 28}, {58, 31}, {57, 36}, {52, 36}, {51, 32}, {54, 31} }, 2), "#5fc4c8")
-- confetti
for _, p in ipairs{ {38,10,"#e8493b"},{46,8,"#7cc35a"},{52,12,"#8a6fd0"},{44,40,"#f5b82e"},{20,12,"#5fc4c8"},{36,18,"#8a6fd0"},{56,20,"#f5b82e"} } do
  D.fill(c:rect(p[1], p[2], p[1] + 2, p[2] + 2), p[3])
end
D.fill(D.heart(52, 46, 3), "#f5809f")
c:sparkle(14, 20)
D.fin()
