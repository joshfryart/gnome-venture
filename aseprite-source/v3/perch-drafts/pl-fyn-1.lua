-- pl-fyn-1-perch: chibi perch sprite, 36x36. Phase: TEXTURE
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-fyn-1-perch-20261120-185156/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0 }

local bodyR  = { gloss = "#efb896", dot = "#f8d4b8", rim = "#d58e68", base = "#c16341",
                 shade = "#823432", deep = "#631a27", bounce = "#a04a35" }
local stoneR = { gloss = "#c9c5bc", dot = "#e6e3dc", rim = "#8b95a2", base = "#7a8a9a",
                 shade = "#4a5a6a", deep = "#2e3a4a", bounce = "#5a5064" }
local poleR  = { rim = "#b08055", base = "#9a6a45", shade = "#6a4530", deep = "#4a2e1e" }
local flagR  = { rim = "#a37f95", base = "#815c7f", shade = "#5a4470", deep = "#4a3a68" }
local flameR = { gloss = "#fff0a0", dot = "#fff6d0", rim = "#fcda68", base = "#f0b83c",
                 shade = "#d0b56f", deep = "#e8502a", bounce = "#e89830" }

-- flame crown: 3 licks, x11..24, y3..11 (right lick chunky, dark notch cleared)
local flameRows = {
  "......XX......",
  ".....XXXX.....",
  ".....XXXXX.XXX",
  "...XXXXXXX.XXX",
  ".XXXXXXXXXXXX.",
  "XXXXXXXXXXXXXX",
  ".XXXXXXXXXXXX.",
  "...XXXXXXXXXX.",
  ".....XXXXXXXX.",
}

local p = c:build{
  { "mound", c:ellipse(17.5, 27, 10.5, 3), stoneR, { gloss = false, light = c:ellipse(17.5, 27, 11.5, 3.5) } },
  { "pole",  c:rect(8, 15, 9, 26), poleR, { flat = true, gloss = false } },
  { "body",  c:ellipse(17.5, 15.5, 8, 8), bodyR, { gloss = { 15, 12 } } },
  { "flame", c:ascii(flameRows, 11, 3), flameR, { gloss = false, deep = 0 } },
  { "flag",  c:poly({ { 8, 11 }, { 4, 14 }, { 8, 17 } }), flagR, { flat = true, gloss = false } },
}

-- face
c:eye(13, 14, true)
c:eye(20, 14, true)
c:px(14, 15, "#fff4d6")            -- pupil glint, upper-left
c:px(21, 15, "#fff4d6")
c:fill(c:rect(17, 19, 18, 19), "#631a27")

-- flame: pale core + inner orange marks
c:fill(c:rect(16, 9, 17, 10), "#fff0a0")
c:px(15, 10, "#f0b83c")
c:px(19, 10, "#e8502a")
c:px(14, 8, "#e8502a")
c:px(17, 5, "#fff6d0")             -- glint at the crown tip

-- TEXTURE ---------------------------------------------------------------
-- mound: stone joints, tone-on-tone (1 step), following the curve
c:px(12, 26, "#6a7484"); c:px(13, 27, "#4a5a6a")  -- joint between left stones
c:px(17, 26, "#6a7484"); c:px(18, 27, "#4a5a6a")  -- centre joint
c:px(23, 26, "#6a7484")                            -- right joint
c:px(10, 28, "#5a5064"); c:px(15, 29, "#5a5064"); c:px(21, 29, "#5a5064")  -- underside chips
-- body: 1px dither at the light/shade border (base into shade, lower half)
c:px(15, 20, "#c16341"); c:px(19, 20, "#c16341"); c:px(14, 18, "#c16341")
-- body: subtle tone-on-tone skin pits on the lit side
c:px(12, 13, "#b25838"); c:px(22, 12, "#b25838")
-- pole: wood grain
c:px(9, 17, "#6a4530"); c:px(9, 21, "#6a4530")
-- flag: fabric weave hint (1px shade on lower right)
c:px(6, 14, "#6a5584")
-- ground: edge wear on the mound rim, lit side
c:px(11, 25, "#8b95a2")
-- body: small gold bean marking taken from the pal's pot
c:fill(c:rect(22, 16, 23, 16), "#d0b56f"); c:px(22, 17, "#b88a2e")

-- CRITIQUE fixes ---------------------------------------------------------
-- soften the ground strip: ends taper, a few darker grain px
c:px(10, 32, "#7a4a1f"); c:px(16, 31, "#7a4a1f"); c:px(24, 32, "#7a4a1f")
-- mound: dither inside the deep edge (lower right)
c:px(23, 28, "#7a8a9a"); c:px(25, 27, "#5a5064")

c:ground(17.5, 31.5, 9, 1)
local t = c:save(D .. "out/pl-fyn-1-perch.aseprite", D .. "out/pl-fyn-1-perch.png")
print(GV.report(t))
