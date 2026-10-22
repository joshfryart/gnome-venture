-- flowers/basket : woven wicker basket with arched handle (scene, 100x75 grid written at 2x)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 100, h = 75, mode = "scene", out = 2, ol = 1, olx = 1 }

-- ground shadow
c:fill(c:ellipse(50, 71, 32, 3), "#3d2a1c")

-- dark open top
c:part(c:ellipse(50, 24, 31, 5), GV.ramp("#5e2f1e"), { gloss = false, bounce = false, cres = 0, deep = 0 })

-- arched handle: 4 px ring, top half
local top = c:rect(0, 0, 99, 27)
local handle = c:ellipse(50, 28, 28, 23):cut(c:ellipse(50, 28, 24, 19)):clip(top)
c:part(handle, GV.ramp("#8a4f2a"), { flat = true, rim = false })
c:fill(c:ellipse(50, 28, 27, 22):cut(c:ellipse(50, 28, 25, 20)):clip(top), "#d9a660")
-- small lit tick on the handle crest
c:fill(c:rect(36, 7, 41, 7), "#ecc58a")

-- basket body
local body = c:poly({ {20, 28}, {81, 28}, {68, 63}, {62, 71}, {39, 71}, {33, 63} })
local wood = GV.ramp("#d9a660")
c:part(body, wood, { gloss = false })

-- staves (converging to the bottom)
for i = 0, 12 do
  local xt = 22 + i * 4.7
  local xb = 37 + i * 2.2
  c:fill(c:line({ {math.floor(xt + 0.5), 29}, {math.floor(xb + 0.5), 69} }, 1):clip(body:shrink(1)), "#b07a45")
end
-- highlight stroke
c:fill(c:line({ {30, 34}, {33, 64} }, 2):clip(body:shrink(1)), "#ecc58a")
-- lower shade band
c:fill(c:rect(0, 65, 99, 74):clip(body:shrink(1)), "#8a4f2a")
-- weave rows, gently curved
for _, y in ipairs({ 33, 39, 45, 51, 58, 64 }) do
  local col = y >= 64 and "#5e2f1e" or "#8a4f2a"
  c:fill(c:line({ {15, y}, {35, y + 1}, {65, y + 1}, {85, y} }, 1):clip(body:shrink(1)), col)
end

-- top rim bar with lit strip, thread-gold seam
c:part(c:rrect(19, 26, 81, 29, 1), GV.ramp("#8a4f2a", { rim = "#ecc58a" }), { gloss = false, cres = 2, deep = 1 })
c:seam({ {21, 28}, {79, 28} })

local t = c:save(O .. "aseprite/flowers/basket.aseprite", O .. "png/flowers/basket.png")
print(GV.report(t))
