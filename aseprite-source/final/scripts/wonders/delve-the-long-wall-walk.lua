-- delve-the-long-wall-walk.lua : EA zone 4 delve. "A long, windy wall path."
-- Autumn day: a battlemented wall walk running off over wind-swept ridges, a roofed watchtower with a streaming banner,
-- and a small wall-walker in a straw hat holding it on against the gale.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local SLUG = "delve-the-long-wall-walk"
local FLAT = { gloss = false, rim = false, bounce = false, outline = false }
local function fl(t) local r = {}; for k, v in pairs(FLAT) do r[k] = v end; for k, v in pairs(t) do r[k] = v end; return r end

L.sky(c, "day", 90)
L.cloud(c, 40, 30, 24, "#f4f0e0", "#cfd8e4"); L.cloud(c, 150, 22, 28, "#f4f0e0", "#cfd8e4"); L.cloud(c, 214, 50, 16, "#f4f0e0", "#cfd8e4")
for _, w in ipairs({ {70,48,18},{100,40,12},{16,56,14},{190,34,16},{120,60,10} }) do c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2]), "#f4f0e0") end
for _, g in ipairs({ {96,26},{110,20},{84,34} }) do
  for _, p in ipairs({ {0,0},{1,1},{2,1},{3,0},{4,1},{5,1},{6,0} }) do c:px(g[1] + p[1], g[2] + p[2], "#3e2f66") end
end

-- far misty mountains and ridge layers
c:part(L.below(c, function(x) return 66 - math.abs(math.sin(x / 19)) * 16 end):clip(c:rect(0, 40, W, 100)), GV.ramp("#8aa0c0"), fl({ cres = 6, deep = 8 }))
c:part(L.below(c, function(x) return 80 - math.abs(math.sin(x / 13 + 1)) * 10 end):clip(c:rect(0, 50, W, 104)), GV.ramp("#6a9a8a"), fl({ cres = 5, deep = 7 }))
-- the far wall: climbing the ridges as a stitched line with little towers
local function wallpts(pts) c:part(c:line(pts, 2), GV.ramp("#c9c5bc"), { flat = true, gloss = false, outline = false }) end
wallpts({ {0,86},{22,78},{40,80},{58,70},{76,74},{96,66},{110,70} })
for _, t in ipairs({ {58,70},{96,66},{22,78} }) do
  c:part(c:rect(t[1] - 2, t[2] - 7, t[1] + 2, t[2]), GV.ramp("#c9c5bc"), { flat = true, gloss = false, outline = false })
  c:fill(c:rect(t[1] - 3, t[2] - 9, t[1] + 3, t[2] - 8), "#d6322b")
end
-- autumn hills (orange and gold treed)
c:part(L.below(c, function(x) return 92 - math.abs(math.sin(x / 11 + 3)) * 7 end):clip(c:rect(0, 70, W, 110)), GV.ramp("#d0862a"), fl({ cres = 5, deep = 8 }))
for _, t in ipairs({ {12,88,"#d6322b"},{26,90,"#e8a317"},{44,86,"#f08a24"},{60,90,"#d6322b"},{78,88,"#e8a317"},{96,92,"#7ab55c"},{112,90,"#f08a24"},{130,88,"#d6322b"},{150,91,"#e8a317"},{170,89,"#7ab55c"},{190,92,"#f08a24"} }) do
  c:part(c:ellipse(t[1], t[2], 5, 4), GV.ramp(t[3]), { cres = 2, deep = 3, gloss = false, outline = false })
end
-- falling leaves on the gale
for _, p in ipairs({ {50,50},{58,58},{82,70},{132,52},{150,64},{170,48},{30,72},{200,64},{22,40},{106,54} }) do
  c:px(p[1], p[2], "#e0501f"); c:px(p[1] + 1, p[2], "#e8a317"); c:px(p[1] - 1, p[2] + 1, "#d6322b")
end

