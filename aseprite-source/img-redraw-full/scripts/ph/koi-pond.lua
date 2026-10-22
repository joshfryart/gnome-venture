local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local rim = c:ellipse(31.5, 44, 21, 9.5)
local water = c:ellipse(31.5, 42.5, 16, 5.5)
local koi = c:ellipse(36, 44, 4, 2):add(c:poly({{39,44},{44,41},{44,48}}))
local reedL = c:line({{26,41},{25,32},{22,22}}, 2)
local reedR = c:line({{30,41},{32,30},{36,19}}, 2)
local tipL = c:rrect(20, 17, 23, 24, 1)
local tipR = c:rrect(35, 14, 38, 21, 1)
c:build{
  { "rim", rim, "stone" },
  { "water", water, "water", { gloss = {19, 40} } },
  { "koi", koi, GV.ramp("#f08a24"), { flat = true } },
  { "reedL", reedL, GV.ramp("#6a9a3a"), { flat = true } },
  { "reedR", reedR, GV.ramp("#7ab55c"), { flat = true } },
  { "tipL", tipL, "wood", { flat = true } },
  { "tipR", tipR, "wood", { flat = true } },
}
c:paint({ "ccc...cc" }, 18, 45, { c = "#c8ecdc" })
c:paint({ "cccc" }, 37, 39, { c = "#c8ecdc" })
c:paint({ "pp" }, 35, 43, { p = "#f1ece0" })
c:px(33, 43, "#2a1a10")
-- stones on rim
for _, s in ipairs({{14,47},{22,51},{32,53},{42,51},{49,47}}) do c:px(s[1], s[2], "#5b6470"); c:px(s[1]+1, s[2], "#5b6470") end
local t = c:save(O .. "aseprite/ph/koi-pond.aseprite", O .. "png/ph/koi-pond.png")
print(GV.report(t))
