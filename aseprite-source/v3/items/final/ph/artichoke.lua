local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("artichoke")
-- artichoke: globe of overlapping scale rows, olive green with purple-tinged tips, stout stem and two side leaves. quirk: a ladybird sits on one scale.
D.shadow(32, 58, 12, 2)
D.ln(32, 48, 32, 58, "#6aa05a") D.ln(33, 48, 33, 58, "#3f8a4e") D.ln(31, 48, 31, 57, "#9cc878")
D.scrap(30, 52, 8, 38, 3.5, D.LEAF2, {norib=true}) D.scrap(34, 52, 56, 40, 3.5, D.LEAF)
local PUR = {"#3a2a52","#5a3f78","#7a5a98","#9a7ab4","#b89acc","#d4bce4"}
local G = {"#1c4a38","#2b6b45","#4a8a50","#6aa85a","#8cc470","#b4de90"}
local m = c:ellipse(32, 32, 15, 17):add(c:rect(24, 42, 40, 48))
D.lit(m, G, 7)
-- scale rows
for row = 0, 5 do
  local y = 18 + row * 6
  local half = row < 2 and 4 + row * 4 or (row < 5 and 12 or 8)
  local n = 3
  for i = -1, 1 do
    local cx = 32 + i * 9 + (row % 2) * 4 - 2
    local sm = D.P({{cx-5,y},{cx+5,y},{cx+4,y+6},{cx,y+9},{cx-4,y+6}}, row % 2 == 0 and G or {"#244a3a","#38684a","#58885a","#78a868","#a0c880","#c8e8a0"}, 2)
    D.ln(cx-4, y+6, cx, y+9, PUR[3]) D.ln(cx+4, y+6, cx, y+9, PUR[2])
    D.px(cx, y+8, PUR[4])
  end
end
D.E(32, 14, 4, 3, 0, G, 2)
-- ladybird
D.E(40, 36, 3, 2.5, 0, D.RED, 1.5) D.ln(40, 34, 40, 38, D.INK) D.px(38, 35, D.INK) D.px(42, 37, D.INK) D.px(38, 36, "#fff4d6")
D.fin()
