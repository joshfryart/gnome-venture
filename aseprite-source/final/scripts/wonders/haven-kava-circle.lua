-- haven-kava-circle : Oceania evening. Gnomes sit round a carved tanoa bowl of kava under palms, tiki torches lit.
local REPO = "/home/user/gnome-venture/"
local H = dofile(REPO .. "aseprite-source/final/scripts/wonders/h3lib.lua")
local L, GV = H.L, H.GV
local c = L.new()
local W, HT = L.W, L.H
local HOR = 74

L.sky(c, "dusk", HOR)
L.stars(c, 26, 44, 11)
local moon = c:ellipse(196, 22, 8, 8); moon:cut(c:ellipse(200, 19, 7, 7))
c:fill(moon, "#fff1c8")
L.cloud(c, 60, 52, 16, "#8c6ab8", "#b784b4"); L.cloud(c, 150, 60, 14, "#b784b4", "#e39a86"); L.cloud(c, 214, 50, 12, "#8c6ab8", "#c98fb0")
-- sea
L.water(c, HOR + 1, "dusk")
for i, x in ipairs({ 20, 60, 100, 140, 180 }) do c:fill(c:rect(x, HOR + 3 + (i % 3) * 2, x + 8, HOR + 3 + (i % 3) * 2), "#e39a86") end
-- far island with a volcano cone
c:part(c:poly({ {150,HOR+1},{166,HOR-9},{176,HOR-16},{184,HOR-9},{204,HOR+1} }), GV.ramp("#4e3a8a"), { gloss = false, rim = false, bounce = false, outline = false })
c:part(c:poly({ {20,HOR+1},{34,HOR-5},{56,HOR-4},{70,HOR+1} }), GV.ramp("#4e3a8a"), { gloss = false, rim = false, bounce = false, outline = false })
-- a small outrigger canoe far out
c:fill(c:rect(104, HOR + 6, 114, HOR + 7), "#2a1a10"); c:fill(c:rect(108, HOR + 1, 108, HOR + 5), "#2a1a10"); c:fill(c:poly({ {109,HOR+1},{109,HOR+5},{114,HOR+5} }), "#f2e4c0")

-- beach / lawn
local ground = L.below(c, function(x) return 90 + math.sin(x / 30) * 1.5 end)
c:part(ground, GV.ramp("#c9a96e"), { cres = 5, deep = 8, gloss = false, outline = false })
c:part(L.below(c, function(x) return 100 + math.sin(x / 20 + 1) * 1.5 end), GV.ramp("#7ab55c"), { cres = 5, deep = 8, gloss = false, outline = false, rim = false })
for _, x in ipairs({ 10, 40, 70, 150, 190, 226, 100, 130 }) do local y = 98 + (x % 9)
  c:px(x, y, "#4a8a3e"); c:px(x + 1, y - 1, "#a4b86a"); c:px(x + 2, y, "#4a8a3e") end

-- palms (back)
H.palm(c, 22, 100, 14, 52, 1.1)
H.palm(c, 224, 100, 232, 48, 1.2)
H.palm(c, 190, 94, 184, 62, 0.8)

-- the fale: open thatched meeting house, back centre
local fx0, fx1 = 78, 160
for _, px in ipairs({ fx0 + 6, fx0 + 30, fx0 + 52, fx1 - 6 }) do
  c:part(c:rect(px, 70, px + 3, 98), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false })
end
c:fill(c:rect(fx0 + 7, 78, fx1 - 7, 96), "#291d4a")           -- dark inside
c:part(c:rect(fx0 + 4, 95, fx1 - 2, 98), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false }) -- raised floor
local roof = c:ellipse(119, 78, 50, 22):clip(c:rect(0, 40, W, 78))
c:part(roof, GV.ramp("#d9a660"), { cres = 6, deep = 9, gloss = false })
for i = 0, 6 do c:seam({ {fx0 - 4 + i * 8, 62 + (i % 2) * 2}, {fx0 + 2 + i * 8, 76} }, { free = true, on = 2, off = 2, gap = "#8a4f2a" }) end
c:part(c:rect(fx0 - 4, 76, fx1 + 4, 79), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false }) -- eave beam
-- lanterns hanging inside
for _, lx in ipairs({ 100, 138 }) do
  c:fill(c:rect(lx, 79, lx, 82), "#2a1a10")
  c:part(c:ellipse(lx, 85, 3, 3), GV.ramp("#f5cf6a"), { flat = true, gloss = false, outline = false })
