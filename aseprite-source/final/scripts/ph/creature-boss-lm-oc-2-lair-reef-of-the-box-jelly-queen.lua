-- Box Jelly Queen (boss, coast, lv 16): a cube-bell box jellyfish. The glass bell shows a darker
-- water cavity through it in hard stepped bands (no real transparency). A small stitched gold
-- crown sits on the flat top. Four pedalia (corner knobs) each trail a cluster of three tentacles:
-- the two front corners hang long and pale, the two back corners hang shorter and deeper blue,
-- which sells the cube. A pink reef coral sprig peeks out at her lower left.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-oc-2-lair-reef-of-the-box-jelly-queen"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local GLASS = GV.R.glass
local FRONT = GV.ramp("#8fcbd8", { rim = "#c8ecdc" })   -- front tentacles: water rim, pale glass edge
local BACK  = GV.ramp("#5a86b8", { rim = "#8fcbd8" })   -- back tentacles: water family, deeper
local CORAL = GV.R.petal

-- one cluster of three 2 px tentacles (centre x), joined at a pedalium knob and fanning out below
local function cluster(x, y, len, fan)
  local m = c:mask()
  for i = -1, 1 do
    local w = (i == 0) and 0 or 1 -- outer strands drop 1 px shorter
    m:add(c:line({ {x + i*2, y}, {x + i*(2 + fan//2), y + 5}, {x + i*(2 + fan) + 1, y + 10},
                   {x + i*(2 + fan), y + 14}, {x + i*(2 + fan) + 1, y + len - w} }, 2))
  end
  m:add(c:rrect(x - 3, y - 3, x + 4, y + 1, 2)) -- pedalium knob the cluster hangs from
  return m
end

-- reef coral sprig (very back, lower left): a forked felt branch with round tips
local coral = c:line({ {11,56}, {11,50} }, 3)
coral:add(c:line({ {11,51}, {8,48}, {7,44} }, 2))
coral:add(c:line({ {12,50}, {13,46} }, 2))
coral:add(c:line({ {8,48}, {7,49}, {6,51} }, 2))
coral:add(c:ellipse(7.5, 43.5, 1.5, 1.5)):add(c:ellipse(13.5, 45.5, 1.5, 1.5))

local back  = cluster(28, 34, 16, 0):add(cluster(37, 34, 16, 0))
local front = cluster(18, 35, 20, 2):add(cluster(47, 35, 20, 2))

-- cube bell: flat-ish domed top, straight sides, squared bottom, hem band below
local bell = c:rrect(13, 12, 52, 34, 7):add(c:rect(13, 26, 52, 34))
local hem  = c:rrect(15, 32, 50, 36, 2)

-- crown: three points on a band, sewn to the bell top
local crown = c:rect(23, 9, 42, 13)
crown:add(c:poly({ {23,9}, {25.5,6}, {28,9} }))
crown:add(c:poly({ {29.5,9}, {32.5,6}, {35.5,9} }))
crown:add(c:poly({ {37,9}, {39.5,6}, {42,9} }))

c:build{
  { "coral", coral, CORAL, { flat = true } },
  { "back",  back,  BACK,  { flat = true } },
  { "front", front, FRONT, { flat = true } },
  { "bell",  bell,  GLASS, { gloss = { 15, 16 } } },
  { "hem",   hem,   GLASS, { gloss = false, contour = "#6f98c4" } },
  { "crown", crown, "gold", { gloss = { 25, 9 } } },
}

-- the water cavity seen through the glass: hard stepped bands, darker toward the open bottom
local cav1 = c:rrect(17, 16, 48, 31, 6)
local cav2 = c:rrect(20, 19, 45, 31, 5)
local cav3 = c:rrect(23, 25, 42, 31, 3)
c:fill(cav1, "#8fcbd8"); c:fill(cav2, "#3f8fb0"); c:fill(cav3, "#2f6290")

-- angry royal face on the cavity
c:eye(21, 20); c:eye(39, 20)
c:paint({ "uu....", "..uuu." }, 19, 17, { u = "#2a1a10" })
c:paint({ ".uuu..", "....uu" }, 39, 17, { u = "#2a1a10" }) -- mirrored brow
c:paint({ "..uuuuuu..", ".u......u.", "u.c....c.u" }, 28, 26, { u = "#2a1a10", c = "#f2e4c0" })

-- crown jewel and the stitch that sews the crown band on
c:spot(c:rect(31, 9, 34, 11), "#dd3a2a", "#ff9158")
c:px(26, 11, "#3f8fb0"); c:px(39, 11, "#3f8fb0")
c:seam({ {23, 13}, {42, 13} })

-- hem seam round the bell mouth, button at its head
c:seam({ {21, 34}, {49, 34} })
c:button(16, 33)

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
