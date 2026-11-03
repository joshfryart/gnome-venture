local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- acai-seed: round fibrous brown-purple seeds with hairy rind, on a palm-frond scrap; sprout is a pinnate palm seedling. quirk: one seed has fibres combed into a quiff.
local c = D.new("acai-seed")
local SD = { "#2a1a1e", "#44272a", "#5e3a33", "#7a5040", "#9a6c52", "#c09474" }
D.scrap(6, 54, 56, 48, 7, D.LEAF, {norib=false})
for i = 0, 7 do local x = 14 + i * 5 D.ln(x, 51 - floor(i*0.4), x + 3, 57 - floor(i*0.4), "#2e7646") end
local seeds = {{22,48,5.2,4.8},{35,50,4.8,4.6},{45,47,4.4,4.2}}
for _, s in ipairs(seeds) do
  local m = D.seed(s[1], s[2], s[3], s[4], 0, SD)
  m:each(function(x, y) if (x*3 + y*5) % 7 == 0 then c:px(x, y, SD[(x+y)%2==0 and 2 or 5]) end end)
end
-- quiff of fibres
for i = 0, 3 do D.ln(21+i, 44, 19+i*2, 41-i%2, SD[5]) end
-- sprout from seed 2: stem + palm leaflets
D.stem(35, 46, 35, 28, "#86b86c") D.stem(36, 46, 36, 28, "#6a9a58")
for i, y in ipairs{30, 34, 38} do
  D.lf(30 - (i==1 and 1 or 0), y, 4.5, 1.1, -0.35, D.LEAF2) D.lf(41 + (i==1 and 1 or 0), y, 4.5, 1.1, 0.35, D.LEAF2)
end
D.lf(35, 24, 1.4, 4.5, 0, D.LEAF2)
D.fin()
