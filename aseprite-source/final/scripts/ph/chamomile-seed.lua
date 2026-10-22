local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(15, 12, 49, 54, 2)
local flap = c:poly({ {15,12}, {50,12}, {32.5,33} })
local p = c:build{
  { "body", body, GV.ramp("#f1ece0"), { stitch = true, gloss = false } },
  { "flap", flap, GV.ramp("#e6c88a"), { light = body } },
}
-- flower: petals around centre
local petals = c:mask()
for i = 0, 5 do
  local a = math.rad(i * 60 - 90)
  petals:add(c:ellipse(32 + 6 * math.cos(a), 43 + 6 * math.sin(a), 2.5, 2.5))
end
c:part(petals, GV.ramp("#fbf6ea"), { flat = true, contour = "#c9a05a" })

c:part(c:ellipse(32, 43, 3, 3), "gold", { gloss = { 31, 42 } })
-- seeds
for _, s in ipairs({ {19,49}, {24,50}, {40,49}, {44,50} }) do
  c:part(c:ellipse(s[1] + 0.5, s[2] + 0.5, 1.5, 1), GV.ramp("#a8702f"), { flat = true })
end
c:button(31, 29)
local t = c:save(O .. "aseprite/ph/chamomile-seed.aseprite", O .. "png/ph/chamomile-seed.png")
print(GV.report(t))
