-- stops/stamp-workshop : round passport stamp, double ring + dotted ring, 8-tooth gear over a bench line
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local CX, CY = 31.5, 31.5
local woodS = "#8a4f2a"
local woodB = "#b07a45"

-- gear: body + 8 teeth (axis 4x3, diagonal 3x3) as one mask
local gear = c:ellipse(CX, CY - 2, 8, 8)
for i = 0, 7 do
  local a = i * math.pi / 4
  local tx, ty = CX + math.cos(a) * 9.5, CY - 2 + math.sin(a) * 9.5
  gear:add(c:ellipse(tx, ty, 2, 2))
end
gear:cut(c:ellipse(CX, CY - 2, 2.5, 2.5))

c:build{
  { "disc",  c:ellipse(CX, CY, 21, 21), "cream", { gloss = { 17, 16 } } },
  { "ring",  c:ellipse(CX, CY, 21, 21):cut(c:ellipse(CX, CY, 18.5, 18.5)), GV.ramp(woodS), { flat = true, contact = false } },
  { "gear",  gear, GV.ramp("#d9a660"), { gloss = { 26, 23 } } },
  { "bench", c:rect(19, 43, 44, 44), GV.ramp(woodS), { flat = true } },
}
-- hub hole
c:fill(c:ellipse(CX, CY - 2, 2.5, 2.5), "#5e2f1e")
-- thin inner ring
c:fill(c:ellipse(CX, CY, 16.5, 16.5):edge():cut(c:rect(18, 42, 45, 45)), woodB)
-- dotted ring between main ring and inner ring acts as the stitch
for i = 0, 23 do
  local a = i * math.pi / 12
  local x, y = math.floor(CX + math.cos(a) * 20 + 0.5), math.floor(CY + math.sin(a) * 20 + 0.5)
  c:px(x, y, "#f5cf6a")
end

local t = c:save(O .. "aseprite/stops/stamp-workshop.aseprite", O .. "png/stops/stamp-workshop.png")
print(GV.report(t))
