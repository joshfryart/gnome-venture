-- wonder-starpath-canoe.lua : night beach, a great voyaging canoe on the sand, navigators reading the stars, a gold star-path across the sky.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 78

L.sky(c, "night", HOR)
L.stars(c, 70, 70, 21)
-- bigger stars (crosses)
local big = { {30,16},{64,30},{98,12},{130,26},{160,14},{196,28},{222,12},{44,52},{176,48},{110,44},{206,58},{14,40} }
for _, s in ipairs(big) do
  c:px(s[1], s[2], "#fff1c8"); c:px(s[1]-1, s[2], "#c3b2ea"); c:px(s[1]+1, s[2], "#c3b2ea"); c:px(s[1], s[2]-1, "#c3b2ea"); c:px(s[1], s[2]+1, "#c3b2ea")
end
-- the starpath: dotted gold line through a few stars up from the horizon
c:seam({ {128,74},{120,62},{126,50},{112,44},{98,12} }, { free = true, on = 1, off = 2 })
c:seam({ {110,44},{130,26},{160,14} }, { free = true, on = 1, off = 3 })
-- a low moon-less glow at the horizon
c:fill(c:rect(0, HOR - 3, W - 1, HOR), "#4a428e"); c:fill(c:rect(0, HOR - 1, W - 1, HOR), "#6a5ab0")
-- far island
c:part(c:poly({ {160,HOR+1},{172,HOR-6},{184,HOR-8},{200,HOR-4},{214,HOR+1} }), GV.ramp("#26225a"), { gloss = false, rim = false, bounce = false, outline = false, cres = 2, deep = 2 })
-- sea
c:bands(c:rect(0, HOR + 1, W - 1, 104), L.SEA.night, { dir = "v" })
for i = 0, 30 do local x = (i * 43 + 5) % (W - 6); local y = HOR + 3 + (i * 7) % 24; c:fill(c:rect(x, y, x + 3 + i % 3, y), "#2a4a82") end
-- star reflections in the water
for _, s in ipairs(big) do
  if s[1] > 60 and s[1] < 200 then c:fill(c:rect(s[1] - 1, HOR + 5 + (s[1] % 11), s[1] + 1, HOR + 5 + (s[1] % 11)), "#c3b2ea") end
