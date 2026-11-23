-- pl-chil-1-perch.lua : chibi perch of the moss-crowned log pal, 36x36
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-chil-1-perch-20261120-173008/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, cres = 2, deep = 1 }

local wood  = GV.ramp("#bb7747")
local rust  = GV.ramp("#934c36")
local cream = GV.ramp("#f8e4b7")
local moss  = GV.ramp("#92d275")
local slate = GV.ramp("#5b4a61")
local wine  = GV.ramp("#701d27")
local topwood = GV.ramp("#d9a660") -- rim colour of the lighter log top

local headM = c:ellipse(17.5, 11.5, 8.5, 7)
local bodyM = c:rrect(12, 14, 23, 22, 4)
local stumpSide = c:rrect(6, 24, 29, 30, 2)
local stumpTop  = c:ellipse(17.5, 24, 11, 2.5):cut(c:rect(0, 25, 35, 35))
local crownM = c:ascii({
  "..m..m..m..m..",  -- y3
  ".mm.mm.mm.mm..",  -- y4
  "mmm.mmm.mmm.mm",  -- y5
}, 11, 3, "m"):add(c:ellipse(17.5, 7, 9, 2))
local mossRow = c:ascii({
  "....m..mm...m..mm...m..",
}, 7, 21, "m")
local mossOnStump = mossRow:clip(stumpTop:shift(0, -1)):clip(c:rect(6, 20, 29, 23))

local p = c:build{
  { "shadow",   c:ellipse(16.5, 32, 10.5, 1.2), GV.ramp("#5e2f1e", { rim = "#5e2f1e" }), { flat = true, gloss = false, contact = false, contour = false, solid = false } },
  { "stump",    stumpSide, wood, { gloss = false } },
  { "stumpTop", stumpTop,  topwood, { gloss = false, cres = 1, light = stumpSide:grow(2) } },
  { "crown",    crownM,    moss, { flat = true, gloss = false, contact = false, contour = false } },
  { "mossRim",  mossOnStump, moss, { flat = true, gloss = false, contact = false, contour = false } },
  { "body",     bodyM, rust, { gloss = false } },
  { "armL",     c:line({ { 12, 17 }, { 10, 21 } }, 2), rust, { gloss = false, cres = 1 } },
  { "armR",     c:line({ { 23, 17 }, { 25, 21 } }, 2), rust, { gloss = false, cres = 1 } },
  { "footL",    c:rrect(13, 21, 16, 22, 1), slate, { flat = true, contour = false } },
  { "footR",    c:rrect(19, 21, 22, 22, 1), slate, { flat = true, contour = false } },
  { "head",     headM, rust },
  -- mushroom accent beside the perch
  { "shroom",     c:ellipse(5.5, 25.5, 2.5, 1.8), wine, { flat = true } },
  { "shroomStem", c:rrect(4, 27, 7, 30, 1), cream, { flat = true } },
}

-- big cream face on the head (drawn after it)
c:part(c:ellipse(17.5, 13.5, 6, 4.5):clip(headM), cream, { flat = true, gloss = false, contact = false })

-- big dark round eyes with a cream glint (like the pal)
for _, ex in ipairs({ 13, 19 }) do
  for j = 0, 2 do for i = 0, 2 do c:px(ex + i, 10 + j, "#2a1a10") end end
  c:px(ex, 10, "#f8e4b7")
end
-- tiny mouth
c:paint({ "mm" }, 16, 16, { m = wood.shade })

-- TEXTURE -------------------------------
-- wood grain on the stump side: short vertical dashes, longer at the centre of the cylinder
local grain = {
  { 11, 26, 2 }, { 20, 25, 3 }, { 26, 26, 2 },
}
for _, g in ipairs(grain) do
  for j = 0, g[3] - 1 do c:px(g[1], g[2] + j, wood.shade) end
end
-- two knots on the top face
c:px(13, 23, topwood.shade); c:px(21, 23, topwood.shade)
-- moss tufts creeping over the front edge of the stump
c:px(9, 25, moss.base); c:px(17, 25, moss.base); c:px(27, 25, moss.base)
-- cream spots on the mushroom cap
c:px(5, 25, "#f8e4b7"); c:px(7, 26, "#f8e4b7")

-- little wine heart at the upper right (from the pal), floating clear of the crown
c:build{
  { "heart", c:ascii({
    "h.h",
    "hhh",
    ".h.",
  }, 27, 5, "h"), wine, { flat = true, gloss = false, contact = false, contour = false } },
}

c:ground(16.5, 32, 12, 1.2)

local t = c:save(D .. "out/pl-chil-1-perch.aseprite", D .. "out/pl-chil-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
