-- pl-baob-3-perch.lua : 36x36 perch — chibi baob-buddy with purple beanie on a soil mound
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-3-perch-20261120-165315/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local PHASE = 7 -- current phase: critique fixes

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1 }

-- ramps (from the pal's palette)
local tan    = { base = "#e5a660", gloss = "#f0d3ac", dot = "#f6e4c8", rim = "#f0d3ac",
                 shade = "#cb782c", deep = "#8b3a21", bounce = "#ecb985" }  -- pal's browns
local purple = GV.ramp("#8b4bc3", { gloss = "#ad7fca", rim = "#ad7fca" })
local lilac  = { base = "#ad7fca", gloss = "#e0ccf6", dot = "#e9dcf8", rim = "#c8b2e6",
                 shade = "#8b4bc3", deep = "#582369", bounce = "#9d6fd1" }  -- pal's flag/brim face
local soil   = GV.ramp("soil")                                              -- mound (soil family)
local brown  = GV.ramp("#8a6a58")                                           -- feet
local wood   = GV.ramp("wood")
local leafR  = { base = "#8fd05a", rim = "#c8f08a", gloss = "#c8f08a", dot = "#c8f08a",
                 shade = "#5fae4a", deep = "#3f8a4a", bounce = "#5fae4a" }
local creamR = { base = "#f5e7ba", rim = "#fff6e0", gloss = "#fff6e0", dot = "#fff6e0",
                 shade = "#e9cc8e", deep = "#c9a96e", bounce = "#e9cc8e" }  -- pal's mitten hand

-- masks
local poleM  = c:rect(25, 5, 26, 28)
local penM   = c:poly({ { 27, 5 }, { 30.8, 8 }, { 27, 11 } })
local moundM = c:ellipse(17.5, 28, 10.5, 2.8)
local footLM = c:rrect(10, 23, 12, 26, 1)
local footRM = c:rrect(19, 23, 21, 26, 1)
local ballM  = c:ellipse(15.5, 17, 9.5, 7.5)
local leafM  = c:ellipse(5, 16, 2, 1.3)
local handM  = c:rrect(6, 17, 8, 19, 1)
local domeM  = c:ellipse(15.5, 11, 10, 6):cut(c:rect(0, 12, 35, 35))
local brimM  = c:rrect(6, 11, 25, 13, 1)
local pomM   = c:ellipse(15.5, 4.5, 2.5, 1)

local p = c:build({
  { "pole",   poleM,  wood,  { flat = true } },
  { "pen",    penM,   lilac,  { cres = 1, deep = 0 } },
  { "mound",  moundM, soil,   { deep = 1 } },
  { "footL",  footLM, brown,  { cres = 1, deep = 0, bounce = false } },
  { "footR",  footRM, brown,  { cres = 1, deep = 0, bounce = false } },
  { "ball",   ballM,  tan,    { gloss = false } },
  { "hand",   handM,  creamR, { flat = true, cres = 1, deep = 0 } },
  { "leaf",   leafM,  leafR,  { cres = 1, deep = 0 } },
  { "dome",   domeM,  lilac,  { cres = 2, gloss = false } },
  { "brim",   brimM,  lilac,  { flat = true, rim = false, gloss = false, contact = false } },
  { "pom",    pomM,   purple, { cres = 1, deep = 0, gloss = false } },
})
-- the pal's 3-tone beanie band: light at the top, dark at the chin edge
for x = 7, 24 do
  c:px(x, 11, "#d7b3e6"); c:px(x, 12, "#ad7fca"); c:px(x, 13, "#8b4bc3")
end
c:px(7, 20, "#f5cf6a"); c:px(8, 20, "#e8a317")       -- gold cuff under the mitten hand

c:ground(17.5, 30.8, 10.5, 1.6, "#6e5e8e")

-- face
c:eye(10, 16, true)                                  -- sparkle eye, 3x3 cream + 2x2 pupil
c:px(18, 15, "#2b1c26"); c:px(19, 16, "#2b1c26"); c:px(18, 17, "#2b1c26") -- wink >
c:fill(c:rrect(14, 19, 18, 21, 1), "#f2e0a6")        -- cream muzzle patch
c:px(16, 19, "#5e1118"); c:px(15, 20, "#5e1118"); c:px(16, 20, "#5e1118") -- open smile
c:px(17, 20, "#5e1118")
c:px(8, 19, "#f5a0b8"); c:px(9, 19, "#f5a0b8")       -- pink cheek

-- texture: hand-placed, 1 shade step from base, following the form
-- soil mound: pebble joints + worn upper-left edge
for _, q in ipairs({ { 11, 27 }, { 15, 29 }, { 20, 28 }, { 24, 30 }, { 17, 30 } }) do
  c:px(q[1], q[2], soil.shade)
end
c:px(10, 28, soil.rim); c:px(9, 27, soil.rim)

-- body: soft knit flecks on the lit half, only on base pixels
for _, q in ipairs({ { 9, 14 }, { 13, 15 }, { 20, 13 }, { 22, 15 }, { 11, 18 }, { 13, 21 }, { 10, 16 } }) do
  if c:get(q[1], q[2]) == tan.base then c:px(q[1], q[2], "#e9b96e") end
end
-- 1px dither where ball light meets its shade crescent
c:px(17, 17, "#f0d3ac"); c:px(19, 19, "#cb782c")

-- leaf vein
c:px(5, 16, "#3f8a4a"); c:px(6, 16, "#5fae4a")

-- beanie knit: two short dark dash marks on the dome shade half
c:px(20, 8, "#683399"); c:px(22, 9, "#683399"); c:px(21, 7, "#683399")

-- detail: glints + dome gloss comma
c:px(9, 6, "#e0ccf6"); c:px(10, 6, "#e0ccf6"); c:px(9, 7, "#e0ccf6") -- dome gloss comma
c:px(14, 4, "#f6e4c8")                               -- pom cream glint
c:px(14, 3, "#e0ccf6")                               -- pom top lift
c:px(28, 6, "#e0ccf6")                               -- pennant face glint
c:px(21, 8, "#9d6fd1"); c:px(23, 9, "#9d6fd1")       -- dither on dome terminator
c:px(21, 10, "#8b4bc3")

local t = c:save(D .. "out/pl-baob-3-perch.aseprite", D .. "out/pl-baob-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw <= 2 and t.margin >= 1)
