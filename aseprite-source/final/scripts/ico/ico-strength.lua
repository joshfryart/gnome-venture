local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local skin = GV.ramp("#e9b98a", { gloss = "#ffe2a8", shade = "#c47a52" })
local cuffR = GV.ramp("#b07a45", { shade = "#8a4f2a" })

local arm = c:rrect(13, 20, 26, 47, 6)
arm:add(c:rrect(13, 35, 46, 47, 6))
local bicep = c:ellipse(34.5, 36, 10.5, 8.5)
local fist = c:ellipse(19.5, 18, 8, 6.5)
local cuff = c:rrect(43, 32, 51, 51, 2)

c:build{
  { "arm", arm, skin, { light = arm:copy():add(bicep) } },
  { "bicep", bicep, skin },
  { "fist", fist, skin },
  { "cuff", cuff, cuffR },
}

-- finger creases on the fist
for _, y in ipairs({ 15, 19 }) do
  for x = 23, 27 do if fist:has(x, y) then c:px(x, y, "#c47a52") end end
end


c:seam({ {47, 34}, {47, 50} })

local t = c:save(O .. "aseprite/ico/ico-strength.aseprite", O .. "png/ico/ico-strength.png")
print(GV.report(t))
