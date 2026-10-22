local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tin  = GV.ramp("#8b8f96")
local dark = GV.ramp("#6b737e")

-- handle arch (behind body)
local handle = c:line({ {15,30}, {16,22}, {19,16}, {25,14}, {31,16}, {34,22}, {35,30} }, 3)
-- spout stub (snapped)
local spout = c:line({ {37,38}, {43,32} }, 4)
-- body: tapered tin
local body = c:poly({ {12,28}, {39,28}, {36,54}, {15,54} })
local rimband = c:rrect(11, 26, 39, 30, 1)
-- loose nozzle, tilted
local nozzle = c:poly({ {46,22}, {49,17}, {53,20}, {50,25} })
nozzle:add(c:rrect(48, 15, 53, 19, 1))
-- dropped chip
local chip = c:poly({ {42,47}, {48,46}, {49,51}, {43,52} })

c:build{
  { "handle", handle, dark, { flat = true } },
  { "spout",  spout,  dark },
  { "body",   body,   tin, { gloss = {17,34} } },
  { "rim",    rimband, dark },
  { "nozzle", nozzle, dark, { flat = true } },
  { "chip",   chip,   tin, { flat = true } },
}

-- jagged break on spout end
c:px(43,30,"#2a1a10"); c:px(44,32,"#2a1a10"); c:px(45,31,"#2a1a10")
-- chip notch in body edge (where the chip came from)
c:paint({ ".k", "kk", ".k" }, 35, 44, { k = "#2a1a10" })

-- crack down the body
c:line({ {26,31}, {28,37}, {24,42}, {29,48}, {27,53} }, 1):each(function(x, y)
  c:px(x, y, "#2a1a10")
end)
c:line({ {27,31}, {29,37}, {25,42}, {30,48} }, 1):each(function(x, y)
  if c:get(x, y) ~= "#2a1a10" then c:px(x, y, tin.shade) end
end)

-- rivets
c:px(15,33,tin.shade); c:px(36,33,tin.shade)

-- loose water drop
local drop = c:ellipse(51, 33, 1.5, 2):add(c:rect(51, 29, 51, 30))
c:fill(drop, "#8fcbd8")
c:px(50,32,"#c8ecdc")
c:px(52,35,"#3f8fb0")

c:ground(30, 56, 18, 1.5)

local t = c:save(O .. "aseprite/ph/broken-tin-watering-can.aseprite", O .. "png/ph/broken-tin-watering-can.png")
print(GV.report(t))
