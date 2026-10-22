local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- compost dome heaped above the bin
local dome = c:ellipse(31.5, 31, 19, 20):cut(c:rect(0, 32, 63, 63))
dome:add(c:rect(13, 28, 50, 32))
local body = c:rrect(10, 29, 53, 51, 2)
local slat1 = c:rect(12, 32, 51, 35)
local slat2 = c:rect(12, 39, 51, 42)
local slat3 = c:rect(12, 46, 51, 49)
local postL = c:rrect(7, 26, 12, 52, 2)
local postR = c:rrect(51, 26, 56, 52, 2)
local mossTop = c:ellipse(16, 18, 6, 3):add(c:ellipse(47, 19, 5, 3))
local mossMid = c:ellipse(30, 11, 5, 2.5)
local mossBase = c:ellipse(20, 51, 7, 3):add(c:ellipse(43, 51.5, 8, 3))

c:build{
  { "dome", dome, GV.ramp("#44281c") },
  { "body", body, "wood" },
  { "s1", slat1, GV.ramp("#d9a660"), { gloss = false } },
  { "s2", slat2, GV.ramp("#d9a660"), { gloss = false } },
  { "s3", slat3, GV.ramp("#d9a660"), { gloss = false } },
  { "postL", postL, GV.ramp("#d9a660") },
  { "postR", postR, GV.ramp("#d9a660"), { gloss = false } },
  { "mossT", mossTop, "moss" },
  { "mossM", mossMid, GV.ramp("#6a9a3a") },
  { "mossB", mossBase, "moss" },
}
-- scraps on the heap
c:part(c:ellipse(24, 23, 2), "moss", { flat = true })
c:part(c:ellipse(37, 17, 2), GV.ramp("#f08a24"), { flat = true })
c:part(c:ellipse(32, 25, 2), "gold", { flat = true })
c:paint({ "..gg", ".ggg", "ggg.", "g..." }, 41, 22, { g = "#7ab55c" })
-- moss drips over the posts
c:fill(c:line({ {9, 28}, {10, 34}, {9, 40} }, 2), "#6a9a3a")
c:fill(c:line({ {54, 28}, {53, 35}, {54, 42} }, 2), "#6a9a3a")
c:ground(31.5, 54, 24, 1)
local t = c:save(O .. "aseprite/ph/compost_bin-mossy.aseprite", O .. "png/ph/compost_bin-mossy.png")
print(GV.report(t))
