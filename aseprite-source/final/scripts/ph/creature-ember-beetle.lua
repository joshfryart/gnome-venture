local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- legs (mirrored about x=31.5)
local legs = { {{23,36},{17,33},{11,32}}, {{23,41},{16,41},{11,44}}, {{23,47},{17,50},{12,52}} }
for _, L in ipairs(legs) do
  c:limb(L)
  local R = {}
  for i, p in ipairs(L) do R[i] = { 63 - p[1], p[2] } end
  c:limb(R)
end
-- antennae with 4x4 clubs
c:limb({ {29,20},{25,15},{22,13} })
c:limb({ {34,20},{38,15},{41,13} })
c:part(c:rrect(19, 10, 22, 13, 1), "dusk", { flat = true })
c:part(c:rrect(41, 10, 44, 13, 1), "dusk", { flat = true })
local p = c:build{
  { "shell", c:ellipse(31.5, 42, 13.5, 14), GV.ramp("#e0501f") },
}
-- centre seam
c:fill(c:rect(31, 29, 32, 55):clip(p.shell.m:shrink(1)), "#2a1a10")
-- glow stripe
c:fill(c:ellipse(31.5, 45, 4.5, 7), "#f5cf6a")
c:fill(c:ellipse(31.5, 43, 2, 3.5), "#f8eed2")
-- head
c:part(c:ellipse(31.5, 25, 7, 6.5), GV.ramp("#9c2a1e"))
-- eyes: dark ring, cream 3x3, 2x2 pupil
for _, ex in ipairs({ 27, 34 }) do
  c:paint({ ".kkk.", "kkkkk", "kkkkk", "kkkkk", ".kkk." }, ex - 1, 22, { k = "#2a1a10" })
  c:eye(ex, 23, true)
end
local t = c:save(O .. "aseprite/ph/creature-ember-beetle.aseprite", O .. "png/ph/creature-ember-beetle.png")
print(GV.report(t))
