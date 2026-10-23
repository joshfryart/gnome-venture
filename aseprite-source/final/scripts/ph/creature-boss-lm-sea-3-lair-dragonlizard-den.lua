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

local hide  = GV.ramp("#857846")   -- olive-brown: soil base pulled toward moss
local hideD = GV.ramp("#5e5532")   -- far legs, scutes
local throat = GV.ramp("#c9a96e")  -- soil pale
local rock  = GV.ramp("#8b8f96")   -- stone
local cave  = GV.ramp("#3d2a1c")   -- soil dark (den mouth)

-- den rock and cave mouth
local rockM = c:poly({ {6,56}, {8,50}, {13,46}, {24,45}, {34,44}, {46,45}, {53,46}, {57,50}, {57,56} })
local caveM = c:ellipse(40, 56, 7, 6):clip(rockM)

-- palm hint behind, top right
local trunk = c:line({ {51,45}, {52,37}, {51,29}, {49,21}, {48,16} }, 3)
local fronds = c:line({ {48,14}, {43,11}, {38,12}, {35,15} }, 3)
fronds:add(c:line({ {49,14}, {53,10}, {56,12}, {57,16} }, 3))
fronds:add(c:line({ {48,13}, {46,9}, {42,7} }, 2))
fronds:add(c:line({ {49,15}, {52,18}, {53,21} }, 2))

-- heavy tail slung over the right of the rock, tapering
local tail = c:line({ {42,36}, {48,38} }, 7)
tail:add(c:line({ {48,38}, {52,41}, {54,45} }, 5))
tail:add(c:line({ {54,45}, {54,49}, {52,52} }, 3))

-- legs: far pair dark, near pair hide; sprawled with clawed feet
local legFF = c:poly({ {25,38}, {31,38}, {30,46}, {24,47}, {23,44} })
local legFB = c:poly({ {41,38}, {47,39}, {48,46}, {43,47} })
local body = c:ellipse(33.5, 36, 13, 7.5)
local legNB = c:poly({ {34,39}, {41,40}, {40,46}, {42,49}, {34,49}, {35,45} })
local legNF = c:poly({ {16,36}, {23,37}, {22,43}, {24,48}, {14,48}, {16,44} })

-- bony dorsal scutes along the spine
local scutes = c:mask()
for _, s in ipairs({ {27,29}, {32,27}, {37,27}, {42,29} }) do
  scutes:add(c:poly({ {s[1]-2, s[2]+3}, {s[1], s[2]-2}, {s[1]+3, s[2]+3} }))
end

-- big head, three-quarter facing left, long snout
local head = c:ellipse(24, 25, 10, 8.5)
head:add(c:ellipse(15, 28, 6, 4.5))
head:add(c:poly({ {28,28}, {34,30}, {32,36}, {26,34} }))  -- thick neck
local jaw = c:ellipse(20, 33, 9, 2.5):clip(head)

-- forked tongue flicking out
local tongue = c:ascii({ "t...", ".ttt", ".ttt", "t..." }, 6, 28)

local p = c:build{
  { "trunk", trunk, "wood", { gloss = false } },
  { "fronds", fronds, "leaf", { gloss = false } },
  { "rock", rockM, rock },
  { "cave", caveM, cave, { gloss = false, rim = false } },
  { "tail", tail, hide, { light = body:copy():add(tail) } },
  { "legFF", legFF, hideD, { gloss = false } },
  { "legFB", legFB, hideD, { gloss = false } },
  { "scutes", scutes, hideD, { gloss = false } },
  { "body", body, hide, { stitch = { side = "lit" } } },
  { "legNB", legNB, hide, { gloss = false } },
  { "legNF", legNF, hide, { gloss = false } },
  { "head", head, hide },
  { "jaw", jaw, throat, { gloss = false, contact = false } },
  { "tongue", tongue, "#d9667f", { flat = true } },
}

-- rough hide: diamond scale marks
local function dia(x, y) c:spot(c:poly({ {x,y-2}, {x+2,y}, {x,y+2}, {x-2,y} }), "#4e4228", "#857846") end
dia(30, 34); dia(36, 33); dia(42, 35); dia(33, 39); dia(39, 39); dia(47, 39)

-- eyes with heavy brow ridges
c:eye(16, 21); c:eye(26, 20)
c:paint({ "bbb...", "..bbbb" }, 15, 18, { b = "#2a1a10" })
c:paint({ "...bbb", "bbbb.." }, 25, 17, { b = "#2a1a10" })

-- stitched scar across the brow, button where the neck meets the shoulder
c:seam({ {21, 16}, {24, 22}, {26, 26} })
c:button(29, 30)

-- nostril, mouth line
c:px(11, 27, "#2a1a10")
c:paint({ "mmmmmm" }, 10, 31, { m = "#4a2c1a" })

-- claws
for _, q in ipairs({ {14,48}, {17,48}, {20,48}, {35,49}, {38,49} }) do c:px(q[1], q[2], "#f2e4c0") end

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
