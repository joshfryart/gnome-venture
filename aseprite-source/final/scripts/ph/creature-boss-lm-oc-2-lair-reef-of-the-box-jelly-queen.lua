-- Box Jelly Queen (boss, coast, lv 16): a cube-bell box jellyfish with a glassy shell and a
-- darker water core seen through it (hard stepped glass -> water bands), a small stitched gold
-- crown, four pedalia at the bell corners each trailing a cluster of three tentacles that drift
-- in the current, and a pink reef coral sprig at her lower left.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-oc-2-lair-reef-of-the-box-jelly-queen"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local GLASS = GV.R.glass
local CORE  = GV.R.water
local TENT  = GV.ramp("#8fcbd8")
local CORAL = GV.R.petal

-- reef coral sprig (back, lower left): branching felt coral
local coral = c:line({ {10,56}, {10,50}, {8,46} }, 3)
coral:add(c:line({ {10,51}, {13,48}, {13,45} }, 2))
coral:add(c:line({ {9,53}, {6,51}, {6,48} }, 2))

-- four tentacle clusters (three 2 px tentacles each), drifting right in the current
local tent = c:mask()
local function cluster(x, y, sway)
  for i = -1, 1 do
    local bx = x + i * 3
    tent:add(c:line({ {bx, y}, {bx + sway, y + 5}, {bx + sway - 1, y + 9}, {bx + sway + 1, y + 13 - math.abs(i)} }, 2))
  end
end
cluster(17, 42, 2); cluster(27, 43, 2); cluster(37, 43, 2); cluster(47, 42, 2)

-- four pedalia (corner knobs the tentacles hang from)
local ped = c:mask()
for _, x in ipairs({ 17, 27, 37, 47 }) do ped:add(c:rrect(x - 3, 38, x + 3, 44, 2)) end

-- cube bell: rounded top corners, squared bottom
local bell = c:rrect(13, 14, 50, 41, 6):add(c:rect(13, 30, 50, 41))
-- water core seen through the glass
local core = c:rrect(18, 19, 45, 37, 4)

-- crown: three points on a band
local crown = c:rect(23, 10, 40, 14)
crown:add(c:poly({ {23,10}, {25.5,5}, {28,10} }))
crown:add(c:poly({ {29,10}, {31.5,4}, {34,10} }))
crown:add(c:poly({ {35,10}, {37.5,5}, {40,10} }))

local p = c:build{
  { "coral", coral, CORAL, { flat = true } },
  { "tent",  tent,  TENT,  { flat = true } },
  { "ped",   ped,   GLASS, { gloss = false } },
  { "bell",  bell,  GLASS },
  { "core",  core,  CORE,  { contour = "#6f98c4", gloss = { 21, 21 } } },
  { "crown", crown, "gold", { gloss = { 25, 11 } } },
}

-- face on the core: locked eyes, angry brows, frown with two little fangs
c:eye(21, 24); c:eye(37, 24)
c:paint({ "uu...", "..uuu" }, 20, 21, { u = "#2a1a10" })
c:paint({ "uuu..", "...uu" }, 38, 21, { u = "#2a1a10" })
c:paint({ "..uuuuuu..", ".u......u.", "u.c....c.u" }, 26, 31, { u = "#2a1a10", c = "#f2e4c0" })

-- crown jewels and the stitched crown band
c:spot(c:rect(30, 11, 32, 12), "#dd3a2a", "#ff9158")
c:px(25, 12, "#3f8fb0"); c:px(38, 12, "#3f8fb0")
c:seam({ {23, 14}, {40, 14} })

-- bell hem seam with a button at its head
c:seam({ {18, 40}, {48, 40} })
c:button(14, 38)

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
