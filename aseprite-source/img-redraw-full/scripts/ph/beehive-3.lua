local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local plinth = GV.ramp("#c4925f")
local red = GV.ramp("#d6322b")
local bee = GV.ramp("#f08a24")

-- flag behind the hive on the right
c:part(c:rect(46, 24, 47, 40), "wood", { flat = true })
c:part(c:poly({ { 48, 24 }, { 56, 27 }, { 48, 30 } }), red, { flat = true })

local hive = c:rrect(15, 38, 48, 49, 5)
local p = c:build{
  { "feet",   c:rect(18, 53, 22, 56):add(c:rect(41, 53, 45, 56)), "wood", { flat = true } },
  { "plinth", c:rrect(13, 48, 50, 54, 2), plinth },
  { "dome",   c:ellipse(31.5, 18, 7.5, 6), "gold", { light = hive } },
  { "knob",   c:rrect(30, 9, 33, 13, 1), GV.ramp("#b07a10"), { flat = true } },
  { "tier3",  c:rrect(22, 20, 41, 29, 4), "gold" },
  { "tier2",  c:rrect(18, 28, 45, 39, 5), "gold" },
  { "tier1",  hive, "gold" },
}
-- straw ring grooves
c:fill(c:line({ { 19, 44 }, { 44, 44 } }, 1):clip(p.tier1.m), "#b8661a")
c:fill(c:line({ { 22, 34 }, { 41, 34 } }, 1):clip(p.tier2.m), "#b8661a")
c:fill(c:line({ { 25, 25 }, { 38, 25 } }, 1):clip(p.tier3.m), "#b8661a")
-- entrance arch
c:fill(c:rrect(28, 44, 35, 49, 3):add(c:rect(28, 47, 35, 49)), "#44281c")
-- bees
for _, b in ipairs({ { 11, 30 }, { 53, 40 } }) do
  c:part(c:ellipse(b[1], b[2], 2, 2), bee, { flat = true })
  c:px(b[1], b[2], "#2a1a10")
  c:px(b[1] - 1, b[2] - 3, "#f2e4c0"); c:px(b[1] + 1, b[2] - 3, "#f2e4c0")
end
-- sparkle
c:paint({ ".s.", "sss", ".s." }, 42, 12, { s = "#f5cf6a" })

c:seam({ { 15, 53 }, { 48, 53 } })
c:button(18, 31)
c:ground(31.5, 57, 20, 1.5)

local t = c:save(O .. "aseprite/ph/beehive-3.aseprite", O .. "png/ph/beehive-3.png")
print(GV.report(t))
