-- delve-rose-red-canyon-city.lua : MENA zone 4 delve. "A city carved in canyon walls."
-- Warm afternoon: rose-red banded canyon walls framing a strip of sky, a columned facade carved into the rock at the end of the gorge,
-- tiers of little carved doors and windows with stairs and lanterns, and a chibi camel resting on the sand.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local SLUG = "delve-rose-red-canyon-city"
local FL = { gloss = false, rim = false, bounce = false, outline = false }
local function fl(t) local r = {}; for k, v in pairs(FL) do r[k] = v end; for k, v in pairs(t or {}) do r[k] = v end; return r end
local ROSE = GV.ramp("#c4685a", { gloss = "#f0a890", rim = "#e8907a", shade = "#a04a50", deep = "#6a2a40" })

-- narrow sky strip high above (warm, hazy)
c:bands(c:rect(0, 0, W - 1, 60), { "#8fc4e2", "#a4d0e8", "#c8dcd8", "#f0dcb8", "#f8cc98" }, { dir = "v" })
L.cloud(c, 120, 20, 14, "#fff1d8", "#f0d0b0")
-- far gorge: lighter, hazier rock at the end
c:part(c:rect(70, 28, 170, 110), GV.ramp("#d89a84", { shade = "#b87a78", deep = "#8a5a66" }), fl({ cres = 8, deep = 12 }))
c:fill(c:rect(70, 28, 170, 34), "#e8b098")
-- strata bands on far rock
for _, y in ipairs({ 40, 52, 66, 80 }) do c:fill(c:rect(70, y, 170, y + 1), "#c07a78") end

-- the carved facade (a grand tomb-temple), centred, with columns, pediment, urn and a doorway
local FX = 120
local fac = c:rect(FX - 34, 54, FX + 34, 110)
c:part(fac, GV.ramp("#e09a80", { shade = "#b8686a", deep = "#7a4256" }), { cres = 6, deep = 9, gloss = false })
-- upper tier: pediment and tholos
c:part(c:poly({ {FX - 30, 66}, {FX, 52}, {FX + 30, 66} }), GV.ramp("#eaa88c", { shade = "#c07a78", deep = "#7a4256" }), { cres = 4, deep = 6, gloss = false })
c:part(c:rect(FX - 8, 56, FX + 8, 80), GV.ramp("#e8a088", { shade = "#b8686a", deep = "#7a4256" }), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(FX, 56, 5, 4), GV.ramp("#e09a80"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(FX, 49, 3, 3), GV.ramp("#e8a317"), { flat = true })
-- columns (6) with capitals
for i = 0, 5 do
  local x = FX - 30 + i * 12
  c:part(c:rect(x, 68, x + 4, 106), GV.ramp("#f0b89c", { shade = "#c07a78", deep = "#8a5266" }), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x - 1, 66, x + 5, 67), "#f8d0b0"); c:fill(c:rect(x - 1, 104, x + 5, 105), "#c07a78")
end
-- dark doorway with lamp glow
c:part(c:rrect(FX - 7, 82, FX + 7, 108, 4), GV.ramp("#2a1d2e"), { gloss = false, rim = false, bounce = false, outline = false, contour = "#2a1a10" })
c:fill(c:ellipse(FX, 96, 4, 5):clip(c:rect(0, 0, W, 108)), "#8a5a30"); c:fill(c:ellipse(FX, 98, 2, 3), "#f5cf6a"); c:px(FX, 97, "#fff1c8")
-- carved frieze dashes
c:seam({ {FX - 28, 72}, {FX + 28, 72} }, { free = true, on = 2, off = 1, gap = "#a04a50" })
-- steps up to the facade
for i = 0, 3 do c:part(c:rect(FX - 22 + i * 3, 106 + i * 2, FX + 22 - i * 3, 107 + i * 2), GV.ramp("#e8c0a0"), { flat = true, gloss = false, outline = false }) end

