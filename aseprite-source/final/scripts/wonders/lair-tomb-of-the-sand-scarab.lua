-- lair-tomb-of-the-sand-scarab.lua : Boss lair (MENA, zone 4). A beetle as big as a cart guards a desert tomb. Hazy golden afternoon. Params out= ase=
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 92
L.sky(c, "warm", HOR)
c:fill(c:ellipse(186, 40, 16, 16), "#fbe0a8"); c:fill(c:ellipse(186, 40, 12, 12), "#fff1c8")
L.cloud(c, 50, 24, 16, "#fdf2d8", "#f5cc92"); L.cloud(c, 120, 14, 12, "#fdf2d8", "#f5cc92")
-- far dunes and pyramids
c:fill(L.below(c, function(x) return 88 + math.sin(x * 0.05) * 3 end), "#e0b078")
local function pyr(x, top, hw, col, shade)
  c:fill(c:poly({ {x - hw, 92}, {x, top}, {x + hw, 92} }), col)
  c:fill(c:poly({ {x, top}, {x + hw, 92}, {x, 92} }), shade)
end
pyr(46, 56, 34, "#f0c890", "#d9a870"); pyr(92, 70, 20, "#f0c890", "#d9a870")
-- dunes
c:part(L.below(c, function(x) return 98 + math.sin(x * 0.04 + 2) * 6 end), GV.ramp("#e9c890"), { outline = false, gloss = false, cres = 4, deep = 6 })
c:part(L.below(c, function(x) return 114 + math.sin(x * 0.06) * 4 end), GV.ramp("#dcb070"), { outline = false, gloss = false, cres = 4, deep = 6 })

-- the tomb facade (right)
local fx = 176
c:part(c:rect(fx - 40, 62, fx + 40, 112), GV.ramp("#d8b888"), { cres = 6, deep = 9, gloss = false })
c:part(c:rect(fx - 44, 56, fx + 44, 64), GV.ramp("#c9a96e"), { cres = 3, deep = 5, gloss = false })
c:seam({ {fx - 40, 60}, {fx + 40, 60} }, { on = 4, off = 2 })
for _, x in ipairs({ fx - 34, fx - 18, fx + 14, fx + 30 }) do
  c:part(c:rect(x, 66, x + 4, 112), GV.ramp("#e8d0a0"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x - 1, 66, x + 5, 67), "#c9a96e")
end
c:part(c:rrect(fx - 10, 74, fx + 10, 114, 9), GV.ramp("#291d4a"), { gloss = false, cres = 3, deep = 4 })
c:fill(c:rect(fx - 8, 82, fx + 8, 112), "#1c1a48")
c:fill(c:rect(fx - 1, 90, fx + 1, 92), "#f5cf6a")
-- winged sun disc above the door
c:part(c:ellipse(fx, 68, 5, 5), GV.ramp("#e8a317"), { flat = true })
c:part(c:poly({ {fx - 6, 68}, {fx - 22, 64}, {fx - 18, 71} }), GV.ramp("#3f8fb0"), { flat = true, outline = false })
c:part(c:poly({ {fx + 6, 68}, {fx + 22, 64}, {fx + 18, 71} }), GV.ramp("#3f8fb0"), { flat = true, outline = false })
-- obelisk and braziers
c:part(c:poly({ {18,112},{20,66},{22,60},{24,66},{26,112} }), GV.ramp("#c9c5bc"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(21, 76, 23, 78), "#e8a317"); c:fill(c:rect(21, 86, 23, 88), "#e8a317"); c:fill(c:rect(21, 96, 23, 98), "#e8a317")
for _, bx in ipairs({ fx - 26, fx + 26 }) do
  c:part(c:poly({ {bx - 4, 106}, {bx + 4, 106}, {bx + 2, 112}, {bx - 2, 112} }), GV.ramp("#5b6470"), { flat = true })
  c:fill(c:ellipse(bx, 102, 3, 4), "#e0501f"); c:fill(c:ellipse(bx, 103, 2, 2.5), "#f5b838"); c:px(bx, 102, "#fff1c8")
end
-- palm
c:fill(c:line({ {100,112},{104,92},{102,80} }, 2), "#8a4f2a")
for _, d in ipairs({ {-12,3},{-8,-3},{-3,-6},{4,-6},{9,-3},{12,3} }) do c:part(c:line({ {102,80}, {102 + d[1] * 0.5, 78 + d[2]}, {102 + d[1], 80 + d[2] + 3} }, 3), GV.ramp("#4a8a3e"), { flat = true, gloss = false }) end

-- little cart for scale (left foreground)
c:part(c:rect(8, 112, 36, 120), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })
c:seam({ {10,116},{34,116} }, { on = 2, off = 1 })
c:part(c:ellipse(22, 124, 6, 6), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false }); c:fill(c:ellipse(22, 124, 2, 2), "#d9a660")
c:part(c:ellipse(14, 110, 6, 4), GV.ramp("#e8d9b0"), { flat = true }); c:part(c:ellipse(28, 109, 5, 4), GV.ramp("#d9885a"), { flat = true })

