-- pl-baob-1-perch.lua : 36x36 perch — chibi chef bear on a wooden board
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-1-perch-20261120-165053/gvlib/gvlib.lua")
-- palette of this pal
local OL = "#2b1c26"                 -- dark outline (pal's dark)
GV.C.ol1, GV.C.ol2, GV.C.ol3 = OL, OL, OL
GV.C.halo = "#fff4d6"                -- eye cream
local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 1, cres = 2, deep = 1, margin = 2 }

-- ramps
local skin   = GV.ramp("#dd956d", { rim = "#eacbb5", shade = "#b95b35", deep = "#842721", bounce = "#dbad8c" })
local hatR   = GV.ramp("#f2e9d9", { gloss = "#fff6e0", dot = "#ffffff", rim = "#fff6e0", shade = "#c8b8c5", deep = "#9890b4", bounce = "#d8d0e0" })
local wood   = GV.ramp("#c4a494", { gloss = "#e4d0a8", rim = "#e4d0a8" })
local footR  = GV.ramp("#b8a468", { rim = "#c8b87a", gloss = "#c8b87a", shade = "#a38850", deep = "#7d6a3e" })
local grey   = GV.ramp("#c8b8c5", { rim = "#d8d0e0", shade = "#786877", bounce = "#c8b8c5" })
local pinkR  = { base = "#d9726b", rim = "#f5809f", gloss = "#f5809f", dot = "#f5809f", shade = "#b95b35", deep = "#5e1625", bounce = "#d9726b" }
local creamC = { base = "#f2e9d9", rim = "#f2e9d9", gloss = "#f2e9d9", dot = "#f2e9d9", shade = "#e4d0a8", deep = "#c4a494", bounce = "#f2e9d9" }

-- parts, back to front
c:build{
  { "board", c:rrect(5, 25, 29, 30, 2), wood, { cres = 2, deep = 1, gloss = { 7, 26 } } },
  { "footL", c:rrect(11, 22, 14, 25, 1), footR, { flat = true } },
  { "footR", c:rrect(20, 22, 23, 25, 1), footR, { flat = true } },
  { "dome",  c:ellipse(17, 16, 6.5, 6.5), skin, { gloss = false, cres = 3, deep = 1 } },
  { "hat",   c:ellipse(18, 6.5, 5.5, 3.4), hatR, { cres = 1, deep = 1, bounce = false, gloss = false } },
  { "arm",   c:line({ { 11, 15.5 }, { 10, 13.5 } }, 2), skin, { flat = true, gloss = false } },
  { "cup",   c:rrect(6, 11, 9, 14, 1), creamC, { flat = true, cres = 1, deep = 1 } },
  { "top",   c:ellipse(7.25, 10.5, 1.8, 1.3), pinkR, { flat = true, cres = 1, deep = 1 } },
  { "pot",   c:rrect(26, 22, 29, 25, 1), grey, { cres = 1, deep = 1, gloss = false } },
}
-- hat band: flat white stripe inside the puff (no part ring)
c:fill(c:rect(13, 8, 23, 8), "#fff6e0")
-- pot rim light row
c:fill(c:rect(26, 22, 29, 22), "#d8d0e0")

-- hat pleats (vertical flute stripes, one shade step, from band up)
for _, x in ipairs({ 15, 19 }) do c:px(x, 6, "#c8b8c5"); c:px(x, 7, "#c8b8c5") end
c:px(15, 5, "#c8b8c5"); c:px(19, 5, "#c8b8c5")
-- muzzle: form shading (lower-right inside) + bounce below
c:fill(c:line({ { 19, 17 }, { 20.5, 18.5 } }, 1), "#e4d0a8")
c:px(15, 20, "#e4d0a8")
-- board: wood grain dashes (hand-placed, following the plank, tone-on-tone)
c:px(10, 28, "#ae846c"); c:px(11, 28, "#ae846c")
c:px(16, 29, "#ae846c"); c:px(17, 29, "#ae846c"); c:px(18, 29, "#ae846c")
c:px(22, 28, "#ae846c")
c:px(13, 27, "#e4d0a8"); c:px(14, 27, "#e4d0a8"); c:px(15, 27, "#e4d0a8")
-- feet: toe notch pixels
c:px(13, 24, "#8a7a4a"); c:px(21, 24, "#8a7a4a")
-- pot: inner shade under its rim
c:px(27, 23, "#786877"); c:px(28, 24, "#786877")
-- cupcake: cream cup weave dash + pink pip
c:px(6, 13, "#e4d0a8"); c:px(7, 14, "#e4d0a8")
c:px(6, 11, "#f5809f")
-- glints
c:px(27, 22, "#f2e9d9")          -- pot rim glint
c:px(14, 4, "#fff6e0")           -- hat puff top glint

-- face: muzzle + eyes + mouth (painted, not parts)
c:fill(c:ellipse(17.5, 18.5, 3, 1.7), "#f2e9d9")
c:paint({ "EE", "EE", "EE" }, 13, 13, { E = OL })
c:px(13, 13, "#fff6e0")                                          -- left eye glint
c:paint({ "EE", "EE", "EE" }, 20, 13, { E = OL })
c:px(20, 13, "#fff6e0")                                          -- right eye glint
c:px(17, 19, "#5e1625"); c:px(18, 19, "#5e1625")                 -- tiny 2px mouth

c:ground(17.5, 31.5, 12, 1.5, "#9a8a94")

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-1-perch-20261120-165053/out/pl-baob-1-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-1-perch-20261120-165053/out/pl-baob-1-perch.png")
print(GV.report(t))
assert(t.semi == 0)
