-- ph/tallow-wax : a squat stub of pale grub tallow in its puddle, drips over the lip, a faint gold glow on top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- same pale tallow ramps as creature-tallow-grub (soil cream family)
local sideR = GV.ramp("#efe3b8", { shade = "#d8bd84", deep = "#b98b55", bounce = "#e3c79a", dot = "#fff3c8" })
local topR  = GV.ramp("#fff7da", { shade = "#efdcaa", deep = "#d8bd84", bounce = "#f2e2b4", dot = "#fff3c8" })

-- a squat stub of tallow standing in its own puddle, drips running over the lip
local pud  = c:ellipse(31.5, 49, 20, 5)
local stub = c:rect(19, 21, 44, 47)
stub:add(c:ellipse(31.5, 21, 12.5, 5))
stub:add(c:ellipse(31.5, 47, 12.5, 3.5))
-- melted top face with three drips over the lip (one breaks the left silhouette)
local top = c:ellipse(31.5, 21, 11, 4)
top:add(c:rrect(17, 21, 21, 34, 2)); top:add(c:ellipse(19, 34, 2.5, 2.5))
top:add(c:rrect(29, 23, 33, 39, 2)); top:add(c:ellipse(31, 39, 2.5, 2.5))
top:add(c:rrect(39, 22, 42, 29, 1)); top:add(c:ellipse(40.5, 29, 2, 2))

local p = c:build{
  { "pud",  pud,  sideR, { stitch = false } },
  { "stub", stub, sideR, { gloss = false, cres = 6, deep = 2 } },
  { "top",  top,  topR,  { light = stub, gloss = { 22, 20 } } },
}
-- soft crater in the melted top with a faint gold glow pooled in it
c:fill(c:ellipse(31.5, 21, 6.5, 1.5), topR.shade)
c:fill(c:ellipse(31.5, 21.5, 4.5, 1), "#f5cf6a"); c:fill(c:rect(30, 21, 33, 21), "#ffe08a")
c:px(29, 21, "#fff1c8")
-- lavender line along the puddle lip, echoing the grub's belly line
local bl = c:line({ {14, 51}, {22, 53}, {31, 53} }, 1); bl:clip(p.pud.m:shrink(1))
c:fill(bl, "#8f7fc9")

local t = c:save(D .. "final/aseprite/ph/tallow-wax.aseprite", PNG .. "tallow-wax.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
