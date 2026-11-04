-- napa-cabbage: tall oblong head of crinkled pale-green leaves with fat white midribs and a frilly top. quirk: a fat dewdrop sits on the left leaf.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("napa-cabbage")
local LF = D.R("#f4fbc0", "#b4dc6a", "#6cac50", "#2f6a48")
local WH = D.R("#fffaea", "#f6f4d8", "#d4d4a8", "#98a06c")
c:groundShadow(32, 58, 14, 2)
local core = c:ellipse(32, 38, 12, 21):cut(c:rect(0, 56, 63, 63))
B.lit(c, core, D.R("#fffbd0", "#e4eea0", "#a8c870", "#5a8a50"), 10)
-- inner leaves ribs
for i = -1, 1 do
  local x = 32 + i * 6
  c:fillMask(c:line({ {x, 52}, {x + i, 36}, {x + i * 2, 18} }, 2), WH.base)
  for y = 20, 50, 2 do c:px(x + i * (1 - (y - 18) / 34) - 1, y, WH.hi) end
end
-- big outer leaves
local ol = B.ell(21, 36, 8.5, 19, 0.28)
B.lit(c, ol, LF, 6)
c:fillMask(c:line({ {22,54}, {20,36}, {18,20} }, 2), WH.base) 
for k = 0, 6 do local y = 24 + k * 4 B.ln(c, 21 - (y > 36 and 0 or 0), y, 14 + k * .3, y - 3, LF.shade, ol) end
local orr = B.ell(43, 37, 8.5, 18, -0.28)
B.lit(c, orr, LF, 6)
c:fillMask(c:line({ {42,54}, {44,36}, {46,20} }, 2), WH.base)
for k = 0, 6 do local y = 24 + k * 4 B.ln(c, 44, y, 50 - k * .3, y - 3, LF.shade, orr) end
-- crinkled frilly top
for _, p in ipairs{ {16,17,4}, {23,12,5}, {32,9,5}, {41,12,5}, {48,17,4} } do
  local m = c:ellipse(p[1], p[2], p[3], p[3] * .75)
  B.lit(c, m, D.R("#e8f8a0", "#a8d450", "#5a9a48", "#2f6a48"), 2)
  c:px(p[1] - 1, p[2], "#f4fbc0") c:px(p[1] + 1, p[2] + 1, "#5a9a48")
end
-- cut stem base
local base = c:ellipse(32, 57, 9, 2)
B.lit(c, base, WH, 2)
-- dewdrop
local dd = c:ellipse(17, 38, 2, 2.5)
c:fillMask(dd, "#b6f0e0") c:fillMask(dd:shrink(1), "#e4f6ff") c:px(16, 37, "#fffaea")
D.fin()
