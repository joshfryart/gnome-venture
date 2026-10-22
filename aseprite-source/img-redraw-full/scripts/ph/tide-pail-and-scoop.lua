local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- high arc handle (3 px), drawn first so the rim sits over its ends
local arc = c:ellipse(31.5, 29, 16, 18):cut(c:ellipse(31.5, 29, 13, 15)):cut(c:rect(0, 29, 63, 63))
-- scoop: short handle poking out right, spade blade
local scoopHandle = c:rect(42, 41, 50, 43)
local blade = c:rrect(49, 37, 56, 49, 3)
local body = c:poly({ {16, 30}, {48, 30}, {44, 57}, {20, 57} })
local rim = c:rrect(13, 25, 50, 31, 2)

local p = c:build{
  { "handle", arc, GV.ramp("#5b6470"), { flat = true } },
  { "scoopH", scoopHandle, GV.ramp("#5b6470"), { flat = true } },
  { "blade", blade, GV.ramp("#c9c5bc"), { gloss = { 51, 39 } } },
  { "body", body, GV.ramp("#8b8f96", { gloss = "#c9c5bc" }), { gloss = { 20, 34 } } },
  { "rim", rim, GV.ramp("#5b6470"), { gloss = { 16, 27 } } },
}
-- water line across the body
c:fill(c:rect(20, 42, 43, 42), "#8fcbd8")
-- handle rivets on the rim
c:px(15, 28, "#c9c5bc"); c:px(47, 28, "#c9c5bc")

local t = c:save(O .. "aseprite/ph/tide-pail-and-scoop.aseprite", O .. "png/ph/tide-pail-and-scoop.png")
print(GV.report(t))
