-- delve-pirate-gull-grottoes: a sunny sea grotto, a gang of thieving pirate gulls guarding their loot. SE (South Europe), day.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local HOR = 74

-- view through the grotto mouth: sky, sea, far island, little sailboat --------------------------------------------
L.sky(c, "day", HOR)
L.cloud(c, 90, 32, 16); L.cloud(c, 150, 24, 12)
c:fill(c:ellipse(176, 40, 7, 7), "#fff1c8")
L.water(c, HOR + 1, { "#6ad0d8", "#4ec0d0", "#3fb0c8", "#34a0c0", "#2c8cb4", "#2a78a4" })
c:part(c:poly({ {104,HOR+1},{118,HOR-7},{132,HOR-9},{150,HOR-4},{162,HOR+1} }), GV.ramp("#a4b86a"), { outline = false, gloss = false, rim = false, bounce = false })
-- whitewashed village on the far island
for i, x in ipairs({ 120, 128, 136, 144 }) do c:fill(c:rect(x, HOR - 6 + (i % 2), x + 4, HOR), "#f2e4c0"); c:fill(c:rect(x + 1, HOR - 4 + (i % 2), x + 1, HOR - 3 + (i % 2)), "#3f8fb0") end
c:fill(c:ellipse(130, HOR - 8, 3, 2.5):clip(c:rect(0, 0, W, HOR - 7)), "#3f8fb0")
-- sailboat
c:fill(c:poly({ {174,HOR+10},{196,HOR+10},{192,HOR+14},{178,HOR+14} }), "#a8582f")
c:fill(c:poly({ {185,HOR-4},{185,HOR+9},{196,HOR+9} }), "#f2e4c0"); c:fill(c:poly({ {183,HOR-1},{183,HOR+9},{176,HOR+9} }), "#fbe8c0")
c:fill(c:rect(185, HOR - 5, 185, HOR + 10), "#5e2f1e"); c:px(186, HOR - 5, "#d6322b"); c:px(187, HOR - 5, "#d6322b")
for i, p in ipairs({ {150,86,10},{170,92,12},{130,100,9},{196,98,8},{110,92,8} }) do c:fill(c:rect(p[1], p[2], p[1] + p[3], p[2]), "#c8f0e8") end

-- the grotto walls: limestone frame around an arched mouth ---------------------------------------------------------
local frame = c:rect(0, 0, W - 1, H - 1)
frame:cut(c:ellipse(124, 84, 80, 66))
c:part(frame, GV.ramp("#b8a88a"), { cres = 10, deep = 16, gloss = false, rim = false })
-- cracks and strata in the stone
for _, l in ipairs({ { {10,30},{34,34},{52,28} }, { {200,26},{222,32},{236,28} }, { {6,70},{22,66} }, { {222,70},{236,76} }, { {40,10},{70,14} }, { {190,8},{214,12} } }) do
  c:fill(c:line(l, 1), "#6a5a4a")
end
-- warm stone highlights (upper left of each block)
for _, l in ipairs({ { {12,22},{30,24} }, { {200,18},{216,20} }, { {44,6},{62,8} } }) do c:fill(c:line(l, 1), "#e2d4b0") end
-- stalactites hanging into the mouth
for _, p in ipairs({ {70,30,12},{90,22,16},{110,18,10},{140,18,12},{160,22,15},{180,30,12} }) do
  c:part(c:poly({ {p[1]-3,p[2]},{p[1],p[2]+p[3]},{p[1]+3,p[2]} }), GV.ramp("#b8a88a"), { flat = true, gloss = false })
end
-- ferns and thyme on the lip of the mouth
for _, p in ipairs({ {58,38},{196,40},{40,56},{214,58} }) do
  c:fill(c:line({ {p[1], p[2]}, {p[1] - 4, p[2] - 6} }, 2), "#4a8a3e"); c:fill(c:line({ {p[1], p[2]}, {p[1] + 4, p[2] - 6} }, 2), "#7ab55c"); c:px(p[1], p[2] - 8, "#e46a9b")
end

