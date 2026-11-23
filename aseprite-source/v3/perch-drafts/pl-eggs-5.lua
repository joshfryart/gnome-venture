-- pl-eggs-5 perch: 36x36 chibi pot-lid pal on a small egg-nest base
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-5-perch-20261120-181344/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local pc = app.pixelColor
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0, margin = 3, deep = 2 }

-- pal palette
local steel  = "#9c9295"
local steelD = "#674451"
local face   = "#d5742d"
local moss   = "#4c8d3b"
local cheek  = "#f5a0b8"
local brown  = "#9d6f27"
local nest   = "#b48a70"
local nestD  = "#8a6a58"
local eggG   = "#cdd7e5"
local eye    = "#2b1c26"

-- SHADE phase: gvlib drives crescent/rim/bounce/gloss per part
-- TEXTURE phase: hand-placed subtle marks following the form
local lid   = c:ellipse(17.5, 12, 9.5, 6.5):cut(c:rect(0, 17, 35, 35))  -- hood y5..17
local knob  = c:rect(15.5, 3.5, 18.5, 5.5)                              -- knob y4..6
local bod   = c:ellipse(17.5, 19.5, 7.5, 7.5):cut(c:rect(0, 26, 35, 35))-- face ball y12..26
local mossB = c:ellipse(17.5, 23.5, 7, 3.5):clip(bod)                   -- belly band low
local staff = c:line({ {10.5, 13}, {9.5, 27} }, 2)                      -- wicker stick
local nestM = c:ellipse(17.5, 29.5, 8.5, 2.5)                           -- nest mound
local egg1  = c:ellipse(14.5, 28, 2, 2)
local egg2  = c:ellipse(20.5, 28, 2, 2)
local key   = c:ascii({ "yy", "yy" }, 29, 24)

c:build{
  { "staff", staff, brown, { rim = false, bounce = false, gloss = false, cres = 2 } },
  { "nest",  nestM, GV.ramp("#b48a70", { shade = "#8a6a58", deep = "#5b3a2c", bounce = "#9d6f27" }), { bounce = false, gloss = false } },  { "body",  bod,   face,  { gloss = false } },
  { "moss",  mossB, moss,  { cres = 1, rim = false, bounce = false, gloss = false } },
  { "lid",   lid,   steel, { gloss = { 13, 8 } } },
  { "knob",  knob,  steel, { flat = true, cres = 2 } },
  { "egg1",  egg1,  eggG,  { flat = true, cres = 2 } },
  { "egg2",  egg2,  eggG,  { flat = true, cres = 2 } },
  { "key",   key,   "#cfeaf8", { flat = true, cres = 2 } },
}

-- glow of the key accent: 1px gold under the sparkle (DETAIL)
-- face details (integers only — fractional px coords are dropped)
c:px(15, 18, eye); c:px(16, 18, eye)
c:px(20, 18, eye); c:px(21, 18, eye)
c:px(17, 19, eye)                        -- tiny mouth
c:px(12, 19, cheek); c:px(22, 19, cheek)
-- lid right-side cool dark (the pot-lid's shaded right)
local lidRight = c:mask():add(lid):clip(c:rect(24, 0, 35, 35))
c:fill(lidRight, "#674451")
-- staff lit top
c:px(10, 13, "#b48a70"); c:px(10, 14, "#b48a70")

-- texture: hand-placed, following the form
c:px(13, 6, "#bfb8b8"); c:px(11, 9, "#bfb8b8")        -- lid sheen along lit edge
c:px(23, 11, "#786d72")                                -- lid tone break
c:px(14, 21, "#66b44c"); c:px(17, 21, "#66b44c"); c:px(20, 21, "#66b44c") -- moss lit top
c:px(15, 24, "#1f4928")                                -- moss grain
c:px(13, 30, "#d0c3a0"); c:px(18, 31, "#d0c3a0"); c:px(23, 30, "#d0c3a0") -- nest weave
c:px(14, 28, "#eef2f8")                                -- egg glints
c:px(20, 28, "#eef2f8")

c:ground(17.5, 31.5, 10, 2)

local t = c:save(D .. "out/pl-eggs-5-perch.aseprite", D .. "out/pl-eggs-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
