local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local brown = GV.ramp("#a8825a")
-- tilted egg body: round rump at lower left, head rising at upper right
local body = c:ellipse(29, 40, 17, 14)
body:add(c:ellipse(40, 27, 10, 9))
body:add(c:poly({ {30, 26}, {46, 20}, {50, 34}, {38, 46} }))
-- short tail tuft at the back
local tail = c:poly({ {14, 34}, {8, 30}, {9, 36}, {14, 40} })
local legs = c:rect(25, 52, 27, 57):add(c:rect(33, 52, 35, 57))
local plume = c:line({ {40, 19}, {41, 14}, {44, 11}, {47, 11}, {48, 13} }, 3)
local beak = c:poly({ {49, 25}, {55, 27}, {49, 30} })
local p = c:build{
  { "legs", legs, "gold", { flat = true } },
  { "tail", tail, brown },
  { "plume", plume, GV.ramp("#3b2a1a"), { flat = true } },
  { "body", body, brown, { stitch = { side = "lit" } } },
  { "beak", beak, "gold", { flat = true } },
}
-- cream throat patch
local throat = c:ellipse(44, 33, 4, 2.5):clip(p.body.m)
c:part(throat, GV.ramp("#f1e6d2"), { flat = true })
-- striped breast bands (curved)
local band = "#6e4f2f"
c:fill(c:line({ {18, 38}, {24, 40}, {32, 41}, {38, 40} }, 2):clip(p.body.m), band)
c:fill(c:line({ {21, 46}, {28, 47}, {36, 46} }, 2):clip(p.body.m), band)
-- feet toes
c:paint({ "ggg..", "....." }, 24, 58, { g = GV.C.gold })
c:paint({ "ggg" }, 32, 58, { g = GV.C.gold })
c:px(27, 58, GV.C.gold); c:px(35, 58, GV.C.gold)
-- eye
c:eye(42, 24, true)
local t = c:save(O .. "aseprite/animals/quail.aseprite", O .. "png/animals/quail.png")
print(GV.report(t))