end
c:fill(c:rect(126, HOR + 4, 130, HOR + 4), "#fff1c8"); c:fill(c:rect(124, HOR + 8, 132, HOR + 8), "#c3b2ea"); c:fill(c:rect(127, HOR + 12, 129, HOR + 12), "#c3b2ea")
-- beach: sand, curve from the left, wet-sand edge
local sand = L.below(c, function(x) return 100 + 3 * math.sin(x / 40 + 1) - x * 0.02 end)
c:part(sand, GV.ramp("#c9a96e"), { gloss = false, rim = false, outline = false, cres = 6, deep = 12 })
c:fill(sand:copy():clip(c:rect(0, 98, W, 104)), "#9a6b3f")
for _, x in ipairs({ 10, 60, 100, 150, 200 }) do c:fill(c:rect(x, 100 + (x % 3), x + 10, 100 + (x % 3)), "#e2f0e0") end -- foam
for i = 0, 40 do local x = (i * 59 + 13) % W; local y = 108 + (i * 23) % 22; c:px(x, y, "#9a6b3f"); c:px(x + 1, y, "#e8d9b0") end
-- palm at the left
local function palm(x, y, lean)
  c:part(c:poly({ {x - 2, y}, {x - 1 + lean // 2, y - 28}, {x + 1 + lean // 2, y - 28}, {x + 3, y} }), GV.ramp("#8a4f2a"), { gloss = false, cres = 2, deep = 3 })
  for _, f in ipairs({ {-16, -2}, {-11, -9}, {16, -2}, {11, -9}, {0, -12}, {-6, 2}, {7, 2} }) do
    local tx, ty = x + lean // 2 + f[1], y - 28 + f[2]
    c:limb({ {x + lean // 2, y - 29}, {(x + lean // 2 + tx) // 2, math.min(ty, y - 29) - 4}, {tx, ty + 4} }, 3)
  end
end
-- leaf blobs instead of limbs (limbs are lavender): draw fronds as moss parts
local function frond(x, y, dx, dy)
  local m = c:ellipse(x + dx / 2, y + dy / 2, math.max(2, math.abs(dx) / 2 + 1), math.max(2, math.abs(dy) / 2 + 2))
  c:part(m, "moss", { cres = 3, deep = 4, gloss = false, outline = false })
end
local function palm2(x, y)
  c:part(c:poly({ {x - 2, y}, {x - 1, y - 30}, {x + 2, y - 30}, {x + 3, y} }), GV.ramp("#8a4f2a"), { gloss = false, cres = 2, deep = 3 })
  c:seam({ {x, y - 4}, {x + 1, y - 28} }, { free = true, on = 2, off = 2, gap = "#5e2f1e" })
  for _, f in ipairs({ {-14, 4}, {-9, -4}, {14, 4}, {9, -4}, {0, -7}, {-5, 5}, {6, 5} }) do frond(x + 1, y - 30, f[1], f[2]) end
  c:part(c:ellipse(x - 1, y - 28, 2, 2), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
  c:part(c:ellipse(x + 3, y - 28, 2, 2), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
end
palm2(18, 112)

-- the great canoe (double-lashed, outrigger float in front) -------------------------------------------------
local bx, by = 118, 116
-- shadow
c:fill(c:ellipse(bx, by + 5, 62, 3), "#7a5a2a")
-- mast and crab-claw sail (behind hull)
c:part(c:rect(bx - 2, by - 56, bx, by - 6), GV.ramp("#8a4f2a"), { gloss = false, cres = 1, deep = 2 })
local sail = c:poly({ {bx + 1, by - 54}, {bx + 30, by - 38}, {bx + 22, by - 16}, {bx + 1, by - 10} })
c:part(sail, GV.ramp("#e8d9b0"), { cres = 5, deep = 8, pale = true, gloss = false })
for _, y in ipairs({ -44, -34, -24 }) do c:seam({ {bx + 3, by + y}, {bx + 21 - (y + 24) * -1 // 3 , by + y + 4} }, { free = true, on = 2, off = 1, gap = "#d8c496" }) end
c:fill(c:poly({ {bx + 10, by - 40}, {bx + 14, by - 38}, {bx + 12, by - 30} }), "#d6322b")
c:part(c:rect(bx - 3, by - 58, bx + 1, by - 56), GV.ramp("#e8a317"), { flat = true, gloss = false })
-- hull
local hull = c:poly({ {bx - 62, by - 16}, {bx - 56, by - 6}, {bx - 40, by + 2}, {bx + 40, by + 2}, {bx + 56, by - 6}, {bx + 64, by - 20}, {bx + 58, by - 8}, {bx + 38, by - 8}, {bx - 38, by - 8}, {bx - 58, by - 8} })
hull = c:poly({ {bx - 64, by - 20}, {bx - 56, by - 8}, {bx - 40, by + 2}, {bx + 40, by + 2}, {bx + 56, by - 8}, {bx + 64, by - 20}, {bx + 56, by - 12}, {bx + 30, by - 9}, {bx - 30, by - 9}, {bx - 56, by - 12} })
c:part(hull, GV.ramp("#8a4f2a"), { cres = 5, deep = 8 })
-- red bow ornaments (carved prow), pattern band
c:part(c:ellipse(bx - 62, by - 21, 3, 3), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:part(c:ellipse(bx + 62, by - 21, 3, 3), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:px(bx - 63, by - 22, "#fff1c8")
for x = bx - 40, bx + 40, 6 do c:px(x, by - 4, "#f5cf6a"); c:px(x + 1, by - 4, "#f5cf6a"); c:px(x + 2, by - 3, "#d6322b") end
c:seam({ {bx - 48, by - 10}, {bx + 48, by - 10} }, { free = true, on = 2, off = 1 })
-- outrigger: booms and float
c:part(c:rect(bx - 34, by - 7, bx - 32, by + 8), GV.ramp("#b07a45"), { flat = true, gloss = false })
c:part(c:rect(bx + 30, by - 7, bx + 32, by + 8), GV.ramp("#b07a45"), { flat = true, gloss = false })
c:part(c:ellipse(bx, by + 10, 52, 3.5), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })
for x = bx - 30, bx + 30, 6 do c:px(x, by + 9, "#e8a317") end
-- deck lashings / seat thwarts
c:fill(c:rect(bx - 22, by - 13, bx - 18, by - 9), "#b07a45"); c:fill(c:rect(bx + 14, by - 13, bx + 18, by - 9), "#b07a45")

-- navigators (chibi): three on the sand right of the canoe, one sitting in front, pointing at the starpath
local function navi(x, y, wrap, hair, skin, up)
  c:ground(x, y + 1, 10, 2, "#9a6b3f")
  if up then
    c:limb({ {x + 5, y - 10}, {x + 10, y - 16}, {x + 12, y - 24} }, 2)
    c:part(c:rect(x + 11, y - 27, x + 13, y - 24), GV.ramp(skin), { flat = true, gloss = false })
  end
  c:part(c:rrect(x - 7, y - 11, x + 7, y, 3), GV.ramp(wrap), { cres = 3, deep = 5 })
  c:seam({ {x - 6, y - 5}, {x + 6, y - 5} }, { on = 2, off = 1 })
  c:part(c:ellipse(x, y - 18, 7.5, 7), GV.ramp(skin), { cres = 3, deep = 5, gloss = false })
  -- hair top knot
  c:part(c:ellipse(x, y - 22, 7, 3):cut(c:rect(x - 9, y - 21, x + 9, y - 15)), GV.ramp(hair), { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(x - 1, y - 26, 3, 2.5), GV.ramp(hair), { flat = true, gloss = false })
  c:eye(x - 6, y - 21 + 1); c:eye(x + 1, y - 21 + 1)
end
navi(192, 119, "#d6322b", "#2a1a10", "#b07a45", true)
navi(222, 115, "#3f8fb0", "#2a1a10", "#9a6b3f", false)
navi(160, 124, "#e8a317", "#3e2f66", "#c47a52", false)
-- small fire with glow between them
c:fill(c:ellipse(206, 121, 14, 4), "#b8661a")
c:part(c:ellipse(206, 122, 5, 2), GV.ramp("#5b6470"), { flat = true, gloss = false })
c:part(c:poly({ {202,122},{203,115},{206,109},{209,115},{210,122} }), "flame", { cres = 2, deep = 3, gloss = false })
c:fill(c:poly({ {204,122},{205,116},{206,113},{207,116},{208,122} }), "#fff1c8")
c:px(212, 105, "#f5cf6a"); c:px(200, 103, "#f5cf6a"); c:px(207, 99, "#e0501f")
L.finish(c, "wonder-starpath-canoe")
