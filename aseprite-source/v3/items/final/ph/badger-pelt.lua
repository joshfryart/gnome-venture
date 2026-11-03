local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("badger-pelt")
-- badger-pelt: flat grizzled grey pelt with four stubby legs, tufted tail and the famous black-and-white head stripes, shaggy fringe all round. quirk: a single moth has chewed a round hole near the rump.
local F = D.FUR
D.shadow(32, 56, 22, 2.5)
local body = D.P({{20,20},{44,20},{50,26},{54,34},{50,40},{54,48},{48,52},{44,46},{36,50},{28,50},{20,46},{14,52},{10,48},{14,40},{10,34},{14,26}}, F, 6)
-- fringe tufts
for i = 0, 9 do local x = 14 + i * 4 D.px(x, 52 - (i % 2) * 2, F[3]) D.px(x + 1, 51, F[2]) end
-- grizzle
for y = 26, 46 do for x = 16, 48 do if (x * 7 + y * 13) % 9 == 0 and body:has(x, y) then D.px(x, y, F[6]) end end end
-- head
D.E(32, 16, 9, 9, 0, F, 5)
-- stripes
D.P({{28,8},{31,8},{30,26},{27,22}}, {"#0e0c12","#16141c","#1e1c26","#2a2630","#2a2630","#3a3640"}, 1)
D.P({{34,8},{37,8},{37,22},{34,26}}, {"#0e0c12","#16141c","#1e1c26","#2a2630","#2a2630","#3a3640"}, 1)
D.E(32, 12, 1.4, 5, 0, {"#d0ccd2","#e0dce2","#f0ecf0","#f8f4f8","#fbf8fb","#fffcff"}, 1)
-- nose + ears
D.E(32, 24, 3, 2.2, 0, {"#0e0c12","#16141c","#1e1c26","#2a2630","#3a3640","#4a4650"}, 1.5) D.px(31, 23, "#fff4d6")
D.px(24, 10, "#fff4d6") D.px(40, 10, "#fff4d6")
D.E(24, 11, 2, 2.2, 0, {"#2a2630","#2a2630","#2a2630","#2a2630","#2a2630","#d0ccd2"}, 1) D.E(40, 11, 2, 2.2, 0, {"#2a2630","#2a2630","#2a2630","#2a2630","#2a2630","#d0ccd2"}, 1)
-- tail
D.E(48, 56, 5, 3, -0.4, F, 2)
-- paws claws
for _, p in ipairs{{12,50},{52,50},{12,32},{52,34}} do D.px(p[1], p[2], "#e8e0c8") D.px(p[1]+1, p[2]+1, "#e8e0c8") end
-- moth hole
D.E(38, 40, 2.4, 2, 0, {"#1c1a22","#1c1a22","#1c1a22","#1c1a22","#1c1a22","#1c1a22"}, 1)
c:px(37, 39, "#2b1c26")
D.fin()
