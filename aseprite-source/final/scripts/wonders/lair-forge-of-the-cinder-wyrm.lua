-- lair-forge-of-the-cinder-wyrm.lua : boss lair, SE (South Europe), a lava lizard in an old volcano forge. Cutaway cavern, glowing.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-forge-of-the-cinder-wyrm"

-- cavern back wall in warm brown-red bands
c:bands(c:rect(0, 0, W - 1, H - 1), { "#3a1e2a", "#48242e", "#582c34", "#683638", "#784240", "#8a5048" }, { dir = "v" })
-- brick-ish courses on the wall (stitched-felt vibe: dashes)
for y = 14, 96, 9 do for x = (y % 18 == 0) and 4 or 14, W, 22 do c:fill(c:rect(x, y, x + 8, y), "#6a3a3c") end end
-- arched window to the outside: dusk sky with smoke and a crater rim
local win = c:ellipse(120, 38, 26, 30):clip(c:rect(0, 8, W, 50)); win:add(c:rect(94, 38, 146, 62))
c:fill(win, "#2a1e48")
local inner = win:copy()
c:fill(inner:copy():clip(c:rect(0, 0, W, 30)), "#3e2f66")
c:fill(inner:copy():clip(c:rect(0, 30, W, 44)), "#8c4a78")
c:fill(inner:copy():clip(c:rect(0, 44, W, 54)), "#e0501f")
c:fill(c:poly({ {94,62},{94,52},{106,44},{116,40},{124,40},{134,44},{146,52},{146,62} }):clip(win), "#3a1e2a")
c:fill(c:poly({ {112,41},{116,38},{124,38},{128,41} }), "#f08a24")
-- smoke puffs rising from the crater
for _, p in ipairs({ {120,30,5},{126,22,6},{116,14,7} }) do
  c:fill(c:ellipse(p[1], p[2], p[3], p[3]):clip(win), "#6a4a8a"); c:fill(c:ellipse(p[1] - 1, p[2] - 1, p[3] - 2, p[3] - 2):clip(win), "#8a6aa8")
end
for _, p in ipairs({ {104,14},{134,12},{140,26},{100,24} }) do c:px(p[1], p[2], "#fbe0a8") end
-- arch stones around the window
c:seam({ {94,38},{97,26},{104,16},{114,10},{126,10},{136,16},{143,26},{146,38} }, { free = true, on = 3, off = 0, gap = "#2a1a10" })

-- rock walls left and right (framing)
local lw = c:poly({ {0,0},{30,0},{36,18},{26,34},{34,52},{22,72},{28,96},{0,100} })
c:part(lw, GV.ramp("#5a3a3c"), { cres = 6, deep = 10, gloss = false })
local rw = c:poly({ {W,0},{206,0},{200,16},{212,34},{204,54},{216,74},{210,96},{W,100} })
c:part(rw, GV.ramp("#5a3a3c"), { cres = 6, deep = 10, gloss = false })
-- stalactites
for _, s in ipairs({ {50,3},{70,3},{170,3},{190,3} }) do
  c:part(c:poly({ {s[1]-5,3},{s[1],14 + (s[1] % 7)},{s[1]+5,3} }), GV.ramp("#5a3a3c"), { cres = 3, deep = 5, gloss = false })
end

-- lava river in the foreground
c:bands(c:rect(0, 112, W - 1, H - 1), { "#f5b840", "#f08a24", "#e0501f", "#d6322b", "#ae2a2a" }, { dir = "v" })
for i = 0, 18 do local x = (i * 47 + 5) % W; local y = 114 + (i * 11) % 18; c:fill(c:rect(x, y, x + 5 + i % 4, y), "#fbe0a8") end
-- stone platform
local plat = c:poly({ {14,114},{22,102},{50,98},{190,98},{218,102},{226,114} })
c:part(plat, GV.ramp("#6a5a5e"), { cres = 5, deep = 8, gloss = false })
c:seam({ {40,106},{60,104},{80,108} }, { free = true, on = 3, off = 0, gap = "#2a1a10" })
c:seam({ {150,106},{168,103},{184,108} }, { free = true, on = 3, off = 0, gap = "#2a1a10" })
c:fill(c:rect(24, 101, 210, 101), "#8a7a7a")

