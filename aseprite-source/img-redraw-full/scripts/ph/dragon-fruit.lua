local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = GV.ramp("#58a03e")
local p = c:build{
  { "stem", c:rect(30, 12, 34, 22), GV.ramp("#2e5a2c") },
  { "body", c:ellipse(32, 37, 17, 16), "petal" },
  { "tl", c:poly({ {23,26},{22,14},{24,6},{26,12},{31,24} }), leaf, { flat = false } },
  { "tr", c:poly({ {34,24},{38,12},{42,7},{42,15},{41,26} }), leaf },
  { "sl", c:poly({ {19,40},{12,33},{7,27},{15,29},{22,33} }), leaf },
  { "sr", c:poly({ {43,33},{50,29},{57,27},{52,34},{45,40} }), leaf },
  { "bl", c:poly({ {21,50},{17,45},{14,41},{21,43},{28,49} }), leaf },
  { "br", c:poly({ {36,49},{43,43},{50,41},{47,46},{42,51} }), leaf },
}
-- seed flecks
for _, s in ipairs({ {27,35},{37,31},{31,41},{40,38},{24,44},{34,47} }) do
  c:px(s[1], s[2], "#35161f")
end
local t = c:save(O .. "aseprite/ph/dragon-fruit.aseprite", O .. "png/ph/dragon-fruit.png")
print(GV.report(t))
