-- haven-gaucho-gnome-ranch : the pampas by day. A gaucho gnome on a chibi horse, mate gourd on a stump, an asado, a windmill.
local REPO = "/home/user/gnome-venture/"
local H = dofile(REPO .. "aseprite-source/final/scripts/wonders/h3lib.lua")
local L, GV = H.L, H.GV
local c = L.new()
local W, HT = L.W, L.H
local HOR = 70

L.sky(c, "day", HOR)
L.cloud(c, 40, 22, 20, "#f4f0e0", "#cfd8e4"); L.cloud(c, 120, 38, 16, "#f4f0e0", "#cfd8e4"); L.cloud(c, 190, 18, 18, "#f4f0e0", "#cfd8e4"); L.cloud(c, 230, 44, 10, "#f4f0e0", "#cfd8e4")
for _, g in ipairs({ {70,32},{80,28},{160,48} }) do
  c:px(g[1], g[2], "#2a1a10"); c:px(g[1]+1, g[2]+1, "#2a1a10"); c:px(g[1]+2, g[2], "#2a1a10"); c:px(g[1]+3, g[2]+1, "#2a1a10"); c:px(g[1]+4, g[2], "#2a1a10")
end
-- pampas: layered rolling plains
c:part(L.below(c, function(x) return HOR + math.sin(x / 40) * 1.5 end), GV.ramp("#c8d77a"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
c:part(L.below(c, function(x) return HOR + 9 + math.sin(x / 25 + 2) * 2 end), GV.ramp("#a4b86a"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
c:part(L.below(c, function(x) return 92 + math.sin(x / 33 + 1) * 2 end), GV.ramp("#7ab55c"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
c:part(L.below(c, function(x) return 104 + math.sin(x / 28) * 1.5 end), GV.ramp("#a4b86a"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
-- grass tufts
for i = 0, 40 do
  local x = (i * 53 + 7) % W; local y = 78 + (i * 31) % 52
  local g = y < 100 and "#6a9a3a" or "#4a8a3e"
  c:px(x, y, g); c:px(x + 1, y - 1, "#c8d77a"); c:px(x + 2, y, g)
end
-- far cows
for _, p in ipairs({ {112,80,"#f2e4c0"},{128,83,"#8a4f2a"},{96,84,"#8a4f2a"} }) do
  c:part(c:ellipse(p[1], p[2], 4, 2.5), GV.ramp(p[3]), { flat = true, gloss = false, outline = false })
  c:fill(c:rect(p[1] - 3, p[2] + 2, p[1] - 3, p[2] + 4), "#4a2c1a"); c:fill(c:rect(p[1] + 3, p[2] + 2, p[1] + 3, p[2] + 4), "#4a2c1a")
  c:fill(c:rect(p[1] + 4, p[2] - 3, p[1] + 6, p[2] - 1), "#4a2c1a")
end

-- windmill (molino), right
local mx = 212
c:part(c:poly({ {mx - 9, 94}, {mx - 3, 50}, {mx + 3, 50}, {mx + 9, 94} }), GV.ramp("#8b8f96"), { cres = 3, deep = 5, gloss = false })
c:seam({ {mx - 7, 84}, {mx + 7, 84} }, { free = true, on = 1, off = 1, gap = "#5b6470" })
c:seam({ {mx - 5, 70}, {mx + 5, 70} }, { free = true, on = 1, off = 1, gap = "#5b6470" })
for k = 0, 7 do
  local a = k / 8 * math.pi * 2 + 0.3
  local ex, ey = mx + math.cos(a) * 17, 48 + math.sin(a) * 17
  c:part(c:line({ {mx, 48}, {ex, ey} }, 3), GV.ramp(k % 2 == 0 and "#c9c5bc" or "#f2e4c0"), { flat = true, gloss = false, outline = false, contour = "#5b6470" })
end
c:part(c:ellipse(mx, 48, 3, 3), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:part(c:poly({ {mx + 3, 47}, {mx + 20, 44}, {mx + 20, 54}, {mx + 3, 51} }), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false, outline = false })

-- rancho (whitewashed, tiled roof), left
local rx0, rx1 = 12, 74
c:part(c:rect(rx0, 70, rx1, 94), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 5, deep = 8, gloss = false, pale = true })
c:part(c:poly({ {rx0 - 5, 72}, {rx0 + 14, 56}, {rx1 - 14, 56}, {rx1 + 5, 72} }), GV.ramp("#d6532b"), { cres = 4, deep = 7, gloss = false })
for i = 0, 5 do c:fill(c:rect(rx0 + 2 + i * 10, 62, rx0 + 2 + i * 10, 70), "#a8301f") end
c:part(c:rrect(rx0 + 25, 78, rx0 + 37, 94, 3), GV.ramp("#8a4f2a"), { cres = 3, deep = 4, gloss = false, outline = false, contour = "#2a1a10" })
c:px(rx0 + 35, 87, "#f5cf6a")
for _, wx in ipairs({ rx0 + 6, rx0 + 46 }) do
  c:part(c:rect(wx, 78, wx + 9, 87), GV.ramp("#3f8fb0"), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
  c:part(c:rect(wx - 3, 78, wx - 1, 87), GV.ramp("#4a8a3e"), { flat = true, gloss = false, outline = false })
  c:part(c:rect(wx + 10, 78, wx + 12, 87), GV.ramp("#4a8a3e"), { flat = true, gloss = false, outline = false })
end
-- ombu tree behind house
c:part(c:ellipse(92, 66, 14, 11), GV.ramp("#4a8a3e"), { cres = 5, deep = 8 })
c:part(c:rect(90, 74, 94, 94), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false })

-- corral fence
for x = 0, W, 16 do c:part(c:rect(x, 90, x + 2, 108), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#4a2c1a" }) end
c:part(c:rect(0, 94, W, 96), GV.ramp("#d9a660"), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })
c:part(c:rect(0, 101, W, 103), GV.ramp("#d9a660"), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })

-- asado fire, left front: logs, flames, cross-stake with ribs, and the cook
local fx = 38
c:part(c:poly({ {fx - 4, 116}, {fx + 1, 100}, {fx + 6, 116} }), GV.ramp("#f08a24"), { cres = 2, deep = 3, gloss = false })
c:fill(c:poly({ {fx - 1, 116}, {fx + 1, 106}, {fx + 3, 116} }), "#f5cf6a")
c:part(c:line({ {fx - 12, 119}, {fx + 12, 115} }, 3), GV.ramp("#5e2f1e"), { cres = 2, deep = 3, gloss = false })
c:part(c:line({ {fx - 12, 115}, {fx + 12, 119} }, 3), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(fx - 1, 72, fx + 1, 108), GV.ramp("#5b6470"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
c:part(c:rect(fx - 9, 80, fx + 9, 82), GV.ramp("#5b6470"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(fx - 1, 90, 6, 8), GV.ramp("#b8452f"), { cres = 3, deep = 5 })
for _, y in ipairs({ 86, 90, 94 }) do c:fill(c:rect(fx - 5, y, fx + 3, y), "#f2e4c0") end
c:px(fx + 6, 68, "#c9c5bc"); c:px(fx + 7, 65, "#e2f0e0"); c:px(fx + 6, 62, "#c9c5bc")
H.folk(c, 66, 126, { cloth = "#e8a317", hat = "#4e8a9a", big = true, beard = "#f2e4c0" })

-- mate on a stump: gourd, bombilla, steaming
local sx = 112
c:part(c:rrect(sx - 7, 112, sx + 7, 126, 2), GV.ramp("#b07a45"), { cres = 3, deep = 5, gloss = false })
c:seam({ {sx - 5, 118}, {sx + 5, 118} }, { on = 2, off = 1 })
c:part(c:ellipse(sx, 107, 6, 6), GV.ramp("#8a4f2a"), { cres = 3, deep = 5 })
c:fill(c:ellipse(sx, 102, 4, 1.5), "#4a8a3e")
c:part(c:line({ {sx + 2, 102}, {sx + 8, 90} }, 2), GV.ramp("#c9c5bc"), { flat = true, gloss = false, outline = false })
c:px(sx - 2, 96, "#e2f0e0"); c:px(sx - 1, 93, "#cfd8e4"); c:px(sx - 2, 90, "#e2f0e0")

-- the horse (chibi), right of centre, facing right
local hx, gy = 160, 124
c:part(c:line({ {hx - 22, gy - 24}, {hx - 27, gy - 8} }, 3), GV.ramp("#2a1a10"), { flat = true, gloss = false, outline = false })      -- tail
for _, l in ipairs({ -15, -9, 8, 14 }) do
  c:part(c:rect(hx + l, gy - 14, hx + l + 3, gy - 1), GV.ramp("#a8582f"), { cres = 2, deep = 3, gloss = false })
  c:part(c:rect(hx + l, gy - 3, hx + l + 3, gy), GV.ramp("#2a1a10"), { flat = true, gloss = false, outline = false })
end
c:part(c:ellipse(hx, gy - 22, 22, 10), GV.ramp("#c27a3e"), { cres = 5, deep = 8 })
c:part(c:line({ {hx + 14, gy - 26}, {hx + 22, gy - 38} }, 9), GV.ramp("#c27a3e"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(hx + 25, gy - 38, 9, 7), GV.ramp("#c27a3e"), { cres = 3, deep = 5 })
c:part(c:ellipse(hx + 32, gy - 35, 4, 4), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false })
c:px(hx + 33, gy - 36, "#2a1a10"); c:px(hx + 33, gy - 34, "#2a1a10")
c:part(c:poly({ {hx + 18, gy - 44}, {hx + 20, gy - 52}, {hx + 24, gy - 44} }), GV.ramp("#a8582f"), { flat = true, gloss = false })
c:part(c:poly({ {hx + 24, gy - 45}, {hx + 28, gy - 52}, {hx + 30, gy - 44} }), GV.ramp("#a8582f"), { flat = true, gloss = false })
c:part(c:line({ {hx + 14, gy - 44}, {hx + 12, gy - 28} }, 3), GV.ramp("#2a1a10"), { flat = true, gloss = false, outline = false })       -- mane
c:eye(hx + 22, gy - 42)
-- saddle blanket
c:part(c:rrect(hx - 8, gy - 31, hx + 8, gy - 24, 2), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false, outline = false })
c:seam({ {hx - 6, gy - 27}, {hx + 6, gy - 27} }, { on = 2, off = 1 })
-- gaucho gnome in the saddle
H.folk(c, hx, gy - 28, { cloth = "#d6322b", hat = false, big = true, beard = "#f2e4c0" })
-- poncho stripe + flat gaucho hat, then eyes again over the brim edge
c:fill(c:rect(hx - 6, gy - 36, hx + 6, gy - 35), "#f5cf6a")
local hy = gy - 28 - 10 - 4
c:part(c:ellipse(hx, hy - 6, 6, 4), GV.ramp("#3d2a1c"), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
c:part(c:ellipse(hx, hy - 4, 12, 2.5), GV.ramp("#5e2f1e"), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
c:eye(hx - 7, hy - 3); c:eye(hx + 2, hy - 3)
c:seam({ {hx - 5, hy - 5}, {hx + 5, hy - 5} }, { free = true })
c:ground(hx, gy + 1, 26, 2)

L.finish(c, "haven-gaucho-gnome-ranch")
