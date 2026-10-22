local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dome = c:ellipse(31, 33, 18.5, 18):cut(c:rect(0, 36, 63, 63))
local p = c:build{
  { "pole",  c:rect(44, 8, 45, 24), GV.ramp("#5e2f1e"), { flat = true } },
  { "flag",  c:poly({ { 46, 8 }, { 53, 12 }, { 46, 16 } }), "red", { gloss = false } },
  { "dome",  dome, "soil" },
  { "box",   c:rect(13, 33, 49, 51), GV.ramp("#a8582f") },
  { "postL", c:rrect(10, 31, 14, 52, 1), "wood", { gloss = false } },
  { "postR", c:rrect(48, 31, 52, 52, 1), "wood", { gloss = false } },
  { "plank1", c:rect(15, 36, 46, 39), GV.ramp("#b6814d"), { gloss = false } },
  { "plank2", c:rect(15, 42, 46, 45), GV.ramp("#b6814d"), { gloss = false } },
  { "knob",  c:rrect(16, 38, 21, 44, 2), "gold", { gloss = false } },
}
-- scraps on the heap
c:paint({ ".l.", "lll", ".L." }, 20, 19, { l = "#7ab55c", L = "#4a8a3e" })
c:paint({ ".r.", "rrr", ".R." }, 35, 16, { r = "#e0501f", R = "#ae2a2a" })
c:paint({ "gg", "gG" }, 30, 25, { g = "#e8a317", G = "#b8661a" })
c:paint({ "..m", ".mm", "mmM" }, 39, 23, { m = "#7ab55c", M = "#4a8a3e" })
c:px(26, 28, "#7a4a1f"); c:px(37, 29, "#7a4a1f"); c:px(17, 27, "#7a4a1f")
-- sparkle
c:paint({ ".s.", "sws", ".s." }, 15, 16, { s = "#f5cf6a", w = "#fff1c8" })
-- plank board gaps (nail dots)
c:px(44, 37, "#5e2f1e"); c:px(44, 43, "#5e2f1e")
c:seam({ { 15, 49 }, { 47, 49 } }, { free = true })

c:ground(31.5, 53, 21, 1.5)
local t = c:save(O .. "aseprite/ph/compost_bin-3.aseprite", O .. "png/ph/compost_bin-3.png")
print(GV.report(t))
