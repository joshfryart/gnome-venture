local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local gold = GV.ramp("gold", { gloss = "#fff1c8" })
local lp = c:ellipse(18, 38, 7.5, 8):clip(c:rect(0, 39, 63, 63))
local rp = c:ellipse(46, 37, 7.5, 8):clip(c:rect(0, 38, 63, 63))
local gem = c:poly({ {46, 28}, {50, 33}, {46, 39}, {42, 33} })
local chains = c:line({ {12, 38}, {17, 22}, {23, 38} }, 2):add(c:line({ {41, 37}, {46, 22}, {51, 37} }, 2))
local p = c:build{
  { "post", c:rect(30, 14, 33, 54), "wood" },
  { "base", c:rrect(19, 52, 45, 57, 2), "wood" },
  { "chains", chains, "wood", { flat = true } },
  { "beam", c:rrect(13, 20, 50, 24, 2), "wood" },
  { "finial", c:ellipse(32, 12, 5), gold },
  { "coin", c:ellipse(18, 35, 3.5), GV.ramp("#f5cf6a") },
  { "gem", gem, "moss" },
  { "lpan", lp, gold, { light = lp } },
  { "rpan", rp, gold, { light = rp } },
}
c:seam({ {12, 40}, {24, 40} }); c:seam({ {40, 39}, {52, 39} })
c:button(30, 20)
local t = c:save(O .. "aseprite/ph/nav-trading.aseprite", O .. "png/ph/nav-trading.png")
print(GV.report(t))
