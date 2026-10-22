local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- sheet body with the top-right corner cut away (it is folded over)
local sheet = c:rect(11, 14, 47, 51):cut(c:poly({{37,13},{49,13},{49,26}}))
-- corrugated flute edge on the right: zig-zag teeth
local edge = c:mask()
for y = 18, 51 do
  local t = (y - 18) % 6
  local w = (t < 3) and t or (6 - t)
  for x = 46, 49 + w do edge:set(x, y) end
end
edge:cut(c:poly({{37,13},{52,13},{52,28}}))
local flap = c:poly({{37,14},{48,26},{37,26}})
local tape = c:poly({{17,31},{34,27},{36,35},{19,39}})
local p = c:build{
  { "sheet", sheet, GV.ramp("#dcb06a") },
  { "edge",  edge,  GV.ramp("#b07a45"), { gloss = false } },
  { "flap",  flap,  GV.ramp("#ecc58a"), { gloss = false } },
  { "tape",  tape,  GV.ramp("#f1ece0"), { gloss = false } },
}
-- flute lines (faint corrugation showing through)
for _, y in ipairs({22, 40, 46}) do c:fill(c:line({{15,y},{43,y}},1):cut(tape):cut(flap), "#c4955a") end
c:fill(c:line({{15,28},{35,28}},1):cut(tape):cut(flap), "#c4955a")
-- fold edge crease along the diagonal
c:fill(c:line({{38,14},{48,24}},1), "#8a4f2a")
-- tape tear ends
c:px(18,33,"#c9a96e"); c:px(19,37,"#c9a96e"); c:px(35,29,"#c9a96e"); c:px(35,33,"#c9a96e")
-- scuff
c:paint({ ".ss", "ss." }, 15, 45, { s = "#a8582f" })
local t = c:save(O .. "aseprite/ph/cardboard-sheet.aseprite", O .. "png/ph/cardboard-sheet.png")
print(GV.report(t))
