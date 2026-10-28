-- lair-reef-of-the-box-jelly-queen.lua : boss lair, OC, underwater coral reef. A cube-bell jelly queen with a gold crown.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-reef-of-the-box-jelly-queen"

-- water column in hard bands
c:bands(c:rect(0, 0, W - 1, H - 1), { "#7ad8d8", "#5cc4cc", "#46acc0", "#3a94b0", "#2f7ca2", "#286890", "#245680" }, { dir = "v" })
-- light shafts from the surface
for _, s in ipairs({ {20,34},{70,30},{150,34},{200,30} }) do
  c:fill(c:poly({ {s[1],0},{s[1]+s[2],0},{s[1]+s[2]-26,100},{s[1]-30,100} }), "#6ed0d4")
end
c:fill(c:rect(0, 0, W, 4), "#a8ece0")
-- seabed
local bed = L.below(c, function(x) return 106 + 3 * math.sin(x / 30) + 2 * math.sin(x / 11) end)
c:fill(bed, "#d8c08a"); c:fill(bed:copy():clip(c:rect(0, 116, W, H)), "#c9a96e"); c:fill(bed:copy():clip(c:rect(0, 124, W, H)), "#b8935a")
for i = 0, 30 do local x = (i * 61 + 13) % W; local y = 110 + (i * 7) % 18; c:fill(c:rect(x, y, x + 3, y), "#ecdca4") end

-- far coral silhouettes (hazy, no outline)
for _, f in ipairs({ {30,104,12},{58,106,9},{176,104,14},{214,106,10} }) do
  c:fill(c:ellipse(f[1], f[2], f[3], f[3] * 0.8):clip(c:rect(0, 0, W, 108)), "#3a8cb0")
end

-- sea fans and kelp (back layer)
local function kelp(x, y, h, col)
  for i = 0, h do
    local xx = x + math.floor(2 * math.sin(i / 5 + x))
    c:fill(c:rect(xx, y - i, xx + 2, y - i), col)
  end
end
kelp(14, 116, 40, "#4a8a3e"); kelp(20, 118, 30, "#7ab55c"); kelp(226, 116, 44, "#4a8a3e"); kelp(232, 118, 32, "#7ab55c")

-- left reef: branching coral + brain coral + anemone
local function branch(x, y, h, spread, ramp)
  c:part(c:rrect(x - 2, y - h, x + 2, y, 1), ramp, { cres = 2, deep = 3, gloss = false })
  c:part(c:line({ {x, y - h * 0.6}, {x - spread, y - h * 0.9} }, 4), ramp, { cres = 2, deep = 3, gloss = false })
  c:part(c:line({ {x, y - h * 0.5}, {x + spread, y - h * 0.8} }, 4), ramp, { cres = 2, deep = 3, gloss = false })
  c:part(c:ellipse(x - spread, y - h * 0.9 - 2, 3, 3), ramp, { flat = true, gloss = false })
  c:part(c:ellipse(x + spread, y - h * 0.8 - 2, 3, 3), ramp, { flat = true, gloss = false })
  c:part(c:ellipse(x, y - h - 2, 3, 3), ramp, { flat = true, gloss = false })
end
c:part(c:ellipse(30, 118, 26, 14):clip(c:rect(0, 0, W, 126)), GV.ramp("#e8708a"), { cres = 5, deep = 8 })
for _, p in ipairs({ {18,112},{28,108},{38,112},{24,118},{34,118},{44,118} }) do c:px(p[1], p[2], "#b83a5a"); c:px(p[1] + 1, p[2], "#b83a5a"); c:px(p[1] + 1, p[2] + 1, "#b83a5a") end
branch(54, 122, 28, 8, GV.ramp("#f08a24")); branch(70, 124, 20, 6, GV.ramp("#e46a9b"))
branch(10, 124, 22, 6, GV.ramp("#e8a317"))
-- right reef
c:part(c:ellipse(212, 118, 24, 14):clip(c:rect(0, 0, W, 126)), GV.ramp("#8a6ac8"), { cres = 5, deep = 8 })
for _, p in ipairs({ {200,112},{212,108},{222,112},{206,119},{218,119} }) do c:px(p[1], p[2], "#5a3a98"); c:px(p[1] + 1, p[2], "#5a3a98") end
branch(176, 124, 30, 8, GV.ramp("#e46a9b")); branch(192, 124, 20, 6, GV.ramp("#f08a24")); branch(236, 124, 22, 5, GV.ramp("#e8a317"))
-- clownfish by the left reef
local function clown(x, y, dir)
  local d = dir
  c:part(c:ellipse(x, y, 7, 4), GV.ramp("#f08a24"), { cres = 2, deep = 3, gloss = false })
  c:part(c:poly({ {x - 7 * d, y}, {x - 12 * d, y - 4}, {x - 12 * d, y + 4} }), GV.ramp("#f08a24"), { flat = true, gloss = false })
  c:fill(c:rect(x + 1 * d, y - 3, x + 2 * d, y + 3), "#f2e4c0"); c:fill(c:rect(x - 4 * d, y - 2, x - 3 * d, y + 2), "#f2e4c0")
  c:eye(x + 3 * d - 2, y - 3, true)
