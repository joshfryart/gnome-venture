local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- foot: long low slug, tail tapering left, head rising at right
local foot = c:rrect(10, 43, 51, 52, 4)
foot:add(c:poly({ {8, 52}, {13, 46}, {15, 53} }))
local head = c:rrect(45, 26, 55, 52, 5)
local stalkA = c:line({ {49, 30}, {48, 20} }, 2)
local stalkB = c:line({ {53, 30}, {55, 21} }, 2)
local shell = c:ellipse(27.5, 29.5, 17, 17)

local p = c:build{
  { "stalkA", stalkA, GV.ramp("#c9b083"), { flat = true } },
  { "stalkB", stalkB, GV.ramp("#c9b083"), { flat = true } },
  { "foot",   foot:add(head), GV.ramp("#e0c9a0") },
  { "shell",  shell, GV.ramp("#f2b72a"), { gloss = { 16, 19 } } },
}

-- spiral curl (2px), from centre outward
local pts = {}
for i = 0, 40 do
  local th = i * 0.27
  local r = 1.0 + th * 1.55
  pts[#pts + 1] = { math.floor(28 + r * math.cos(th) + 0.5), math.floor(31 + r * math.sin(th) + 0.5) }
end
c:fill(c:line(pts, 2):clip(shell:shrink(3)), "#b9800d")

-- spark bolt on the shell front
c:paint({
  "...ss",
  "..ss.",
  ".sss.",
  "ssss.",
  "..ss.",
  ".ss..",
  "ss...",
}, 33, 14, { s = "#fff1c8" })

-- seam where shell meets body
c:seam({ { 37, 47 }, { 45, 47 } })

-- eyes on stalk tips, smile
c:eye(46, 16, true); c:eye(53, 17, true)
c:paint({ "u...u", ".uuu." }, 48, 38, { u = "umber" })

local t = c:save(O .. "aseprite/games/snail-gold.aseprite", O .. "png/games/snail-gold.png")
print(GV.report(t))
