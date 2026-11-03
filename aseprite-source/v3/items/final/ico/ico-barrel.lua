-- ico-barrel first draft (Sonnet). quirk: a spigot dripping a single blue drop
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-barrel"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

c:groundShadow(32,57,18,2)
local body = c:poly{{17,19},{47,19},{50,30},{50,43},{47,54},{17,54},{14,43},{14,30}}
D.cyl(body, W, 14, 50)
for _, x in ipairs{20,26,32,38,44} do for y = 20, 53 do if body:has(x, y) then c:px(x, y, W[2]) end end end
for _, r in ipairs{{27,29},{43,45}} do
  local m = D.isect(body, c:rect(0, r[1], 63, r[2])) D.cyl(m, ST, 14, 50)
end
local lid = c:ellipse(32,19,15,4) D.lit(lid, W, 2)
local wat = c:ellipse(32,19,12,3) D.lit(wat, SE, 1.5)
c:px(26,18,D.CR) c:px(27,18,D.CR)
local sp = c:rect(50,36,56,39) D.lit(sp, GO, 1.5)
D.fill(c:rect(54,40,55,41), GO[2])
D.fill(c:rect(54,43,55,45), SE[4]) c:px(54,43,SE[6])
D.fin()
