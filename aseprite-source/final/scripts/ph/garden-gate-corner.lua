local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "rb" }
local hr = c:rect(30, 22, 63, 25):add(c:rect(30, 31, 63, 34))
local vr = c:rect(22, 30, 25, 63):add(c:rect(31, 35, 34, 63))
local pk = c:mask()
for _, x in ipairs({38, 46, 54}) do pk:add(c:rrect(x, 13, x + 4, 40, 2)) end
local sl = c:mask()
for _, y in ipairs({38, 46, 54}) do sl:add(c:rrect(13, y, 36, y + 4, 2)) end
c:build{
  { "hrail", hr, "#7d7680", { gloss = false } },
  { "vrail", vr, "#7d7680", { gloss = false } },
  { "pickets", pk, "#f4f0e0", { light = c:rect(13, 13, 63, 63) } },
  { "slats", sl, "#f4f0e0", { light = c:rect(13, 13, 63, 63) } },
  { "knob", c:rrect(17, 17, 33, 33, 3), "#d6c9b6" },
  { "cap", c:rrect(20, 20, 30, 30, 2), "#f4f0e0" },
}
c:button(24, 24)
local t = c:save(O .. "aseprite/ph/garden-gate-corner.aseprite", O .. "png/ph/garden-gate-corner.png")
print(GV.report(t))
