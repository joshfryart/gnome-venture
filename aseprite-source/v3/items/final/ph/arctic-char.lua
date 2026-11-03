local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor = math.floor
local c = D.new("arctic-char")
-- arctic-char: slim torpedo fish, olive-slate back, blazing orange belly, pale spots, white-edged fins and a hooked lower jaw. quirk: it is balancing a tiny ice cube on its nose.
local body = D.P({{8,32},{14,26},{26,22},{40,23},{48,28},{54,31},{48,38},{40,42},{26,43},{14,40}}, {"#27384a","#34546a","#4a7a82","#6a9a8a","#94b898","#c4d8a8"}, 7)
-- orange belly
c:ellipse(30, 38, 17, 3)
body:each(function(x, y) if y >= 36 + (x < 20 and 1 or 0) and y < 43 then local t = y - 36 D.px(x, y, ({"#f08a3c","#ff9c48","#e8723a","#c85a30","#a84628","#a84628","#a84628"})[t + 1] or "#a84628") end end)
-- spots
for _, p in ipairs{{18,30},{24,28},{30,29},{36,28},{42,30},{22,34},{28,34},{34,33},{40,34}} do D.px(p[1], p[2], "#f4ecc0") D.px(p[1]+1, p[2], "#d8e0a8") end
-- tail
D.P({{48,30},{60,22},{58,32},{60,42},{48,34}}, {"#6a2c1c","#a83c20","#d85a2c","#f0803c","#ffa050","#ffe0b0"}, 2)
D.ln(58, 24, 58, 40, "#fff4d6")
-- fins
D.P({{20,40},{28,40},{24,48},{18,47}}, {"#a83c20","#d85a2c","#f0803c","#ff9c48","#ffb468","#fff4d6"}, 1.5)
D.P({{30,22},{38,22},{34,16}}, {"#27384a","#34546a","#4a7a82","#6a9a8a","#94b898","#c4d8a8"}, 1.5)
-- jaw + eye
D.P({{8,32},{14,32},{14,36},{9,36},{7,34}}, {"#6a2c1c","#a83c20","#d85a2c","#e86a30","#f08a3c","#ffa050"}, 1)
D.E(15, 30, 2.4, 2.4, 0, {"#fff4d6","#fff4d6","#fff4d6","#fff4d6","#fff4d6","#fff4d6"}, 1) D.px(15, 30, D.INK) D.px(16, 30, D.INK) D.px(15, 31, D.INK)
-- gill
D.ln(19, 27, 20, 38, "#27384a")
-- ice cube
D.P({{4,20},{11,19},{12,26},{5,27}}, {"#5a8aa0","#86b8c8","#b2dce4","#d4f0f0","#eafaf6","#fcfffa"}, 1.5)
D.px(6, 21, "#ffffff" and "#fff4d6")
D.px(30, 26, "#c4d8a8") D.px(31, 26, "#c4d8a8")
D.fin()
