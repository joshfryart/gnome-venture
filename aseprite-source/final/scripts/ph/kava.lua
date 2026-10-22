local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tapered root: chain of ellipses from thin left to fat right
local body = c:mask()
for i = 0, 10 do
  local t = i / 10
  local x = 16 + t * 30
  local y = 41 - t * 16
  local r = 4 + t * 4
  body:add(c:ellipse(x, y, r + 0.5, r))
end
local knobs = c:ellipse(24, 31, 4.5, 4):add(c:ellipse(33, 25.5, 5, 4.5)):add(c:ellipse(42, 20.5, 4.5, 4))
local p = c:build{
  { "sprout", c:line({ {16,44}, {12,48} }, 3), "#4a8a3e", { flat = true } },
  { "leaf", c:ellipse(12, 50, 2, 1.5), "moss", { flat = true } },
  { "root", body, GV.ramp("#f08a24"), { gloss = {22, 38}, light = body:copy():add(knobs) } },
}
c:part(c:ellipse(24, 31, 4.5, 4), GV.ramp("#e0501f"), { gloss = {22, 29} })
c:part(c:ellipse(33, 25.5, 5, 4.5), GV.ramp("#e0501f"), { gloss = {31, 23} })
c:part(c:ellipse(42, 20.5, 4.5, 4), GV.ramp("#e0501f"), { gloss = {40, 18} })
-- fibre line (shade curve)
c:paint({ "..........ssss", "......ssss....", "...sss........", ".ss...........", "s............." }, 20, 33, { s = "#b8452f" })
c:paint({ "sss....", "...ssss" }, 34, 29, { s = "#b8452f" })
-- fibre hairs at the right end
c:paint({ "h.h", ".h.", "h.h" }, 50, 25, { h = "#d0862a" })
c:paint({ "h.", ".h" }, 48, 31, { h = "#d0862a" })
local t = c:save(O .. "aseprite/ph/kava.aseprite", O .. "png/ph/kava.png")
print(GV.report(t))
