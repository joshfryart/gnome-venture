local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pink = GV.ramp("#e46a9b", { deep = "#a8241f" })
-- squat round pot, wider than tall
local pot = c:ellipse(31.5, 40, 21, 14):cut(c:rect(0, 0, 63, 28))
pot:add(c:rect(16, 28, 47, 31))
local band = c:rrect(13, 27, 50, 30, 1)
local lid = c:ellipse(31.5, 27, 16, 11):cut(c:rect(0, 27, 63, 63))
local knob = c:ellipse(31.5, 13, 4, 4)
local flower = c:ellipse(31.5, 42, 7, 7)
local p = c:build{
  { "pot", pot, "wood" },
  { "lid", lid, GV.ramp("#d9a660", { rim = "#ecc58a" }) },
  { "knob", knob, GV.ramp("#8a4f2a"), { gloss = { 30, 11 } } },
  { "band", band, GV.ramp("#5e2f1e"), { gloss = false } },
  { "flower", flower, pink, { gloss = { 28, 38 } } },
}
-- painted petals notch + centre
c:paint({ ".g.", "ggg", ".g." }, 30, 41, { g = "#f5cf6a" })
c:paint({ "ll.", "lll", ".ll" }, 36, 32, { l = "#58a03e" })
c:paint({ "ll", "ll" }, 19, 40, { l = "#ecc58a" })
c:paint({ "ll", "ll" }, 43, 40, { l = "#ecc58a" })
c:seam({ {14, 28}, {49, 28} }, { free = true })
c:ground(31.5, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/rangoon-creeper-seed.aseprite", O .. "png/ph/rangoon-creeper-seed.png")
print(GV.report(t))