end
clown(80, 96, 1); clown(160, 88, -1)

-- the Box Jelly Queen
local QX, QY = 120, 40
-- tentacles trailing down, behind the bell's lower edge but drawn first
for i, dx in ipairs({ -22, -11, 0, 11, 22 }) do
  local ph = i * 1.3
  for y = QY + 26, QY + 66 + (i % 2) * 8 do
    local xx = QX + dx + math.floor(2.5 * math.sin((y - QY) / 4 + ph))
    c:fill(c:rect(xx, y, xx + 1, y), (y % 6 < 3) and "#e8a0d8" or "#d070b8")
  end
end
-- frilly oral arms (thicker, in the centre)
for _, dx in ipairs({ -6, 6 }) do
  for y = QY + 26, QY + 46 do
    local xx = QX + dx + math.floor(3 * math.sin((y - QY) / 3 + dx))
    c:fill(c:rect(xx, y, xx + 3, y), "#f4c8e8")
  end
end
-- bell: a soft cube with four panels
local bell = c:rrect(QX - 28, QY - 20, QX + 28, QY + 28, 9)
c:part(bell, GV.ramp("#9ab8f0", { gloss = "#e8f4ff", rim = "#c8dcff", dot = "#f2fbf8", shade = "#7a98d8", deep = "#5a78b8" }), { cres = 5, deep = 8, pale = false })
for _, dx in ipairs({ -14, 0, 14 }) do c:fill(c:rect(QX + dx, QY - 18, QX + dx, QY + 26), "#7aa0d8") end
-- soft inner glow, lower rim stitch in thread gold
c:fill(c:rrect(QX - 22, QY - 14, QX - 16, QY + 6, 2), "#d8e8ff")
c:seam({ {QX - 24, QY + 25}, {QX + 24, QY + 25} }, { free = true })
-- crown of gold
for i, dx in ipairs({ -18, -9, 0, 9, 18 }) do
  local hh = (i % 2 == 1) and 9 or 12
  c:part(c:poly({ {QX + dx - 4, QY - 19}, {QX + dx, QY - 19 - hh}, {QX + dx + 4, QY - 19} }), GV.ramp("#e8a317"), { flat = true, gloss = false })
end
c:part(c:rect(QX - 22, QY - 21, QX + 22, QY - 18), GV.ramp("#e8a317"), { flat = true })
for _, dx in ipairs({ -18, 0, 18 }) do c:fill(c:rect(QX + dx - 1, QY - 20, QX + dx, QY - 19), "#d6322b") end
-- eyes and a regal little smile
for _, dx in ipairs({ -13, 13 }) do c:eye(QX + dx - 2, QY - 4) end
c:fill(c:rect(QX - 5, QY + 9, QX + 4, QY + 9), "#7a3a5a"); c:px(QX - 6, QY + 8, "#7a3a5a"); c:px(QX + 5, QY + 8, "#7a3a5a")

-- bubbles
for _, b in ipairs({ {60,40,3},{66,26,2},{184,50,3},{196,30,2},{40,70,2},{214,74,3},{84,16,2},{150,12,2} }) do
  c:fill(c:ellipse(b[1], b[2], b[3], b[3]), "#bdf0ee"); c:fill(c:ellipse(b[1] + 1, b[2] + 1, b[3] - 1, b[3] - 1), "#7ad8d8")
  c:px(b[1] - 1, b[2] - 1, "#f2fbf8")
end
-- tiny fish school
for _, f in ipairs({ {150,60},{158,66},{166,58} }) do
  c:fill(c:rect(f[1], f[2], f[1] + 4, f[2] + 1), "#f5cf6a"); c:fill(c:rect(f[1] + 5, f[2] - 1, f[1] + 6, f[2] + 2), "#e8a317"); c:px(f[1] + 1, f[2], "#2a1a10")
end
c:ground(QX, 126, 36, 3)
L.finish(c, SLUG)
