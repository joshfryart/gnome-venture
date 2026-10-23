-- Guardian of Dragonlizard Den (boss, island lair): a huge Komodo-style monitor lizard,
-- three-quarter view facing left, sprawled on four heavy legs on top of a rocky den mouth
-- (dark cave arch), heavy tail slung down over the rock, palm hint behind. Rough olive-brown
-- hide with diamond scale marks, bony dorsal scutes, forked tongue, stitched brow scar.
-- Families: soil tinted toward moss (hide), soil pale (throat), stone (den rock), leaf + wood (palm).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-sea-3-lair-dragonlizard-den"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local hide  = GV.ramp("#948447")   -- olive-brown: soil base pulled toward moss
local hideD = GV.ramp("#6a5f36")   -- far legs
local throat = GV.ramp("#c9a96e")  -- soil pale
local bone  = GV.ramp("#c9c5bc")   -- stone pale (dorsal scutes)
local rock  = GV.ramp("#8b8f96")   -- stone
local cave  = GV.ramp("#3d2a1c")   -- soil dark (den mouth)

-- den rock and cave mouth
local rockM = c:poly({ {7,56}, {8,50}, {13,47}, {24,46}, {34,45}, {46,46}, {52,47}, {56,51}, {56,56} })
local caveM = c:ellipse(37, 56, 7, 6):clip(rockM)

-- palm hint behind, top right
local trunk = c:line({ {50,46}, {51,38}, {50,30}, {48,22}, {47,16} }, 3)
local fronds = c:line({ {47,14}, {43,11}, {40,13} }, 3)
fronds:add(c:line({ {48,14}, {52,10}, {55,13}, {55,17} }, 3))
fronds:add(c:line({ {47,13}, {46,9}, {43,7} }, 2))

-- heavy tail slung down over the right of the rock, tapering
local tail = c:line({ {44,36}, {49,39} }, 7)
tail:add(c:line({ {49,39}, {52,43}, {53,47} }, 5))
tail:add(c:line({ {53,47}, {52,51}, {49,53} }, 3))

-- legs: far pair dark, near pair hide; sprawled, clawed
local legFF = c:poly({ {27,36}, {32,37}, {32,45}, {27,47}, {25,45} })
local legFB = c:poly({ {43,38}, {48,40}, {49,47}, {44,47} })
local body = c:ellipse(37, 35, 11, 7.5)
local legNB = c:poly({ {36,39}, {43,40}, {42,44}, {44,48}, {35,48}, {37,44} })
local legNF = c:poly({ {19,33}, {27,35}, {25,41}, {27,48}, {16,48}, {19,42} })

-- bony dorsal scutes along neck and spine
local scutes = c:mask()
for _, s in ipairs({ {30,23}, {34,25}, {38,26}, {43,28} }) do
  scutes:add(c:poly({ {s[1]-2, s[2]+4}, {s[1]+1, s[2]-1}, {s[1]+3, s[2]+4} }))
end

-- big long head, facing left
local head = c:ellipse(24, 20, 9, 7)
head:add(c:ellipse(16, 23, 5.5, 4))
head:add(c:poly({ {27,24}, {34,26}, {36,34}, {26,34}, {22,28} }))  -- thick neck
local jaw = c:ellipse(20, 28.5, 8, 2.5):clip(head)

-- forked tongue flicking out of the snout tip
local tongue = c:ascii({ "t....", ".tttt", ".tttt", "t...." }, 6, 23)

local p = c:build{
  { "trunk", trunk, "wood", { gloss = false } },
  { "fronds", fronds, "leaf", { gloss = false } },
  { "rock", rockM, rock },
  { "cave", caveM, cave, { gloss = false, rim = false } },
  { "scutes", scutes, bone, { gloss = false } },
  { "tail", tail, hide, { light = body:copy():add(tail) } },
  { "legFF", legFF, hideD, { gloss = false } },
  { "legFB", legFB, hideD, { gloss = false } },
  { "body", body, hide, { stitch = { side = "lit" } } },
  { "legNB", legNB, hide, { gloss = false } },
  { "legNF", legNF, hide, { gloss = false } },
  { "head", head, hide },
  { "jaw", jaw, throat, { gloss = false, contact = false } },
  { "tongue", tongue, "#d9667f", { flat = true } },
}

-- rough hide: diamond scale marks
local function dia(x, y) c:spot(c:poly({ {x,y-2}, {x+2,y}, {x,y+2}, {x-2,y} }), "#4e4228", "#857846") end
dia(35, 33); dia(41, 33); dia(38, 38); dia(44, 38); dia(30, 30)

-- eye with heavy brow ridge, stitched scar behind it
c:eye(20, 16)
c:paint({ "bb.....", ".bbbbbb" }, 18, 13, { b = "#2a1a10" })
c:seam({ {27, 13}, {29, 18}, {29, 22} })
c:button(30, 30)

-- nostril, long mouth line with teeth
c:px(12, 21, "#2a1a10")
c:paint({ "mmmmmmmmmmmmmm" }, 11, 26, { m = "#4a2c1a" })
c:paint({ "f..f..f" }, 14, 27, { f = "#f2e4c0" })

-- claws
for _, q in ipairs({ {16,48}, {19,48}, {22,48}, {35,48}, {38,48} }) do c:px(q[1], q[2], "#f2e4c0") end

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
