-- pl-ffy-4-perch.lua : 36x36 chibi perch of the lantern-straw-hat pal.
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ffy-4-perch-20261120-182207/gvlib/gvlib.lua")
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ffy-4-perch-20261120-182207/"

local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- ramps
local body  = GV.ramp("#caa55f")
local dome  = GV.ramp("#e8c871")
local brim  = GV.ramp("#fce8a2")
local gold  = "gold"
local wood  = "wood"
local maskr = GV.ramp("#453459")
local feetr = GV.ramp("#773b28")

-- masks
local spark = c:mask()
spark:rrect(27, 7, 29, 9, 1)
local pole = c:rrect(8, 6, 9, 27, 0)
local lant = c:rrect(5, 5, 12, 12, 2)
local pad = c:mask()
pad:ellipse(17.5, 28, 10.5, 2.5)
local bodym = c:mask()
bodym:ellipse(17.5, 20, 8, 7.5)
local domem = c:mask()
domem:ellipse(17.5, 10, 7.5, 5)
local brimm = c:mask()
brimm:ellipse(17.5, 14.5, 10.5, 2)
local maskm = c:rrect(10, 17, 25, 21, 3)
local feetl = c:rrect(13, 28, 16, 29, 0)
local feetr2 = c:rrect(19, 28, 22, 29, 0)

local p = c:build{
  { "spark", spark, brim, { flat = true, gloss = false } },
  { "pole",  pole,  wood, { flat = true, gloss = false } },
  { "lant",  lant,  gold, { gloss = { 6, 6 } } },
  { "pad",   pad,   gold, { gloss = false } },
  { "body",  bodym, body },
  { "dome",  domem, dome, { gloss = { 13, 7 } } },
  { "brim",  brimm, brim, { gloss = false } },
  { "mask",  maskm, maskr, { gloss = false, cres = 1 } },
}
-- feet painted directly: parts inside the pad would contour to umber
local feetramp = GV.ramp("#773b28")
c:fill(feetl, feetramp.base)
c:fill(feetl:copy():clip(c:rect(13, 28, 16, 28)), feetramp.rim)
c:fill(feetr2, feetramp.base)
c:fill(feetr2:copy():clip(c:rect(19, 28, 22, 28)), feetramp.rim)

-- face: cream 3x3 eyes inside the mask, tiny beak mouth below
c:eye(13, 18, true)
c:eye(19, 18, true)
c:paint({ "mm" }, 17, 22, { m = "#743926" })
-- wing nub on the right of the body, olive shade
local wingr = c:rrect(25, 19, 27, 23, 1)
c:part(wingr, GV.ramp("#a88b4a"), { flat = true, gloss = false })

-- lantern glow: bright glass core, lit top, gold base bar kept
c:fill(c:rect(6, 7, 11, 10), "#fce8a2")
c:fill(c:rect(6, 7, 8, 9), "#fff6c0")
c:fill(c:rect(6, 10, 11, 10), "#fbdc96")
c:px(6, 6, "#d0862a")
c:seam({ { 6, 6 }, { 11, 6 } }, { on = 2, off = 2, gap = "#7a3a14" })

-- second pal accent: marker tubes (blue + pink) on the pad right flank
c:px(26, 27, "#d8f4ff"); c:px(26, 28, "#7ac8f0")
c:px(28, 28, "#ffc8d8"); c:px(28, 29, "#f08aa0")

-- hand-placed texture, 1 step from base
c:px(12, 22, "#bfab6f") -- terminator step break on belly, light side
c:px(13, 23, "#bfab6f")
c:px(14, 22, "#a96f38")
c:px(20, 23, "#bfab6f")
c:px(21, 22, "#a96f38")
c:px(19, 24, "#bfab6f")
-- straw weave on the pad front (dark dashes 1 tone below base)
local weave = c:mask()
for _, x in ipairs({ 7, 11, 23, 27 }) do
  weave:rrect(x, 29, x + 2, 29, 0)
end
for _, x in ipairs({ 9, 25 }) do
  weave:rrect(x, 30, x + 1, 30, 0)
end
c:fill(weave, "#b8661a")
-- brim hatch marks like the pal's hat weave (every 4th, following the form)
local hatch = c:mask()
for _, x in ipairs({ 9, 13, 17, 21, 25 }) do
  hatch:set(x, 13)
  hatch:set(x, 15)
end
c:fill(hatch, "#dfae52")
-- hat band: red where dome meets brim, clipped to the dome, flush on the brim
local bandm = domem:copy()
bandm:clip(c:rect(9, 11, 26, 11))
c:fill(bandm, "#d1473d")
local bandl = domem:copy()
bandl:clip(c:rect(9, 12, 26, 12))
c:fill(bandl, "#ae2a2a")
-- dome straw grain: sparse tone-on-tone dashes on the lit half
c:px(12, 8, "#d3bd7b"); c:px(13, 8, "#d3bd7b")
c:px(15, 6, "#d3bd7b")
c:px(11, 10, "#9a7a3a")

-- DETAIL: pink cheeks under the mask corners, lantern spark glint
c:px(12, 21, "#ecb4ac")
c:px(23, 21, "#ecb4ac")
c:px(27, 7, "#fff6c0")

local t = c:save(D .. "out/pl-ffy-4-perch.aseprite", D .. "out/pl-ffy-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
