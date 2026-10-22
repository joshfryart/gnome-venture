local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

-- back wall with soft stepped light from the canopy gap
c:bands(c:rect(0, 0, 63, 63), { "#a4c86a", "#8fc060", "#7ab55c", "#6aa452" }, { dir = "radial", cx = 31, cy = 4, r = 50 })
-- forest floor
c:part(c:rect(0, 49, 63, 63):add(c:ellipse(31.5, 50, 40, 3)), GV.ramp("#2e5a2c"), { gloss = false })
-- trunks
local trunkR = GV.ramp("#b6814d", { rim = "#f0d49a" })
c:part(c:rect(13, 20, 19, 52):add(c:poly({ {11, 53}, {22, 53}, {19, 48}, {13, 48} })), trunkR, { gloss = false, cres = 3 })
c:part(c:rect(44, 16, 50, 52):add(c:poly({ {42, 53}, {53, 53}, {50, 48}, {44, 48} })), trunkR, { gloss = false, cres = 3 })
-- canopy: dark side blobs, lighter middle
local dark = GV.ramp("#2e5a2c")
c:part(c:ellipse(15, 19, 13, 7):add(c:ellipse(7, 23, 7, 4)):add(c:ellipse(22, 14, 7, 4)), dark, { gloss = { 9, 15 } })
c:part(c:ellipse(48, 15, 14, 7):add(c:ellipse(57, 20, 7, 4)):add(c:ellipse(40, 10, 7, 4)), dark, { gloss = { 41, 11 } })
c:part(c:ellipse(30.5, 9, 10, 5):add(c:ellipse(26, 11, 5, 4)), "moss", { gloss = { 25, 7 } })
-- hanging vines
local vine = GV.ramp("#b0bc66")
c:part(c:line({ {23, 21}, {24, 27}, {22, 33}, {23, 39} }, 2), vine, { flat = true, outline = false })
c:part(c:line({ {31, 13}, {30, 19}, {32, 25}, {31, 31}, {32, 36} }, 2), vine, { flat = true, outline = false })
c:paint({ "v.", ".v" }, 25, 28, { v = "#b0bc66" })
c:paint({ ".v", "v." }, 28, 22, { v = "#b0bc66" })
-- bromeliad: red leaf rosette
c:part(c:ellipse(38, 31, 3.5, 2):add(c:poly({ {35, 31}, {37, 26}, {38, 31} })):add(c:poly({ {39, 31}, {41, 26}, {42, 31} })),
  GV.ramp("#d6322b"), { gloss = false, cres = 2 })
-- fern: two curled fronds
local fern = GV.ramp("#58a03e")
c:part(c:line({ {31, 47}, {28, 43}, {24, 41}, {22, 38}, {24, 36}, {26, 38} }, 2), fern, { flat = true })
c:part(c:line({ {32, 47}, {35, 43}, {39, 41}, {41, 38}, {39, 36}, {37, 38} }, 2), fern, { flat = true })
c:paint({ "f.f.f", ".f.f." }, 27, 45, { f = "#7ab55c" })
-- flowers
local petal = GV.ramp("#e46a9b")
c:part(c:ellipse(54, 38, 2.5), petal, { gloss = false, cres = 2 })
c:part(c:ellipse(9, 44, 2.5), petal, { gloss = false, cres = 2 })
c:px(54, 38, "#f5cf6a"); c:px(9, 44, "#f5cf6a")
-- hem stitch along bottom
c:seam({ { 1, 60 }, { 62, 60 } }, { free = true })
local t = c:save(O .. "aseprite/ph/land-rainforest.aseprite", O .. "png/ph/land-rainforest.png")
print(GV.report(t))
