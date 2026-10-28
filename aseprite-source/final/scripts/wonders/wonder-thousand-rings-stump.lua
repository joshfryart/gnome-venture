-- wonder-thousand-rings-stump.lua : a hollow stump as wide as a village green; every ring is a year, some whisper. Late-afternoon forest light.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local FLAT = { gloss = false, rim = false, bounce = false, outline = false }
-- forest backdrop: warm green-gold light between tall trunks
c:bands(c:rect(0, 0, W - 1, 110), { "#2f5a46", "#3a6a4e", "#4a7a52", "#62905a", "#82a862", "#a8c070", "#d0d082", "#ecdc98" }, { dir = "v" })
-- far trunks (hazy), then near trunks
for _, t in ipairs({ 14, 52, 86, 150, 190, 228 }) do
  c:part(c:rect(t - 4, 0, t + 4, 106), GV.ramp("#6a8a5a", { shade = "#587a52", deep = "#486a48" }), { gloss = false, rim = false, bounce = false, outline = false, cres = 3 })
end
for _, t in ipairs({ 4, 108, 238 }) do
  c:part(c:rect(t - 7, 0, t + 7, 110), GV.ramp("#8a4a32", { shade = "#6a3428", deep = "#4a2420", rim = "#b06a44" }), { gloss = false, bounce = false, cres = 5, deep = 8 })
  for y = 10, 100, 14 do c:fill(c:rect(t - 3 + (y % 5), y, t - 3 + (y % 5), y + 8), "#5a2c22") end
end
-- sun shafts (hard pale diagonals) and canopy leaf clumps
for _, s in ipairs({ { {30,0},{44,0},{70,110},{46,110} }, { {150,0},{160,0},{196,110},{170,110} } }) do c:fill(c:poly(s), "#d0d082") end
for _, l in ipairs({ {20,6,18},{70,4,20},{128,8,22},{180,4,18},{222,8,16} }) do c:fill(c:ellipse(l[1], l[2], l[3], 8), "#2a5a40"); c:fill(c:ellipse(l[1] + 4, l[2] + 5, l[3] - 5, 4), "#356a4a") end
-- forest floor
c:part(L.below(c, function(x) return 100 + 2 * math.sin(x / 13) end), GV.ramp("#6a9a3a", { shade = "#4a8a3e", deep = "#2f5a2a" }), { cres = 6, deep = 9, gloss = false })

-- THE STUMP: bark wall first
local wall = c:poly({ {16,86},{12,108},{2,126},{238,126},{228,108},{224,86} })
c:part(wall, GV.ramp("#8a5a3a", { shade = "#6a4028", deep = "#4a2c1a", rim = "#b07a50" }), { cres = 8, deep = 14, gloss = false })
-- bark ridges
for i = 0, 22 do
  local x = 20 + i * 9 + (i % 3)
  local y0 = 96 + (i * 7) % 8
  c:fill(c:rect(x, y0, x, y0 + 10 + (i * 5) % 12), (i % 2 == 0) and "#5a3622" or "#a06a42")
end
-- roots flaring at the foot
for _, r in ipairs({ { {6,124},{0,118},{-4,128},{14,128} }, { {44,126},{30,122},{22,129},{54,129} }, { {198,126},{214,122},{224,129},{190,129} }, { {232,124},{240,118},{244,128},{226,128} } }) do
  c:part(c:poly(r), GV.ramp("#7a4a2f", { shade = "#5a3622", deep = "#3a2418" }), { cres = 3, deep = 5, gloss = false })
