-- haven-floating-market : Southeast-Asian canal market, bright morning. Boat stalls, a noodle boat, a resting boat.
local REPO = "/home/user/gnome-venture/"
local H = dofile(REPO .. "aseprite-source/final/scripts/wonders/h3lib.lua")
local L, GV = H.L, H.GV
local c = L.new()
local W, HT = L.W, L.H
local HOR = 62

L.sky(c, "day", HOR)
L.cloud(c, 40, 20, 18, "#f4f0e0", "#cfd8e4"); L.cloud(c, 150, 12, 16, "#f4f0e0", "#cfd8e4"); L.cloud(c, 215, 30, 12, "#f4f0e0", "#cfd8e4")
-- far green hills
c:part(L.below(c, function(x) return 48 + math.sin(x / 22) * 4 end), GV.ramp("#7ab55c"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
c:part(L.below(c, function(x) return 56 + math.sin(x / 15 + 1) * 3 end), GV.ramp("#4a8a3e"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
-- water
L.water(c, 74, { "#5aa8b8", "#4a9ab0", "#3f8fa8", "#3584a0", "#2f789a", "#2a6c90" })
-- bank with palms and stilt houses
c:part(L.below(c, function(x) return 70 end):clip(c:rect(0, 0, W, 76)), GV.ramp("#a4b86a"), { cres = 3, deep = 5, gloss = false, outline = false, rim = false })
H.palm(c, 14, 76, 8, 36, 0.9); H.palm(c, 120, 76, 126, 38, 0.8); H.palm(c, 232, 76, 226, 34, 0.9)
local function stilt(x0, x1, y0, roof)
  for x = x0 + 2, x1 - 4, 10 do c:part(c:rect(x, y0 + 12, x + 2, 78), GV.ramp("#5e2f1e"), { flat = true, gloss = false, outline = false }) end
  c:part(c:rect(x0, y0, x1, y0 + 12), GV.ramp("#d9a660"), { cres = 4, deep = 6, gloss = false })
  for x = x0 + 5, x1 - 3, 7 do c:fill(c:rect(x, y0 + 1, x, y0 + 11), "#b07a45") end
  c:part(c:poly({ {x0 - 4, y0 + 1}, {x0 + 6, y0 - 9}, {x1 - 6, y0 - 9}, {x1 + 4, y0 + 1} }), GV.ramp(roof), { cres = 3, deep = 5, gloss = false })
  c:part(c:rect(x0 + 4, y0 + 4, x0 + 10, y0 + 10), GV.ramp("#291d4a"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
  c:fill(c:rect(x0 + 6, y0 + 6, x0 + 7, y0 + 8), "#f5cf6a")
end
stilt(30, 64, 56, "#b8452f"); stilt(72, 106, 58, "#8a5a3a"); stilt(160, 196, 56, "#4e8a9a")
-- arched wooden footbridge, right
c:part(c:ellipse(212, 80, 26, 12):clip(c:rect(0, 66, W, 82)):cut(c:ellipse(212, 83, 18, 12)), GV.ramp("#b07a45"), { cres = 3, deep = 5, gloss = false })
for x = 190, 236, 6 do c:fill(c:rect(x, 66, x, 69), "#5e2f1e") end
c:fill(c:rect(190, 66, 236, 66), "#5e2f1e")
-- a tiny gnome crossing the bridge
H.folk(c, 212, 70, { cloth = "#d6322b", hat = "#f5cf6a" })

-- boat helper
local function boat(x0, x1, y, col)
  c:fill(c:rect(x0 + 2, y + 6, x1 - 2, y + 6), "#2f789a"); c:fill(c:rect(x0 + 6, y + 8, x1 - 6, y + 8), "#5aa8b8")
  c:part(c:poly({ {x0, y - 6}, {x0 + 6, y + 5}, {x1 - 6, y + 5}, {x1, y - 6}, {x1 - 3, y - 3}, {x0 + 3, y - 3} }), GV.ramp(col), { cres = 3, deep = 5, gloss = false })
  c:seam({ {x0 + 8, y + 1}, {x1 - 8, y + 1} }, { free = true, on = 2, off = 1 })
end
local function awning(x0, x1, y0, y1, a, b)
  local m = c:poly({ {x0 + 4, y0}, {x1 - 4, y0}, {x1 + 2, y1}, {x0 - 2, y1} })
  c:part(m, GV.ramp(a), { cres = 3, deep = 4, gloss = false })
  local i = 0
  for x = x0 - 2, x1 + 2, 6 do if i % 2 == 1 then c:fill(m:copy():clip(c:rect(x, y0, x + 5, y1)), b) end; i = i + 1 end
end

-- back boats (small, far)
boat(36, 74, 94, "#4e8a9a")
for i, col in ipairs({ "#e46a9b", "#f5cf6a", "#d6322b", "#f6b8cf", "#e46a9b", "#f5cf6a" }) do c:part(c:ellipse(42 + i * 5, 89, 3, 3), GV.ramp(col), { flat = true, gloss = false, outline = false }) end
boat(140, 180, 92, "#8a4f2a")
awning(146, 174, 76, 84, "#4e8a9a", "#f2e4c0"); c:fill(c:rect(147, 84, 147, 91), "#5e2f1e"); c:fill(c:rect(173, 84, 173, 91), "#5e2f1e")
H.folk(c, 160, 91, { cloth = "#7ab55c", hat = "#e8c070" })

-- fruit boat (right front)
boat(160, 236, 112, "#d6322b")
for _, f in ipairs({ {172,104,"#f08a24"},{180,106,"#f5cf6a"},{188,103,"#e46a9b"},{196,106,"#7ab55c"},{204,104,"#f08a24"},{212,106,"#e46a9b"},{178,99,"#7ab55c"},{190,98,"#f5cf6a"},{202,99,"#f08a24"} }) do
  c:part(c:ellipse(f[1], f[2], 4, 4), GV.ramp(f[3]), { cres = 2, deep = 3, gloss = false })
end
c:fill(c:rect(186, 99, 190, 101), "#c8d77a")   -- dragon-fruit green fins hint
H.folk(c, 222, 108, { cloth = "#f2e4c0", hat = "#e8c070", big = true })
c:part(c:poly({ {212, 77}, {236, 77}, {240, 90}, {208, 90} }), GV.ramp("#f5cf6a"), { cres = 3, deep = 4, gloss = false })
c:fill(c:rect(215, 90, 215, 96), "#5e2f1e")

-- noodle boat (centre front): awning, stove, steaming pot, bowls, cook
boat(70, 150, 120, "#b07a45")
awning(76, 144, 84, 98, "#d6322b", "#f2e4c0")
c:fill(c:rect(78, 98, 78, 114), "#5e2f1e"); c:fill(c:rect(142, 98, 142, 114), "#5e2f1e")
c:part(c:rect(96, 110, 112, 118), GV.ramp("#5b6470"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(100, 114, 108, 117), "#f08a24"); c:fill(c:rect(102, 115, 106, 117), "#f5cf6a")
c:part(c:ellipse(104, 105, 9, 6), GV.ramp("#8b8f96"), { cres = 3, deep = 5 })
c:fill(c:ellipse(104, 101, 7, 1.5), "#f5cf6a")
for _, p in ipairs({ {101,95},{105,92},{103,88} }) do c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#f4f0e0") end
H.folk(c, 128, 117, { cloth = "#4e8a9a", hat = "#e8c070", big = true, beard = "#f2e4c0" })
-- a bowl of noodles being passed over
c:part(c:ellipse(86, 116, 5, 3), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:fill(c:ellipse(86, 114, 3, 1), "#f5cf6a"); c:px(85, 112, "#f4f0e0"); c:px(87, 110, "#f4f0e0")
for x = 74, 82, 4 do c:fill(c:rect(x, 118, x + 2, 120), "#f2e4c0") end

-- resting boat (left front): a gnome sipping tea in a hammock
boat(6, 58, 124, "#4e8a9a")
c:part(c:line({ {12, 106}, {52, 106} }, 2), GV.ramp("#d6322b"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(32, 112, 18, 6):clip(c:rect(0, 108, W, 122)), GV.ramp("#f6b8cf"), { cres = 3, deep = 4, gloss = false, outline = false, rim = false })
H.folk(c, 32, 114, { cloth = "#e8a317", hat = "#7ab55c", sit = true })
c:fill(c:rect(10, 106, 10, 124), "#5e2f1e"); c:fill(c:rect(54, 106, 54, 124), "#5e2f1e")
-- lanterns strung over the water
for _, x in ipairs({ 66, 122, 150 }) do
  c:fill(c:rect(x, 78, x, 82), "#2a1a10")
  c:part(c:ellipse(x, 85, 3, 3), GV.ramp("#d6322b"), { flat = true, gloss = false, outline = false }); c:px(x, 83, "#f5cf6a")
end
L.finish(c, "haven-floating-market")
