local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wide squat tin: lid hinged at the back (top), domed slightly
local box = c:rrect(9, 31, 54, 53, 3)
local lid = c:rrect(8, 19, 55, 31, 4)
local lip = c:rect(8, 28, 55, 31):clip(lid)
local plate = c:rrect(17, 35, 46, 50, 3)
local latch = c:rrect(28, 28, 35, 37, 1)

local p = c:build{
  { "box", box, "#8b8f96" },
  { "lid", lid, "#c9c5bc", { light = c:rrect(8, 19, 55, 53, 4) } },
}
c:fill(lip, "#8b8f96")
c:fill(c:rect(10, 31, 53, 31), GV.R.stone.deep or "#3e4450")
-- hinge knobs on the back corners of the lid top
c:part(c:rrect(14, 16, 19, 20, 1), "#5b6470", { flat = true })
c:part(c:rrect(44, 16, 49, 20, 1), "#5b6470", { flat = true })
c:part(plate, "#5b6470", { gloss = false })
c:part(latch, "gold", { flat = true })
c:px(31, 33, "#8a4a1c"); c:px(32, 33, "#8a4a1c")

-- wheat ear on the plate
local stalkC = "#2e5a2c"
c:fill(c:rect(31, 41, 32, 49), stalkC)
local g, gs, gl = "#e8a317", "#b07a10", "#f5cf6a"
local function grain(x, y)
  c:fill(c:rrect(x, y, x + 3, y + 4, 1), g)
  c:px(x, y + 1, gl); c:px(x + 1, y, gl)
  c:px(x + 3, y + 3, gs); c:px(x + 2, y + 4, gs)
end
grain(30, 37)          -- top grain, centred
grain(27, 40); grain(33, 40)
grain(27, 44); grain(33, 44)

-- rivets
for _, r in ipairs({ {12, 34}, {50, 34}, {12, 49}, {50, 49} }) do
  c:px(r[1], r[2], "#f2efe8"); c:px(r[1] + 1, r[2], "#c9c5bc")
  c:px(r[1], r[2] + 1, "#c9c5bc"); c:px(r[1] + 1, r[2] + 1, "#5b6470")
end

c:ground(31.5, 55, 21, 1.5)
local t = c:save(O .. "aseprite/ph/tritordeum-seed.aseprite", O .. "png/ph/tritordeum-seed.png")
print(GV.report(t))