end
-- the doorway in the trunk: a hollow with a warm lamp and the seed pouch on a shelf
local dx = 120
c:part(c:rect(dx - 12, 104, dx + 12, 124):cut(c:ellipse(dx, 98, 14, 7)):add(c:ellipse(dx, 104, 12, 11)), GV.ramp("#3a2418", { shade = "#2a1a10", deep = "#1a0f08", rim = "#b07a50" }), { cres = 3, deep = 4, gloss = false })
c:fill(c:ellipse(dx, 112, 9, 9):clip(c:rect(dx - 10, 100, dx + 10, 123)), "#f0b060"); c:fill(c:ellipse(dx, 114, 6, 7):clip(c:rect(dx - 10, 100, dx + 10, 123)), "#f8d890")
c:fill(c:rect(dx - 10, 120, dx + 10, 123), "#6a4028"); c:fill(c:rect(dx - 10, 119, dx + 10, 119), "#a06a42")
c:part(c:ellipse(dx + 1, 116, 4, 3.5), GV.ramp("#b8452f", { shade = "#8a2f2a", deep = "#5a1a22" }), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(dx - 1, 111, dx + 3, 112), "#e8a317"); c:px(dx - 1, 113, "#e8a317")
c:px(dx - 2, 115, "#f5cf6a")
-- little round steps up to the door
c:part(c:rrect(dx - 8, 124, dx + 8, 127, 1), GV.ramp("#b07a45"), { gloss = false, cres = 2 })
-- rope ladder on the right hanging from the rim
c:fill(c:rect(190, 90, 190, 120), "#d9a660"); c:fill(c:rect(198, 90, 198, 120), "#d9a660")
for y = 94, 118, 6 do c:fill(c:rect(190, y, 198, y), "#b07a45") end

-- stump top, seen at a slant, with the rings
local TX, TY, RX, RY = 120, 80, 104, 28
c:part(c:ellipse(TX, TY, RX, RY), GV.ramp("#e8c88a", { shade = "#c89c60", deep = "#9a6a3a", rim = "#f8e0a8" }), { cres = 6, deep = 10, gloss = false })
local TONES = { "#e8c88a", "#d8ae6c" }
local n = 0
for i = 4, 52, 5 do
  local rx, ry = RX - i, RY - i * RY / RX
  if ry < 6 then break end
  c:fill(c:ellipse(TX, TY, rx, ry), TONES[(n % 2) + 1]); n = n + 1
  local ring = c:ellipse(TX, TY, rx, ry); ring:cut(c:ellipse(TX, TY, rx - 1, ry - 0.7))
  c:fill(ring, (n % 3 == 0) and "#8a5a3a" or "#b08050")
end
-- the whispering ring: gold-lit band
do
  local rx, ry = RX - 34, RY - 34 * RY / RX
  local ring = c:ellipse(TX, TY, rx, ry); ring:cut(c:ellipse(TX, TY, rx - 2, ry - 1.4))
  c:fill(ring, "#f5cf6a")
  for _, a in ipairs({ -50, -20, 12, 40, 70 }) do c:px(TX + a, TY + ry - 1, "#fff1c8") end
end
-- radial cracks
for _, k in ipairs({ { {TX+8,TY-2},{TX+36,TY-8},{TX+60,TY-12} }, { {TX-8,TY+2},{TX-40,TY+10},{TX-70,TY+6} } }) do c:seam(k, { free = true, on = 3, off = 0, gap = "#8a5a3a" }) end
-- the hollow at the centre: dark mouth with a lip
c:part(c:ellipse(TX, TY - 1, 20, 7), GV.ramp("#2a1a10", { shade = "#1a0f08", deep = "#0f0804", rim = "#d9a660" }), { cres = 2, deep = 3, gloss = false })
c:fill(c:ellipse(TX + 2, TY, 14, 4), "#3a2418"); c:fill(c:ellipse(TX + 3, TY + 1, 8, 2), "#4a2c1a")
c:px(TX - 6, TY, "#f5cf6a"); c:px(TX + 8, TY + 1, "#f5cf6a")
-- whisper curls rising off the gold ring
for _, w in ipairs({ { 58, 56 }, { 76, 52 }, { 174, 56 }, { 160, 52 } }) do
  c:px(w[1], w[2], "#fff1c8"); c:px(w[1] + 1, w[2] - 1, "#fff1c8"); c:px(w[1] + 2, w[2] - 1, "#fff1c8"); c:px(w[1] + 3, w[2] - 2, "#f5cf6a"); c:px(w[1] + 2, w[2] - 3, "#f5cf6a")
end
-- moss and little toadstools on the rim
for _, m in ipairs({ {30,92},{44,100},{200,96},{214,92},{172,106} }) do
  c:part(c:ellipse(m[1], m[2] - 7, 5, 2.5), GV.ramp("#7ab55c"), { flat = true, gloss = false, outline = false })
