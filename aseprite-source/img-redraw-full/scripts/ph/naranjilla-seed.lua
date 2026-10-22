local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:rrect(13, 28, 51, 56, 9)
jar:add(c:poly({ {24, 19}, {41, 19}, {51, 33}, {13, 33} }))
jar:add(c:ellipse(32, 31, 18, 8))
local glass = GV.ramp("#e2f0ea", { shade = "#b4dcd8", deep = "#8fcbd8", bounce = "#c8ecdc" })
c:build{
  { "jar",  jar, glass },
  { "cork", c:rrect(25, 7, 39, 19, 2), GV.ramp("#d9a660") },
  { "rim",  c:rrect(21, 18, 43, 22, 2), GV.ramp("#8fcbd8") },
  { "fruit", c:ellipse(32, 41, 11), GV.ramp("#f08a24", { shade = "#e0501f", deep = "#b8452f" }) },
  { "leaf", c:poly({ {33, 30}, {37, 25}, {43, 23}, {41, 28}, {36, 31} }), "leaf", { flat = true } },
  { "stalk", c:line({ {31, 31}, {31, 27} }, 2), GV.ramp("#2f5a2a"), { flat = true } },
}
c:paint({ "w.", "..", ".w", "..", "w." }, 29, 10, { w = "#a8582f" })
c:paint({ "w", ".", "w" }, 35, 12, { w = "#a8582f" })
c:seam({ {22, 20}, {43, 20} })
c:fill(c:rect(17, 34, 18, 46), "#f8fbf0")
c:fill(c:rect(17, 48, 18, 49), "#f8fbf0")
c:fill(c:rect(22, 54, 42, 54), "#8fcbd8")
local t = c:save(O .. "aseprite/ph/naranjilla-seed.aseprite", O .. "png/ph/naranjilla-seed.png")
print(GV.report(t))
