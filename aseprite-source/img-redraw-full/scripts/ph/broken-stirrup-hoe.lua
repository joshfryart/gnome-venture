local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood = GV.ramp("#b6814d", { rim = "#f0d49a" })
local steel = GV.ramp("#8c4a1a", { shade = "#8a4f2a" })

-- handle: steep diagonal pole, snapped by a jagged crack around y 33
local pole = c:line({ {17, 49}, {37, 14} }, 5)
local upper = pole:copy():clip(c:rect(0, 0, 63, 28))
upper:add(pole:copy():clip(c:rect(0, 29, 26, 30)))       -- jagged tooth
local lower = pole:copy():clip(c:rect(0, 33, 63, 63))
lower:add(pole:copy():clip(c:rect(29, 31, 63, 32)))
lower = lower:shift(-2, 2)                               -- snapped piece slips down

-- blade: horizontal oblong head, lower-right corner chipped off
local blade = c:poly({ {33, 10}, {54, 10}, {52, 22}, {31, 22} })
blade:cut(c:poly({ {48, 23}, {54, 16}, {54, 23} }))
local collar = c:rrect(30, 20, 40, 25, 2)

-- loose splinter beside the break
local splinter = c:line({ {38, 41}, {45, 35} }, 3)

local p = c:build{
  { "lower", lower, wood },
  { "upper", upper, wood },
  { "blade", blade, steel, { gloss = { 36, 13 } } },
  { "collar", collar, "gold" },
  { "splinter", splinter, wood, { flat = true } },
}
-- crack lines running into the wood
c:paint({ "d..", ".d.", "..d" }, 25, 23, { d = "#2a1a10" })
c:paint({ "d", "d", ".d" }, 20, 37, { d = "#2a1a10" })
-- chip notch on blade top edge
c:paint({ "dd", "d." }, 44, 12, { d = "#5e2f1e" })
c:seam({ {31, 22}, {40, 22} })
local t = c:save(B .. "img-redraw-full/aseprite/ph/broken-stirrup-hoe.aseprite",
                 B .. "img-redraw-full/png/ph/broken-stirrup-hoe.png")
print(GV.report(t))
