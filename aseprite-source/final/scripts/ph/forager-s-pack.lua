local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- arched handle (behind)
local handle = c:ellipse(31.5, 31, 12, 17):cut(c:ellipse(31.5, 31, 8, 13)):cut(c:rect(0, 32, 63, 63))
-- flared sack: narrow lip, wide bottom
local sack = c:poly({ {19, 31}, {45, 31}, {52, 52}, {12, 52} })
sack:add(c:rrect(12, 44, 51, 54, 4))
local straps = c:rect(0, 39, 63, 41):add(c:rect(0, 46, 63, 48)):clip(sack:shrink(1))
local p = c:build{
  { "handle", handle, "wood" },
  { "sack", sack, "#b07a45", { stitch = { side = "lit" } } },
  { "straps", straps, "gold", { flat = true } },
  { "clasp", c:ellipse(31.5, 36.5, 3.5, 3.5), "#d6c9b6" },
}
c:seam({ {16, 32}, {48, 32} })
c:px(31, 36, GV.C.umber); c:px(32, 37, GV.C.umber)
local t = c:save(O .. "aseprite/ph/forager-s-pack.aseprite", O .. "png/ph/forager-s-pack.png")
print(GV.report(t))
