local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local CR, UM = "#f4f0e0", "#4a2c1a"

-- seal disc (radius limited so the icon halo keeps 3 px from the frame)
local disc = c:ellipse(31.5, 31.5, 19.5)
c:part(disc, "#a8582f", { gloss = { 18, 17 } })

-- dotted outer ring: 2 on / 2 off
local pts = {}
for i = 0, 96 do
  local a = i / 96 * 2 * math.pi
  pts[#pts + 1] = { 31.5 + 17 * math.cos(a), 31.5 + 17 * math.sin(a) }
end
c:seam(pts, { on = 2, off = 2 })

-- solid cream inner ring
local ring = c:ellipse(31.5, 31.5, 15.5):cut(c:ellipse(31.5, 31.5, 13.5))
c:part(ring, CR, { flat = true, rim = false, contour = false, contact = false })

-- gate
local gate = c:mask()
for x = 22, 41 do
  local top = (x <= 23 or x >= 40) and 22 or 23
  local bot = (x >= 28 and x <= 35) and 27 or 26
  gate:add(c:rect(x, top, x, bot))
end
gate:add(c:rect(30, 27, 33, 29))          -- centre strut
gate:add(c:rect(23, 29, 40, 31))          -- crossbar
gate:add(c:rect(25, 27, 27, 40))          -- posts
gate:add(c:rect(36, 27, 38, 40))
c:fill(gate:grow(1), UM)
c:part(gate, CR, { cres = 1, deep = 0, gloss = false, bounce = false, rim = false, contour = false, contact = false })

local t = c:save(O .. "aseprite/stops/stamp-shrine.aseprite", O .. "png/stops/stamp-shrine.png")
print(GV.report(t))