-- rock ledge, left, with the loot hoard ------------------------------------------------------------------------------
local ledge = c:poly({ {0,H},{0,100},{30,96},{70,100},{96,106},{108,H} })
c:part(ledge, GV.ramp("#8b8f96"), { cres = 7, deep = 11, gloss = false })
c:fill(c:rect(0, 100, 28, 100), "#c9c5bc")
-- treasure chest, lid open, overflowing
c:part(c:rect(40, 96, 70, 112), GV.ramp("#a8582f"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(40, 100, 70, 101), "#e8a317"); c:fill(c:rect(54, 96, 56, 112), "#e8a317")
c:part(c:poly({ {38,96},{40,84},{70,84},{72,96} }), GV.ramp("#a8582f"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(42, 88, 68, 88), "#e8a317")
c:part(c:ellipse(55, 94, 17, 6), GV.ramp("#f5cf6a"), { cres = 2, deep = 3 })
for _, p in ipairs({ {46,89},{52,87},{60,88},{66,90},{50,92},{58,91} }) do c:fill(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), "#fff1c8"); c:px(p[1] + 2, p[2] + 1, "#b8661a") end
-- stolen goods: a hat, a baguette, a fish, a spoon, a pearl necklace
c:part(c:ellipse(18, 94, 9, 3), GV.ramp("#e46a9b"), { flat = true, gloss = false }); c:part(c:poly({ {12,94},{18,80},{24,94} }), GV.ramp("#e46a9b"), { flat = true, gloss = false })
c:fill(c:line({ {12, 94}, {24, 94} }, 1), "#f6b8cf")
c:part(c:ellipse(30, 104, 9, 3), GV.ramp("#d9a660"), { cres = 1, gloss = false }); c:fill(c:rect(26, 102, 26, 102), "#7a4a1f"); c:fill(c:rect(31, 102, 31, 102), "#7a4a1f"); c:fill(c:rect(35, 103, 35, 103), "#7a4a1f")
c:part(c:ellipse(78, 106, 8, 3), GV.ramp("#8fcbd8"), { flat = true, gloss = false }); c:fill(c:poly({ {85,104},{91,101},{91,109} }), "#8fcbd8"); c:px(73, 105, "#2a1a10")
c:fill(c:line({ {6,106},{16,108} }, 1), "#c9c5bc"); c:fill(c:ellipse(18, 108, 2, 1.5), "#c9c5bc")
for i = 0, 6 do c:fill(c:ellipse(86 + i * 3, 114 + (i % 2), 1, 1), "#f2e4c0") end

-- pirate gulls ---------------------------------------------------------------------------------------------------------------
local function gull(x, y, kind, lookdir)
  -- x,y = feet position; chibi: big head, squat body
  c:fill(c:rect(x - 5, y - 2, x - 4, y), "#f08a24"); c:fill(c:rect(x + 3, y - 2, x + 4, y), "#f08a24")
  c:fill(c:rect(x - 7, y, x - 3, y), "#f08a24"); c:fill(c:rect(x + 2, y, x + 6, y), "#f08a24")
  c:part(c:poly({ {x - 15, y - 4}, {x - 8, y - 14}, {x - 4, y - 12}, {x - 4, y - 4} }), GV.ramp("#cfd6e8"), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })  -- tail feathers
  c:part(c:ellipse(x, y - 11, 11, 9), GV.ramp("#e6ecf2", { dot = "#fff3c8", gloss = "#fff3c8", shade = "#bcc4d4", deep = "#929ab0", bounce = "#cdd4e0", rim = "#f5e8c8" }), { cres = 4, deep = 6, pale = true })
  c:part(c:ellipse(x - 2, y - 11, 6, 5), GV.ramp("#8b8f96"), { flat = true, gloss = false, outline = false })  -- wing
  c:part(c:ellipse(x + 3, y - 24, 10, 9), GV.ramp("#e6ecf2", { dot = "#fff3c8", gloss = "#fff3c8", shade = "#bcc4d4", deep = "#929ab0", bounce = "#cdd4e0", rim = "#f5e8c8" }), { cres = 4, deep = 6, pale = true })
  c:eye(x - 4, y - 28); c:eye(x + 4, y - 28)
  c:part(c:poly({ {x + 8, y - 24}, {x + 18, y - 21}, {x + 8, y - 15} }), GV.ramp("#e8a317"), { flat = true, gloss = false, outline = false })
  c:px(x + 10, y - 21, "#b8661a")
  if kind == "tricorn" then
    c:part(c:poly({ {x - 9, y - 31}, {x + 3, y - 40}, {x + 15, y - 31} }), GV.ramp("#291d4a"), { cres = 3, deep = 4, gloss = false })
    c:fill(c:rect(x - 10, y - 32, x + 16, y - 31), "#3e2f66"); c:fill(c:rect(x + 2, y - 37, x + 4, y - 36), "#f5cf6a")
    c:fill(c:line({ {x - 3, y - 26}, {x + 3, y - 26} }, 1), "#291d4a")   -- eyepatch strap over the forehead
  elseif kind == "bandana" then
    c:part(c:rect(x - 7, y - 33, x + 13, y - 31), GV.ramp("#d6322b"), { flat = true, gloss = false, outline = false })
    c:fill(c:poly({ {x + 12, y - 33}, {x + 17, y - 30}, {x + 14, y - 28} }), "#d6322b")
    for i = 0, 3 do c:px(x - 5 + i * 5, y - 32, "#f2e4c0") end
  else
    c:part(c:poly({ {x - 8, y - 32}, {x + 2, y - 36}, {x + 14, y - 32} }), GV.ramp("#4e8a9a"), { flat = true, gloss = false, outline = false })
    c:fill(c:rect(x - 8, y - 32, x + 14, y - 31), "#2a1a10")
  end
end
gull(22, 100, "bandana")
gull(92, 112, "tricorn")
-- gull on the sea-side rock, right, with a stolen shiny thing in its beak
local rr = c:poly({ {W,H},{W,92},{214,94},{192,102},{176,H} })
c:part(rr, GV.ramp("#8b8f96"), { cres = 6, deep = 9, gloss = false })
c:fill(c:rect(198, 99, 238, 99), "#c9c5bc")
gull(212, 100, "cap")
c:part(c:ellipse(228, 78, 3, 3), GV.ramp("#f5cf6a"), { flat = true }); c:px(228, 78, "#fff1c8")   -- a coin, mid-fly
-- a flying gull in the open sky
for _, g in ipairs({ {150,44},{162,40} }) do
  c:fill(c:line({ {g[1], g[2]}, {g[1] + 3, g[2] + 2}, {g[1] + 6, g[2]} }, 1), "#f8f0d8"); c:fill(c:line({ {g[1] + 6, g[2]}, {g[1] + 9, g[2] + 2}, {g[1] + 12, g[2]} }, 1), "#f8f0d8")
end
-- tide pool water at the bottom, with a glint
c:fill(c:rect(108, H - 8, 176, H - 8), "#8fe8e0"); c:fill(c:rect(124, H - 14, 150, H - 14), "#c8f0e8")

L.finish(c, "delve-pirate-gull-grottoes")