-- left canyon wall: big banded cliff with carved tiers of doors & windows
local lw = c:poly({ {0,0},{72,0},{64,20},{70,44},{56,64},{66,92},{58,112},{40,H},{0,H} })
c:part(lw, ROSE, { cres = 8, deep = 12, gloss = false })
local rw = c:poly({ {W,0},{168,0},{176,20},{170,44},{182,64},{174,92},{184,112},{200,H},{W,H} })
c:part(rw, ROSE, { cres = 8, deep = 12, gloss = false })
-- sandstone banding: wavy light/dark stripes clipped to both walls
local walls = lw:copy(); walls:add(rw)
local band_cols = { "#e08a78", "#b8584a", "#d9806a", "#a84a48" }
for i = 0, 11 do
  local y0 = 8 + i * 10
  local bm = c:mask()
  for x = 0, W - 1 do
    local yy = y0 + math.floor(math.sin(x / 11 + i) * 2 + 0.5)
    bm:set(x, yy); bm:set(x, yy + 1)
  end
  c:fill(bm:clip(walls), band_cols[(i % 4) + 1])
end
-- carved little doors / windows with lamps on the cliff faces (left)
local function nook(x, y, w, h, lit)
  c:fill(c:rect(x - 1, y - 1, x + w + 1, y + h), "#7a3a44")
  c:fill(c:rect(x, y, x + w, y + h), lit and "#f5cf6a" or "#2a1d2e")
  c:fill(c:rect(x, y, x + w, y), lit and "#fff1c8" or "#4a2d44")
end
for _, n in ipairs({ {8,16,5,6,true},{22,26,5,6,false},{38,18,5,7,true},{50,34,4,6,false},{12,46,5,6,false},{28,54,5,7,true},{46,62,4,6,true},{6,70,5,7,false},{26,84,6,8,false},{44,92,5,7,true} }) do nook(n[1], n[2], n[3], n[4], n[5]) end
for _, n in ipairs({ {192,16,5,6,false},{208,24,5,6,true},{226,14,5,7,true},{184,34,4,6,true},{200,46,5,6,false},{220,40,5,7,false},{190,62,5,6,true},{212,60,5,7,true},{230,70,5,7,false},{196,82,5,7,false},{216,90,6,8,true} }) do nook(n[1], n[2], n[3], n[4], n[5]) end
-- carved stairways zigzagging between tiers
for _, st in ipairs({ { {10,24},{30,32},{16,44},{34,52} }, { {188,24},{206,34},{190,48},{208,56} } }) do
  c:seam(st, { free = true, on = 3, off = 1, gap = "#6a2a40" })
end
-- gnome-sized rooftop hats of carved houses peeking: small domes on ledges
for _, d in ipairs({ {20,108},{190,108} }) do
  c:part(c:ellipse(d[1], d[2], 6, 4):clip(c:rect(0, 0, W, d[2])), GV.ramp("#e8c26a"), { cres = 2, deep = 3, gloss = false })
end
-- hanging banners and lantern strings across the gorge
c:seam({ {70, 40}, {94, 46}, {120, 44}, {148, 46}, {172, 40} }, { free = true, on = 2, off = 1, gap = "#6a2a40" })
for i, x in ipairs({ 84, 98, 112, 128, 142, 156 }) do
  local y = 45 + ({ 1,1,0,0,1,1 })[i]
  c:fill(c:rect(x, y, x + 3, y + 5), ({ "#d6322b","#e8a317","#4e8a9a","#e46a9b","#e8a317","#d6322b" })[i])
  c:px(x + 1, y + 6, ({ "#d6322b","#e8a317","#4e8a9a","#e46a9b","#e8a317","#d6322b" })[i])
end

