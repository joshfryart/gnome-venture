-- mulberry-jam: squat glass jar of dark purple jam, cloth lid tied with twine, tiny berry label. quirk: a purple drip crawls down the glass and a dab sits on the cloth.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mulberry-jam")
local JAM = D.R("#9a7ee0", "#5a3aa0", "#3a2678", "#21154a")
local GL = D.R("#e4f6ff", "#b6f0e0", "#5fc4c8", "#3a86b0")
local CL = D.R("#fff4d6", "#f0e0b8", "#d0b890", "#8a7050")
c:groundShadow(32, 57, 18, 2)
local jar = c:rrect(13, 24, 50, 55, 8)
H.vcyl(c, jar, JAM, 13, 50)
D.speck(c, jar:shrink(2), JAM.hi, 4, .94)
-- glass rim and shine
jar:edge():each(function(x, y) if x < 22 then c:px(x, y, GL.hi) elseif x > 44 then c:px(x, y, GL.shade) end end)
for y = 31, 46 do c:px(17, y, GL.hi) end
c:px(18, 30, "#fff4d6") c:px(17, 30, "#fff4d6")
-- label
local lab = c:rrect(21, 36, 42, 48, 2)
B.lit(c, lab, CL, 2, { nospec = true })
c:fillMask(lab:shrink(1), "#fff4d6")
for _, p in ipairs{ {29,41}, {32,41}, {35,41}, {30,44}, {33,44}, {31,47} } do B.lit(c, c:ellipse(p[1], p[2] - 2, 1.2, 1.2), "dusk", 1) end
c:px(31, 39, "#3f9150") c:px(32, 38, "#3f9150")
-- cloth lid
local lid = c:ellipse(32, 24, 18, 5):add(c:rrect(14, 24, 49, 30, 3))
B.lit(c, lid, CL, 4)
c:stitch({ {16,28}, {32,30}, {48,28} })
-- twine
c:fillMask(c:line({ {14,29}, {32,32}, {49,29} }, 1), "#b97a4a")
c:fillMask(c:line({ {32,32}, {28,36} }, 1), "#b97a4a") c:fillMask(c:line({ {32,32}, {37,36} }, 1), "#b97a4a")
-- jam dab and drip
c:fillMask(c:ellipse(40, 22, 2, 1.2), JAM.base) c:px(39, 21, JAM.hi)
local dr = c:rect(45, 28, 46, 40):add(c:ellipse(45, 42, 1.5, 2))
c:fillMask(dr, JAM.base) c:px(45, 41, JAM.hi)
D.fin()
