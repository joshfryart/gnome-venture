-- ph/tallow-wax : a squat puck of pale grub tallow with drips over the lip and a faint gold glow
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- same pale tallow ramps as creature-tallow-grub (soil cream family)
local sideR = GV.ramp("#efe3b8", { shade = "#d8bd84", deep = "#b98b55", bounce = "#e3c79a" })
local topR  = GV.ramp("#fff7da", { shade = "#efdcaa", deep = "#d8bd84", bounce = "#f2e2b4" })

-- puck: top ellipse, straight sides, rounded bottom ellipse; a lumpy slump on the right
local side = c:ellipse(31.5, 26, 21, 8)
side:add(c:rect(11, 26, 52, 41))
side:add(c:ellipse(31.5, 41, 21, 8))
side:add(c:ellipse(47, 40, 7, 7))
-- top face with three drips running over the front lip
local top = c:ellipse(31.5, 26, 18.5, 6)
top:add(c:rrect(16, 28, 20, 39, 2))
top:add(c:rrect(33, 29, 37, 45, 2))
top:add(c:rrect(44, 28, 47, 35, 2))
top:add(c:ellipse(18, 38, 2.5, 2.5))
top:add(c:ellipse(35, 44, 2.5, 2.5))

local p = c:build{
  { "side", side, sideR, { stitch = false } },
  { "top",  top, topR, { light = side, gloss = { 21, 23 } } },
}
-- faint glow: a little gold melt pool in the top centre (like the grub's gold bump)
local pool = c:ellipse(31.5, 25.5, 6, 2.5)
c:part(pool, "gold", { gloss = false, cres = 1, deep = 1, contact = false })
c:px(28, 24, GV.R.gold.gloss); c:px(29, 24, GV.R.gold.gloss)
-- lavender underside line, echoing the grub's belly line
local bl = c:line({ {14, 45}, {22, 47}, {30, 48} }, 1); bl:clip(p.side.m:shrink(1))
c:fill(bl, "#8f7fc9")
-- tiny ridges on the side, like the grub's segment grooves
for _, x in ipairs({ 25, 41 }) do
  local g = c:line({ {x, 34}, {x, 43} }, 1); g:clip(p.side.m:shrink(2)); g:cut(p.top.m:grow(1))
  c:fill(g, sideR.shade)
end

c:ground(31.5, 50, 19, 1.5)
local t = c:save(D .. "final/aseprite/ph/tallow-wax.aseprite", PNG .. "tallow-wax.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
