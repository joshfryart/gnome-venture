-- pl-aurs-5-perch.lua : 36x36 perch of the mushroom-cap gnome pal (pl-aurs-5)
-- scene mode + ol=1: 1px selective outline, no black border, art within 2..33
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurs-5-perch-20261120-164953/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local C = GV.C
local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 0 }

local capR   = GV.ramp("#b67b5b")
local colR   = GV.ramp("#e6d0b8")
local faceR  = GV.ramp("#a9cad9")
local bodyR  = GV.ramp("#443f88", { rim = "#6882af", gloss = "#a9cad9" })
local footR  = GV.ramp("#86463e")
local stumpR = GV.ramp("#9a6a45")
local poleR  = GV.ramp("#603432")
local leafR  = GV.ramp("#8fd05a")

-- masks
local poleM   = c:rect(29, 4, 30, 30)
local tasselM = c:mask()
for y = 9, 13 do tasselM:set(32, y) end
local leafM   = c:ascii({ ".gg.", "gggg", ".gg." }, 4, 21)
local capM    = c:ellipse(16.5, 6.5, 8, 5)
capM:cut(c:rect(-16, -16, 54, 2))   -- from y3 up
capM:cut(c:rect(-16, 11, 54, 54))   -- cap bowl ends at y10
local pomM    = c:rrect(14, 3, 17, 5, 1)
local collarM = c:rrect(10, 10, 23, 13, 1)
local faceM   = c:rrect(10, 13, 23, 19, 2)
local bodyM   = c:rrect(11, 19, 22, 26, 3)
local footLM  = c:rrect(12, 27, 14, 29, 1)
local footRM  = c:rrect(19, 27, 21, 29, 1)
local stumpM  = c:rrect(9, 27, 25, 31, 3)

-- crescents are measured on the whole object (single light source)
local palL = c:mask()
palL:add(capM) palL:add(pomM) palL:add(collarM) palL:add(faceM)
palL:add(bodyM) palL:add(footLM) palL:add(footRM)
local allL = palL:copy(); allL:add(stumpM)

local parts = c:build{
  { "pole",   poleM,   poleR,  { flat = true, contour = false, contact = false, stitch = false } },
  { "tassel", tasselM, colR,   { flat = true, contour = false, contact = false, stitch = false, rim = false, outline = false } },
  { "leaf",   leafM,   leafR,  { flat = true, contour = false, contact = false, stitch = false } },
  { "stump",  stumpM,  stumpR, { light = allL, cres = 2, deep = 1, contour = false, contact = false, stitch = false, gloss = false } },
  { "body",   bodyM,   bodyR,  { light = palL, contour = false, contact = false, stitch = false, gloss = false } },
  { "footL",  footLM,  footR,  { light = palL, contour = false, contact = false, stitch = false, gloss = false } },
  { "footR",  footRM,  footR,  { light = palL, contour = false, contact = false, stitch = false, gloss = false } },
  { "face",   faceM,   faceR,  { light = palL, contour = false, contact = false, stitch = false, gloss = false, cres = 2 } },
  { "collar", collarM, colR,   { light = palL, contour = false, contact = false, stitch = false, gloss = false } },
  { "cap",    capM,    capR,   { light = palL, cres = 2, contour = false, contact = false, stitch = false, gloss = { 11, 6 } } },
  { "pom",    pomM,    colR,   { flat = true, contour = false, contact = false, stitch = false, rim = false, outline = false } },
}

-- CRITIQUE fixes
-- stump: lit top face (light from upper-left)
for _, p in ipairs({ { 10, 28 }, { 11, 28 }, { 23, 28 }, { 24, 28 } }) do
  c:px(p[1], p[2], "#b5855f")
end
-- cap: hand sheen comma beside the auto gloss
c:px(11, 5, "#d3be91"); c:px(12, 5, "#d3be91"); c:px(11, 6, "#d3be91")

-- hand colours: lilac tassel from the pal
for y = 9, 13 do c:px(32, y, "#9890b4") end
c:px(33, 14, "#d8c8f0"); c:px(32, 14, "#d8c8f0")
-- leaf stem reaching the stump
c:px(8, 22, "#5fae4a")
-- seated contact: stump shade under body/feet on the stump top
for _, x in ipairs({ 11, 15, 16, 17, 18, 22 }) do c:px(x, 27, stumpR.shade) end
-- pole foot contact on the ground
c:px(29, 31, "#aaa9b8"); c:px(30, 31, "#aaa9b8")
-- ground lower-right shade (light upper-left)
for x = 4, 7 do c:px(x, 31, "#74758c") end
for x = 26, 28 do c:px(x, 31, "#74758c") end
c:px(28, 30, "#74758c")
-- pom: cream knob, warm top, cool bottom
c:px(15, 3, colR.rim); c:px(14, 5, colR.shade); c:px(17, 5, colR.shade)
-- leaf: darker lower side
c:px(5, 23, leafR.shade); c:px(6, 23, leafR.shade)

-- TEXTURE: knit ribs on the collar (2 tone, from the pal's hatband)
for x = 11, 22 do if (x - 11) % 2 == 1 then c:px(x, 12, "#c8a288") end end
-- wood grain dashes on the stump sides
c:px(9, 29, stumpR.shade); c:px(25, 29, stumpR.shade)
-- feet: deep bottom row
for _, x in ipairs({ 12, 14 }) do c:px(x, 29, footR.shade) end
for _, x in ipairs({ 19, 21 }) do c:px(x, 29, footR.shade) end

-- DETAILS: locked chibi eyes, cheeks, mouth (from the pal's face)
c:eye(12, 15, true); c:eye(19, 15, true)
c:fill(c:ascii({ "PP", "PP" }, 10, 16), "#f5a0b8")   -- left cheek
c:fill(c:ascii({ "PP", "PP" }, 22, 16), "#f5a0b8")   -- right cheek
c:px(16, 18, C.ol3); c:px(17, 18, C.ol3)             -- tiny mouth
-- gold spark beside the pole (pal's glint)
c:px(33, 8, "#ffe38a")
-- pom glint
c:px(14, 4, "#f6ecdc")
c:ground(16.5, 30, 13.5, 1.5, "#aaa9b8")
local t = c:save(D .. "out/pl-aurs-5-perch.aseprite", D .. "out/pl-aurs-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
