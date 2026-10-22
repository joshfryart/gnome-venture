local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local T = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- handle: diagonal pill toward lower right
local handle = c:poly({ {30.5, 25.5}, {50.5, 45.5}, {45.5, 50.5}, {25.5, 30.5} })
handle:add(c:ellipse(48, 48, 3.5, 3.5))

-- head: block perpendicular to the handle
local cx, cy = 25, 25
local ux, uy = 0.743, -0.669
local vx, vy = 0.669, 0.743
local function P(a, b) return { cx + ux * a + vx * b, cy + uy * a + vy * b } end
local head = c:poly({ P(15, -7), P(15, 7), P(-15, 7), P(-15, -7) })
local top  = c:poly({ P(10, -7), P(10, -3), P(-15, -3), P(-15, -7) })
local cap  = c:poly({ P(15, -7), P(15, 7), P(10, 7), P(10, -7) })
local strike = c:poly({ P(-12, -7), P(-12, 7), P(-15, 7), P(-15, -7) })

c:build{
  { "handle", handle, "wood" },
  { "head",   head,   "stone" },
  { "top",    top,    GV.ramp("#c9c5bc"), { flat = true, contact = false } },
  { "cap",    cap,    GV.ramp("#5b6470"), { gloss = false } },
}

local t = c:save(T .. "aseprite/ph/nav-crafting.aseprite", T .. "png/ph/nav-crafting.png")
print(GV.report(t))
