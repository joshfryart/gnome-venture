local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wide low soil mound, flat-ish bottom
local mound = c:ellipse(31.5, 49, 21, 8):cut(c:rect(0, 55, 63, 63))
mound:add(c:rrect(14, 50, 49, 55, 3))
local top = c:ellipse(31.5, 47, 16, 4)

-- three blades: left leans out, centre straight, right leans out
local function blade(pts)
  local m = c:line(pts, 2)
  return m
end
local bl = c:poly({ {19, 49}, {25, 49}, {24, 41}, {19, 29}, {17, 29}, {20, 41} })
local bc = c:poly({ {29, 49}, {35, 49}, {34, 38}, {32, 26}, {31, 26}, {29, 38} })
local br = c:poly({ {38, 49}, {44, 49}, {43, 41}, {46, 29}, {44, 29}, {39, 41} })
local blades = bl:copy():add(bc):add(br)

local soilR = GV.ramp("#8c4a1a")
local topR = GV.ramp("#a5663a")
local leafR = GV.ramp("#6cbd48", { rim = "#a4b86a" })

local p = c:build{
  { "mound", mound, soilR, { gloss = { 16, 46 } } },
  { "top", top, topR, { gloss = false, bounce = false, contact = false } },
  { "blades", blades, leafR, { flat = true } },
}
-- lit left edge on blades
for _, b in ipairs({ bl, bc, br }) do
  local x0, y0, x1, y1 = b:bbox()
end
blades:each(function(x, y) if not blades:has(x - 1, y) then c:px(x, y, "#a4b86a") end end)
blades:each(function(x, y) if not blades:has(x + 1, y) and blades:has(x - 1, y) and y > 38 then c:px(x, y, leafR.shade) end end)
-- soil specks
c:px(25, 52, "#5e2f1e"); c:px(38, 53, "#5e2f1e"); c:px(44, 50, "#5e2f1e")
local t = c:save(O .. "aseprite/ph/stage-grain-2.aseprite", O .. "png/ph/stage-grain-2.png")
print(GV.report(t))
