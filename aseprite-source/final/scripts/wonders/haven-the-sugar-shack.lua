-- haven-the-sugar-shack.lua : "A gnome sugarhouse tapping maples. Steam pours from the roof of a log cabin at the edge of the maple wood." NA, autumn day.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 78
local NF = { gloss = false, rim = false, bounce = false, outline = false }
local function nf(t) local o = {}; for k, v in pairs(NF) do o[k] = v end; for k, v in pairs(t or {}) do o[k] = v end; return o end

L.sky(c, "day", HOR)
L.cloud(c, 60, 24, 16, "#f4f0e0", "#cfd8e4"); L.cloud(c, 190, 38, 14, "#f4f0e0", "#cfd8e4")
-- far hills, autumn colours
c:part(c:poly({ {0,HOR+2},{0,64},{40,56},{80,64},{120,58},{170,66},{W,56},{W,HOR+2} }), GV.ramp("#a85a3a"), nf{ cres = 3, deep = 5 })
c:part(c:poly({ {0,HOR+2},{0,70},{30,66},{70,72},{110,68},{160,74},{W,66},{W,HOR+2} }), GV.ramp("#d28a3a"), nf{ cres = 3, deep = 5 })
-- snowy-ish meadow ground: late-winter sugaring season, patches of snow on brown earth
local g = L.below(c, function(x) return HOR + 2 + math.sin(x / 17) end)
c:part(g, GV.ramp("#e8eef0"), nf{ cres = 4, deep = 7 })
for _, p in ipairs({ {20,112,12,2},{200,108,14,2},{40,124,10,2},{150,125,16,2},{220,122,9,2},{110,120,8,1} }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#c9b49a") end

local function maple(x, y, s, col, tapped)
  -- trunk
  c:part(c:rect(x - 3 * s, y - 20 * s, x + 3 * s, y + 10), GV.ramp("#6a4a30"), { cres = 3, deep = 5, gloss = false })
  c:part(c:ellipse(x, y - 28 * s, 14 * s, 11 * s), GV.ramp(col), { cres = 5, deep = 8, gloss = false })
  c:part(c:ellipse(x - 9 * s, y - 20 * s, 8 * s, 7 * s), GV.ramp(col), { cres = 4, deep = 6, gloss = false })
  c:part(c:ellipse(x + 9 * s, y - 20 * s, 8 * s, 7 * s), GV.ramp(col), { cres = 4, deep = 6, gloss = false })
  if tapped then
    c:fill(c:rect(x - 6, y - 4, x - 4, y - 3), "#a8a8b0")  -- spile
    c:part(c:rrect(x - 11, y - 2, x - 5, y + 5, 1), GV.ramp("#a8a8b0"), { flat = true, gloss = false })  -- bucket
    c:px(x - 5, y - 3, "#e8a317")
  end
end
maple(24, 100, 1.1, "#d6502b", true); maple(60, 96, 0.9, "#e8a317", true); maple(214, 100, 1.1, "#d6502b", true); maple(184, 94, 0.9, "#e8742b", false)
-- fallen leaves (foreground)
for i = 0, 22 do local x = (i * 47 + 13) % W; local y = 104 + (i * 31) % 26; c:fill(c:rect(x, y, x + 1, y), (i % 2 == 0) and "#d6502b" or "#e8a317") end

-- log cabin (centre-right), chimney vent on roof with a cloud of steam
local cx0, cx1, wy0, wy1 = 90, 160, 78, 112
-- logs: stacked rounded rows
c:part(c:rect(cx0, wy0, cx1, wy1), GV.ramp("#a8693a"), { cres = 5, deep = 9, gloss = false })
for y = wy0 + 6, wy1 - 2, 6 do c:seam({ {cx0 + 1, y}, {cx1 - 1, y} }, { free = true, on = 3, off = 0, gap = "#7a4a22" }) end
for y = wy0 + 3, wy1, 6 do c:part(c:ellipse(cx0, y, 2, 3), GV.ramp("#c9915a"), { flat = true, gloss = false, outline = false }); c:part(c:ellipse(cx1, y, 2, 3), GV.ramp("#c9915a"), { flat = true, gloss = false, outline = false }) end
-- roof
c:part(c:poly({ {cx0 - 8, wy0 + 2}, {125, 50}, {cx1 + 8, wy0 + 2} }), GV.ramp("#8a3a2a"), { cres = 6, deep = 10, gloss = false })
c:seam({ {cx0 - 4, wy0 - 2}, {125, 53}, {cx1 + 4, wy0 - 2} }, { free = true, on = 2, off = 1 })
-- cupola vent on top (steam pours)
c:part(c:rect(116, 40, 134, 52), GV.ramp("#a8693a"), { cres = 3, deep = 5, gloss = false })
c:part(c:poly({ {113, 41}, {125, 32}, {137, 41} }), GV.ramp("#8a3a2a"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(120, 44, 130, 49), "#4a2c1a")
-- door (lit, warm) and window
c:part(c:rrect(106, 90, 124, 112, 2), GV.ramp("#7a4a1f"), { gloss = false, cres = 3, deep = 5 })
c:fill(c:rect(109, 93, 121, 112), "#f5b860"); c:fill(c:rect(109, 93, 121, 96), "#f0a030")
c:px(122, 102, "#e8a317")
c:part(c:rect(132, 88, 150, 102), GV.ramp("#f5b860"), { cres = 2, deep = 4, gloss = false, contour = "#2a1a10" })
c:fill(c:rect(140, 88, 141, 102), "#7a4a1f"); c:fill(c:rect(132, 95, 150, 96), "#7a4a1f")
-- woodpile at left of the cabin
for r = 0, 2 do for i = 0, 5 - r do c:part(c:ellipse(94 + i * 5 + r * 2, 118 - r * 4, 2.5, 2.5), GV.ramp("#c9915a"), { flat = true, gloss = false, outline = false }); c:px(94 + i * 5 + r * 2, 118 - r * 4, "#8a5a2e") end end
-- steam: big pale puffs rising and drifting up-left
local puffs = { {125,30,8},{116,22,10},{126,12,9},{112,12,8},{100,6,7},{122,4,6} }
for _, p in ipairs(puffs) do
  local m = c:ellipse(p[1], p[2], p[3], p[3] * 0.75)
  c:fill(m, "#fbf8ee"); c:fill(m:copy():clip(c:rect(0, p[2] + 2, W, H)), "#d8e2ea")
end
-- evaporator pan seen through a lower side hatch? keep outdoors: sap barrel + bubbling pan on the right
c:part(c:rrect(172, 108, 196, 124, 3), GV.ramp("#5b6470"), { cres = 4, deep = 7, gloss = false })
c:part(c:ellipse(184, 108, 11, 3), GV.ramp("#e8a850"), { flat = true, gloss = false })
c:px(180, 106, "#fff1c8"); c:px(186, 105, "#fff1c8"); c:px(190, 107, "#fff1c8")
c:fill(c:rect(176, 116, 192, 116), "#e0501f"); c:fill(c:rect(178, 118, 190, 120), "#f5cf6a")
-- barrels of sap
for _, bx in ipairs({ 168, 202 }) do
  c:part(c:rrect(bx - 6, 112, bx + 6, 128, 4), GV.ramp("#a8693a"), { cres = 4, deep = 6, gloss = false })
  c:seam({ {bx - 5, 116}, {bx + 5, 116} }, { free = true, on = 3, off = 0, gap = "#5b6470" }); c:seam({ {bx - 5, 124}, {bx + 5, 124} }, { free = true, on = 3, off = 0, gap = "#5b6470" })
end
-- chibi gnome sugarmaker with a ladle (left of door) and a maple syrup jug
local gx, gy = 80, 112
c:part(c:ellipse(gx, gy + 3, 7, 8), GV.ramp("#4e8a9a"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(gx, gy - 9, 7, 6), GV.ramp("#f0c8a0"), { cres = 3, deep = 4, gloss = false })
c:eye(gx - 5, gy - 13, true); c:eye(gx - 0, gy - 13, true)
c:part(c:ellipse(gx, gy - 3, 6, 3), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false })
c:part(c:poly({ {gx - 8, gy - 12}, {gx, gy - 28}, {gx + 8, gy - 12} }), GV.ramp("#d6322b"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(gx + 8, gy - 6, gx + 8, gy + 8), "#6a4420"); c:part(c:ellipse(gx + 8, gy - 8, 3, 3), GV.ramp("#a8a8b0"), { flat = true, gloss = false, outline = false })
c:ground(gx, gy + 11, 8, 2)
c:ground(125, 113, 36, 3)
L.finish(c, "haven-the-sugar-shack")
