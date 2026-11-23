-- pl-aurs-2-perch.lua : 36x36 perch sprite (chibi moss/fern pal on mossy log)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurs-2-perch-20261120-164341/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- spec palette outline colours (dark plums, never pure black inside)
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#563b42", "#2b1c26", "#2b1c26"

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

local BLOCK = { flat = true, cres = 0, deep = 0, gloss = false, rim = false, bounce = false, contour = false, contact = false }

-- back to front
local blob  = c:part(c:ellipse(17.5, 17.5, 10, 9), GV.ramp("#44815a"))
local face  = c:part(c:ellipse(16, 16, 7, 6), GV.ramp("#75b88e"), { contour = false, rim = false, cres = 2, deep = 0 })
local muzz  = c:part(c:ellipse(17.5, 22, 5, 3.5), GV.ramp("#d1bbae"), { contour = false, cres = 1, deep = 0, bounce = false })
local crest = {}
for i, bx in ipairs({ 13.5, 17.5, 21.5 }) do
  crest[i] = c:part(c:line({ {bx, 9}, {bx + (i-2), 6} }, 3), GV.ramp("#8fd05a"), { contour = false, deep = 0, cres = 1 })
end
local staff = c:part(c:line({ {5, 12}, {5, 28} }, 3), GV.R.wood)
-- hanging cord: gold curl at staff top, lavender strand out left, gold tip
c:px(6, 11, GV.R.wood.rim); c:px(7, 12, GV.R.wood.rim)        -- top curl
c:part(c:line({ {6, 13}, {4, 16} }, 2), GV.ramp("#d8c8f0", { gloss = "#e2d4f4", dot = "#efe6fa", rim = "#c4b4da" }),
  { flat = true, gloss = false, contact = false, rim = false })
c:px(4, 17, GV.R.wood.rim); c:px(3, 16, GV.R.wood.rim)        -- gold tip
local crys  = c:part(c:ellipse(28.5, 11.5, 1.5, 2.5), GV.ramp("#7ac8f0",
  { gloss = "#c8ecdc", dot = "#eaf8e4", rim = "#8fcbd8", bounce = "#5a86b8", shade = "#2f6290", deep = "#2a3c6c" }))
local log   = c:part(c:rrect(5, 27, 26, 30, 1), GV.R.wood)
local footL = c:part(c:rrect(12, 25, 15, 27, 1), GV.ramp("#84745b"), { contour = false, flat = true, contact = false })
local footR = c:part(c:rrect(20, 25, 23, 27, 1), GV.ramp("#84745b"), { contour = false, flat = true, contact = false })
c:ground(16.5, 30, 13.5, 1.5, "#563b42")

-- hand-placed texture (<=1 shade step, follows the form)
-- moss cap on the log's lit top edge
for x = 6, 25 do
  if not (x >= 12 and x <= 15) and not (x >= 20 and x <= 23) then
    c:px(x, 27, (x % 3 == 0) and "#3f8a4a" or "#8fd05a")
  end
end
-- wood grain dashes on the log front, 1 shade step
for _, gx in ipairs({ 8, 9, 13, 14, 18, 22, 23 }) do c:px(gx, 29, GV.R.wood.shade) end
-- tone-on-tone moss freckles following the blob's shade side
for _, p in ipairs({ {9, 22}, {10, 23}, {25, 15}, {24, 13} }) do c:px(p[1], p[2], GV.ramp("#44815a").shade) end
-- lighter tips on the crest blades
c:px(12, 6, GV.ramp("#8fd05a").dot); c:px(16, 5, GV.ramp("#8fd05a").dot); c:px(20, 6, GV.ramp("#8fd05a").dot)
-- 1px tone-on-tone speckle in the face's lit field
c:px(12, 14, GV.ramp("#75b88e").rim); c:px(21, 13, GV.ramp("#75b88e").dot)

-- detail: face + accents
local ink = "#2b1c26"
c:px(13, 15, ink); c:px(14, 15, ink); c:px(15, 15, ink)                     -- eye L
c:px(13, 16, ink); c:px(14, 16, ink); c:px(15, 16, ink)
c:px(14, 15, "#ede9de")                                                     -- glint L
c:px(18, 15, ink); c:px(19, 15, ink); c:px(20, 15, ink)                     -- eye R
c:px(18, 16, ink); c:px(19, 16, ink); c:px(20, 16, ink)
c:px(19, 15, "#ede9de")                                                     -- glint R
c:px(16, 21, ink); c:px(17, 21, ink)                                        -- tiny mouth
-- curved terminator: 1-step shade arc on the blob's lower-left, then deep at the very rim
local blobRamp = GV.ramp("#44815a")
for _, p in ipairs({ {9, 21}, {10, 22}, {11, 23} }) do c:px(p[1], p[2], blobRamp.shade) end
c:px(9, 22, blobRamp.deep); c:px(8, 21, blobRamp.shade)

local t = c:save(D .. "out/pl-aurs-2-perch.aseprite", D .. "out/pl-aurs-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
