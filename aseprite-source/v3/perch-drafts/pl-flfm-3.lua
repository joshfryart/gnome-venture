-- pl-flfm-3-perch.lua — phase 6: DETAIL (gloss, highlights, tiny accents)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-3-perch-20261120-183300/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "scene" }

-- ramps (from the pal's own palette)
local bodyR  = GV.ramp("#9175cc", { gloss = "#d8c8f0", dot = "#b9c9d6", rim = "#b9c9d6", shade = "#566597", deep = "#302454", bounce = "#5a6499" })
local bootR  = GV.ramp("#a85a52", { gloss = "#d29a88", dot = "#d29a88", rim = "#c08074", shade = "#7a3a3a", deep = "#4a2430" })
local grassR = GV.ramp("#9eaa91", { gloss = "#cae1c7", dot = "#cae1c7" })
local stumpR = GV.ramp("soil", { base = "#9a6a45" })
local rodR   = GV.ramp("wood", { base = "#9a6a45" })
local coneR  = GV.ramp("#f27b27", { gloss = "#ff9250", dot = "#ff9250", rim = "#ee8434" })
local swirlR = GV.ramp("#cae1c7", { rim = "#e4efe2", gloss = "#eef4ec", dot = "#eef4ec", shade = "#9eaa91", deep = "#7d5c7d" })

-- soft ground shadow (fill, behind everything, no part)
c:fill(c:ellipse(17, 29.5, 12, 1.7), "#7d5c7d")
c:fill(c:ellipse(17, 29.5, 8, 1.2), "#5c4358")

local p = c:build{
  -- fishing rod: taller than the pal, right beside the body, planted into the shadow
  { "rod", c:line({ { 28.5, 3.5 }, { 28.5, 28.5 } }, 2), rodR, { flat = true, gloss = false, outline = false, contact = false } },
  -- small wooden stump perch, lit top via rim, crescent on the lower right
  { "stump", c:rrect(10, 23, 24, 29, 3), stumpR, { cres = 2, deep = 1, gloss = false, outline = false } },
  -- treat at the left: swirl on a cone, cone tip grounded in the shadow
  { "cone",  c:poly({ { 4, 25 }, { 7.5, 25 }, { 5.5, 28.5 } }), coneR, { flat = true, gloss = false, outline = false, contact = false } },
  { "swirl", c:ellipse(5.5, 22.5, 2, 2), swirlR, { flat = true, gloss = false, outline = false, contact = false } },
  -- little boots standing on the stump top
  { "bootL", c:rrect(11, 20, 14, 22, 1), bootR, { flat = true, gloss = false, outline = false } },
  { "bootR", c:rrect(20, 20, 23, 22, 1), bootR, { flat = true, gloss = false, outline = false } },
  -- chibi berry body/head, wider than tall, bottoms out on the boots
  { "body", c:ellipse(17, 13.5, 10, 7.5), bodyR, { cres = 3, deep = 1, gloss = { 12, 8 }, outline = false, contour = "#2b1c26" } },
  -- crown: grass strip hugging the top rim + two round leaf tufts (no contour: they sit on the berry)
  { "crown", (function()
      local m = c:ellipse(17, 13.5, 10, 7.5)
      m:cut(c:ellipse(17, 13.5, 8.4, 5.4))
      m:cut(c:rect(0, 7, 35, 35))
      return m
    end)(), grassR, { flat = true, gloss = false, outline = false, contact = false, pale = false, contour = false } },
  { "tuftL", c:ellipse(12.3, 4.0, 2.0, 2.2), grassR, { flat = true, gloss = false, outline = false, contact = false, contour = false } },
  { "tuftR", c:ellipse(21.4, 3.9, 2.3, 2.4), grassR, { flat = true, gloss = false, outline = false, contact = false, contour = false } },
}

-- face (paint on the berry)
c:px(13, 10, "#2b1c26"); c:px(14, 10, "#b9c9d6"); c:px(13, 11, "#2b1c26"); c:px(14, 11, "#2b1c26"); c:px(13, 12, "#2b1c26") -- bean eye L
c:px(20, 10, "#b9c9d6"); c:px(21, 10, "#2b1c26"); c:px(20, 11, "#2b1c26"); c:px(21, 11, "#2b1c26"); c:px(21, 12, "#2b1c26") -- bean eye R
c:px(16, 16, "#2b1c26"); c:px(17, 16, "#2b1c26")                                                                            -- tiny mouth
c:px(10, 14, "#f5a0b8"); c:px(11, 14, "#f5a0b8")                                                                            -- blush L
c:px(22, 14, "#f5a0b8"); c:px(23, 14, "#f5a0b8")                                                                            -- blush R

-- TEXTURE: hand-placed, subtle, following the form -------------------------------------
-- gold seam stitch along the stump's top lip (stitched-perch signature)
c:seam({ { 11, 24 }, { 23, 24 } }, { on = 2, off = 1 })
-- wood grain ticks on the stump front
c:px(13, 27, "#7a4a1f"); c:px(19, 28, "#7a4a1f"); c:px(22, 26, "#7a4a1f")
-- grass blade flecks on the strip grounded on the cap
c:px(14, 6, "#cae1c7"); c:px(19, 6, "#cae1c7"); c:px(22, 7, "#cae1c7")
-- berry skin flecks in the shade half (one step down only)
c:px(20, 17, "#566597"); c:px(23, 16, "#566597"); c:px(17, 19, "#566597")
-- 1px dither where light meets shade, upper-right of the gloss
c:px(16, 9, "#566597"); c:px(20, 9, "#566597")
-- cone hatch marks + swirl glint
c:px(5, 26, "#ee8434"); c:px(6, 27, "#c4571c")
c:px(5, 21, "#eef4ec")

-- swirl roundness
c:px(7, 24, "#9eaa91")
-- tiny cross flower on the grass cap (petals + centre)
c:px(16, 6, "#cae1c7"); c:px(18, 6, "#cae1c7"); c:px(17, 7, "#cae1c7"); c:px(17, 6, "#f5a0b8")

-- 1px hand outline (selective, dark plum, no black)
local sil = c:mask()
for _, P in pairs(p) do sil:add(P.m) end
local rim = sil:grow(1):cut(sil)
c:fill(rim, "#2b1c26")

-- firefly beside the rod (repainted after the outline: it sits outside the sil ring)
c:px(32, 11, "#f27b27"); c:px(32, 12, "#c4571c")

local t = c:save(D .. "out/pl-flfm-3-perch.aseprite", D .. "out/pl-flfm-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0)
