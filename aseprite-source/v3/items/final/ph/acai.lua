local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- acai: drooping panicle of glossy blue-black berries on a reddish branched stalk, two palm leaflets. quirk: a tiny bee visits.
local c = D.new("acai")
local STK = { "#4a1630", "#7a2036", "#a82c3c", "#c8503e", "#e87a55", "#ffa27a" }
local BER = { "#14102e", "#241a4a", "#3a2a72", "#5a44a0", "#8670c8", "#c0b0ec" }
D.lf(14, 14, 11, 2.6, 0.55, D.LEAF) D.lf(50, 12, 11, 2.6, -0.5, D.LEAF2)
c:px(6,8,"#173f36")
-- main stalk and branches
local main = {{32,8},{32,18},{31,26}}
D.ln(32,6,32,20,STK[4]) D.ln(33,6,33,20,STK[3])
local br = {{{32,14},{22,22},{18,30}},{{32,14},{42,22},{46,30}},{{32,18},{27,30},{26,38}},{{32,18},{38,30},{39,38}},{{32,20},{32,32},{32,44}}}
for _, b in ipairs(br) do D.ln(b[1][1],b[1][2],b[2][1],b[2][2],STK[4]) D.ln(b[2][1],b[2][2],b[3][1],b[3][2],STK[3]) end
local berries = {{18,32},{15,38},{22,41},{46,32},{49,39},{43,42},{26,40},{28,47},{23,48},{39,40},{37,47},{42,49},{32,35},{32,45},{33,53},{29,54},{36,54}}
for _, b in ipairs(berries) do
  local m = c:ellipse(b[1], b[2], 3.3, 3.3)
  D.lit(m, BER, 3)
  c:px(b[1]-1, b[2]-1, "#c0b0ec")
end
-- bee
local bx, by = 52, 46
c:fillMask(c:ellipse(bx,by,3,2), "#f5b82e") c:px(bx-1,by,"#2b1c26") c:px(bx+1,by,"#2b1c26")
c:px(bx-4,by-1,"#e4f6ff") c:px(bx-3,by-2,"#e4f6ff") c:px(bx+2,by-2,"#e4f6ff")
D.fin()
