local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local body = c:poly({ {14,11},{51,11},{51,30},{49,37},{45,44},{39,49},{32,54},{25,49},{19,44},{15,37},{14,30} })
local inner = body:shrink(4)
local left = inner:copy():clip(c:rect(0, 0, 31, 63))
local right = inner:copy():clip(c:rect(32, 0, 63, 63))
c:build{
  { "rim",   body, "stone" },
  { "left",  left, GV.ramp("#a5663a") },
  { "right", right, GV.ramp("#8c4a1a"), { gloss = false } },
  { "boss",  c:ellipse(32, 29, 6), GV.ramp("#6a6070"), { gloss = false } },
}
c:seam({ {32, 16}, {32, 22} })
c:seam({ {32, 37}, {32, 48} })
c:px(30, 26, "#c9c5bc"); c:px(29, 27, "#c9c5bc")
local t = c:save(O .. "aseprite/ico/ico-shield.aseprite", O .. "png/ico/ico-shield.png")
print(GV.report(t))
