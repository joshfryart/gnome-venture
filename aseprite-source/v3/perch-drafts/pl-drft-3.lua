-- pl-drft-3-perch.lua : 36x36 perch sprite (chibi pal on its stump perch, fish + lamp post)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-3-perch-20261120-174045/gvlib/gvlib.lua")

-- ramps pinned to the pal's palette
local Rgold  = GV.ramp("#f6b959", { gloss="#efd984", dot="#efd984", rim="#efd984", shade="#e7ba28", deep="#734d48", bounce="#e7ba28" })
local Rbody  = GV.ramp("#403582", { gloss="#9379a0", dot="#9379a0", rim="#5471a6", shade="#2b2654", deep="#2b1c26", bounce="#5471a6" })
local Rfish  = GV.ramp("#d56b2d", { gloss="#efd984", dot="#efd984", rim="#f6b959", shade="#62222d", deep="#2b1c26", bounce="#734d48" })
local Rstump = GV.ramp("#734d48", { gloss="#9379a0", dot="#9379a0", rim="#9379a0", shade="#62222d", deep="#2b1c26", bounce="#734d48" })
local Rbrim  = { base="#62222d", shade="#62222d", deep="#62222d", bounce="#62222d", rim="#d56b2d" }

local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }
c.cx, c.cy = 18.5, 19

-- soft shadow ellipse under the stump
c:ground(17, 31, 13, 1.5, "#2b2654")

-- perch stump (flat base + lit rim, shade painted by hand below)
c:part(c:rrect(8, 21, 26, 29, 3), Rstump, { flat=true, gloss=false, contact=false, contour="#2b1c26" })
c:fill(c:rect(9, 28, 25, 29), "#62222d")
c:fill(c:rect(25, 23, 26, 27), "#62222d")
c:px(10, 28, "#734d48"); c:px(23, 28, "#734d48") -- dither at the shade border

-- lamp post planted on the stump's left shoulder, lantern tucked under the hat's left slope
c:part(c:rect(8, 12, 9, 24), Rstump, { flat=true, gloss=false, contact=false })
c:part(c:rrect(5, 8, 9, 11, 1), Rgold, { flat=true, rim=false, gloss=false, contact=false, contour="#2b1c26" })

-- pal: body, then dark-red brim, then head (head overlaps body top and brim bottom)
c:part(c:ellipse(19, 21, 7, 4), Rbody, { flat=true, rim=false, gloss=false, contour="#2b1c26" })
c:part(c:rrect(9, 10, 27, 11, 1), Rbrim, { flat=true, rim=false, gloss=false, contact=false })
c:part(c:rrect(12, 12, 26, 19, 3), Rbody, { flat=true, rim=false, gloss=false, contour="#2b1c26" })
c:fill(c:rect(13, 13, 13, 18), "#5471a6") -- lit left edge of the face
c:fill(c:rect(25, 14, 25, 17), "#2b2654") -- shaded right edge
c:px(24, 13, "#2b2654")
-- body lit left column, shaded right column
c:fill(c:rect(12, 20, 12, 23), "#5471a6")
c:fill(c:rect(26, 20, 26, 23), "#2b2654")

-- gold cone hat (flat base, light/shade painted by hand so no hard bands)
c:part(c:poly({ { 17, 4.5 }, { 26, 10 }, { 7, 10 } }), Rgold, { flat=true, rim=false, gloss=false, contact=false, contour="#2b1c26" })
c:px(17, 4, "#efd984")
c:paint({ "cdgge" },       15, 6, { c="#efd984", d="#f6b959", g="#e7ba28", e="#734d48" })
c:paint({ "cdddgggee" },   13, 7, { c="#efd984", d="#f6b959", g="#e7ba28", e="#734d48" })
c:paint({ "cddddgggggee" }, 11, 8, { c="#efd984", d="#f6b959", g="#e7ba28", e="#734d48" })
c:paint({ "ccddddgggggggee" }, 9, 9, { c="#efd984", d="#f6b959", g="#e7ba28", e="#734d48" })
c:px(14, 8, "#e7ba28") -- 1px dither at the light/shade border
c:px(13, 8, "#efd984") -- hat glint

-- fish held across the lap, tail fin to the right
c:part(c:ellipse(19, 22, 6, 2), Rfish, { cres=1, deep=0, contour="#62222d", gloss=false })
c:px(17, 20, "#efd984") -- shine dot on the fish's back
c:part(c:rrect(24, 21, 27, 23, 1), Rfish, { flat=true, rim=false, gloss=false, contact=false, contour="#2b1c26" })
c:fill(c:rrect(24, 21, 27, 23, 1), "#62222d")
c:px(26, 22, "#d56b2d") -- fin glint

-- face: dark eyes with cream glints, tiny mouth
c:paint({
  "cdd",
  "ddd",
  "ddd",
}, 14, 14, { c="#efd984", d="#2b1c26" })
c:paint({
  "cdd",
  "ddd",
  "ddd",
}, 21, 14, { c="#efd984", d="#2b1c26" })
c:paint({ "mm" }, 18, 17, { m="#2b1c26" })

-- fish cream scale marks
c:px(16, 21, "#efd984"); c:px(19, 21, "#efd984"); c:px(22, 21, "#efd984")
c:px(15, 22, "#efd984"); c:px(18, 22, "#efd984"); c:px(21, 22, "#efd984")

-- lantern cream glow core
c:fill(c:rect(7, 9, 8, 10), "#efd984")
c:px(7, 11, "#e7ba28")

-- stump wood grain
c:px(11, 27, "#62222d"); c:px(12, 27, "#62222d"); c:px(18, 27, "#62222d"); c:px(20, 28, "#62222d")

-- gold glow sparkles
c:px(5, 5, "#efd984"); c:px(31, 4, "#efd984"); c:px(32, 9, "#efd984")

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-3-perch-20261120-174045/out/pl-drft-3-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-3-perch-20261120-174045/out/pl-drft-3-perch.png"
)
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
