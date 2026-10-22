local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- squared arch handle: outer 21..42 x 13..27, opening 10 px
local handle = c:rrect(21, 12, 42, 27, 2):cut(c:rect(27, 18, 36, 27))
local body = c:rrect(8, 24, 55, 55, 3)
local band = c:rect(8, 34, 55, 38)
local p = c:build{
  { "handle", handle, "stone" },
  { "body", body, "red", { gloss = { 12, 27 } } },
  { "band", band, "wood", { light = body, gloss = false } },
  { "latch", c:rrect(27, 30, 36, 42, 2), "gold", { gloss = { 29, 32 } } },
}
-- shade line under band
for x = 10, 53 do c:px(x, 39, "#8a4f2a") end
-- keyhole
c:paint({ "kk", "kk", ".k" }, 31, 35, { k = "#8a4a1c" })
-- rivets
for _, q in ipairs({ { 12, 28 }, { 50, 28 }, { 12, 50 }, { 50, 50 } }) do
  c:paint({ "gg", "gG" }, q[1], q[2], { g = "#f5cf6a", G = "#e8a317" })
end
local t = c:save(B .. "aseprite/ico/ico-toolbox.aseprite", B .. "png/ico/ico-toolbox.png")
print(GV.report(t))
