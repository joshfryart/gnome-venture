-- bilberry-jam: a squat glass jar of dark purple jam, gingham cloth cover tied with red twine in a bow. quirk: a jam drip has run down the glass and a tiny spoon handle sticks out under the string.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bilberry-jam")
local J = { "#14082c", "#241044", "#3a1c66", "#56308c", "#7a52b4", "#a88ae0" }
D.sh(32, 56, 17, 3)
local jar = c:rrect(15, 26, 49, 54, 6)
D.vc(jar, D.GLS, 15, 49, { wrap = .4 })
-- jam fill
local jam = c:rrect(17, 30, 47, 52, 5)
D.vc(jam, J, 17, 47, { wrap = .4 })
-- surface line
for x = 19, 45 do c:px(x, 31, J[5]) end
-- glass rim highlight left
for y = 33, 48 do c:px(16, y, "#e4faf8") end c:px(17, 34, "#e4faf8")
-- cloth top
local cloth = c:poly{ {13,22}, {51,22}, {53,28}, {49,30}, {15,30}, {11,28} }
D.lit(cloth, { "#a82c3c", "#c4343c", "#d4403a", "#ee6a50", "#f8e8d8", "#fff4d6" }, 2)
-- gingham checks
for y = 22, 30 do for x = 12, 52 do if cloth:has(x, y) and ((floor(x / 3) + floor(y / 3)) % 2 == 0) then c:px(x, y, "#f8e8d8") end end end
-- skirt of cloth
for x = 11, 53, 3 do c:px(x, 29, "#d4403a") c:px(x, 30, "#a82c3c") end
-- twine + bow
for x = 16, 48 do c:px(x, 31, "#b8821e") end
c:paint({ "xx.xx", "xxxxx", "x.x.x" }, 29, 28, { x = "#e8493b" })
c:px(32, 29, "#7a2036")
-- spoon handle
c:paint({ "x", "x", "x" }, 46, 18, { x = "#c98a54" }) c:px(46, 21, "#e8b982") c:px(47, 20, "#c98a54")
for y = 18, 26 do c:px(46, y, y < 22 and "#c98a54" or "#864c33") end
c:px(45, 17, "#e8b982") c:px(46, 17, "#e8b982") c:px(47, 17, "#e8b982")
-- drip
for y = 32, 40 do c:px(22, y, J[5]) end c:px(22, 41, J[4]) c:px(21, 41, J[3]) c:px(23, 41, J[3])
D.fin()
