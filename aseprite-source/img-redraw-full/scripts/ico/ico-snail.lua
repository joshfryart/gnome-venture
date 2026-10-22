local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- body / foot: long low slug with raised neck at right
local body = c:rrect(14, 41, 51, 49, 4)
body:add(c:poly({ {11, 49}, {16, 43}, {18, 50} }))      -- tapered tail
body:add(c:rrect(43, 26, 51, 47, 4))                      -- neck
body:add(c:ellipse(47, 27, 5, 4))                         -- head
local stalks = c:line({ {44, 25}, {43, 17} }, 3):add(c:line({ {49, 25}, {50, 17} }, 3))
local shell = c:ellipse(27, 29, 14, 14)

local p = c:build{
  { "stalks", stalks, GV.ramp("#b9a678"), { flat = true } },
  { "body", body, GV.ramp("#cdbb8f") },
  { "shell", shell, GV.ramp("#c47a3a") },
}

-- spiral swirl, 1.5 turns from centre out to r9.5
local pts = {}
for i = 0, 30 do
  local t = i / 30
  local a = math.pi * 3 * t + math.pi * 0.25
  local r = 1.5 + 8 * t
  pts[#pts + 1] = { math.floor(27 + r * math.cos(a) + 0.5), math.floor(29 + r * math.sin(a) + 0.5) }
end
c:fill(c:line(pts, 3), "#7a4a1f")
c:gloss(p.shell.m, p.shell.r, { 18, 19 })

-- stalk tip clubs with eye glints
c:fill(c:rrect(41, 13, 44, 16, 1), "#2a1a10")
c:fill(c:rrect(49, 13, 52, 16, 1), "#2a1a10")
c:px(42, 14, "#f2e4c0"); c:px(50, 14, "#f2e4c0")
c:paint({ "u.u", ".u." }, 47, 29, { u = "umber" })

local t = c:save(O .. "aseprite/ico/ico-snail.aseprite", O .. "png/ico/ico-snail.png")
print(GV.report(t))
