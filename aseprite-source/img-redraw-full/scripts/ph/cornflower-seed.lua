local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local env = c:rect(20, 10, 43, 53)
local flap = c:poly({ {20, 10}, {44, 10}, {32, 29} })
local seal = c:ellipse(31.5, 28.5, 3.5, 3.5)
local petals = c:mask()
for i = 0, 5 do
  local a = math.rad(i * 60 - 90)
  petals:add(c:ellipse(32 + 5.5 * math.cos(a), 41 + 5.5 * math.sin(a), 2.5, 2.5))
end
local centre = c:ellipse(32, 41, 2.5, 2.5)
petals:add(centre:grow(1))

c:build{
  { "env",    env,    GV.ramp("#f1ece0") },
  { "flap",   flap,   GV.ramp("#e6d9b8"), { gloss = false } },
  { "seal",   seal,   GV.ramp("#d0862a"), { gloss = false } },
  { "petals", petals, GV.ramp("#5a86b8") },
  { "centre", centre, GV.ramp("#f5cf6a"), { flat = true } },
}
-- stem and leaf (flat accents)
c:part(c:line({ {32, 47}, {32, 51} }, 2), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:poly({ {34, 51}, {38, 46}, {39, 47}, {36, 51} }), GV.ramp("#58a03e"), { flat = true })
c:seam({ {21, 11}, {30, 25} })
c:seam({ {42, 11}, {34, 25} })
c:button(30, 27)

local t = c:save(O .. "aseprite/ph/cornflower-seed.aseprite", O .. "png/ph/cornflower-seed.png")
print(GV.report(t))
