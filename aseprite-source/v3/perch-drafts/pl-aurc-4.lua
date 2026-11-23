-- pl-aurc-4-perch: chibi perch sprite of the teal sword-pal on its pink perch (36x36)
-- phase: CRITIQUE (face moves down to chibi-low position, grip reaches the ground, head gloss re-anchored)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-4-perch-20261120-163749/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "icon" }

-- sprout: stem + two leaves (raised so they clear the blob outline)
local sprout = c:rect(17, 4, 18, 8)
               :add(c:ellipse(14.5, 5.5, 2.5, 1.5))
               :add(c:ellipse(20.5, 5.5, 2, 1.5))
-- sword: 4px steel blade + gold guard + grip
local blade = c:rect(5, 10, 8, 21)
local guard = c:rrect(4, 21, 9, 22, 1)
local grip  = c:rect(5, 23, 8, 29)
-- perch: pink cushion with gold trim + two legs
local cushion = c:rrect(8, 24, 27, 28, 3)
                 :add(c:rect(10, 29, 11, 30))
                 :add(c:rect(24, 29, 25, 30))
-- the pal: one round blob, face in upper half
local blob = c:ellipse(17.5, 14.5, 8.5, 7.5)
              :add(c:rrect(12, 18, 23, 25, 3))
-- floating heart
local heart = c:ascii({
  ".a.a.",
  "aaaaa",
  ".aaa.",
  "..a..",
}, 25, 10)

local heartR = GV.ramp("#a34578")
local p = c:build{
  { "sprout",  sprout,  GV.ramp("#bcbf61"), { flat = true } },
  { "blade",   blade,   GV.ramp("#f8f4e4", { shade = "#9c948b" }), { flat = true, rim = false } },
  { "guard",   guard,   GV.ramp("#bcbf61"), { flat = true } },
  { "grip",    grip,    GV.ramp("#4e3f5d"), { flat = true } },
  { "cushion", cushion, GV.ramp("#a34578"), { cres = 1, deep = 1 } },
  { "blob",    blob,    GV.ramp("#81c0a7"), { gloss = { 11, 8 } } },
  { "heart",   heart,   heartR, { flat = true, solid = true } },
}

-- cushion: solid gold trim line under its top edge (from the pal's bench)
c:fill(c:rect(10, 25, 25, 25):clip(p.cushion.m), GV.ramp("#bcbf61").base)

-- blade: 1px shade column lower-right + one lit px back at the middle (dither)
c:fill(c:rect(8, 11, 8, 20):clip(p.blade.m), "#9c948b")
c:px(8, 15, "#f8f4e4")
-- sprout: leaf/stem ends one tone down, follows the form
c:px(14, 6, "#9c8f3f"); c:px(20, 6, "#9c8f3f"); c:px(18, 5, "#a88744")

-- face: big round eyes sit low (chibi), tiny mouth below
c:eye(11, 12)
c:eye(20, 12)
c:paint({ "u.u" }, 16, 19, { u = "#1f514d" })

-- details: heart glint, blob head highlight above the left eye
c:px(26, 11, heartR.gloss)
c:px(11, 9, "#abd8b7"); c:px(12, 8, "#abd8b7")

c:ground(17.5, 30, 12, 1.5)

local t = c:save("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-4-perch-20261120-163749/out/pl-aurc-4-perch.aseprite",
                 "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-4-perch-20261120-163749/out/pl-aurc-4-perch.png")
print(GV.report(t))
