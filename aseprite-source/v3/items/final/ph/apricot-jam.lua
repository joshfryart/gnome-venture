local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor = math.floor
local c = D.new("apricot-jam")
-- apricot-jam: round glass pot of bright orange jam capped in dotted cloth and twine, with a toast slice leaning on it. quirk: a thumbprint is pressed into the toast jam.
D.shadow(30, 57, 22, 3)
-- toast behind right
D.P({{36,24},{54,24},{56,32},{53,36},{54,52},{38,52},{39,36},{35,32}}, D.TAN, 3)
D.E(46, 38, 7, 8, 0, {"#a83a1c","#d05a22","#f0802c","#ff9a3c","#ffb450","#ffcc70"}, 3)
D.E(45, 38, 2, 1.5, 0, {"#a83a1c","#c25a24","#d05a22","#e8782e","#f0802c","#ff9a3c"}, 1)
-- jar
local jar = c:rrect(8, 28, 36, 55, 6)
D.H.vcyl(c, jar, D.GLASS, 6, 38, {})
local jam = c:rrect(10, 32, 34, 53, 5)
D.H.vcyl(c, jam, {"#9a2c18","#c24a20","#e8702a","#ff9238","#ffb050","#ffd078"}, 8, 36, {})
D.px(14, 38, "#ffe8a0") D.px(15, 38, "#ffe8a0") D.px(13, 39, "#ffd078")
for _, p in ipairs{{20,44},{26,48},{16,48}} do D.px(p[1], p[2], "#ffd078") end
-- cloth cap
D.P({{6,22},{12,20},{18,22},{24,20},{30,22},{36,20},{38,24},{34,32},{10,32},{6,26}}, D.CRM, 2.5)
for _, p in ipairs{{12,25},{18,27},{24,24},{30,27},{15,29},{27,30},{34,24}} do D.px(p[1], p[2], "#ee6a50") D.px(p[1]+1, p[2], "#ee6a50") end
D.ln(9, 31, 35, 31, "#c9a98a") D.ln(9, 32, 35, 32, "#8a6a5a")
D.ln(24, 31, 28, 38, "#b88c5c") D.ln(25, 31, 29, 38, "#d9b37c")
D.px(12, 36, "#fff4d6") D.px(12, 37, "#fff4d6")
D.fin()
