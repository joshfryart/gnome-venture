-- pl-chil-5-perch.lua : chef pal on its little wooden perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-chil-5-perch-20261120-173614/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- palette-consistent outline tones (spec palette, dark plum family)
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#5b292e", "#451e33", "#2b1c26"

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1 }

-- ramps (anchor on the spec palette; shade/deep derived, dot never pure white)
local R = {
  cream  = GV.ramp("#f5ecd3", { gloss = "#f8f0d8", dot = "#f8f0d8", rim = "#f8f0d8", shade = "#cbb8b1", deep = "#846363", bounce = "#d3d1d4" }),
  body   = GV.ramp("#a95e43", { gloss = "#e8a878", dot = "#e8a878" }),
  bow    = GV.ramp("#854152", { gloss = "#cbb8b1", dot = "#cbb8b1", rim = "#cbb8b1", shade = "#6d3541", deep = "#451e33" }),
  muzzle = GV.ramp("#d3925e", { shade = "#a95e43", deep = "#a95e43", bounce = "#cbb891" }),
  wood   = GV.ramp("#846363", { shade = "#5b292e", deep = "#451e33" }),
  feet   = GV.ramp("#d3925e"),
  green  = GV.ramp("#72b35a", { shade = "#4a8f4e", deep = "#2f5a2a" }),
  gold   = GV.ramp("#d99a32", { gloss = "#fbe68a", dot = "#fbe68a", rim = "#f0c040" }),
}

local FL = { flat = true } -- silhouettes only (no longer used after block-in)
-- overlay parts sit on the body/other parts: no contour seam
local SH = { contour = false }             -- shaded part, no contour, contact on
local SHn = { contour = false, contact = false }
local GL = { contour = false, contact = false, gloss = false }  -- no auto gloss (hand-placed later)
local function smallo(t) t = {} for k, v in pairs(SH) do t[k] = v end t.cres = 1 return t end

local p = c:build({
  { "slab",  c:rrect(7, 27, 28, 30, 1), R.wood, SH },
  { "pepperL", c:rrect(4, 27, 7, 30, 1), R.green, smallo() },
  { "body",  c:rrect(8, 13, 26, 25, 5), R.body, GL },
  { "bow",   c:rrect(14, 22, 21, 24, 1), R.bow, smallo() },
  { "muzzle", c:rrect(11, 19, 22, 21, 2), R.muzzle, smallo() },
  { "footL", c:rrect(10, 24, 13, 26, 1), R.feet, smallo() },
  { "footR", c:rrect(20, 24, 23, 26, 1), R.feet, smallo() },
  { "sprout", c:rect(27, 13, 29, 16), R.green, smallo() },
  { "puff",  c:mask():ellipse(13, 8.8, 6, 4.2):ellipse(20, 9.2, 5.5, 4.2):rect(9, 9, 24, 12), R.cream, SHn },
  { "band",  c:rrect(9, 12, 25, 13, 1), R.cream, { flat = true, contour = false, contact = true } },
  { "crumb", c:rect(23, 4, 25, 6), R.gold, smallo() },
})

-- TEXTURE: hand-placed, subtle, tone-on-tone, following the form
-- wood grain dashes on the lit top of the plank
for _, gp in ipairs({ { 9, 28 }, { 10, 28 }, { 18, 28 }, { 19, 28 }, { 24, 28 } }) do
  c:px(gp[1], gp[2], R.wood.shade)
end
-- felt pips on the hat puff
c:px(14, 7, R.cream.shade); c:px(19, 10, R.cream.shade)
-- 1px dither on the body crescent border (base tone stepping into shade)
c:px(25, 19, R.body.base); c:px(24, 22, R.body.base); c:px(21, 24, R.body.base)

-- DETAIL: eyes, mouth, glints, gloss
local D2 = "#d3925e"      -- glasses gold (from palette)
local P4 = "#2b1c26"      -- pupil
local GL2 = "#f5ecd3"     -- glint
-- left eye: gold ring, dark pupil, cream glint upper-left
for x = 10, 14 do
  c:px(x, 15, D2); c:px(x, 18, D2)
end
c:px(10, 16, D2); c:px(10, 17, D2); c:px(14, 16, D2); c:px(14, 17, D2)
for x = 11, 13 do c:px(x, 16, P4); c:px(x, 17, P4) end
c:px(11, 16, GL2)
-- gold bridge between the eyes
c:px(15, 16, D2); c:px(16, 16, D2); c:px(17, 16, D2); c:px(18, 16, D2)
-- right eye: wink line with upturned ends
c:px(19, 16, D2); c:px(23, 16, D2)
for x = 19, 23 do c:px(x, 17, D2) end
-- small mouth on the muzzle
for x = 16, 20 do c:px(x, 20, "#451e33") end
-- blush cheeks
c:px(13, 20, "#cbb8b1"); c:px(21, 20, "#cbb8b1")
-- glints + small gloss accents
c:px(24, 5, R.gold.dot or "#fbe68a")           -- crumb centre glint
c:px(27, 14, "#a6c27c")                        -- sprout lit seed
c:px(5, 28, "#a6c27c")                         -- pepper lit top
c:px(11, 6, "#fff3c8"); c:px(12, 6, "#fff3c8") -- felt gloss on hat upper-left

c:ground(17.5, 31.5, 11, 0.8, "#451e33")

local t = c:save(D .. "out/pl-chil-5-perch.aseprite", D .. "out/pl-chil-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