-- anvil and tools at the right
c:part(c:rect(210, 96, 222, 100), GV.ramp("#5b6470"), { cres = 2, deep = 3, gloss = false })
c:part(c:poly({ {204,86},{232,86},{224,92},{218,94},{214,94},{208,92} }), GV.ramp("#8b8f96"), { cres = 3, deep = 5 })
c:part(c:rect(215, 88, 218, 78), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
c:part(c:rect(211, 76, 222, 80), GV.ramp("#5b6470"), { cres = 2, deep = 3, gloss = false })
-- sparks
for _, p in ipairs({ {208,80},{226,82},{200,74},{230,72} }) do c:px(p[1], p[2], "#fbe0a8"); c:px(p[1] + 1, p[2] - 1, "#f08a24") end

-- the Cinder Wyrm (a lava lizard), facing right
local BX, BY = 118, 86
local scale = GV.ramp("#d6322b", { gloss = "#ff9158", rim = "#f2793a", shade = "#ae2a2a", deep = "#6b1b2c" })
-- tail curling away left and up
c:part(c:line({ {96,92},{72,100},{52,96},{40,84},{42,70} }, 7), scale, { cres = 3, deep = 5, gloss = false })
c:fill(c:poly({ {38,72},{42,62},{46,72} }), "#f08a24")   -- flame tail tip
c:fill(c:poly({ {40,70},{42,64},{44,70} }), "#fbe0a8")
-- spines
for i = 0, 6 do
  local x = 90 + i * 10
  c:part(c:poly({ {x - 3, BY - 12}, {x, BY - 24 + (i % 2) * 3}, {x + 3, BY - 12} }), GV.ramp("#f08a24"), { flat = true, gloss = false })
end
-- body
c:part(c:ellipse(BX, BY, 36, 18), scale, { cres = 7, deep = 11 })
-- glowing belly band and ember spots
c:part(c:ellipse(BX, BY + 11, 28, 7):clip(c:rect(0, BY + 6, W, BY + 20)), GV.ramp("#f5b840", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false, contour = "#6b1b2c" })
for _, p in ipairs({ {-22,-6},{-10,-10},{4,-8},{16,-10},{26,-4},{-16,0},{0,0},{12,2} }) do
  c:fill(c:rect(BX + p[1], BY + p[2], BX + p[1] + 2, BY + p[2] + 1), "#f5b840"); c:px(BX + p[1] + 1, BY + p[2], "#fff1c8")
end
-- legs (over the body)
c:part(c:ellipse(92, 98, 9, 7), scale, { cres = 3, deep = 5, gloss = false }); c:part(c:ellipse(150, 98, 8, 7), scale, { cres = 3, deep = 5, gloss = false })
for _, x in ipairs({ 86, 91, 96, 144, 149, 154 }) do c:fill(c:rect(x, 103, x + 1, 104), "#fbe0a8") end
-- head, snout, horns
c:part(c:poly({ {160,68},{158,56},{166,66} }), GV.ramp("#f08a24"), { flat = true, gloss = false })
c:part(c:poly({ {172,66},{176,54},{180,68} }), GV.ramp("#f08a24"), { flat = true, gloss = false })
c:part(c:ellipse(168, 80, 16, 14), scale, { cres = 5, deep = 8 })
c:part(c:ellipse(184, 86, 12, 8), scale, { cres = 3, deep = 5, gloss = false })
-- mouth line with a few tiny teeth, nostrils
for x = 176, 194 do c:px(x, 91 + (x > 190 and 1 or 0), "#2a1a10") end
for _, x in ipairs({ 180, 186 }) do c:px(x, 92, "#f2e4c0"); c:px(x, 93, "#f2e4c0") end
c:px(192, 84, "#2a1a10"); c:px(193, 84, "#2a1a10")
-- eye and brow ridge
c:eye(163, 72)
c:fill(c:rect(160, 70, 168, 70), "#6b1b2c")
-- puff of smoke from the nostril
for _, p in ipairs({ {198,76,3},{203,69,4},{208,61,5} }) do
  c:fill(c:ellipse(p[1], p[2], p[3], p[3]), "#8a6a8a"); c:fill(c:ellipse(p[1] - 1, p[2] - 1, p[3] - 1, p[3] - 1), "#b098b0")
end
-- ember sparks drifting
for _, p in ipairs({ {60,50},{84,44},{150,30},{170,48},{30,110},{190,122},{100,124},{70,118} }) do c:px(p[1], p[2], "#fbe0a8"); c:px(p[1], p[2] + 1, "#f08a24") end
L.finish(c, SLUG)
