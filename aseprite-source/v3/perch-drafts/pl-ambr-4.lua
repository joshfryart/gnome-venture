-- pl-ambr-4-perch.lua : 36x36 perch (cactus-critter pal in a small pot)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-4-perch-20261120-162002/"
local GV = dofile(D .. "gvlib/gvlib.lua")
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#4c2f52", "#2b1c26", "#241a36"
GV.C.halo = "#f8e095"
local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 0 }

local body   = GV.ramp("#3f8a4a")                                            -- green skin
local quill  = GV.ramp("#a2db6a")                                            -- light quills
local face   = GV.ramp("#795d70", { shade = "#4c2f52", deep = "#241a36" })   -- purple mask
local belly  = GV.ramp("#a8a045")                                            -- gold belly
local pot    = GV.ramp("#795d70", { shade = "#4c2f52", deep = "#241a36" })   -- clay pot
local fruit  = GV.ramp("#f8e095")                                            -- pale pear
local leaf   = GV.ramp("#264432", { shade = "#143327", deep = "#143327" })   -- dark leaf/quill tip

local FL = { flat = true, rim = false, gloss = false, contact = false, cres = 2, deep = 2 }
local SH = { cres = 2, deep = 2, gloss = false }
local function small(r) return { flat = true, gloss = false } end

-- quill crest (back), 6 columns
local qm = c:mask()
for i, x in ipairs({ 9, 12, 15, 18, 21, 24 }) do
  local top = ({ 4, 3, 3, 3, 3, 4 })[i]
  qm:add(c:rrect(x, top, x + 1, 11, 1))
end
-- body blob + belly + eye-mask band + pear + leaf(+stem)
local bm = c:ellipse(17.5, 16.2, 8.75, 8.2)
local glm = c:ellipse(18, 20, 5, 3)
local fcm = c:rrect(9, 12, 26, 16, 2):clip(bm)
local pm  = c:rrect(4, 15, 8, 19, 2)
local lm  = c:rrect(5, 13, 7, 14, 0)
-- pot
local rim  = c:rrect(9, 23, 26, 25, 1)
local pb   = c:poly({ { 11, 26 }, { 25, 26 }, { 24, 31 }, { 13, 31 } })
-- accents: sparkle diamond + fallen quill
local sm = c:rrect(29, 4, 31, 6, 1)
local fq = c:line({ { 26, 30 }, { 29, 27 } }, 2)

c:build{
  { "quill", qm,  quill, SH },
  { "body",  bm,  body,  { cres = 2, deep = 2, gloss = { 15, 10 } } },
  { "belly", glm, belly, { cres = 1, deep = 0 } },
  { "face",  fcm, face,  { cres = 1, deep = 0, gloss = false, rim = true } },
  { "fruit", pm,  fruit, { cres = 2, deep = 2 } },
  { "leaf",  lm,  leaf,  small(leaf) },
  { "rim",   rim, pot,   { flat = true, cres = 2, deep = 2, gloss = false } },
  { "pot",   pb,  pot,   { cres = 1, deep = 0 } },
  { "spark", sm,  fruit, { flat = true, cres = 2, deep = 2, gloss = false } },
  { "fq",    fq,  quill, { flat = true, cres = 2, deep = 2, gloss = false } },
}
-- face (eyes + mouth), painted after the band part
c:eye(11, 13, true); c:eye(21, 13, true)
c:px(17, 15, "#241a36"); c:px(18, 15, "#241a36")
-- DETAIL: eye glints, fallen-quill tip
c:px(12, 14, fruit.base); c:px(22, 14, fruit.base)
c:px(26, 30, leaf.deep)
-- TEXTURE: tone-on-tone marks, 1 shade step max
c:px(5, 15, fruit.shade); c:px(6, 15, fruit.shade); c:px(7, 15, fruit.shade)
c:px(21, 19, belly.shade); c:px(15, 20, belly.shade); c:px(17, 21, belly.shade)
c:px(24, 20, body.shade)          -- dither at the body's light/shade border
c:px(12, 28, pot.rim)             -- clay highlight fleck on the pot's lit side
c:px(30, 5, fruit.dot)            -- sparkle core
-- ground contact + hand accents
c:ground(17.5, 31.4, 12, 0.9, "#795d70")

local t = c:save(D .. "out/pl-ambr-4-perch.aseprite", D .. "out/pl-ambr-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 2 and t.w == 36 and t.h == 36)
