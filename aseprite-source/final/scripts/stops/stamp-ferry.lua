local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 31.5
local INK, INK2, TINT, SAIL = "#2f6290", "#3f8fb0", "#c8ecdc", "#8fcbd8"

local disc = c:ellipse(cx, cy, 21.5)
c:part(disc, "cream", { gloss = false })

local function ring(r0, r1) return c:ellipse(cx, cy, r1):cut(c:ellipse(cx, cy, r0)) end
-- outer dotted ring (2x2 dots)
local n = 30
for i = 0, n - 1 do
  local a = i / n * 2 * math.pi
  local x = math.floor(cx + 19.6 * math.cos(a))
  local y = math.floor(cy + 19.6 * math.sin(a))
  c:fill(c:rect(x, y, x + 1, y + 1), INK)
end
-- main ring 3px, inner ring 1px
c:fill(ring(14.6, 17.6), INK)
c:fill(ring(12.4, 13.4), INK2)

-- sails
local main = c:poly({ {33, 20}, {41, 34}, {33, 34} })
c:fill(main, SAIL); c:fill(main:edge(), INK)
local jib = c:poly({ {30, 23}, {30, 34}, {24, 34} })
c:fill(jib:edge(), INK)
-- mast
c:fill(c:rect(30, 19, 32, 34), INK)
-- hull
local hull = c:poly({ {21, 34}, {43, 34}, {38, 40}, {26, 40} })
c:fill(hull, INK); c:fill(hull:shrink(1), TINT)
-- waves (2px wavy line)
local pts = {}
for x = 23, 40 do pts[#pts + 1] = { x, 41 + math.floor(1 + 1.2 * math.sin((x - 23) / 3 * math.pi)) } end
c:fill(c:line(pts, 2), INK2)

local t = c:save(O .. "aseprite/stops/stamp-ferry.aseprite", O .. "png/stops/stamp-ferry.png")
print(GV.report(t))
