-- Jeff snail (Snail Trail host, coming soon): a snail with an amber spiral shell at his feet, Jeff looking at it. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -7, 0
local body = K.jeffBody(c, dx, dy)
local armL = c:rrect(6, 36, 12, 42, 2); armL:cut(body:grow(1))
local armR = c:rrect(37, 34, 43, 40, 2); armR:add(c:ellipse(43, 37, 2, 3)); armR:cut(body:grow(1))
-- snail facing right: foot, raised head, two stalks, spiral shell on its back
local foot = c:rrect(34, 50, 54, 54, 2)
local head = c:rect(49, 43, 53, 52); head:add(c:ellipse(51.5, 43, 2.5, 2.5))
local stalks = c:line({ {50, 41}, {49, 36} }, 1):add(c:line({ {53, 41}, {55, 36} }, 1))
local shell = c:ellipse(43, 43, 8, 7.5)
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "stalks", stalks, "skin", { flat = true, contact = false } },
  { "foot", foot, "skin", {} },
  { "head", head, "skin", { gloss = false } },
  { "shell", shell, "gold", { gloss = { 38, 38 } } },
}
c:paint({ ".uuuu.", "u....u", "u.uu.u", "u.u..u", "u..u.u", ".uu..u" }, 41, 40, { u = "#7a3a14" })  -- spiral
c:px(48, 35, "#2a1a10"); c:px(55, 35, "#2a1a10")                     -- stalk eyes
c:paint({ "u" }, 52, 46, { u = "umber" })                              -- snail eye
K.jeffFace(c, dx, dy, "custom", { eyes = "right", brows = "raised", mouth = "smile" })
K.save(c, "jeff-snail")
