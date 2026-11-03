local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-exclaim: bold tapered exclamation mark with a round dot.
-- quirk: little shake ticks around it and the dot has bounced off its bar.
local c = D.new("ico-exclaim")
local bar = c:poly{ {24,8},{40,8},{37,40},{27,40} }:add(c:ellipse(32, 9, 8, 3)):add(c:ellipse(32, 40, 5, 2))
D.lit(bar, D.RED, 6, { amb = 0.05 })
local dot = c:ellipse(32, 51, 6, 6)
D.lit(dot, D.RED, 5, { amb = 0.05 })
c:groundShadow(32, 58, 7, 1)
for _, t in ipairs{ {{13,16},{18,20}}, {{12,26},{17,26}}, {{51,16},{46,20}}, {{52,26},{47,26}} } do
  c:part(c:line(t, 3), D.ORG, { noshade = true, nopop = true })
end
D.fin()
