local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local handle = c:ellipse(31.5, 27, 13, 15):cut(c:ellipse(31.5, 27, 9, 11)):cut(c:rect(0, 26, 63, 63))
local body = c:rrect(12, 25, 51, 51, 7)
local flap = c:rrect(12, 25, 51, 39, 7)
local clasp = c:rrect(27, 33, 36, 42, 1)
local p = c:build{
  { "handle", handle, GV.ramp("#b6814d", { rim = "#f0d49a", gloss = "#f0d49a" }), { gloss = false } },
  { "body", body, GV.ramp("#a5663a") },
  { "flap", flap, GV.ramp("#8c4a1a"), { light = body } },
  { "clasp", clasp, "gold", { gloss = false } },
}
-- edge stitch on the body below the flap
local ring = p.body.m:shrink(2):edge()
ring:each(function(x, y)
  if y > 41 and (x + y) % 3 == 0 then c:px(x, y, "#f5cf6a") end
end)
-- flap seam, skipping the clasp
c:seam({ {16, 37}, {25, 37} }); c:seam({ {38, 37}, {47, 37} })
-- clasp hole
c:fill(c:rect(30, 36, 33, 39), "#b07a10")
c:px(30, 36, "#7a3a14"); c:px(28, 34, "#fff1c8"); c:px(29, 34, "#fff1c8")

local t = c:save(O .. "aseprite/ph/nav-satchel.aseprite", O .. "png/ph/nav-satchel.png")
print(GV.report(t))
