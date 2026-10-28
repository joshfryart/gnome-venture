-- lair-of-the-grey-wolf-king.lua : Boss lair (EE, zone 4). The Grey Wolf King on a high ridge crag, crowned, in front of a rising moon. Cold twilight. Params out= ase=
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 96
L.SKY.cold = { "#2e3a6c", "#3e4c80", "#566a9a", "#7a8ab4", "#a4a4c4", "#d4b4bc", "#f0c0a0" }
L.sky(c, "cold", HOR)
L.stars(c, 30, 40, 5)
-- big pale moon
c:fill(c:ellipse(120, 58, 38, 38), "#c3c8e4"); c:fill(c:ellipse(120, 58, 34, 34), "#dcdff0"); c:fill(c:ellipse(120, 58, 30, 30), "#eef0f8")
for _, p in ipairs({ {100,44,5,4},{140,70,6,4},{108,76,3,2},{134,40,3,2} }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#c3c8e4") end
for _, cl in ipairs({ {40,30,16},{204,24,18},{60,60,14},{190,54,16} }) do L.cloud(c, cl[1], cl[2], cl[3], "#7a8ab4", "#a4a4c4") end
-- distant snowy ridges
local function ridge(base, amp, f, ph, col, snow)
  local m = L.below(c, function(x) return base + math.sin(x * f + ph) * amp + math.sin(x * f * 2.3 + ph) * amp * 0.4 end)
  c:fill(m, col)
  if snow then
    local s = m:copy(); s:cut(L.below(c, function(x) return base + math.sin(x * f + ph) * amp + math.sin(x * f * 2.3 + ph) * amp * 0.4 + 5 end)); c:fill(s, snow)
  end
end
ridge(78, 12, 0.045, 0, "#5a6a9a", "#c8d0e8"); ridge(88, 9, 0.06, 2, "#46567c", "#b4bcd8")
-- pine forest band on the ridge
local function pine(x, y, h, col)
  for i = 0, 2 do c:fill(c:poly({ {x - 6 + i * 1.5, y - h * i / 3 + 2}, {x, y - h * (i + 1) / 3 - 3}, {x + 6 - i * 1.5, y - h * i / 3 + 2} }), col) end
end
for x = 4, 236, 11 do pine(x, 104 + (x * 7) % 5, 18 + (x * 13) % 8, "#2f4a4a") end
-- snowy foreground ground
c:part(L.below(c, function(x) return 112 + math.sin(x * 0.05) * 3 end), GV.ramp("#e8ecf4"), { outline = false, gloss = false, cres = 3, deep = 4 })
-- the crag with a den arch
local crag = c:poly({ {64,H},{74,116},{88,104},{104,102},{136,102},{152,104},{166,116},{176,H} })
c:part(crag, GV.ramp("#8b8f96"), { cres = 8, deep = 12, gloss = false })
c:part(c:ellipse(120, 102, 30, 4), GV.ramp("#e8ecf4"), { flat = true, outline = false })
for _, l in ipairs({ { {80,118},{92,114},{98,120} }, { {144,114},{156,118},{162,126} } }) do c:seam(l, { free = true, on = 3, off = 0, gap = "#2a1a10" }) end
-- den: dark arch with glowing small eyes inside
c:part(c:rrect(106, 118, 134, H - 1, 12), GV.ramp("#291d4a"), { outline = true, gloss = false, cres = 3, deep = 4 })
c:fill(c:rect(108, 124, 132, H - 3), "#1c1a48")
for _, x in ipairs({ 112, 126 }) do c:fill(c:rect(x, 126, x + 2, 127), "#f5cf6a") end
-- pine on each side, big
pine(30, 124, 36, "#2f5a2a"); pine(46, 130, 30, "#4a8a3e"); pine(206, 124, 38, "#2f5a2a"); pine(192, 130, 28, "#4a8a3e")
for _, x in ipairs({ 30, 206 }) do c:fill(c:rect(x - 1, 124, x + 1, 130), "#5e2f1e") end
-- carved wooden totem with red embroidered cloth (Slavic touch) on the left of the crag
c:part(c:rect(60, 84, 64, 116), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
c:part(c:poly({ {64,88},{78,90},{74,100},{78,110},{64,108} }), "red", { cres = 2, deep = 4, gloss = false })
c:seam({ {66,94},{74,96} }, { free = true, on = 2, off = 1 })
c:part(c:ellipse(62, 82, 4, 4), GV.ramp("#e8d9b0"), { flat = true })

-- the Grey Wolf King
local G = GV.ramp("#8b92a0")
local CX = 120
c:part(c:ellipse(CX + 24, 90, 7, 13), G, { cres = 3, deep = 4, gloss = false })             -- tail
c:part(c:ellipse(CX + 26, 82, 3, 4), GV.ramp("#f2e4c0"), { flat = true, outline = false })
c:part(c:ellipse(CX, 92, 24, 20), G, { cres = 6, deep = 9 })                                  -- body
c:part(c:ellipse(CX, 94, 11, 14), GV.ramp("#e8e0d0", { dot = "#fff3c8" }), { cres = 3, deep = 4, gloss = false }) -- chest
for _, sx in ipairs({ -10, 10 }) do c:part(c:rrect(CX + sx - 4, 98, CX + sx + 3, 112, 2), G, { cres = 3, deep = 4, gloss = false }) end
for _, sx in ipairs({ -10, 10 }) do c:part(c:ellipse(CX + sx, 112, 6, 3), GV.ramp("#e8e0d0"), { flat = true }) end
-- head: ears, ruff, face
for _, s in ipairs({ -1, 1 }) do
  c:part(c:poly({ {CX + s * 9, 54}, {CX + s * 20, 36}, {CX + s * 22, 56} }), G, { cres = 3, deep = 4, gloss = false })
  c:part(c:poly({ {CX + s * 13, 53}, {CX + s * 19, 43}, {CX + s * 20, 54} }), GV.ramp("#d9885a"), { flat = true, outline = false })
  c:part(c:poly({ {CX + s * 14, 70}, {CX + s * 30, 72}, {CX + s * 20, 80} }), GV.ramp("#e8e0d0"), { flat = true, outline = false })
end
c:part(c:ellipse(CX, 66, 22, 16), G, { cres = 5, deep = 7 })
c:part(c:ellipse(CX, 74, 11, 8), GV.ramp("#e8e0d0", { dot = "#fff3c8" }), { cres = 3, deep = 4, gloss = false })
c:fill(c:rect(CX - 3, 69, CX + 2, 71), "#2a1a10"); c:fill(c:rect(CX - 2, 72, CX - 2, 74), "#2a1a10"); c:fill(c:rect(CX + 1, 72, CX + 1, 74), "#2a1a10")
c:fill(c:rect(CX - 5, 77, CX + 4, 77), "#2a1a10")
c:fill(c:rect(CX - 4, 78, CX - 3, 79), "#f2e4c0"); c:fill(c:rect(CX + 3, 78, CX + 4, 79), "#f2e4c0")
c:eye(CX - 14, 58); c:eye(CX + 9, 58)
for k = 0, 4 do c:px(CX - 15 + k, (k < 3) and 56 or 57, "#2a1a10"); c:px(CX + 15 - k, (k < 3) and 56 or 57, "#2a1a10") end
-- gold crown with three points and jewels
local crown = c:poly({ {CX - 10, 54}, {CX - 10, 44}, {CX - 5, 49}, {CX, 41}, {CX + 5, 49}, {CX + 10, 44}, {CX + 10, 54} })
c:part(crown, GV.ramp("#e8a317"), { cres = 3, deep = 4 })
c:px(CX, 51, "#d6322b"); c:px(CX - 6, 51, "#3f8fb0"); c:px(CX + 6, 51, "#3f8fb0")
for _, p in ipairs({ {CX - 10, 43}, {CX, 40}, {CX + 10, 43} }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#fff1c8") end
-- small pack wolves watching on the ridge
local function pup(x, y)
  c:part(c:line({ {x - 6, y}, {x - 10, y - 5} }, 2), GV.ramp("#6a7280"), { flat = true })
  c:part(c:ellipse(x, y, 7, 4), GV.ramp("#6a7280"), { flat = true })
  c:part(c:poly({ {x + 3, y - 6}, {x + 4, y - 12}, {x + 6, y - 7} }), GV.ramp("#6a7280"), { flat = true })
  c:part(c:poly({ {x + 7, y - 7}, {x + 9, y - 12}, {x + 10, y - 6} }), GV.ramp("#6a7280"), { flat = true })
  c:part(c:ellipse(x + 6, y - 4, 4, 3.5), GV.ramp("#6a7280"), { flat = true })
  c:part(c:ellipse(x + 9, y - 2, 2.5, 1.5), GV.ramp("#eef0f8"), { flat = true, outline = false })
  c:px(x + 4, y - 5, "#2a1a10"); c:px(x + 7, y - 5, "#2a1a10"); c:px(x + 11, y - 2, "#2a1a10")
end
pup(30, 112); pup(214, 112)
-- snow drifts and flakes
for _, p in ipairs({ {16,20},{50,12},{84,26},{150,14},{176,36},{222,18},{40,44},{100,8},{196,46},{12,70},{230,64} }) do c:px(p[1], p[2], "#eef0f8") end
c:ground(CX, 112, 22, 2)
L.finish(c, "lair-of-the-grey-wolf-king")
