local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local Y = -2
local function P(t) local r = {} for i, q in ipairs(t) do r[i] = { q[1], q[2] + Y } end return r end
local dome = c:ellipse(32, 47 + Y, 22, 24):cut(c:rect(-10, 49 + Y, 80, 99))
dome:add(c:rrect(10, 40 + Y, 54, 49 + Y, 5))
local crust = c:line(P{ {9,42},{14,37},{20,33},{26,31},{32,30},{38,31},{44,33},{50,37},{55,42} }, 6):clip(dome)
local crumbs = c:ellipse(46.5, 50.5 + Y, 2.5, 2):add(c:ellipse(52.5, 46 + Y, 2, 2)):add(c:ellipse(41, 52 + Y, 1.5, 1.5))
local p = c:build{
  { "dome",  dome,  "petal", { stitch = true, light = dome } },
  { "crust", crust, GV.ramp("#f0d49a"), { light = dome, gloss = false } },
  { "crumbs", crumbs, GV.ramp("#c9a96e"), { flat = true } },
}
c:fill(c:line(P{ {14,40},{20,36},{26,34},{32,33},{38,34},{44,36},{50,40} }, 1):clip(crust:shrink(1)), "#c66b50")
c:seam(P{ {12,41},{17,36},{23,32},{29,30},{35,30},{41,31},{47,34},{52,39} })
for _, d in ipairs{ {21,41},{34,43},{26,22},{39,24} } do
  c:fill(c:rect(d[1], d[2] + Y, d[1] + 1, d[2] + 1 + Y), "#ae2a2a")
end
c:ground(32, 50 + Y, 20, 1.5)
local t = c:save(O .. "aseprite/ph/forager-s-crumb.aseprite", O .. "png/ph/forager-s-crumb.png")
print(GV.report(t))
