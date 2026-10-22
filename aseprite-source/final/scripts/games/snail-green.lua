local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = GV.ramp("#e0c9a0", { shade = "#bca373" })
local stalk = GV.ramp("#c9b083")

-- foot: long low slug with a raised neck/head at the right
local foot = c:rrect(7, 43, 55, 52, 4):add(c:rrect(43, 26, 55, 49, 6))
foot:add(c:poly({ {4, 52}, {9, 46}, {9, 52} }))
local shell = c:ellipse(27, 32, 17, 17)

c:build{
  { "stalkL", c:line({ {47, 30}, {45, 18} }, 2), stalk, { flat = true } },
  { "stalkR", c:line({ {52, 30}, {54, 18} }, 2), stalk, { flat = true } },
  { "clubL",  c:rrect(43, 13, 48, 18, 2), stalk, { gloss = false } },
  { "clubR",  c:rrect(52, 13, 57, 18, 2), stalk, { gloss = false } },
  { "foot",   foot, body, { gloss = { 50, 30 } } },
  { "shell",  shell, "moss", { stitch = { side = "lit" } } },
}

-- spiral winding out from the shell centre
local pts = {}
for i = 0, 40 do
  local th = i / 40 * 2.1 * 2 * math.pi
  local r = 1.5 + 5.6 * th / (2 * math.pi)
  pts[#pts + 1] = { 28 + r * math.cos(th + math.pi), 33 - r * math.sin(th + math.pi) }
end
c:fill(c:line(pts, 2):clip(shell:shrink(2)), "#3d7f35")

-- little red leaf tuft riding on top of the shell
c:part(c:ellipse(30, 15.5, 5, 2.5), "red", { gloss = false })
c:part(c:rrect(22, 14, 25, 17, 1), GV.ramp("#c92f2a"), { flat = true })

-- eyes on the stalk tips, smile
c:eye(44, 14, true); c:eye(53, 14, true)
c:paint({ "u....u", ".uuuu." }, 48, 38, { u = "#7a5a35" })

c:ground(31, 55, 24, 1.5)
local t = c:save(O .. "aseprite/games/snail-green.aseprite", O .. "png/games/snail-green.png")
print(GV.report(t))
