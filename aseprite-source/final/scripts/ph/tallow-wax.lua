-- ph/tallow-wax : a soft heap of pale grub tallow in its puddle, glowing faintly from inside
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- same pale tallow ramps as creature-tallow-grub (soil cream family)
local sideR = GV.ramp("#efe3b8", { shade = "#d8bd84", deep = "#b98b55", bounce = "#e3c79a", dot = "#fff3c8" })
local topR  = GV.ramp("#fff7da", { shade = "#efdcaa", deep = "#d8bd84", bounce = "#f2e2b4", dot = "#fff3c8" })

-- a soft heap of tallow slumped into its own puddle, drips running down the sides
local pud = c:ellipse(31.5, 45, 22, 6)
local heap = c:ellipse(31.5, 36, 16, 11)
heap:add(c:ellipse(28, 26, 10.5, 9))
heap:add(c:ellipse(25.5, 18, 4.5, 4))           -- soft curl on top
heap:add(c:rrect(14, 34, 19, 46, 2))            -- drip left
heap:add(c:ellipse(16.5, 46, 3, 2.5))
heap:add(c:rrect(41, 36, 46, 44, 2))            -- drip right
heap:add(c:ellipse(43.5, 44, 3, 2.5))
heap = heap:closed(2)

local p = c:build{
  { "pud",  pud, sideR, { stitch = false } },
  { "heap", heap, topR, { gloss = { 20, 22 } } },
}
-- faint glow seen through the wax: stepped warm rings, like the grub's light
c:fill(c:ellipse(31.5, 35, 6.5, 5.5):clip(p.heap.m:shrink(3)), "#f9e3a0")
c:fill(c:ellipse(31.5, 35, 4, 3.5), "#f5cf6a")
c:fill(c:ellipse(31.5, 35, 2, 1.5), "#e8a317")
c:px(30, 34, "#fff1c8")
-- lavender line under the puddle lip, echoing the grub's belly line
local bl = c:line({ {14, 48}, {22, 50}, {31, 50} }, 1); bl:clip(p.pud.m:shrink(1))
c:fill(bl, "#8f7fc9")


local t = c:save(D .. "final/aseprite/ph/tallow-wax.aseprite", PNG .. "tallow-wax.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
