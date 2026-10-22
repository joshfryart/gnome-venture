local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local handle = c:ellipse(45.5, 37, 9.5, 8.5):cut(c:ellipse(45.5, 37, 5.5, 4.5)):cut(c:rect(0, 0, 41, 63))
local body = c:rrect(15, 22, 45, 54, 12):add(c:rect(15, 22, 45, 32))
local liq = c:rect(18, 25, 42, 33):add(c:ellipse(30, 33, 12, 4)):clip(body:shrink(3))
c:build{
  { "handle", handle, "stone" },
  { "body", body, GV.ramp("#c9c5bc"), { light = body } },
  { "cordial", liq, GV.ramp("#d6322b"), { light = body, gloss = { 20, 27 } } },
  { "rim", c:rrect(14, 21, 46, 24, 1), "stone", { flat = true } },
}
c:fill(c:rect(22, 29, 23, 30), "#6b1b2c"); c:fill(c:rect(30, 32, 31, 33), "#6b1b2c"); c:fill(c:rect(38, 29, 39, 30), "#6b1b2c")
c:px(22, 29, "#ae2a2a"); c:px(30, 32, "#ae2a2a"); c:px(38, 29, "#ae2a2a")
c:fill(c:rect(19, 41, 20, 47), "#fff3c8"); c:px(19, 39, "#fff3c8")
local t = c:save(O .. "aseprite/ph/mixed-berry-cordial.aseprite", O .. "png/ph/mixed-berry-cordial.png")
print(GV.report(t))
