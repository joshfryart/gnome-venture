-- pl-bvd-3-perch.lua : chibi perch of the pal (gold hard hat + teal blob on a wooden bench + lamp post)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-3-perch-20261120-170920/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 2 }

-- ramps (pin key tones to the pal palette)
local teal  = GV.ramp("#4281a1", { gloss = "#76b8c8", rim = "#76b8c8", deep = "#224b6b" })
local gold  = GV.ramp("#e8b030", { gloss = "#fedf68", dot = "#fedf68", rim = "#fedf68", shade = "#80564c", deep = "#5e321f" })
local wood  = GV.ramp("#af854f", { shade = "#80564c", deep = "#5e321f" })
local grey  = GV.ramp("#513a4f")
local cryst = GV.ramp("#76b8c8")
local CREAM, GOLDB, GOLDD = "#fedf68", "#e8b030", "#80564c"

-- geometry / masks
local blob   = c:ellipse(17.5, 18.5, 9.5, 8)          -- round pal body/head
local hatD   = c:ellipse(17.5, 8, 9.5, 3.4)           -- gold hard-hat dome
hatD:add(c:rrect(6, 10, 29, 12, 2))                   -- brim
local head   = blob:copy() head:add(hatD)             -- whole head, for crescent measuring
local plank  = c:rrect(5, 25, 28, 27, 1)              -- bench plank
local legL   = c:rect(8, 28, 9, 29)
local legR   = c:rect(24, 28, 25, 29)
local bench  = plank:copy() bench:add(legL) bench:add(legR)
local pole   = c:rect(5, 23, 6, 29)                   -- lamp post
local puck   = c:rect(3, 30, 6, 31)
local lamp   = c:rrect(3, 14, 8, 22, 1)               -- lantern body+cask (details painted on)
local crystM = c:mask()
crystM:ascii({ ".c.", "ccc", ".c." }, 28, 15)         -- tiny crystal

local P = c:build{
  { "cryst", crystM, cryst, { flat = true } },
  { "pole",  pole, wood, { flat = true } },
  { "puck",  puck, wood, { flat = true } },
  { "legL",  legL, wood, { gloss = false } },
  { "legR",  legR, wood, { gloss = false } },
  { "plank", plank, wood, { gloss = false, light = bench } },
  { "blob",  blob, teal, { gloss = { 13, 17 } } },
  { "lamp",  lamp, gold, { flat = true } },
  { "hat",   hatD, gold, { light = head } },
}

-- lantern details (painted on, after parts)
c:fill(c:rect(3, 14, 8, 15), grey.base)               -- grey cap top
c:px(3, 16, grey.shade); c:px(4, 16, GOLDB); c:px(5, 16, GOLDB); c:px(6, 16, GOLDB); c:px(7, 16, GOLDB); c:px(8, 16, grey.shade)
c:fill(c:rect(4, 18, 7, 20), CREAM)                   -- glow window
c:px(5, 19, "#fff3c8"); c:px(6, 19, CREAM)            -- hot centre
c:px(4, 18, CREAM); c:px(7, 18, CREAM)
c:px(5, 13, GOLDB); c:px(6, 13, GOLDB)                -- knob
c:px(5, 14, CREAM); c:px(6, 14, CREAM)

-- bench details: grain follows the plank, worn lit spot near centre-left
c:px(14, 25, "#c99a5f"); c:px(15, 25, "#c99a5f"); c:px(16, 25, "#c99a5f")
c:px(10, 26, GOLDD); c:px(22, 26, GOLDD)
-- blob: closed happy eyes + smile (from the pal)
c:px(12, 17, "#2b1c26"); c:px(13, 16, "#2b1c26"); c:px(14, 17, "#2b1c26"); c:px(13, 17, "#2b1c26")
c:px(21, 17, "#2b1c26"); c:px(22, 16, "#2b1c26"); c:px(23, 17, "#2b1c26"); c:px(22, 17, "#2b1c26")
c:px(16, 21, "#2b1c26"); c:px(17, 21, "#2b1c26"); c:px(18, 21, "#2b1c26"); c:px(15, 20, "#2b1c26"); c:px(18, 20, "#2b1c26")
-- hat lamp on the front (cream cluster, from the pal)
c:fill(c:rect(14, 6, 17, 7), CREAM)
c:px(15, 6, "#fff3c8"); c:px(16, 7, CREAM)
-- pole seam where it passes behind the plank
c:px(5, 24, "#5e321f"); c:px(6, 24, "#5e321f")
-- sparkle on the crystal
c:px(29, 15, cryst.gloss)

c:ground(16.5, 31, 12, 1.3, "#513a4f")

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-3-perch-20261120-170920/out/pl-bvd-3-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-3-perch-20261120-170920/out/pl-bvd-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
