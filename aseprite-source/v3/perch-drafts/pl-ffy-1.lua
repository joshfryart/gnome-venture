-- pl-ffy-1-perch.lua : chibi green pal (lanternpole) on its small perch, 36x36
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ffy-1-perch-20261120-181515/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- this asset's outline is a single 1px dark-palette colour, no black border:
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#2b1c26", "#2b1c26", "#2b1c26"
GV.C.halo = "#dff0d4" -- eye whites

local PHASE = "detail"  -- block | persp | shade | texture | detail
local SHADED = (PHASE ~= "block" and PHASE ~= "persp")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0, cres = 3, deep = 1 }

-- ramps (locked to the pal's palette)
local rBody  = GV.ramp("#64a74f", { gloss = "#dff0d4", dot = "#dff0d4", rim = "#8fc175",
                                    shade = "#3d8d69", deep = "#20583d", pale = false })
local rLight = GV.ramp("#8fc175", { gloss = "#dff0d4", dot = "#dff0d4", rim = "#dff0d4",
                                    shade = "#64a74f", deep = "#3d8d69", pale = false })
local rWood  = GV.ramp("#af916d", { shade = "#795552", deep = "#5e4348" })
local rGold  = GV.ramp("#f2da71")
local rStone = GV.ramp("#454264", { bounce = "#795552" })
local rMoss  = GV.ramp("#3d8d69", { gloss = "#dff0d4", rim = "#8fc175" })
local rBelly = GV.ramp("#dff0d4", { rim = "#dff0d4", shade = "#8fc175", deep = "#8fc175",
                                    bounce = false, pale = false })
local rBlue  = GV.ramp("#70bbe1", { gloss = "#dff0d4", dot = "#dff0d4" })

local p = c:build{
  { "pole",   c:rrect(27, 8, 29, 30, 1), rWood, { flat = true, gloss = false, contact = false } },
  { "lantern", c:rrect(25, 2, 32, 8, 1), rGold, { flat = not SHADED } },
  { "window", c:rect(27, 4, 30, 6), "#dff0d4", { flat = true, rim = false, contact = true } },
  { "rock",   c:ellipse(17, 29.5, 12.5, 3), rStone, { flat = not SHADED, gloss = false } },
  { "armL",   c:line({ {12, 10}, {9.5, 8} }, 3), rLight, { flat = true } },
  { "armR",   c:line({ {20, 10}, {22.5, 8} }, 3), rLight, { flat = true } },
  { "moss",   c:ellipse(16.5, 27.75, 9, 1.9), rMoss, { flat = true } },
  { "body",   c:ellipse(15.5, 18.5, 9.5, 8), rBody, { flat = not SHADED, bounce = false, contour = false } },
  { "belly",  c:ellipse(15.5, 23.5, 4.5, 2.3), rBelly, { flat = true, rim = false, contact = false } },
  { "flower", c:ellipse(15.5, 23.5, 1.7, 1.2), rBlue, { flat = true, contact = false, contour = false } },
}

-- texture marks: tone-on-tone, never more than 1 shade step
c:px(28, 12, rWood.shade); c:px(28, 19, rWood.shade)      -- wood grain dashes
c:px(10, 26, rBody.rim); c:px(23, 27, rBody.rim)          -- moss blade flecks
c:px(18, 25, "#8fc175"); c:px(19, 24, "#8fc175")          -- belly lower-right shade
c:px(8, 14, rBody.rim); c:px(7, 15, rBody.rim)            -- body felt speckles, lit side
c:px(21, 17, rBody.base); c:px(20, 18, rBody.shade)       -- 1px dither on the crescent border
c:px(14, 23, rBlue.gloss)                                 -- light petal fleck

if PHASE ~= "block" then
  -- pole cylinder shading: lit left edge, shade right edge
  for y = 9, 29 do c:px(29, y, rWood.shade) end
end

-- details drawn after the parts (a later c:part repaints its whole area)
c:eye(9, 12)   -- locked 5x5, top-left corner
c:eye(18, 12)
c:paint({ "uu" }, 15, 19, { u = "#2b1c26" }) -- tiny horizontal mouth
-- small accents: lantern glow pair, unanchored floats removed
c:px(23, 3, "#f2da71"); c:px(22, 4, "#f2da71")
-- gold reflection on the window's bottom row
c:px(28, 6, "#f2da71"); c:px(29, 6, "#f2da71")

-- soft ground shadow + the single 1px dark outline (gvlib's black border is unwanted here)
c.mode = "scene"
c:outline(c.sil, { ol = 1, olx = 0, keep = true })
c:ground(16.5, 32, 13.5, 1.6, GV.ramp("#454264").deep)

local t = c:save(D .. "out/pl-ffy-1-perch.aseprite", D .. "out/pl-ffy-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
