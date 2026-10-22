local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- squat wide jar: shoulders narrow into a neck under a wide lid
local jar = c:rrect(15, 26, 48, 54, 8)
jar:add(c:rrect(20, 22, 43, 30, 3))
local fill = c:rrect(18, 31, 45, 52, 6)
local lid = c:rrect(16, 14, 47, 24, 4)
local label = c:rect(19, 37, 44, 46)
c:build{
  { "jar",   jar,   "glass", { gloss = false } },
  { "fill",  fill,  GV.ramp("#d6322b", { shade = "#ae2a2a" }), { gloss = { 22, 33 } } },
  { "lid",   lid,   "gold" },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false, pale = true } },
}
-- glass glints on the shoulder
c:px(18, 29, "#c8ecdc"); c:px(18, 30, "#c8ecdc"); c:px(19, 28, "#c8ecdc")
-- lid ridges
for x = 20, 44, 4 do c:px(x, 16, "#b8661a"); c:px(x, 17, "#b8661a") end
c:seam({ { 17, 24 }, { 46, 24 } })
c:button(30, 17)
-- label: little tomato mark + umber ticks
c:paint({
  "..g.g..",
  ".rrgrr.",
  "rrrrrrr",
  "rrrrrrr",
  ".rrrrr.",
}, 28, 39, { r = "#dd3a2a", g = "#4a8a3e" })
c:paint({ "uu" }, 22, 41, { u = "umber" }); c:paint({ "uu" }, 40, 41, { u = "umber" })
c:ground(31.5, 57, 17, 2.5)
local t = c:save(O .. "aseprite/ph/tomato-chutney.aseprite", O .. "png/ph/tomato-chutney.png")
print(GV.report(t))
