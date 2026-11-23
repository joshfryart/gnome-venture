-- pl-drmc-1-perch: chibi chef-potato pal on a small perch, 36x36
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-1-perch-20261120-175429/gvlib/gvlib.lua")
-- pal-family dark outline (like the examples' #2b1c26) instead of gvlib's olive
GV.C.ol1 = "#5a4a7a"; GV.C.ol2 = "#3a2c52"; GV.C.ol3 = "#241a36"
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, cres = 2, deep = 3, margin = 2 }

-- ramps tuned to the pal's own tones (light upper-left)
local cream = GV.ramp("#f5ebd1", { gloss = "#fff6e0", dot = "#ffffff", rim = "#fff6e0",
  shade = "#d8d0e0", deep = "#b8b0cc", bounce = "#e6ddcb" })
local mauve = GV.ramp("#82535e", { gloss = "#e2b277", dot = "#f5cdae", rim = "#d9977a",
  shade = "#61333e", deep = "#4e222e", bounce = "#96606b" })
local mask  = GV.ramp("#3a2c52", { gloss = "#9a92cc", dot = "#cfc8e8", rim = "#8a7fae",
  shade = "#2e2342", deep = "#251b36", bounce = "#51456c" })
local grey  = GV.ramp("#9b95a8", { gloss = "#cfc8dc", dot = "#e6e2ee", rim = "#cac5d6",
  shade = "#7a7490", deep = "#5e5880", bounce = "#a8a2b8" })
local boot  = GV.ramp("#b8a468", { gloss = "#ffe38a", dot = "#fff0a0", rim = "#ebd6a0",
  shade = "#8a7a4a", deep = "#5a4a30", bounce = "#c4b078" })

-- ground shadow + perch slab
local parts = c:build{
  { "shadow", c:ellipse(17.5, 29.5, 11.5, 1), "#5a4a7a", { flat = true, solid = false, cres = 0, deep = 0, rim = false, bounce = false, gloss = false, outline = false } },
  { "slab",  c:rrect(11, 27, 25, 30, 2), grey, { gloss = false, cres = 1, deep = 0 } },
  { "body",  c:ellipse(17.5, 24, 6.5, 3.5), mauve, { cres = 1, deep = 0, gloss = { 14, 22 } } },
  { "pop",   c:rrect(29, 25, 30, 26, 1), cream, { flat = true, solid = false, cres = 0, deep = 0, gloss = false, rim = false } },
  { "popP",  c:rrect(29, 27, 30, 28, 1), "#f08aa0", { flat = true, solid = false, cres = 0, deep = 0, gloss = false, rim = false } },
  { "bootL", c:rrect(12, 25, 15, 27, 1), boot, { gloss = false, cres = 1, deep = 0 } },
  { "bootR", c:rrect(19, 25, 22, 27, 1), boot, { gloss = false, cres = 1, deep = 0 } },
  { "head",  c:ellipse(17.5, 18.5, 9, 6.5), mauve, { deep = 2, gloss = { 12, 14 } } },
  { "mask",  c:rrect(11, 16, 24, 21, 2), mask, { gloss = { 13, 17 }, cres = 1, deep = 2 } },
  { "band",  c:rrect(11, 12, 25, 14, 1), cream, { gloss = false, cres = 0, deep = 0, contour = false } },
  { "puffR", c:ellipse(22.5, 10, 3.5, 3.5), cream, { cres = 1, deep = 2, gloss = false } },
  { "puffA", c:ellipse(16.5, 8, 7, 4.5), cream, { cres = 1, deep = 2, gloss = { 13, 5 } } },
}
-- tan forehead strip between band and eye mask (from the pal)
for x = 12, 22 do c:px(x, 15, "#c5947e") end
c:px(11, 15, "#c5947e")

-- eyes: cream 5x4 slabs with lower 2x2 pupils (pal-style) on the dark mask
for _, ex in ipairs{ {13, 17}, {19, 17} } do
  local x, y = ex[1], ex[2]
  for j = 0, 3 do for i = 0, 4 do c:px(x + i, y + j, "#f5ebd1") end end
  c:px(x + 1, y + 2, "#241a36"); c:px(x + 2, y + 2, "#241a36"); c:px(x + 3, y + 2, "#241a36")
  c:px(x + 1, y + 3, "#241a36"); c:px(x + 2, y + 3, "#241a36"); c:px(x + 3, y + 3, "#241a36")
  c:px(x, y, "#fff6e0"); c:px(x + 1, y, "#fff6e0")
end
-- stud bead smile, dipped at the centre (below the mask edge)
c:px(12, 22, "#f5cf6a"); c:px(13, 22, "#e8a317")
c:px(14, 23, "#f5cf6a"); c:px(15, 23, "#e8a317")
c:px(16, 23, "#7ac8f0")
c:px(17, 23, "#e8a317"); c:px(18, 23, "#f5cf6a")
c:px(19, 23, "#e8a317")
c:px(20, 22, "#f5cf6a"); c:px(21, 22, "#e8a317")
-- glints: bead top-lights, pop glint, boot lit top
c:px(14, 22, "#fff6e0"); c:px(20, 22, "#fff6e0")
c:px(29, 26, "#fff6e0")
c:px(13, 26, "#ffe38a"); c:px(20, 26, "#ffe38a")
-- pop stick + ground bead accents
c:px(29, 29, "#5a4a30"); c:px(30, 29, "#5a4a30")
c:px(7, 30, "#f5cf6a"); c:px(8, 31, "#e8a317")
-- ---- hand-placed texture (subtle, follows the form) ----------------------
-- hat: cloth crease + 1px dither along the light/shade border
c:px(13, 6, "#d8d0e0"); c:px(13, 7, "#b8b0cc")
c:px(19, 4, "#d8d0e0"); c:px(20, 5, "#d8d0e0"); c:px(21, 6, "#d8d0e0")
c:px(18, 6, "#f5ebd1"); c:px(20, 7, "#f5ebd1")
-- band: stitched-toy edge stitch on the lit side
c:stitch(parts.band.m, { side = "lit" })
-- body: potato skin pits (on visible cheeks / body sliver)
c:px(9, 19, "#96606b"); c:px(25, 19, "#4e222e")
c:px(16, 26, "#96606b"); c:px(17, 27, "#61333e")
-- slab: stone joints + worn corners
c:px(15, 28, "#7a7490"); c:px(19, 29, "#7a7490"); c:px(22, 28, "#7a7490")
c:px(12, 28, "#cac5d6"); c:px(24, 29, "#cac5d6")
-- boots: heel shade + thread gold buckle px
c:px(12, 27, "#5a4a30"); c:px(22, 27, "#5a4a30")

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-1-perch-20261120-175429/out/pl-drmc-1-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-1-perch-20261120-175429/out/pl-drmc-1-perch.png")
print(GV.report(t))