end
c:part(c:ellipse(206, 62, 3.5, 2.5), GV.ramp("#d6322b"), { flat = true, gloss = false }); c:fill(c:rect(206, 64, 206, 66), "#f2e4c0"); c:px(205, 61, "#f2e4c0"); c:px(207, 62, "#f2e4c0")
c:part(c:ellipse(30, 66, 3, 2), GV.ramp("#e07a3a"), { flat = true, gloss = false }); c:fill(c:rect(30, 67, 30, 69), "#f2e4c0")

-- the chipmunk lore-reader, on the stump, with a magnifying glass trained on a ring
local CX, CY = 70, 82
c:part(c:ellipse(CX + 9, CY - 3, 4, 7), GV.ramp("#c07a3a", { shade = "#9a5a2a", deep = "#6a3a1e" }), { cres = 2, deep = 3, gloss = false })        -- tail
c:part(c:ellipse(CX, CY, 7, 7), GV.ramp("#c9843f", { shade = "#a0612c", deep = "#6a3a1e", rim = "#e8b068" }), { cres = 3, deep = 5 })
c:part(c:ellipse(CX, CY + 2, 4, 4), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
c:limb({ {CX - 3, CY + 7}, {CX - 4, CY + 10} }, 2); c:limb({ {CX + 3, CY + 7}, {CX + 4, CY + 10} }, 2)
c:part(c:ellipse(CX - 1, CY - 11, 7, 6), GV.ramp("#c9843f", { shade = "#a0612c", deep = "#6a3a1e", rim = "#e8b068" }), { cres = 3, deep = 4 })
c:part(c:rect(CX - 7, CY - 17, CX - 5, CY - 14), GV.ramp("#c9843f"), { flat = true, gloss = false }); c:part(c:rect(CX + 4, CY - 17, CX + 6, CY - 14), GV.ramp("#c9843f"), { flat = true, gloss = false })
c:fill(c:rect(CX - 3, CY - 16, CX - 3, CY - 14), "#4a2c1a"); c:fill(c:rect(CX + 2, CY - 16, CX + 2, CY - 14), "#4a2c1a")   -- stripes
c:eye(CX - 6, CY - 12, true); c:eye(CX, CY - 12, true)
c:px(CX - 3, CY - 7, "#2a1a10"); c:px(CX - 2, CY - 6, "#2a1a10"); c:px(CX - 1, CY - 7, "#2a1a10")
-- magnifier held out to the left
c:limb({ {CX - 6, CY - 1}, {CX - 12, CY + 2} }, 2)
c:part(c:ellipse(CX - 15, CY + 5, 5, 4), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:fill(c:ellipse(CX - 15, CY + 5, 3, 2.5), "#c8ecdc"); c:px(CX - 17, CY + 4, "#fff3c8"); c:px(CX - 16, CY + 4, "#e8f8f0")
c:ground(CX, CY + 11, 10, 2)

-- foreground ferns, a fallen leaf drift, acorns
local function fern(x, y, h)
  for i = -4, 4 do c:fill(c:rect(x + i * 2, y - h + math.abs(i) * 2, x + i * 2 + 1, y), (i % 2 == 0) and "#4a8a3e" or "#6a9a3a") end
  c:px(x, y - h - 1, "#a4b86a")
end
fern(18, 134, 9); fern(70, 132, 7); fern(168, 133, 8); fern(226, 134, 9)
for _, l in ipairs({ {40,131,"#d9852a"},{96,132,"#c8452f"},{140,131,"#e8a317"},{196,132,"#d9852a"},{208,129,"#c8452f"} }) do c:part(c:ellipse(l[1], l[2], 3, 1.5), GV.ramp(l[3]), { flat = true, gloss = false, outline = false }) end
for _, a in ipairs({ {58,130},{154,129} }) do c:part(c:ellipse(a[1], a[2], 2, 2), GV.ramp("#b07a45"), { flat = true, gloss = false }); c:fill(c:rect(a[1] - 1, a[2] - 3, a[1] + 1, a[2] - 2), "#6a4028") end
L.finish(c, "wonder-thousand-rings-stump")
