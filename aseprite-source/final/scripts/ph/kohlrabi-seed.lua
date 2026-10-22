local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = GV.ramp("#6cb84a")
local lA = c:poly({ {21, 6}, {25, 5}, {30, 13}, {30, 19}, {26, 19}, {22, 12} })
local lB = c:poly({ {39, 5}, {43, 6}, {42, 12}, {38, 19}, {34, 19}, {34, 13} })
local bulb = c:ellipse(32, 27, 12, 10):add(c:poly({ {27, 19}, {37, 19}, {33, 14}, {31, 14} }))
local crate = c:rrect(11, 36, 53, 55, 2)
local posts = c:rect(11, 36, 16, 55):add(c:rect(48, 36, 53, 55))
local rim = c:rrect(9, 32, 55, 37, 1)
c:build{
  { "leafA", lA, leaf },
  { "leafB", lB, leaf },
  { "bulb", bulb, GV.ramp("#8a6ad0") },
  { "crate", crate, "wood" },
  { "posts", posts, GV.ramp("#d9a660"), { gloss = false } },
  { "rim", rim, GV.ramp("#d9a660") },
}
-- leaf midribs
c:paint({ "v", "v", "v", "v" }, 27, 10, { v = "#3f7a2c" })
c:paint({ "v", "v", "v", "v" }, 37, 10, { v = "#3f7a2c" })
-- bulb veins
c:paint({ "vvv", "...vv" }, 24, 25, { v = "#4e3a8a" })
c:paint({ "..vv", "vvv" }, 36, 27, { v = "#4e3a8a" })
-- slats between posts
for _, y in ipairs({ 42, 48 }) do
  c:fill(c:rect(17, y, 47, y + 1), "#8a4f2a")
end
c:fill(c:rect(16, 38, 16, 55), "#8a4f2a")
c:fill(c:rect(48, 38, 48, 55), "#8a4f2a")
-- nails
c:fill(c:rect(12, 34, 13, 35), "#5e2f1e")
c:fill(c:rect(51, 34, 52, 35), "#5e2f1e")
c:fill(c:rect(13, 51, 14, 52), "#5e2f1e")
c:fill(c:rect(50, 51, 51, 52), "#5e2f1e")
c:seam({ { 11, 37 }, { 53, 37 } })
local t = c:save(O .. "aseprite/ph/kohlrabi-seed.aseprite", O .. "png/ph/kohlrabi-seed.png")
print(GV.report(t))
