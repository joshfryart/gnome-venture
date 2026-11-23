-- pl-ana-3-perch.lua : 36x36 perch of the moss-garden critter (chibi of pal.png)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ana-3-perch-20261120-162804/"
local GV = dofile(D .. "gvlib/gvlib.lua")
-- plum selective outline + family cream/pink instead of the brown toy defaults
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#4a3a44", "#361116", "#2b1c26"
GV.C.halo = "#fff4d6"

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 3, deep = 2 }

local body  = GV.ramp("#5ab288", { gloss = "#c2e2ad", dot = "#e9f6de", rim = "#87c6b4", shade = "#418870", deep = "#27595e", bounce = "#5a8f78" })
local leaf  = GV.ramp("#56c772", { gloss = "#a8e488", rim = "#7ed276", shade = "#36a363", deep = "#27595e", bounce = "#36a363" })
local moss  = GV.ramp("#8fa460", { gloss = "#c2e2ad", rim = "#b7b682", shade = "#5f7a34", deep = "#43562a", bounce = "#6a7a3c" })
local stone = GV.ramp("#6d566c", { gloss = "#a094ab", rim = "#8a7e96", shade = "#5a5060", deep = "#3a2f3e", bounce = "#6d6275" })

local P = c:build{
  -- perch slab + moss cap (small, suited to a garden critter)
  { "slab", c:rrect(5, 26, 29, 31, 2), stone, { gloss = { 8, 27 }, cres = 2, deep = 1, bounce = false } },
  { "moss", c:ellipse(17, 26, 9, 2), moss, { gloss = false, cres = 2, deep = 1 } },
  -- critter: one round head-body blob, bottom sits on the moss
  { "body", c:ellipse(17.5, 15.5, 10, 8), body, { gloss = { 13, 10 } } },
  -- belly leaf marking (small: flat with rim)
  { "belly", c:ellipse(20.5, 21, 3, 2), leaf, { flat = true, contour = false } },
  -- crown leaves, bases sunk into the head
  { "leafL", c:ellipse(13, 7, 3, 2.5), leaf, { gloss = { 11, 6 } } },
  { "leafC", c:ellipse(17.5, 6, 3, 2.5), leaf, { gloss = { 17, 5 } } },
  { "leafR", c:ellipse(22, 7, 2.5, 2), leaf, { flat = true } },
  -- accent: pink flower on a stalk, lower right on the slab
  { "stem", c:line({ { 28.5, 22.5 }, { 28.5, 25.5 } }, 2), GV.ramp("#8fa460"), { flat = true } },
  { "bloom", c:ellipse(28, 20.5, 2, 2), GV.R.petal, { flat = true } },
}

-- ---- texture: hand-placed, subtle, follows the form --------------------------
-- 1px dither just inside the body's light/shade crescent border (upper-left side of the ring)
local b = P.body.m
for k in pairs(b.s) do
  local x, y = c:xy(k)
  if c:get(x, y) == body.base and b:has(x + 3, y + 3) and not b:has(x + 4, y + 4)
     and (x + y) % 2 == 0 and (x - 17.5) + (y - 15.5) > 0 then
    c:px(x, y, body.shade)
  end
end
-- leaf veins (1px tone-on-tone, along the leaf)
c:px(17, 6, leaf.shade); c:px(17, 7, leaf.shade); c:px(13, 7, leaf.shade)
-- stone joints on the slab face (lit band)
c:px(6, 28, stone.deep); c:px(27, 28, stone.deep)
-- moss tuft tips
c:px(10, 25, moss.rim); c:px(24, 25, moss.rim); c:px(21, 26, moss.rim)

-- ---- detail: face and small accents --------------------------------------------
c:eye(11, 13, true); c:eye(20, 13, true)          -- cream 3x3, 2x2 pupil
c:px(15, 17, GV.C.ol3); c:px(16, 18, GV.C.ol3); c:px(17, 17, GV.C.ol3) -- tiny smile
c:px(9, 16, "#f5809f"); c:px(10, 16, "#f5809f")   -- cheeks
c:px(23, 16, "#f5809f"); c:px(24, 16, "#f5809f")
c:px(27, 19, GV.ramp("petal").gloss)              -- bloom glint

c:ground(17, 32, 11, 1, "#514153")
local t = c:save(D .. "out/pl-ana-3-perch.aseprite", D .. "out/pl-ana-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