-- sand floor of the canyon
c:part(L.below(c, function(x) return 108 + math.sin(x / 25) * 2 end), GV.ramp("#e8c890", { shade = "#c09a68", deep = "#8a6a48" }), { cres = 6, deep = 10, gloss = false })
-- ripples and pebbles
for i = 0, 10 do local x = (i * 29 + 5) % 220; local y = 114 + (i * 7) % 12; c:fill(c:rect(x, y, x + 8, y), "#d0a870") end
for _, p in ipairs({ {40,122,3,1},{90,126,3,1},{200,120,3,1},{220,126,2,1} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#a8847a"), { flat = true, gloss = false }) end
-- palm in a pot / date palm at left foot
c:part(c:rect(14, 98, 16, 116), GV.ramp("#a8582f"), { flat = true, gloss = false })
for _, f in ipairs({ { {15,98},{6,94},{2,100} }, { {15,98},{24,93},{30,99} }, { {15,98},{10,90},{8,86} }, { {15,98},{20,89},{23,85} } }) do
  c:part(c:line({ f[1], f[2], f[3] }, 2), GV.ramp("#4a8a3e"), { flat = true, gloss = false, outline = false })
end
c:px(14, 99, "#e8a317"); c:px(16, 100, "#e8a317")

-- the camel: chibi dromedary resting, with a striped saddle blanket
local KX, KY = 148, 110
local C = GV.ramp("#d9a660", { gloss = "#f5d89a", shade = "#a8743a", deep = "#6a4020" })
-- tail and back legs
for _, dx in ipairs({ -18, -8 }) do c:part(c:ellipse(KX + dx, KY + 11, 4, 3), C, { cres = 2, deep = 3, gloss = false }) end
for _, dx in ipairs({ 8, 18 }) do c:part(c:ellipse(KX + dx, KY + 11, 4, 3), C, { cres = 2, deep = 3, gloss = false }) end
-- body
c:part(c:ellipse(KX, KY + 2, 22, 10), C, { cres = 5, deep = 8 })
-- hump
c:part(c:ellipse(KX - 2, KY - 9, 8, 7), C, { cres = 3, deep = 5 })
-- saddle blanket (woven stripes)
c:part(c:rect(KX - 12, KY - 6, KX + 8, KY + 8), GV.ramp("#d6322b"), { cres = 2, deep = 4, gloss = false, outline = false, contour = "#2a1a10" })
for i, col in ipairs({ "#e8a317", "#4e8a9a", "#e8a317" }) do c:fill(c:rect(KX - 12, KY - 3 + i * 3, KX + 8, KY - 3 + i * 3), col) end
for x = KX - 11, KX + 7, 3 do c:px(x, KY + 9, "#e8a317") end
-- neck and head, facing left
c:part(c:poly({ {KX + 14, KY - 4}, {KX + 22, KY - 20}, {KX + 30, KY - 22}, {KX + 28, KY - 4} }), C, { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(KX + 28, KY - 18, 11, 9), C, { cres = 4, deep = 6 })
c:part(c:ellipse(KX + 36, KY - 14, 5, 4), GV.ramp("#f2d8a8", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
c:px(KX + 38, KY - 15, "#2a1a10"); c:px(KX + 38, KY - 13, "#2a1a10")
for _, p in ipairs({ {32,-12},{33,-11},{34,-11},{35,-11} }) do c:px(KX + p[1] + 3, KY + p[2] + 3, "#2a1a10") end
c:part(c:ellipse(KX + 22, KY - 28, 3, 3), C, { cres = 1, deep = 2, gloss = false }); c:part(c:ellipse(KX + 32, KY - 28, 3, 3), C, { cres = 1, deep = 2, gloss = false })
c:eye(KX + 25, KY - 22)
-- tassel on the bridle
c:px(KX + 36, KY - 8, "#d6322b"); c:px(KX + 36, KY - 7, "#d6322b"); c:px(KX + 36, KY - 6, "#e8a317")
c:ground(KX, KY + 14, 26, 2)

-- floating dust motes in the light shaft
for _, p in ipairs({ {96,70},{120,40},{104,90},{136,76},{86,56} }) do c:px(p[1], p[2], "#fff1c8") end

L.finish(c, SLUG)
