local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- side handles (rings), behind the pot
local hl = c:ellipse(12, 37, 5, 6):cut(c:ellipse(12, 37, 2, 3))
local hr = c:ellipse(52, 37, 5, 6):cut(c:ellipse(52, 37, 2, 3))
local handles = hl:copy(); handles:add(hr)

local body = c:ellipse(31.5, 39, 19, 16)
local foot = c:rrect(21, 50, 42, 56, 2)
local win  = c:ellipse(31.5, 43, 10, 7)
local seed = c:ellipse(31.5, 45, 6, 4.5)
local cap  = c:ellipse(31.5, 42, 5, 3):cut(c:rect(0, 43, 63, 63))
local lid  = c:ellipse(31.5, 27, 17, 10):cut(c:rect(0, 28, 63, 63))
lid:add(c:rrect(13, 25, 50, 30, 2))
local knob = c:ellipse(31.5, 15, 4, 4)

c:build{
  { "handles", handles, "#2f6290", { gloss = false } },
  { "foot", foot, "water", { gloss = false } },
  { "body", body, "water" },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false } },
  { "seed", seed, GV.ramp("#dcb06a"), { gloss = { 28, 43 } } },
  { "cap", cap, GV.ramp("#a5663a"), { flat = true } },
  { "lid", lid, "wood" },
  { "knob", knob, "#d9a660", { gloss = { 30, 13 } } },
}
-- sprout from the seed
c:paint({ "..gg", ".ggg", "gg..", "s...", "s..." }, 31, 34, { g = "#58a03e", s = "#2e5a2c" })
c:seam({ { 15, 29 }, { 48, 29 } })
c:button(22, 21)
c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/macadamia-seed.aseprite", O .. "png/ph/macadamia-seed.png")
print(GV.report(t))
