-- pl-baob-5-perch.lua : chibi baobab pal on a small wooden perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-5-perch-20261120-170047/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

local headR  = GV.ramp("#978574")
local flameR = GV.R.flame
local bandR  = GV.ramp("#48457f")
local footR  = GV.R.skin
local seatR  = GV.ramp("#b4a88c")            -- warm greige stone stool
local leafR  = GV.R.moss
local goldR  = GV.R.gold

-- masks (core art inside y5..29, x5..29) ---------------------------------
local head = c:ellipse(17.5, 16, 8.5, 6)
local bandM = c:rrect(9, 19, 26, 21, 2):clip(head)

local toes = c:mask()
toes:add(c:ellipse(13.5, 23.5, 1.5, 1))
toes:add(c:ellipse(21.5, 23.5, 1.5, 1))

local plinth = c:rrect(10, 23, 26, 29, 2)

local flame = c:ascii({
  "........XX.......",
  ".......XXXX......",
  "....XXXXXXXX.....",
  "...XXXXXXXXXX....",
  "XXXXXXXXXXXXXXXX",
  ".XXXXXXXXXXXXXX.",
  "..XXXXXXXXXXXX..",
  "...XXXXXXXXXX...",
}, 10, 5)

local leaf = c:ascii({
  "GGG..",
  "GGGGG",
  ".GGG.",
  "..s..",
}, 5, 14, "Gs")

local charm = c:mask()
charm:add(c:ellipse(26, 7, 0.8, 0.8))
charm:add(c:ellipse(27.5, 10.5, 2, 1.8))

-- shaded parts, back to front ---------------------------------------------
c:build{
  { "plinth", plinth,    seatR,  { cres = 2, gloss = { 12, 24 }, contact = false } },
  { "head",   head,      headR,  { gloss = { 12, 12 }, cres = 3, contact = true } },
  { "band",   bandM,     bandR,  { flat = true, contact = true } },
  { "toes",   toes,      footR,  { flat = true, contact = false } },
  { "flame",  flame,     flameR, { gloss = { 14, 7 }, cres = 2, deep = 1, contact = true } },
  { "leaf",   leaf,      leafR,  { flat = true, rim = false, solid = false, contact = false } },
  { "charm",  charm,     goldR,  { flat = true, rim = false, solid = false, contact = false } },
}

-- gold seed dots on the band
local seeds = c:mask()
seeds:add(c:ellipse(14, 20, 1, 0.6))
seeds:add(c:ellipse(18.5, 19.5, 1.2, 0.7))
seeds:add(c:ellipse(23, 20, 1, 0.6))
c:fill(seeds, goldR.rim)
c:px(14, 19, goldR.gloss) c:px(18, 19, goldR.gloss) c:px(23, 19, goldR.gloss)

-- flame inner streaks
local streak = c:mask()
streak:add(c:ascii({ "EE", "EEE", "EE" }, 17, 6, "E"))
streak:add(c:ascii({ "E" }, 15, 9, "E"))
c:fill(streak, GV.R.gold.base)
c:px(17, 7, GV.R.gold.rim)

-- trunk bark dabs on the shade side
c:px(23, 15, headR.shade) c:px(24, 17, headR.shade)
c:px(22, 18, headR.shade) c:px(8, 19, headR.shade)
c:px(12, 13, headR.gloss) c:px(11, 16, headR.rim)

-- seat wood grain
c:fill(c:ascii({ "dd", " d", "d " }, 12, 26, "d"), seatR.shade)
c:fill(c:ascii({ "dd" }, 20, 27, "d"), seatR.shade)

-- dither on band top edge
c:px(16, 19, bandR.shade) c:px(21, 19, bandR.shade)

-- face
c:eye(12, 12, true)
c:eye(20, 12, true)
c:px(10, 15, "#f5a0b8") c:px(11, 15, "#f5a0b8")   -- left cheek
c:px(23, 15, "#f5a0b8") c:px(24, 15, "#f5a0b8")   -- right cheek
c:px(16, 16, "#4f2c2f") c:px(17, 16, "#4f2c2f")   -- tiny mouth

-- glints
c:px(6, 15, leafR.gloss)
c:px(26, 13, goldR.gloss) c:px(27, 13, goldR.rim)
c:px(26, 7, goldR.rim)

c:ground(18, 30, 12, 1.5, "#715863")

local t = c:save(D .. "out/pl-baob-5-perch.aseprite", D .. "out/pl-baob-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2, "check fail")
