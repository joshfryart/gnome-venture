local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 100, h = 100, mode = "scene", out = 2 }
-- drawing grid is 100x100
local W, H = 100, 100

local function wavy(ytop, amp, per, phase, ybot)
  local m = c:mask()
  for x = 0, W - 1 do
    local y0 = math.floor(ytop + amp * math.sin((x + phase) * 2 * math.pi / per) + 0.5)
    for y = y0, ybot do m:set(x, y) end
  end
  return m
end

-- 1. sky bands
c:bands(nil, { "#cfe6b8", "#c3dfaa", "#b6d8a0", "#aad196", "#9fcb8c" }, { dir = "v" })
-- 2. warm glow, upper left
c:bands(c:ellipse(25, 30, 36), { "#dcecc0", "#eaf2c8" }, { dir = "radial", cx = 25, cy = 30, r = 36 })
-- 3. distant hills
local hills = c:poly({ { -2, 80 }, { 9, 20 }, { 21, 80 } })
hills:add(c:poly({ { 30, 80 }, { 41, 32 }, { 53, 80 } }))
hills:add(c:poly({ { 74, 80 }, { 88, 16 }, { 102, 80 } }))
hills:add(c:poly({ { 14, 80 }, { 25, 44 }, { 36, 80 } }))
c:fill(hills, "#6f9a5c")
c:fill(c:poly({ { 41, 32 }, { 53, 80 }, { 47, 80 } }), "#5f8a50")
c:fill(c:poly({ { 88, 16 }, { 102, 80 }, { 96, 80 } }), "#5f8a50")

-- 6. top branch band (behind canopies)
local band = wavy(11, 1.5, 22, 0, 13):add(c:rect(0, 0, W - 1, 10))
band:cut(wavy(4, 1.2, 17, 5, 30):cut(c:rect(0, 6, W - 1, 99)))
c:part(band, GV.ramp("#6e4a2b", { rim = "#8c6238" }), { gloss = false })

-- 4. trunks
local trunks = c:rrect(5, 14, 12, 82, 2):add(c:rrect(85, 10, 92, 82, 2))
c:part(trunks, GV.ramp("#5a3f28"), { gloss = false })

-- 5. canopies (lumpy leaf clouds)
local can = c:ellipse(9, 19, 12, 9):add(c:ellipse(3, 26, 7, 6)):add(c:ellipse(16, 25, 7, 5.5)):add(c:ellipse(12, 11, 8, 6))
local can2 = c:ellipse(88.5, 15, 12, 9):add(c:ellipse(96, 23, 7, 6)):add(c:ellipse(81, 22, 7, 5.5)):add(c:ellipse(86, 7, 8, 6))
c:part(can, "moss", { gloss = { 5, 13 } })
c:part(can2, "moss", { gloss = { 82, 9 } })

-- 7. ground layers
local g1 = wavy(76, 1.2, 30, 0, H - 1)
c:part(g1, GV.ramp("#7fa85a"), { gloss = false, bounce = false })
local g2 = wavy(85, 1.0, 26, 9, H - 1)
c:part(g2, GV.ramp("#4f7338"), { gloss = false, bounce = false })
-- grass tufts
local tuft = { "g.g.g", ".ggg." }
c:paint(tuft, 8, 77, { g = "#a8cf72" })
c:paint(tuft, 46, 75, { g = "#a8cf72" })
c:paint(tuft, 83, 77, { g = "#a8cf72" })

-- 8. stump: shadow, side, top, rings
c:fill(c:ellipse(51, 94, 22, 3), "#3e5e2c")
local side = c:rect(31, 89, 69, 94):add(c:ellipse(50, 94, 19, 3.5))
c:part(side, GV.ramp("#8c6238"), { gloss = false })
local top = c:ellipse(50, 88, 19, 6)
c:part(top, GV.ramp("#d6aa6a"), { gloss = { 39, 85 }, cres = 1, deep = 0 })
-- growth rings
local function ring(rx, ry)
  local e = c:ellipse(50, 88, rx, ry)
  e:cut(e:shrink(1))
  c:fill(e, "#b58348")
end
ring(14, 4)
ring(8, 2)
c:fill(c:rect(49, 88, 50, 88), "#b58348")
-- bark ridges on the side
for _, x in ipairs({ 36, 43, 57, 64 }) do c:fill(c:rect(x, 91, x, 94), "#6e4a2b") end

-- pollen dots
c:px(20, 50, "#e4c274"); c:px(75, 43, "#e4c274"); c:px(55, 60, "#e4c274")

local t = c:save(D .. "img-redraw-full/aseprite/gather/axe-bg.aseprite", D .. "img-redraw-full/png/gather/axe-bg.png")
print(GV.report(t))
