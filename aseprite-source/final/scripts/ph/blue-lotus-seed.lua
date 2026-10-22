local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- squat cloth bundle with a cinched neck and two fabric ears
local body = c:ellipse(31.5, 39, 19, 16)
body:add(c:rrect(14, 30, 49, 52, 9))
local ears = c:poly({ {20, 22}, {15, 10}, {24, 13}, {30, 20} })
ears:add(c:poly({ {33, 20}, {39, 13}, {48, 10}, {43, 22} }))
ears:add(c:rrect(25, 16, 38, 23, 2))
local band = c:rrect(21, 21, 42, 24, 1)
local cloth = GV.ramp("#f1ece0")

local p = c:build{
  { "ears", ears, cloth },
  { "body", body, cloth, { stitch = { side = "lit" } } },
  { "string", band, GV.ramp("#dcb06a"), { gloss = false } },
}
-- hanging string ends
c:part(c:line({ {27, 25}, {26, 29}, {27, 32} }, 2), GV.ramp("#dcb06a"), { flat = true })
c:part(c:line({ {36, 25}, {37, 29}, {36, 32} }, 2), GV.ramp("#dcb06a"), { flat = true })

-- front patch with a blue teardrop seed
local patch = c:rrect(21, 31, 42, 50, 5)
c:part(patch, GV.ramp("#d8eef2", { rim = "#3f93b2" }), { gloss = false, contact = false })
local seed = c:ellipse(31.5, 44, 6, 5)
seed:add(c:poly({ {26, 43}, {32, 33}, {38, 43} }))
c:part(seed, "water", { gloss = { 29, 41 } })
c:fill(c:line({ {29, 44}, {30, 46} }, 1), "#256a80")
c:fill(c:line({ {34, 44}, {33, 46} }, 1), "#256a80")
-- two leaves at the seed's tip
c:paint({ "gg...gg", "ggg.ggg", ".gg.gg." }, 28, 32, { g = "#58a03e" })

c:seam({ {21, 22}, {42, 22} })
c:button(30, 18)

local t = c:save(O .. "aseprite/ph/blue-lotus-seed.aseprite", O .. "png/ph/blue-lotus-seed.png")
print(GV.report(t))
