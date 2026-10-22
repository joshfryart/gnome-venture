local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#8b8f96", { rim = "#c9c5bc" })
-- lid propped open behind the box, seen from the inside
local lid = c:poly({ {13, 30}, {52, 30}, {47, 11}, {18, 11} })
local inside = c:rect(15, 26, 49, 31)
local seed = c:ellipse(32, 25, 10, 8.5)
local body = c:rrect(13, 30, 51, 50, 3)
local p = c:build{
  { "lid", lid, GV.ramp("#c9c5bc"), { gloss = false } },
  { "inside", inside, "#3a3f48", { flat = true } },
  { "seed", seed, GV.ramp("#f08a24", { shade = "#e0501f" }) },
  { "body", body, tin },
}
-- inner face of the lid (dark recess inside a pale metal rim)
c:fill(c:poly({ {17, 28}, {48, 28}, {44, 14}, {21, 14} }), "#5b6470")
c:fill(c:poly({ {17, 28}, {48, 28}, {47, 26}, {18, 26} }), "#4a515c")
-- re-draw the seed top over the lid face
c:part(seed:copy():cut(c:rect(0, 30, 63, 63)):cut(c:rect(0, 0, 63, 15)):clip(c:ellipse(32, 25, 9, 7.5)), GV.ramp("#f08a24", { shade = "#e0501f" }), { contour = false, contact = false, rim = false, bounce = false, gloss = { 27, 20 } })
-- sprout
c:part(c:rect(31, 12, 32, 17), "#2e5a2c", { flat = true })
c:part(c:ellipse(36.5, 11.5, 3.5, 2), "#58a03e", { flat = true, gloss = false })
-- hinge line and rivets
c:fill(c:rect(15, 30, 49, 30), GV.C.umber)
c:paint({ ".g.", "gGg", ".g." }, 18, 29, { g = "#e8a317", G = "#fff1c8" })
c:paint({ ".g.", "gGg", ".g." }, 44, 29, { g = "#e8a317", G = "#fff1c8" })
-- label plate
c:fill(c:rect(22, 38, 42, 46), "#dcb06a")
c:fill(c:rect(23, 39, 41, 45), "#f1ece0")
c:paint({ "..cc..", ".cccc.", "cccccc" }, 29, 41, { c = "#f08a24" })
local t = c:save(O .. "aseprite/ph/ensete-seed.aseprite", O .. "png/ph/ensete-seed.png")
print(GV.report(t))
