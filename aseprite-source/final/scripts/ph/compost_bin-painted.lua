local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local heap = c:ellipse(32, 33, 20, 23):cut(c:rect(0, 34, 63, 63))
local p = c:build{
  { "heap", heap, GV.ramp("#44281c"), { gloss = { 22, 18 } } },
}
-- scraps on the heap
c:part(c:ellipse(24, 22, 2), GV.ramp("#58a03e"), { flat = true })
c:part(c:ellipse(38, 17, 2), GV.ramp("#e0501f"), { flat = true })
c:part(c:ellipse(33, 26, 2), "gold", { flat = true })
c:part(c:poly({{41,25},{46,20},{48,26}}), "moss", { flat = true })
c:px(29, 14, "#7a4a1f"); c:px(44, 29, "#7a4a1f"); c:px(19, 29, "#7a4a1f"); c:px(28, 30, "#9a6b3f")
local box = c:rect(10, 30, 53, 55)
local q = c:build{
  { "box", box, GV.ramp("#e46a9b"), { gloss = { 22, 38 } } },
}
local slatR = GV.ramp("#b6814d", { rim = "#f0d49a" })
c:part(c:rect(10, 34, 53, 36), slatR, { gloss = false })
c:part(c:rect(10, 43, 53, 45), slatR, { gloss = false })
c:part(c:rect(10, 51, 53, 53), slatR, { gloss = false })
c:part(c:rrect(8, 28, 12, 55, 1), "gold", { gloss = { 9, 31 } })
c:part(c:rrect(51, 28, 55, 55, 1), "gold", { gloss = { 52, 31 } })
c:seam({ {13, 32}, {50, 32} })
c:ground(32, 57, 24, 3)
local t = c:save(O .. "aseprite/ph/compost_bin-painted.aseprite", O .. "png/ph/compost_bin-painted.png")
print(GV.report(t))
