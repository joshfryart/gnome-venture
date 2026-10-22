local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a9d6ea", { rim = "#c8ecdc" })
local brine = GV.ramp("#8c4a1a")
local p = c:build{
  { "jar", c:rrect(18, 22, 45, 53, 7), glass },
  { "contents", c:rrect(21, 29, 42, 50, 5), brine, { gloss = false } },
}
-- bean sticks (green, with pod bumps)
for _, x in ipairs({ 22, 27, 33, 38 }) do
  c:part(c:rect(x, 31, x + 2, 49), GV.ramp("#7ab55c", { rim = "#c8d77a" }), { flat = true, contour = false, contact = false })
  for y = 33, 47, 4 do c:px(x + 2, y, GV.R.moss.shade) end
  c:px(x, 31, GV.R.moss.gloss)
end
c:part(c:rrect(17, 13, 46, 23, 4), "gold")
c:part(c:rrect(24, 41, 39, 46, 2), GV.ramp("#f4f0e0"), { gloss = false })
-- tiny bean motif on label
c:paint({ ".mm.mm.", "m..m..m" }, 28, 43, { m = "#4a8a3e" })
c:seam({ { 19, 21 }, { 44, 21 } })
-- glass glints upper-left
c:px(20, 28, "#e8f7f0"); c:px(20, 29, "#e8f7f0"); c:px(20, 30, "#e8f7f0"); c:px(20, 32, "#e8f7f0")
c:ground(31.5, 56, 16, 2.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/pickled-green-beans.aseprite", O .. "png/ph/pickled-green-beans.png")
print(GV.report(t))
