-- ico-melon first draft (Sonnet). quirk: a wedge is cut out showing orange flesh with one seed, and a curly vine tendril
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-melon")
local GR = { "#1f4a3a", "#2f6f4a", "#4a9a52", "#6cb85c", "#9ad06e", "#cde89a" }
local OR = { "#c2562a", "#e07a34", "#f29a46", "#ffb860", "#ffd088", "#ffe8b0" }
c:groundShadow(32, 56, 17, 2)
local body = D.ell(32, 35, 20, 18)
local wedge = D.isect(body, c:poly{ {32, 35}, {58, 18}, {58, 52}, {40, 54} })
local rest = D.sub(body, wedge)
D.lit(rest, GR, 8)
-- netted rind ribs
for _, o in ipairs{ -13, -6, 0 } do
  for y = 19, 52 do
    local t = (y - 17) / 36
    local x = floor(32 + o * sin(pi * t) ^ 0.7 + .5)
    if rest:has(x, y) then c:px(x, y, GR[2]) if (y % 2 == 0) and rest:has(x + 1, y) then c:px(x + 1, y, GR[3]) end end
  end
end
-- flesh wedge
local flesh = wedge:copy():shrink(3)
D.fill(wedge, "#cde89a")
D.fill(wedge:copy():shrink(1), "#e8f2b0")
D.lit(flesh, OR, 6)
D.fill(c:rect(46, 33, 48, 36), "#5a2e1e") c:px(46, 33, "#a35f3c")
c:px(41, 44, "#5a2e1e") c:px(42, 44, "#5a2e1e")
-- stem + vine
c:part(c:line({ {32, 17}, {31, 11}, {34, 8} }, 3), "wood", { band = 1 })
D.ln(35, 10, 40, 8, "#4a9a52") D.ln(40, 8, 43, 11, "#4a9a52") D.ln(43, 11, 41, 13, "#4a9a52") c:px(40, 12, "#4a9a52")
c:fillMask(c:rect(21, 24, 23, 28), "#cde89a") c:px(21, 24, CR)
D.fin()
