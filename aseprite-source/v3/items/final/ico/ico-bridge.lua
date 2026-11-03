-- ico-bridge first draft (Sonnet). quirk: a pair of glowing eyes lurking under the arch
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bridge"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local SK = ST
local m = c:poly{{4,36},{12,28},{24,23},{40,23},{52,28},{60,36},{60,52},{4,52}}
D.lit(m, ST, 3)
for y = 24, 51 do local r = floor((y-24)/5) if (y-24)%5 == 4 then for x = 4, 60 do if m:has(x,y) then c:px(x,y,ST[2]) end end
  else for x = 4, 60 do if m:has(x,y) and (x + r*4) % 10 == 0 then c:px(x,y,ST[2]) end end end end
local hole = B.ell(32,52,13,16) hole:clip(c:rect(0,0,63,52))
D.fill(hole, "#35295f")
for x = 19, 45 do for y = 36, 52 do if hole:has(x,y) and not hole:has(x,y-1) then c:px(x,y,ST[6]) end end end
D.fill(c:rect(26,44,28,45), "#ffe38a") D.fill(c:rect(36,44,38,45), "#ffe38a")
for x = 4, 60 do
  local y0 = 52 + floor(1.2 * math.sin(x * 0.7) + .5)
  for y = y0, 58 do c:px(x, y, y == y0 and SE[6] or (y <= y0 + 1 and SE[4] or SE[3])) end
end
D.fin()
