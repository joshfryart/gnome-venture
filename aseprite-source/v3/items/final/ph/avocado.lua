local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("avocado")
-- avocado: pear-shaped halved avocado, bumpy near-black skin, buttery gradient flesh and a glossy brown stone, with a whole one behind. quirk: a spoon-scoop has been taken from the flesh.
D.shadow(30, 57, 18, 2.5)
-- whole behind
D.P({{44,12},{50,16},{56,28},{58,40},{50,50},{42,48},{40,36},{40,22}}, {"#0e1c14","#1a2e1e","#2a4228","#3e5a30","#587a3c","#7e9a50"}, 4)
D.ln(46, 14, 46, 8, "#51302b")
for _, p in ipairs{{47,24},{52,32},{46,40},{50,44}} do D.px(p[1], p[2], "#587a3c") end
-- half
local half = D.P({{22,10},{30,12},{36,22},{40,36},{38,48},{28,54},{18,50},{14,38},{16,24}}, {"#0e1c14","#1a2e1e","#2a4228","#3e5a30","#587a3c","#7e9a50"}, 3)
local fl = D.P({{23,15},{29,17},{33,25},{35,36},{33,45},{27,49},{20,46},{18,37},{20,26}}, {"#4a7a2a","#6c9a34","#94b83e","#bcd45a","#dce87c","#f6f8aa"}, 6)
-- yellow near core
D.E(26, 37, 8, 8.5, 0, {"#6c9a34","#94b83e","#bcd45a","#dcea7c","#f2f6a0","#fbf8c0"}, 4)
-- stone
D.E(26, 39, 5.5, 5.5, 0, D.BRN, 3.5)
D.px(24, 36, "#e8b982") D.px(25, 36, "#e8b982") D.px(24, 37, "#c98a54")
-- scoop
D.E(31, 28, 2.8, 2.2, 0.5, {"#6c9a34","#94b83e","#bcd45a","#dcea7c","#f2f6a0","#fbf8c0"}, 1)
D.ln(29, 27, 33, 26, "#4a7a2a")
D.fin()