-- watchtower, right: stone base, red-pillared pavilion, curved double roof, streaming banner
local TX = 200
c:part(c:rect(TX - 22, 76, TX + 22, 112), GV.ramp("#a9a49a"), { cres = 5, deep = 8, gloss = false })
for y = 80, 108, 6 do c:seam({ {TX - 22, y}, {TX + 22, y} }, { free = true, on = 4, off = 0, gap = "#5b6470" }) end
for _, x in ipairs({ TX - 12, TX + 2, TX + 14 }) do c:seam({ {x, 76}, {x, 112} }, { free = true, on = 2, off = 4, gap = "#5b6470" }) end
c:part(c:rrect(TX - 4, 94, TX + 4, 112, 3), GV.ramp("#3e2f66"), { cres = 2, deep = 4, gloss = false, outline = false, contour = "#2a1a10" })
-- upper pavilion
c:part(c:rect(TX - 16, 56, TX + 16, 76), GV.ramp("#d6322b"), { cres = 4, deep = 7, gloss = false })
for _, x in ipairs({ TX - 12, TX, TX + 12 }) do c:fill(c:rect(x - 1, 59, x + 1, 74), "#6b1b2c") end
c:fill(c:rect(TX - 9, 60, TX - 4, 70), "#f5cf6a"); c:fill(c:rect(TX + 4, 60, TX + 9, 70), "#f5cf6a")
c:px(TX - 9, 60, "#fff1c8"); c:px(TX + 4, 60, "#fff1c8")
-- roofs: green-grey tile with upturned eaves
local function roof(y, hw, hh)
  c:part(c:poly({ {TX - hw - 6, y + 1}, {TX - hw - 2, y}, {TX - hw + 4, y - 2}, {TX - 4, y - hh}, {TX + 4, y - hh}, {TX + hw - 4, y - 2}, {TX + hw + 2, y}, {TX + hw + 6, y + 1}, {TX + hw, y + 4}, {TX - hw, y + 4} }), GV.ramp("#4e8a9a", { rim = "#8fcbd8" }), { cres = 3, deep = 6, gloss = false })
  c:seam({ {TX - hw + 2, y + 2}, {TX + hw - 2, y + 2} }, { on = 2, off = 1 })
end
roof(56, 18, 8)
c:part(c:rect(TX - 8, 40, TX + 8, 48), GV.ramp("#d6322b"), { cres = 3, deep = 5, gloss = false })
roof(40, 12, 7)
c:part(c:ellipse(TX, 28, 2.5, 2.5), GV.ramp("#e8a317"), { flat = true })
-- banner pole and streaming banner (pointing right, whipping in the wind)
c:fill(c:rect(TX, 14, TX + 1, 30), "#7a4a1f")
local ban = c:poly({ {TX + 2, 14}, {TX + 14, 15}, {TX + 22, 13}, {TX + 28, 17}, {TX + 22, 20}, {TX + 14, 22}, {TX + 2, 21} })
c:part(ban, GV.ramp("#e8a317"), { cres = 2, deep = 3, gloss = false })
c:seam({ {TX + 4, 17}, {TX + 22, 16} }, { free = true, on = 2, off = 2, gap = "#d6322b" })
-- red lanterns swinging sideways
for _, x in ipairs({ TX - 16, TX + 16 }) do
  c:fill(c:rect(x, 72, x + 1, 74), "#2a1a10")
  c:part(c:ellipse(x + 3, 78, 3, 3), GV.ramp("#d6322b", { gloss = "#ff9158" }), { cres = 2, deep = 3, gloss = false })
  c:px(x + 4, 78, "#f5cf6a")
end

-- the near wall: walkway top, battlements at back, brick face in front (running off left and right)
local back = 100
for x = -2, W, 12 do
  c:part(c:rect(x, back - 8, x + 6, back), GV.ramp("#a9a49a"), { cres = 3, deep = 5, gloss = false })
