local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- tail: tapering curl from body down to the lower left
local tail = c:line({ {20, 40}, {15, 42}, {12, 46} }, 5)
tail:add(c:line({ {12, 46}, {12, 50} }, 4))
tail:add(c:line({ {12, 50}, {15, 52} }, 3))
local body = c:ellipse(30, 40, 13, 7.5)
local belly = c:ellipse(30, 45, 9, 3):clip(body:copy())
local legs = c:ellipse(21.5, 47, 3.5, 3):add(c:ellipse(37.5, 47, 3.5, 3))
local head = c:ellipse(42.5, 34, 7.5, 7)
head:add(c:ellipse(47, 37, 5, 4))

c:build{
  { "tail", tail, "gold" },
  { "legs", legs, GV.ramp("#b8661a") },
  { "body", body, "gold" },
  { "belly", belly, GV.ramp("#f5cf6a"), { flat = true } },
  { "head", head, "gold" },
}
local sp = "#b07a10"
c:spot(c:ellipse(22, 37, 2, 1.5), sp)
c:spot(c:ellipse(29, 35, 2, 1.5), sp)
c:spot(c:ellipse(35, 39, 1.5, 1), sp)
c:spot(c:ellipse(26, 41, 1.5, 1), sp)
c:eye(43, 31, true)
c:paint({ "u...", ".uuu" }, 46, 39, { u = "#4a2c1a" })
local t = c:save(O .. "aseprite/ico/ico-lizard.aseprite", O .. "png/ico/ico-lizard.png")
print(GV.report(t))
