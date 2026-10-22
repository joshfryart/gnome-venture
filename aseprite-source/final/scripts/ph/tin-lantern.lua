local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin   = GV.ramp("#b6814d")
local glass = GV.ramp("#f5cf6a")
-- handle loop on top
local handle = c:ellipse(31.5, 14, 7, 7):cut(c:ellipse(31.5, 14, 3.5, 3.5)):cut(c:rect(0, 16, 63, 63))
c:build{
  { "handle", handle, GV.ramp("#c4925f"), { flat = true } },
  { "glass",  c:rrect(21, 19, 42, 46, 4), glass, { gloss = { 25, 24 } } },
  { "flame",  c:ellipse(31.5, 34, 5, 6):add(c:poly({ { 28, 32 }, { 31.5, 23 }, { 35, 32 } })), "gold", { gloss = false } },
  { "top",    c:rrect(18, 15, 45, 21, 3), tin },
  { "bottom", c:rrect(18, 45, 45, 51, 3), tin },
}
-- tin bars across the glass
c:fill(c:rect(21, 26, 21, 40), "#8a4f2a")
c:fill(c:rect(42, 26, 42, 40), "#8a4f2a")
-- flame core
c:paint({ ".y.", "yyy", "yyy", ".y." }, 30, 33, { y = "#fff1c8" })
c:px(31, 31, "#fff1c8")
c:seam({ { 20, 21 }, { 43, 21 } })
c:seam({ { 20, 45 }, { 43, 45 } })
c:ground(31.5, 53, 14, 2)
local t = c:save(O .. "aseprite/ph/tin-lantern.aseprite", O .. "png/ph/tin-lantern.png")
print(GV.report(t))