end

-- tapa mat circle
local mat = c:ellipse(120, 114, 76, 15)
c:part(mat, GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 5, deep = 7, gloss = false, outline = false, rim = false })
c:fill(mat:copy():shrink(3):cut(mat:copy():shrink(4)), "#8a4f2a")
c:fill(mat:copy():shrink(8):cut(mat:copy():shrink(9)), "#b8452f")
for a = 0, 17 do
  local ang = a / 18 * math.pi * 2
  local px, py = 120 + math.cos(ang) * 62, 114 + math.sin(ang) * 11
  c:fill(c:poly({ {px, py - 2}, {px + 2, py}, {px, py + 2}, {px - 2, py} }), a % 2 == 0 and "#8a4f2a" or "#b8452f")
end

-- back row sitters
H.folk(c, 80, 106, { cloth = "#4e8a9a", hat = "#e8a317", sit = true })
H.folk(c, 160, 106, { cloth = "#b8452f", hat = "#4e8a9a", sit = true })
H.folk(c, 120, 100, { cloth = "#6a4fa8", hat = "#d6322b", sit = true, big = true, beard = "#f2e4c0" })  -- the elder
-- the tanoa bowl, centre front of the elder
local bx, by = 120, 116
for _, lx in ipairs({ -10, -3, 5, 11 }) do c:part(c:rect(bx + lx, by + 2, bx + lx + 2, by + 8), GV.ramp("#8a4f2a"), { flat = true, gloss = false }) end
c:part(c:ellipse(bx, by, 15, 6), GV.ramp("#a8582f"), { cres = 4, deep = 6 })
c:part(c:ellipse(bx, by - 1, 12, 4), GV.ramp("#d9c9a0"), { flat = true, gloss = false, outline = false, rim = false })
c:fill(c:ellipse(bx - 3, by - 2, 3, 1), "#f2e4c0")
c:px(bx + 6, by - 1, "#f2e4c0"); c:px(bx + 7, by, "#f2e4c0")
c:seam({ {bx - 12, by + 2}, {bx + 12, by + 2} }, { on = 2, off = 1 })
-- front sitters
H.folk(c, 50, 118, { cloth = "#e8a317", hat = "#d6322b", sit = true, big = true })
H.folk(c, 190, 118, { cloth = "#4e8a9a", hat = "#f08a24", sit = true, big = true, beard = "#d8c496" })
H.folk(c, 88, 128, { cloth = "#7ab55c", hat = "#b8452f", sit = true })
H.folk(c, 152, 128, { cloth = "#d6322b", hat = "#6a4fa8", sit = true })
-- coconut cups on the mat
for _, p in ipairs({ {104,114},{138,114},{70,122},{170,122} }) do
  c:part(c:ellipse(p[1], p[2], 3, 2), GV.ramp("#5e2f1e"), { flat = true, gloss = false })
  c:px(p[1] - 1, p[2] - 1, "#d9c9a0"); c:px(p[1], p[2] - 1, "#d9c9a0")
end

-- tiki torches
for _, tx in ipairs({ 20, 218 }) do
  c:part(c:rect(tx, 92, tx + 2, 114), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false })
  c:part(c:poly({ {tx - 3, 86}, {tx + 1, 76}, {tx + 5, 86} }), GV.ramp("#f08a24"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:poly({ {tx - 1, 85}, {tx + 1, 79}, {tx + 3, 85} }), "#f5cf6a")
  c:px(tx + 1, 83, "#fff1c8")
end
-- flower garlands on the mat edge
for i = 0, 5 do c:px(60 + i * 24, 129 - (i % 2), "#e46a9b"); c:px(61 + i * 24, 129 - (i % 2), "#f6b8cf") end

L.finish(c, "haven-kava-circle")