end
c:part(c:rect(0, back, W - 1, back + 12), GV.ramp("#d8c8a0", { shade = "#b8a478", deep = "#8a7650" }), { cres = 3, deep = 5, gloss = false, outline = false })
-- paving lines on the walkway
for x = 4, W, 18 do c:seam({ {x, back + 1}, {x + 4, back + 11} }, { free = true, on = 3, off = 0, gap = "#a8946a" }) end
c:part(c:rect(0, back + 12, W - 1, H - 1), GV.ramp("#8b8f96"), { cres = 5, deep = 8, gloss = false })
for y = back + 17, H - 3, 6 do
  c:seam({ {0, y}, {W - 1, y} }, { free = true, on = 4, off = 0, gap = "#5b6470" })
  for x = ((y // 6) % 2) * 8 + 4, W, 16 do c:px(x, y + 1, "#5b6470"); c:px(x, y + 2, "#5b6470"); c:px(x, y + 3, "#5b6470"); c:px(x, y + 4, "#5b6470") end
end
-- grass tufts growing in the cracks
for _, x in ipairs({ 20, 70, 130, 160, 232 }) do c:px(x, back + 13, "#7ab55c"); c:px(x + 1, back + 12, "#a4b86a"); c:px(x + 2, back + 13, "#7ab55c") end
-- shadow line at the foot of the battlement
c:fill(c:rect(0, back, W - 1, back), "#a8946a")

-- the wall-walker: chibi folk in a straw hat, leaning into the wind with a satchel and a bundle staff
local PX, PY = 80, 90
-- staff + bundle
c:fill(c:rect(PX + 12, PY - 18, PX + 13, PY + 20), "#7a4a1f")
c:part(c:ellipse(PX + 12, PY - 18, 5, 4), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false })
-- body: indigo coat leaning (skewed by offset)
c:part(c:ellipse(PX, PY + 6, 8, 11), GV.ramp("#3e5a9a"), { cres = 4, deep = 6 })
c:seam({ {PX - 1, PY - 2}, {PX + 1, PY + 16} }, { on = 2, off = 1 })
c:part(c:rect(PX - 9, PY + 4, PX + 9, PY + 6), GV.ramp("#d6322b"), { flat = true, gloss = false, outline = false })
-- feet
for _, dx in ipairs({ -5, 3 }) do c:part(c:ellipse(PX + dx + 1, PY + 18, 3, 2), GV.ramp("#5e2f1e"), { flat = true, gloss = false }) end
-- arm to hat (sleeve)
c:part(c:line({ {PX - 6, PY + 2}, {PX - 12, PY - 4}, {PX - 12, PY - 13} }, 3), GV.ramp("#3e5a9a"), { flat = true, gloss = false, outline = false })
-- head
c:part(c:ellipse(PX, PY - 7, 10, 8), GV.ramp("#f9d49c", { shade = "#d9a070", deep = "#a8644a" }), { cres = 3, deep = 5 })
c:eye(PX - 7, PY - 12); c:eye(PX + 2, PY - 12)
for _, p in ipairs({ {-2,-4},{-1,-3},{0,-3},{1,-3},{2,-4} }) do c:px(PX + p[1], PY + p[2], "#2a1a10") end
-- straw hat: wide cone, held on, tied with a red cord
c:part(c:poly({ {PX - 15, PY - 15}, {PX - 3, PY - 29}, {PX + 5, PY - 29}, {PX + 15, PY - 15}, {PX + 8, PY - 13}, {PX - 8, PY - 13} }), GV.ramp("#e8c26a", { shade = "#c49a4a", deep = "#8a6a2a" }), { cres = 3, deep = 5, gloss = false })
c:seam({ {PX - 12, PY - 16}, {PX + 12, PY - 16} }, { on = 2, off = 1 })
c:fill(c:rect(PX - 9, PY - 13, PX - 8, PY - 8), "#d6322b"); c:fill(c:rect(PX + 9, PY - 13, PX + 10, PY - 8), "#d6322b")
-- hand on the hat brim
c:part(c:ellipse(PX - 12, PY - 15, 2.5, 2.5), GV.ramp("#f9d49c"), { flat = true, gloss = false })
c:ground(PX, PY + 21, 12, 2)

-- wind streaks across the foreground
for _, w in ipairs({ {10,76,14},{36,62,12},{116,78,16},{140,56,10},{60,40,10} }) do c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2]), "#f4f0e0"); c:px(w[1] + w[3] + 1, w[2] - 1, "#f4f0e0") end

L.finish(c, SLUG)
