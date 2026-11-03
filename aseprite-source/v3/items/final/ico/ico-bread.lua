-- ico-bread first draft (Sonnet). quirk: a bite taken out and a few crumbs
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bread"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:rrect(8,48,56,55,2), W, 1.5)
local bite = B.ell(51,36,5,5)
local m = B.ell(32,38,21,14) m:clip(c:rect(0,0,63,49)) m:cut(bite)
D.lit(m, D.CRUST, 4)
m:each(function(x,y) local n = bite:grow(1) if n:has(x,y) then c:px(x,y,"#ffe3a8") end end)
for _, s in ipairs{{{21,27},{26,40}},{{29,25},{34,39}},{{37,26},{42,38}}} do
  for dx = 0, 1 do D.ln(c,s[1][1]+dx,s[1][2],s[2][1]+dx,s[2][2],"#ffe3a8",m) end
  D.ln(c,s[1][1]-1,s[1][2],s[2][1]-1,s[2][2],D.CRUST[1],m)
  D.ln(c,s[1][1]+2,s[1][2],s[2][1]+2,s[2][2],D.CRUST[2],m)
end
c:px(50,46,D.CRUST[5]) c:px(53,44,D.CRUST[4]) c:px(55,47,D.CRUST[5])
D.lit(c:line({{28,17},{26,14},{29,11},{27,8}}, 2), D.rp("sky"), 1)
D.fin()
