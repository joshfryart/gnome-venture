-- wonder-the-oasis-that-moves.lua : a village street; today the oasis has set itself down in the square, appliqued onto the sand. Bright midday.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local FLAT = { gloss = false, rim = false, bounce = false, outline = false }
local SKYC = { "#6fb2da", "#82c0e2", "#98ccea", "#b0daee", "#cce6ee", "#e6f0e0", "#f5eccc" }
c:bands(c:rect(0, 0, W - 1, 96), SKYC, { dir = "v" })
c:fill(c:ellipse(206, 24, 9, 9), "#fff1c8"); c:fill(c:ellipse(206, 24, 6, 6), "#fff8e0")
L.cloud(c, 60, 22, 16, "#fbf6ea", "#d8e4ee"); L.cloud(c, 130, 12, 12, "#fbf6ea", "#d8e4ee")
-- dunes behind the village
c:part(c:poly({ {0,100},{0,76},{40,66},{90,78},{150,68},{200,78},{240,70},{240,100} }), GV.ramp("#ebc88e", { shade = "#d4a870", deep = "#b88858" }), { gloss = false, rim = false, bounce = false, outline = false, cres = 6 })

local function house(x0, y0, w, h, base, dome, flagc)
  local R = GV.ramp(base, { shade = nil })
  c:part(c:rect(x0, y0 - h, x0 + w, y0), R, { cres = 4, deep = 6, gloss = false })
  if dome then
    c:part(c:ellipse(x0 + w / 2, y0 - h, w / 2 - 1, w / 3):cut(c:rect(x0 - 2, y0 - h + 1, x0 + w + 2, y0 + 4)), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5, pale = true })
    c:fill(c:rect(x0 + w / 2, y0 - h - w / 3 - 3, x0 + w / 2, y0 - h - w / 3 + 1), "#8a4f2a")
    c:px(x0 + w / 2, y0 - h - w / 3 - 4, "#e8a317")
  else
    c:part(c:rect(x0 - 1, y0 - h - 2, x0 + w + 1, y0 - h), GV.ramp("#d9bb82"), { flat = true, gloss = false })
    -- roof beam ends
    for i = 0, 2 do c:fill(c:rect(x0 + 2 + i * (w // 3), y0 - h + 1, x0 + 3 + i * (w // 3), y0 - h + 2), "#7a4a1f") end
  end
  -- door (arched) and window
  local dx = x0 + w // 2 - 3
  c:part(c:rect(dx, y0 - 9, dx + 5, y0), GV.ramp("#6a4a8a", { shade = "#4e3a6a", deep = "#2a1a4a" }), { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(dx + 2.5, y0 - 9, 3, 2.5), GV.ramp("#6a4a8a"), FLAT)
  c:fill(c:rect(x0 + 3, y0 - h + 5, x0 + 6, y0 - h + 9), "#2a2250"); c:px(x0 + 3, y0 - h + 5, "#4e3a8a")
  if flagc then c:fill(c:rect(x0 + w - 3, y0 - h - 2, x0 + w - 1, y0 - h + 1), flagc) end
end
-- background row (small, hazy)
for _, b in ipairs({ {70,92,18,14},{96,92,14,10},{146,92,16,12},{166,92,16,16} }) do house(b[1], b[2], b[3], b[4], "#e0b888", b[3] > 15 and (b[1] % 2 == 0)) end
-- left and right mid houses
house(2, 108, 40, 34, "#e8c08a", true)
house(44, 106, 26, 22, "#d8a874", false, "#d6322b")
house(180, 106, 28, 24, "#d8a874", false, "#4aa0a8")
house(206, 110, 40, 38, "#e8c08a", true)
-- sand
c:part(L.below(c, function(x) return 104 + 2 * math.sin(x / 15) end), GV.ramp("#e8cc92", { shade = "#d0aa70", deep = "#b0885a" }), { cres = 6, deep = 9, gloss = false })
-- ripples in the sand
for _, r in ipairs({ {8,122,8},{30,128,10},{190,124,10},{216,129,9},{150,130,8},{96,128,7} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#d0aa70") end

-- the oasis: a green felt patch appliqued onto the square, stitched around the edge
local OX, OY = 122, 108
c:part(c:ellipse(OX, OY, 56, 19), GV.ramp("#7ab55c", { shade = "#5e9a48", deep = "#3a6a34", rim = "#a4d27a" }), { cres = 5, deep = 8, gloss = false })
c:stitch(c:ellipse(OX, OY, 56, 19), {})
-- peeling corner: the patch lifts at the left edge, showing the underside
c:part(c:poly({ {70,102},{76,98},{82,103},{74,107} }), GV.ramp("#5e9a48"), { flat = true, gloss = false })
-- pool
c:part(c:ellipse(OX - 6, OY + 3, 30, 9), GV.ramp("#3f8fb0", { shade = "#2f6290", deep = "#2a3c6c", rim = "#8fcbd8" }), { cres = 4, deep = 6, gloss = false })
for _, w in ipairs({ {100,108,6},{112,112,8},{126,107,6},{132,112,7},{108,104,4} }) do c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2]), "#8fcbd8") end
c:px(120, 109, "#e0f4ee"); c:px(121, 109, "#e0f4ee")
-- reeds
for _, x in ipairs({ 96, 99, 148, 151, 154 }) do c:fill(c:rect(x, OY - 7, x, OY + 1), "#4a8a3e"); c:px(x, OY - 8, "#7a4a1f"); c:px(x, OY - 9, "#7a4a1f") end

-- date palms
local function palm(x, y, hgt, lean)
  c:part(c:line({ {x, y}, {x + lean * 0.5, y - hgt * 0.5}, {x + lean, y - hgt} }, 4), GV.ramp("#8a5a2f"), { flat = true, outline = true, gloss = false })
  for i = 1, 4 do local ty = y - i * hgt / 5; c:fill(c:rect(x + lean * i / 5 - 1, ty, x + lean * i / 5 + 1, ty), "#5e2f1e") end
  local tx, ty = x + lean, y - hgt
  for _, f in ipairs({ { -22, 8 }, { 22, 8 }, { -15, -6 }, { 15, -6 }, { 0, -12 }, { -25, 18 }, { 25, 18 } }) do
    local R = GV.ramp((f[1] % 2 == 0) and "#5aa84a" or "#4a9a44", { shade = "#2f7a3a", deep = "#1f5a30" })
    c:part(c:poly({ {tx - 1, ty}, {tx + f[1] * 0.5, ty + f[2] * 0.5 - 6}, {tx + f[1], ty + f[2]}, {tx + f[1] * 0.55, ty + f[2] * 0.55 + 3}, {tx + 1, ty + 2} }), R, { cres = 2, deep = 3, gloss = false, outline = (math.abs(f[1]) < 20) })
  end
  c:part(c:ellipse(tx, ty + 3, 3, 2.5), GV.ramp("#d9852a"), { flat = true, gloss = false })  -- date cluster
  c:part(c:ellipse(tx - 4, ty + 5, 2, 2.5), GV.ramp("#d9852a"), { flat = true, gloss = false })
end
palm(92, 108, 54, -6); palm(162, 108, 62, 5); palm(128, 102, 40, 2)

-- falling treasures from the palms: coins, a gem, dates
local function coin(x, y) c:part(c:ellipse(x, y, 2.5, 2.5), GV.ramp("#e8a317"), { flat = true, gloss = false }); c:px(x - 1, y - 1, "#fff1c8") end
coin(100, 62); coin(150, 74); coin(138, 56); coin(86, 78)
c:part(c:poly({ {120,64},{123,67},{120,71},{117,67} }), GV.ramp("#5ab0d8"), { flat = true, gloss = false })
c:px(120, 66, "#e0f4ff")

-- the smug camel resting by the oasis (faces left), eyes half-lidded
local KX, KY = 192, 121
local camel = GV.ramp("#d9a660", { shade = "#b07a45", deep = "#7a4a2a", rim = "#f0cc90" })
c:limb({ {KX - 7, KY + 4}, {KX - 8, KY + 8} }, 3); c:limb({ {KX + 7, KY + 4}, {KX + 8, KY + 8} }, 3)
c:part(c:ellipse(KX, KY, 14, 7), camel, { cres = 4, deep = 6 })
c:part(c:ellipse(KX - 1, KY - 8, 4, 4), camel, { cres = 2, deep = 3, gloss = false })   -- humps
c:part(c:ellipse(KX + 8, KY - 7, 4, 4), camel, { cres = 2, deep = 3, gloss = false })
c:part(c:line({ {KX - 10, KY - 3}, {KX - 13, KY - 9}, {KX - 14, KY - 15} }, 5), camel, { flat = true, outline = true, gloss = false })
c:part(c:ellipse(KX - 15, KY - 18, 7, 6), camel, { cres = 3, deep = 4, gloss = false })
c:part(c:ellipse(KX - 21, KY - 16, 4.5, 3.5), GV.ramp("#f0cc90"), { flat = true, outline = true, gloss = false })
c:px(KX - 24, KY - 17, "#2a1a10"); c:px(KX - 24, KY - 16, "#2a1a10")
c:part(c:rect(KX - 11, KY - 26, KX - 9, KY - 23), camel, { flat = true, gloss = false })   -- ear
c:eye(KX - 18, KY - 21)
-- smug: lid over the top of the eye, a brow, a little smirk
c:fill(c:rect(KX - 18, KY - 21, KX - 14, KY - 19), "#d9a660"); c:fill(c:rect(KX - 18, KY - 18, KX - 14, KY - 18), "#2a1a10")
c:fill(c:rect(KX - 19, KY - 23, KX - 14, KY - 23), "#7a4a2a")
c:fill(c:rect(KX - 23, KY - 13, KX - 19, KY - 13), "#2a1a10"); c:px(KX - 24, KY - 14, "#2a1a10")
c:part(c:rect(KX - 4, KY - 3, KX + 12, KY + 1), GV.ramp("#d6322b"), { flat = true, gloss = false, outline = false })  -- saddle blanket
c:seam({ {KX - 4, KY - 1}, {KX + 12, KY - 1} }, { on = 2, off = 1 })
c:ground(KX, KY + 9, 16, 2)

-- a neighbour: round villager in a headscarf, hands on hips, regarding the oasis
local VX, VY = 34, 124
c:part(c:ellipse(VX, VY - 2, 8, 7), GV.ramp("#4aa0a8", { shade = "#2f7e8c", deep = "#1f5668" }), { cres = 4, deep = 6 })
c:limb({ {VX - 4, VY + 3}, {VX - 4, VY + 8} }, 2); c:limb({ {VX + 4, VY + 3}, {VX + 4, VY + 8} }, 2)
c:part(c:ellipse(VX, VY - 13, 8, 7.5), GV.ramp("#e9b98a"), { cres = 3, deep = 5 })
c:part(c:ellipse(VX, VY - 17, 9, 5):cut(c:rect(VX - 11, VY - 13, VX + 11, VY - 9)), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 4, pale = true, gloss = false })
c:seam({ {VX - 7, VY - 14}, {VX + 7, VY - 14} }, { free = true })
c:eye(VX - 7, VY - 13); c:eye(VX + 2, VY - 13)
c:fill(c:rect(VX - 2, VY - 7, VX + 1, VY - 7), "#2a1a10")
c:part(c:rrect(VX + 7, VY - 6, VX + 12, VY + 3, 2), GV.ramp("#b07a45"), { flat = true, gloss = false })  -- water jug
c:ground(VX, VY + 9, 11, 2)
-- drag marks in the sand where the oasis arrived from the left
for _, m in ipairs({ {4,134},{12,133},{20,132},{28,131}, }) do c:fill(c:rect(m[1], m[2], m[1] + 5, m[2]), "#d0aa70") end
L.finish(c, "wonder-the-oasis-that-moves")
