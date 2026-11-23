-- pl-baob-2-perch: chibi baob perch sprite 36x36
local ROOT = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-2-perch-20261120-165155/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- palette
local C = {
  ink    = "#2b1c26",
  dark   = "#41333c",
  mid    = "#5e545c",
  mauve  = "#a5919c",
  rose   = "#99616b",
  leafL  = "#b2ca85",
  leaf   = "#438a4b",
  plumL  = "#8a76a8",
  plum   = "#6e5e8e",
  plumD  = "#4a355c",
  wood   = "#8d4748",
  heart  = "#f06a8a",
}

local leafRamp  = GV.ramp(C.leaf,  { gloss = C.leafL, rim = C.leafL })
local trunkRamp = GV.ramp(C.mid,   { gloss = C.mauve, rim = C.mauve, shade = C.dark, deep = C.ink })
local stumpRamp = GV.ramp(C.wood,  { shade = C.dark, deep = C.ink, gloss = C.rose, rim = C.rose })
local barkRamp  = GV.ramp("#8d4748", { gloss = C.rose, rim = "#a8582f", bounce = "#743b3a" })
local heartRamp = GV.ramp(C.heart, { shade = C.plumD, deep = C.ink, gloss = C.mauve, rim = C.mauve })

-- TEXTURE: raised log top, separated heart, lit bark
local leaves = c:mask()
leaves:add(c:ellipse(17.5, 12, 9, 4))            -- leafy crown skirt
leaves:add(c:poly({ { 10, 15 }, { 11, 8 }, { 12, 8 }, { 13, 15 } }))   -- left blade
leaves:add(c:poly({ { 16, 13 }, { 17, 6 }, { 19, 6 }, { 20, 13 } }))   -- centre blade
leaves:add(c:poly({ { 22, 15 }, { 23, 9 }, { 24, 9 }, { 24, 15 } }))   -- right blade
leaves:cut(c:poly({ { 14, 13 }, { 16, 6 }, { 15, 6 }, { 13, 13 } }))   -- gap 1
leaves:cut(c:poly({ { 21, 13 }, { 22.5, 8 }, { 21.5, 8 }, { 20.5, 13 } })) -- gap 2

local stump = c:rrect(12, 26, 24, 30, 2)         -- log-stump perch
stump:add(c:ellipse(17.5, 26.8, 6, 2.2))         -- top disc of the log

local trunk = c:rrect(10, 13, 25, 25, 5)         -- baob trunk pot, sits on the log
trunk:add(c:ellipse(17.5, 14, 8, 3.5))           -- rounded pot top

local feet = c:mask()
feet:add(c:rrect(13, 23, 15, 25, 1))             -- left foot on the log
feet:add(c:rrect(20, 23, 22, 25, 1))             -- right foot

local heart = c:ascii({
  ".h.h.",
  "hhhhh",
  ".hhh.",
  "..h..",
}, 27, 6)

local p = c:build{
  { "crown", leaves, leafRamp,  { light = leaves:grow(1), cres = 2, deep = 1, gloss = false, rim = true } },
  { "stump", stump,  barkRamp,  { light = stump:grow(1), cres = 2, deep = 1, gloss = false, rim = true } },
  { "trunk", trunk,  trunkRamp, { light = trunk:grow(1), cres = 4, deep = 3, gloss = { 14, 17 },   rim = true } },
  { "feet",  feet,   barkRamp,  { flat = true, rim = false, gloss = false, cres = 1, deep = 1 } },
  { "heart", heart,  heartRamp, { flat = true, gloss = false, rim = true, cres = 2, deep = 1 } },
}

-- log top face: warm sliver at the sides of the trunk
c:fill(c:ellipse(17.5, 26.4, 5.2, 1.3):clip(p.stump.m), "#b07a45")
c:px(13, 26, "#a8582f"); c:px(14, 26, "#d9a660"); c:px(22, 26, "#d9a660"); c:px(23, 26, "#a8582f")
-- bark front band, below the top face
for x = 14, 21 do c:px(x, 28, barkRamp.base) end

-- texture: bark joints on the log sides (tone-on-tone, below the feet)
for _, pt in ipairs({ { 13, 28 }, { 13, 29.5 }, { 23, 27.5 }, { 23.5, 29 } }) do
  c:px(math.floor(pt[1]), math.floor(pt[2]), barkRamp.shade)
end
-- trunk grain: two faint marks on the lower body
c:px(15, 24, "#4d4f4c"); c:px(20, 24, "#4d4f4c")

-- lit left column + warm bounce on lower-right edge
for _, y in ipairs({ 16, 17, 18, 19, 20, 21, 22, 23, 24 }) do
  c:px(11, y, C.mauve)
  c:px(12, y, "#7a7078")
  c:px(24, y, C.rose)
  if y >= 19 then c:px(23, y, C.dark) end
end
-- bark lit bounce on the log's left edge
c:px(12, 27, "#a8582f"); c:px(12, 28, barkRamp.rim); c:px(12, 29, "#a8582f")

-- eyes: rounder 4x4 sclera, tight 2x2 pupil, 1px glint upper-left
c:paint({ ".PP.", "PDDP", "PgDP" }, 12, 17, { P = "#f2e4c0", D = C.ink, g = "#e8ddca" })
c:paint({ ".PP.", "PDDP", "PgDP" }, 19, 17, { P = "#f2e4c0", D = C.ink, g = "#e8ddca" })
-- tiny mouth between and below the eyes
c:paint({ "mm..", "mmmm" }, 16, 21, { m = C.ink })

-- detail: leaf glint on the lit blades, lit green on the right blade
c:px(17, 8, "#e0e8ab"); c:px(12, 10, "#c8d790")
c:px(22, 10, "#5a9a52"); c:px(23, 11, "#5a9a52"); c:px(23, 12, "#57944e")
c:px(28, 7, "#ffb0c0")
-- detail: gloss dot on the trunk lit shoulder (small, upper-left)
c:px(13, 16, "#7f747c")

-- soft ground shadow
c:ground(17.5, 30.3, 8, 1.2)

local t = c:save(ROOT .. "out/pl-baob-2-perch.aseprite", ROOT .. "out/pl-baob-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
