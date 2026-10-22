local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- eyestalks (behind head)
local stalks = c:line({ {46, 32}, {44, 18} }, 2)
stalks:add(c:line({ {51, 32}, {53, 19} }, 2))

-- slug body with raised head at right, tapered tail at left
local body = c:rrect(12, 43, 53, 52, 4)
body:add(c:poly({ {6, 53}, {14, 45}, {14, 53} }))
body:add(c:ellipse(48.5, 37, 6.5, 8))

-- shell
local shell = c:ellipse(28, 31, 17, 17)

local p = c:build{
  { "stalks", stalks, "#c9b083", { flat = true } },
  { "body",   body,   GV.ramp("#e0c9a0") },
  { "shell",  shell,  GV.ramp("#ec7aa6"), { stitch = { side = "lit" } } },
}

-- spiral groove on shell
local pts = {}
local turns = 2.1
local n = 60
for i = 0, n do
  local t = i / n
  local a = -math.pi / 2 + t * turns * 2 * math.pi
  local r = 1.5 + t * 12.5
  pts[#pts + 1] = { math.floor(28 + r * math.cos(a) + 0.5), math.floor(31 + r * math.sin(a) + 0.5) }
end
local sp = c:line(pts, 2):clip(p.shell.m:shrink(2))
c:fill(sp, "#b8456f")

-- lit streak upper-left of shell
local streak = c:ellipse(28, 31, 15, 15):cut(c:ellipse(29, 32, 14, 14))
streak:clip(c:poly({ {10, 14}, {26, 14}, {14, 30}, {10, 30} }))
c:fill(streak, "#f6b8cf")
c:px(15, 30, "#f6b8cf")

-- eyes on stalk tips
c:eye(43, 15, true)
c:eye(52, 16, true)
-- smile
c:paint({ "u...u", ".uuu." }, 47, 40, { u = "#7a5a35" })

c:ground(30, 54, 22, 1.5)
local t = c:save(D .. "img-redraw-hybrid/aseprite/games/snail-pink.aseprite", D .. "img-redraw-hybrid/png/games/snail-pink.png")
print(GV.report(t))