-- the Sand Scarab, 3/4 view facing right
local SH = GV.ramp("#2a8a8a")      -- turquoise shell
local BX, BY = 88, 100
for k = 0, 2 do   -- legs (behind)
  local x0 = BX - 20 + k * 18
  c:part(c:line({ {x0, BY + 10}, {x0 - 6, BY + 18}, {x0 - 4, BY + 28} }, 3), GV.ramp("#3e2f66"), { flat = true, gloss = false })
  c:part(c:line({ {x0 + 8, BY + 10}, {x0 + 14, BY + 18}, {x0 + 14, BY + 28} }, 3), GV.ramp("#3e2f66"), { flat = true, gloss = false })
end
c:part(c:ellipse(BX, BY, 38, 24):cut(c:rect(0, BY + 14, W, H)), SH, { cres = 8, deep = 12 })
c:seam({ {BX, BY - 22}, {BX, BY + 12} }, { on = 3, off = 1 })      -- wing-case split
-- gold lines and gem on the shell
c:fill(c:line({ {BX - 24, BY - 6}, {BX - 12, BY - 12} }, 2), "#e8a317"); c:fill(c:line({ {BX + 12, BY - 12}, {BX + 24, BY - 6} }, 2), "#e8a317")
c:fill(c:line({ {BX - 28, BY + 4}, {BX - 14, BY} }, 2), "#e8a317"); c:fill(c:line({ {BX + 14, BY}, {BX + 28, BY + 4} }, 2), "#e8a317")
c:part(c:ellipse(BX, BY - 18, 3, 3), GV.ramp("#d6322b"), { flat = true })
-- head and horn
local hx, hy = BX + 42, BY + 4
c:part(c:ellipse(hx, hy, 16, 14), GV.ramp("#d9a660"), { cres = 4, deep = 6 })
c:part(c:poly({ {hx - 3, hy - 10}, {hx + 4, hy - 26}, {hx + 11, hy - 10} }), GV.ramp("#e8d9b0"), { flat = true })
c:part(c:poly({ {hx + 11, hy + 4}, {hx + 22, hy + 6}, {hx + 11, hy + 10} }), GV.ramp("#e8d9b0"), { flat = true })
c:eye(hx - 8, hy - 5); c:eye(hx + 1, hy - 5)
for k = 0, 4 do c:px(hx - 9 + k, (k < 3) and hy - 8 or hy - 7, "#2a1a10"); c:px(hx + 9 - k, (k < 3) and hy - 8 or hy - 7, "#2a1a10") end
-- tiny sand whirls and sparkles
for _, p in ipairs({ {70,130},{150,128},{210,124},{120,132} }) do c:fill(c:rect(p[1], p[2], p[1] + 8, p[2]), "#f8dba8") end
c:ground(BX + 10, 128, 44, 2)
L.finish(c, "lair-tomb-of-the-sand-scarab")
