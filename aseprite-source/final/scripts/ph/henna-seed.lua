local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc", { shade = "#8fcbd8", deep = "#3f8fb0", bounce = "#8fcbd8" })
local seed = GV.ramp("#7a5cc0", { shade = "#55419a", deep = "#3e2f66" })
local leaf = GV.ramp("#58a03e")
local jar = c:rrect(15, 22, 48, 54, 9)
local p = c:build{
  { "neck", c:rect(23, 15, 40, 24), glass, { gloss = false } },
  { "jar",  jar, glass, { gloss = false } },
  { "seed", c:ellipse(32, 40, 9, 8.5), seed },
  { "leaf", c:ellipse(39.5, 30.5, 5, 2.5), leaf, { flat = true } },
  { "cork", c:rrect(22, 7, 41, 16, 2), "wood" },
}
c:seam({ {23, 15}, {41, 15} }, { free = true })
-- glass shine strips
c:fill(c:rect(19, 27, 20, 42), "#fff1c8")
c:fill(c:rect(19, 45, 20, 47), "#fff1c8")
c:fill(c:rect(26, 17, 26, 21), "#fff1c8")
-- leaf midrib, cork grain
c:paint({ "mmmm" }, 37, 30, { m = "#4a8a3e" })
c:px(36, 10, "#8a4f2a"); c:px(28, 12, "#8a4f2a")
local t = c:save(O .. "aseprite/ph/henna-seed.aseprite", O .. "png/ph/henna-seed.png")
print(GV.report(t))
