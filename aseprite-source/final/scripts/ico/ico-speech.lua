local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bub = c:rrect(9, 9, 55, 43, 9)
bub:add(c:poly({ {14, 38}, {30, 38}, {13, 55} }))
local p = c:build{
  { "bubble", bub, "water", { gloss = { 13, 13 } } },
}
c:fill(c:rrect(16, 12, 50, 16, 2), "#8fcbd8")
for _, x in ipairs({ 22, 32, 42 }) do
  c:part(c:ellipse(x, 27, 3.5, 3.5), GV.ramp("#f4f0e0"), { gloss = false, cres = 2, deep = 1 })
end
local t = c:save(O .. "aseprite/ico/ico-speech.aseprite", O .. "png/ico/ico-speech.png")
print(GV.report(t))
