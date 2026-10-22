local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ox, oy = -1, -2
local function P(t) local r = {} for i, p in ipairs(t) do r[i] = { p[1] + ox, p[2] + oy } end return r end

-- leaf blade: straight-ish left edge, bellied curved edge on the right
local blade = c:poly(P{ {23,14}, {27,17}, {31,19}, {34,23}, {35,27}, {36,31}, {37,34}, {38,36},
                        {37,38}, {33,39}, {30,35}, {28,30}, {26,25}, {24,20} })
blade:add(c:rect(22 + ox, 13 + oy, 23 + ox, 15 + oy))
local handle = c:line(P{ {38,41}, {43,49} }, 6):shrink(1):grow(1)
local cap = c:ellipse(44 + ox, 51 + oy, 3.5, 3)

local steel = GV.ramp("#d6c9b6", { shade = "#968f96", deep = "#6a6070" })
local wood = GV.ramp("#b6814d", { rim = "#f0d49a" })
c:build{
  { "blade", blade, steel, { gloss = { 27 + ox, 20 + oy } } },
  { "handle", handle, wood },
  { "cap", cap, GV.ramp("#8a4f2a"), { gloss = false } },
}
-- spine line along the blade
c:paint({ "s", "s" }, 26 + ox, 22 + oy, { s = "#b3a89a" })
c:paint({ "s", "s", "s" }, 28 + ox, 27 + oy, { s = "#b3a89a" })
c:paint({ "s", "s" }, 30 + ox, 32 + oy, { s = "#b3a89a" })
-- brass rivets on the handle
c:paint({ "gg", "gG" }, 39 + ox, 42 + oy, { g = "#f5cf6a", G = "#b8661a" })
c:paint({ "gg", "gG" }, 42 + ox, 46 + oy, { g = "#f5cf6a", G = "#b8661a" })
c:ground(36, 54, 11, 1.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/fine-foraging-knife.aseprite",
                 D .. "img-redraw-full/png/ph/fine-foraging-knife.png")
print(GV.report(t))
