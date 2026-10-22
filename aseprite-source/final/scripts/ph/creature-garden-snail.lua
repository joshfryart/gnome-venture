local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
-- foot: long flat slug body, tapering tail to the left, rising into the head on the right
local foot = c:ellipse(31.5, 52, 19, 4.5)
foot:add(c:poly({ {10, 53}, {20, 48}, {20, 56}, {12, 55} }))
local head = c:ellipse(47, 46, 5.5, 6)
local stalks = c:line({ {47, 42}, {50, 34} }, 2):add(c:line({ {44, 42}, {41, 34} }, 2))
local knobs = c:ellipse(50.5, 33.5, 2.5, 2.5):add(c:ellipse(40.5, 33.5, 2.5, 2.5))
local shell = c:ellipse(28, 39, 12.5, 12)
local p = c:build{
  { "stalks", stalks, tan, { flat = true } },
  { "knobs", knobs, tan, { flat = true } },
  { "foot", foot, tan, { stitch = { side = "lit" } } },
  { "head", head, tan },
  { "shell", shell, "wood" },
}
-- spiral: about 1.75 turns from the centre outwards
local pts, cx, cy = {}, 28.5, 39.5
local turns = 1.75
for i = 0, 70 do
  local t = i / 70
  local a = -math.pi / 2 + t * turns * 2 * math.pi
  local r = 1.5 + t * 8
  pts[#pts + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy + r * math.sin(a) + 0.5) }
end
c:fill(c:line(pts, 2):clip(shell:shrink(1)), "#4a2c1a")
c:gloss(shell, GV.R.wood, { 20, 31 })
-- face
c:eye(39, 32, true); c:eye(49, 32, true)
c:px(50, 46, tan.shade)
c:paint({ "d...d", ".ddd." }, 46, 48, { d = "#2a1a10" })
c:ground(32, 57, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-garden-snail.aseprite", O .. "png/ph/creature-garden-snail.png")
print(GV.report(t))
