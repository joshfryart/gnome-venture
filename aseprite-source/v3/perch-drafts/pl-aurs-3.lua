-- pl-aurs-3-perch: chibi perch of the green moss-sprout pal (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurs-3-perch-20261120-164612/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "icon", ol = 1 }

-- body: one chibi ball, x7..26, y8..25
local body = c:ellipse(16.5, 16.5, 9.5, 8.5)

-- gold sprouts: 5 curved nubs fanning from the crown
local sprouts = c:mask()
sprouts:add(c:line({ { 10, 10 }, { 8.5, 7 } }, 3))
sprouts:add(c:rect(7, 5, 9, 6))                       -- left tip nub
sprouts:add(c:line({ { 13, 9 }, { 11.5, 6 } }, 3))
sprouts:add(c:rect(11, 4, 12, 5))
sprouts:add(c:line({ { 16, 9 }, { 16, 6 } }, 3))
sprouts:add(c:rect(15, 4, 17, 5))                     -- centre, tallest
sprouts:add(c:line({ { 20, 9 }, { 21.5, 6 } }, 3))
sprouts:add(c:rect(21, 4, 22, 5))
sprouts:add(c:line({ { 23, 10 }, { 24.5, 7 } }, 3))
sprouts:add(c:rect(24, 5, 26, 6))

-- gold perch pot (small dish), x9..24, y27..31
local pot = c:ellipse(16.5, 29, 7.5, 2)
pot:add(c:rect(9, 28, 24, 29))

-- bead accent beside the pot (from the pal's dangling beads)
local beads = c:mask()
beads:add(c:rect(25, 25, 27, 27))
beads:add(c:rect(26, 28, 28, 30))

local rb, rs, rp = GV.ramp("#a6aa66"), GV.ramp("#eecd63"), GV.ramp("#dcc06f")
local p = c:build{
  { "sprouts", sprouts, rs, { flat = true } },
  { "body",    body,    rb, { gloss = { 12, 11 }, cres = 2, deep = 1 } },
  { "pot",     pot,     rp, { cres = 1, deep = 1, gloss = false } },
  { "beads",   beads,   rs, { flat = true } },
}

-- eyes: 4x4 dark discs, wide on the head
c:fill(c:rect(10, 13, 13, 16), "#2b1c26")
c:fill(c:rect(20, 13, 23, 16), "#2b1c26")
-- tiny mouth: 3px smile arc
c:px(15, 20, "#2b1c26"); c:px(16, 19, "#2b1c26"); c:px(17, 20, "#2b1c26")

-- TEXTURE: tone-on-tone moss speckle on the shade side, dither at the light/shade border
c:px(21, 21, rb.shade); c:px(23, 19, rb.shade); c:px(12, 22, rb.shade)
c:px(22, 22, rb.shade); c:px(19, 23, rb.base); c:px(14, 23, rb.shade)
c:px(24, 17, rb.shade); c:px(11, 21, rb.shade)
c:px(20, 20, rb.shade); c:px(18, 23, rb.base) -- dither along crescent boundary
-- sprout nub variation (1 shade step)
c:px(15, 5, rs.shade); c:px(21, 5, rs.shade); c:px(8, 6, rs.shade)
-- pot weave dashes on the rim + tone break
c:px(12, 28, rp.shade); c:px(16, 28, rp.shade); c:px(20, 29, rp.shade)
c:px(14, 29, rs.rim); c:px(18, 28, rs.rim)

-- DETAIL: eye glints, sprout and pot sparkles
c:px(11, 14, "#f9ebbf"); c:px(21, 14, "#f9ebbf")
c:px(15, 4, "#f9ebbf")                            -- tallest sprout glint
c:px(12, 29, rs.gloss); c:px(28, 25, rs.gloss)    -- pot + bead glints

c:ground(16.5, 29.5, 6, 1, "#423752")
local t = c:save(D .. "out/pl-aurs-3-perch.aseprite", D .. "out/pl-aurs-3-perch.png")
print(GV.report(t))
