local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local rings = c:mask()
for _, y in ipairs({ 23, 30, 37 }) do rings:add(c:rect(27, y, 36, y + 2)) end
c:build{
  { "tip",    c:poly({ {28,44}, {36,44}, {32,53} }), "#6a6070", { flat = true } },
  { "rod",    c:rrect(28, 17, 35, 45, 2), "#968f96", { gloss = { 29, 20 } } },
  { "rings",  rings, "gold", { flat = true } },
  { "handle", c:rrect(15, 11, 48, 18, 3), GV.ramp("#b07a45", { rim = "#d9a660" }) },
}
for y = 41, 43 do c:px(29, y, "#c9c5bc") end
c:seam({ {30, 12}, {30, 17} }); c:seam({ {33, 12}, {33, 17} })
c:ground(32, 54, 9, 1.5)
local t = c:save(O .. "aseprite/ph/soil-probe.aseprite", O .. "png/ph/soil-probe.png")
print(GV.report(t))
