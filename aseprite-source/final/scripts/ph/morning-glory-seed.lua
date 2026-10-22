local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local seed = c:ellipse(32, 21, 10, 9)
local crate = c:rrect(11, 25, 52, 54, 1)
local slats = c:rect(15, 28, 48, 35):add(c:rect(15, 40, 48, 47))
local posts = c:rect(11, 25, 15, 54):add(c:rect(48, 25, 52, 54))
local rim = c:rrect(9, 22, 54, 26, 1)
local tag = c:rrect(24, 31, 39, 45, 3)

local p = c:build{
  { "stem",  c:rect(31, 8, 32, 13), "#2f5a2a", { flat = true } },
  { "leaf",  c:ellipse(36.5, 10.5, 3.5, 2), "#4a8a3e", { flat = true } },
  { "seed",  seed, "moss" },
  { "crate", crate, "#8a4f2a" },
  { "slats", slats, "#d9a660", { light = crate } },
  { "posts", posts, "#a8582f", { light = crate } },
  { "rim",   rim, "#d9a660" },
  { "tag",   tag, "#a4b86a", { gloss = false } },
}
c:fill(c:rrect(26, 33, 37, 43, 2), "#f4f0e0")
c:part(c:ellipse(31.5, 38, 3, 3), "#7ab55c", { flat = true })
-- plank grain
c:paint({ "gggg" }, 17, 31, { g = "#b07a45" })
c:paint({ "gggg" }, 42, 44, { g = "#b07a45" })
-- nails
for _, n in ipairs{ {12, 28}, {49, 28}, {12, 51}, {49, 51} } do
  c:paint({ "nn", "nn" }, n[1], n[2], { n = "#5e2f1e" })
end
c:ground(32, 57, 18, 2)
local t = c:save(O .. "aseprite/ph/morning-glory-seed.aseprite", O .. "png/ph/morning-glory-seed.png")
print(GV.report(t))
