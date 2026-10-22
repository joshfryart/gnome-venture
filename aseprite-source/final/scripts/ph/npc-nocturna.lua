local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- background disc
local disc = c:ellipse(39.5, 50, 30, 30)

-- wings: big upper lobe + smaller lower lobe, flaring past the disc edge
local function wing(sx)
  local function X(x) return sx < 0 and x or 79 - x end
  local m = c:ellipse(X(18), 38, 12, 15)
  m:add(c:ellipse(X(17), 63, 10, 9))
  m:add(c:poly({ {X(22), 28}, {X(34), 48}, {X(34), 62}, {X(20), 62} }))
  return m
end
local lw, rw = wing(-1), wing(1)
local wings = lw:copy(); wings:add(rw)

-- antennae (behind the hat)
local ant = c:line({ {34, 40}, {30, 28}, {26, 18} }, 2)
ant:add(c:line({ {45, 40}, {49, 28}, {53, 18} }, 2))

-- jacket
local jacket = c:ellipse(39.5, 100, 33, 24):cut(c:rect(0, 100, 79, 140))

-- face
local face = c:ellipse(39.5, 57, 16, 18)

-- hat
local brim = c:ellipse(39.5, 43, 30, 5.5)
local crown = c:ellipse(39.5, 42, 15, 12):cut(c:rect(0, 43, 79, 99))
local band = crown:copy():clip(c:rect(0, 35, 79, 38))

local lilac = GV.ramp("#c3b2ea")
local p = c:build{
  { "disc",   disc,   GV.ramp("#b0bc66"), { gloss = false } },
  { "wings",  wings,  lilac },
  { "ant",    ant,    "#7a5cc0", { flat = true } },
  { "jacket", jacket, "gold" },
  { "face",   face,   GV.ramp("#f8eed2"), { stitch = { side = "lit" } } },
  { "brim",   brim,   GV.ramp("#dcb06a") },
  { "crown",  crown,  "#f5cf6a" },
  { "band",   band,   GV.ramp("#d9667f"), { flat = true } },
}

-- feathered antenna ticks
for _, t in ipairs({ {24, 20}, {28, 21}, {25, 23}, {29, 24} }) do
  c:px(t[1], t[2], "#7a5cc0"); c:px(79 - t[1], t[2], "#7a5cc0")
end
-- antenna clubs
c:part(c:rrect(24, 15, 27, 18, 1), "#7a5cc0", { flat = true })
c:part(c:rrect(52, 15, 55, 18, 1), "#7a5cc0", { flat = true })

-- wing eye-spots
for _, x in ipairs({ 15, 60 }) do
  c:paint({ ".ccc.", "cdddc", "cdddc", "cdddc", ".ccc." }, x, 36, { c = "#f8eed2", d = "#54447f" })
  c:px(x + 1, 37, "#f8eed2")
end
-- lower-wing bean markings
c:spot(c:ellipse(16, 64, 2, 1.5)); c:spot(c:ellipse(63, 64, 2, 1.5))

-- face
c:eye(31, 51); c:eye(44, 51)
c:paint({ "d.......d", ".ddddddd." }, 35, 62, { d = "#2a1a10" })

-- jacket seam + buttons
c:seam({ {40, 80}, {40, 99} })
c:button(38, 84); c:button(38, 92)
-- brim hem
c:seam({ {13, 45}, {20, 47}, {30, 48}, {49, 48}, {59, 47}, {66, 45} })

local t = c:save(O .. "aseprite/ph/npc-nocturna.aseprite", O .. "png/ph/npc-nocturna.png")
print(GV.report(t))
