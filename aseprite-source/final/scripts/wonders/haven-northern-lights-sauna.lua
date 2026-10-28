-- haven-northern-lights-sauna.lua : "Northern Lights Sauna. Steam and rest; Hardiness buff." NWE zone 4, lakeside log sauna at blue hour with faint aurora.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 74
local NF = { gloss = false, rim = false, bounce = false, outline = false }
local function nf(t) local o = {}; for k, v in pairs(NF) do o[k] = v end; for k, v in pairs(t or {}) do o[k] = v end; return o end

c:bands(c:rect(0, 0, W - 1, HOR), { "#1c1a48", "#26225a", "#34327a", "#46489a", "#5e66b0", "#8a86c0", "#c0a0b8" }, { dir = "v" })
L.stars(c, 40, 40, 5)
-- faint aurora ribbon, green/teal, a few columns
for x = 0, W - 1 do
  local yb = 34 + math.floor(math.sin(x / 15) * 6); local h = 14 + math.floor(math.sin(x / 9 + 2) * 4)
  for y = yb - h, yb do local t = (y - (yb - h)) / h; c:px(x, y, (t < 0.5) and "#3a7a8a" or "#5acf8a") end
  if x % 2 == 0 then c:px(x, yb + 1, "#8cf0b8") end
end
-- far forest line + hills
c:part(c:poly({ {0,HOR+3},{0,66},{50,60},{100,66},{160,58},{W,64},{W,HOR+3} }), GV.ramp("#3a4a7a"), nf{ cres = 3, deep = 5 })
for x = 4, W, 7 do local h = 6 + (x * 5 % 5); c:fill(c:poly({ {x - 3, 66}, {x, 66 - h}, {x + 3, 66} }), "#2a3a5a") end
-- frozen lake: pale ice with sky tint, cracks, sheen
c:bands(c:rect(0, HOR + 3, W - 1, H - 1), { "#9ab8d8", "#a8c4e0", "#b8d0e8", "#c8dcf0", "#d8e8f4" }, { dir = "v" })
for _, l in ipairs({ { {20,90},{40,92},{52,90} }, { {150,86},{170,88},{190,86} }, { {80,104},{100,106} }, { {190,110},{214,112} } }) do c:seam(l, { free = true, on = 2, off = 1, gap = "#7a98bc" }) end
for _, s in ipairs({ {30,96,8},{110,84,10},{200,98,9},{60,118,10},{150,122,8} }) do c:fill(c:rect(s[1], s[2], s[1] + s[3], s[2]), "#f0f6fc") end
-- far shore bump (the sauna sits on a snowy bank on the right)
local bank = c:poly({ {96,H},{104,102},{130,96},{170,94},{W,96},{W,H} })
c:part(bank, GV.ramp("#eef4fa"), { cres = 6, deep = 10, gloss = false })

-- sauna cabin: dark log walls, turf-ish snowy roof, chimney + steam, glowing window
local x0, x1 = 134, 214
c:part(c:rect(x0, 64, x1, 100), GV.ramp("#7a4a30"), { cres = 5, deep = 9, gloss = false })
for y = 70, 98, 6 do c:seam({ {x0 + 1, y}, {x1 - 1, y} }, { free = true, on = 3, off = 0, gap = "#4a2c1a" }) end
for y = 67, 100, 6 do c:part(c:ellipse(x0, y, 2, 3), GV.ramp("#a8693a"), { flat = true, gloss = false, outline = false }); c:part(c:ellipse(x1, y, 2, 3), GV.ramp("#a8693a"), { flat = true, gloss = false, outline = false }) end
c:part(c:poly({ {x0 - 8, 66}, {x0 + 8, 44}, {x1 - 8, 44}, {x1 + 8, 66} }), GV.ramp("#5a3a2a"), { cres = 5, deep = 8, gloss = false })
-- snow blanket on roof
local snowroof = c:poly({ {x0 - 8, 66}, {x0 + 8, 44}, {x1 - 8, 44}, {x1 + 8, 66}, {x1 + 8, 60}, {x1 - 6, 52}, {x0 + 6, 52}, {x0 - 8, 60} })
c:part(snowroof:clip(c:poly({ {x0 - 8, 66}, {x0 + 8, 44}, {x1 - 8, 44}, {x1 + 8, 66} })), GV.ramp("#f0f6fc"), { cres = 3, deep = 5, gloss = false, outline = false })
for x = x0 - 4, x1 + 4, 8 do c:fill(c:rect(x, 66, x + 2, 68 + (x % 3)), "#f0f6fc") end   -- icicles / snow drips
-- chimney
c:part(c:rect(186, 34, 196, 50), GV.ramp("#8a8a90"), { cres = 3, deep = 5, gloss = false })
c:part(c:rect(184, 32, 198, 35), GV.ramp("#f0f6fc"), { flat = true, gloss = false })
-- steam, drifting up-left
for _, p in ipairs({ {190,26,7},{182,18,9},{192,10,8},{180,6,6},{170,2,5} }) do
  local m = c:ellipse(p[1], p[2], p[3], p[3] * 0.75)
  c:fill(m, "#f4f0fa"); c:fill(m:copy():clip(c:rect(0, p[2] + 2, W, H)), "#c8cae8")
end
-- door and the glowing window, plus a wood-pile
c:part(c:rrect(156, 74, 172, 100, 3), GV.ramp("#a8693a"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(159, 78, 169, 85), "#f5cf6a"); c:fill(c:rect(163, 78, 164, 85), "#7a4a1f")
c:part(c:rect(182, 76, 204, 92), GV.ramp("#f5b860"), { cres = 2, deep = 4, gloss = false, contour = "#2a1a10" })
c:fill(c:rect(182, 76, 204, 78), "#e0501f"); c:fill(c:rect(192, 76, 193, 92), "#7a4a1f")
-- birch whisk bundles hanging by the door, a towel on a peg
c:fill(c:rect(176, 80, 176, 82), "#2a1a10"); c:part(c:ellipse(176, 86, 2.5, 4), GV.ramp("#4a8a3a"), { flat = true, gloss = false, outline = false })
for i = 0, 4 do for r = 0, 2 do c:part(c:ellipse(138 + i * 3, 96 - r * 3, 2, 1.5), GV.ramp("#e8d8b0"), { flat = true, gloss = false, outline = false }) end end
-- boardwalk from the cabin to the ice hole
c:part(c:rect(104, 102, 168, 105), GV.ramp("#a8793a"), { gloss = false, cres = 2, deep = 3 })
c:part(c:rect(76, 112, 134, 115), GV.ramp("#a8793a"), { gloss = false, cres = 2, deep = 3 })
for x = 80, 130, 6 do c:fill(c:rect(x, 112, x, 115), "#6a4420") end
-- the ice-hole (avanto): dark water, snow edge, a small ladder
c:part(c:ellipse(46, 116, 18, 6), GV.ramp("#eef4fa"), { cres = 3, deep = 5, gloss = false, outline = false })
c:part(c:ellipse(46, 116, 14, 4), GV.ramp("#2f5a8a"), { flat = true, gloss = false, outline = false })
c:fill(c:rect(42, 115, 50, 115), "#4a8ab8"); c:fill(c:rect(38, 118, 54, 118), "#244a74")
c:fill(c:rect(54, 108, 54, 117), "#a8a8b0"); c:fill(c:rect(58, 108, 58, 117), "#a8a8b0"); for y = 110, 116, 3 do c:fill(c:rect(54, y, 58, y), "#a8a8b0") end
-- pine trees (snow-laden) at left and far right
local function pine(x, y, s)
  for k = 0, 3 do
    local w = (13 - k * 3) * s
    c:part(c:poly({ {x - w, y - k * 8 * s + 8 * s}, {x, y - k * 8 * s - 4 * s}, {x + w, y - k * 8 * s + 8 * s} }), GV.ramp("#2a5a4a"), { cres = 3, deep = 5, gloss = false })
    c:fill(c:poly({ {x - w * 0.5, y - k * 8 * s + 2}, {x, y - k * 8 * s - 4 * s}, {x + w * 0.5, y - k * 8 * s + 2} }), "#eef4fa")
  end
  c:part(c:rect(x - 1, y + 8 * s, x + 1, y + 11 * s), GV.ramp("#4a2c1a"), { flat = true, gloss = false, outline = false })
end
pine(14, 96, 1.1); pine(34, 100, 0.8); pine(226, 106, 1.0)
-- chibi bear cub in a towel by the ice hole, steaming, looking pleased
local bx, by = 84, 108
c:part(c:ellipse(bx, by, 9, 10), GV.ramp("#f2e4c0"), { cres = 4, deep = 6, gloss = false })     -- towel body
c:seam({ {bx - 7, by + 2}, {bx + 7, by + 2} }, { free = true, on = 2, off = 1, gap = "#d6322b" })
c:part(c:ellipse(bx, by - 11, 8, 7), GV.ramp("#8a5a3a"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(bx - 7, by - 16, 3, 3), GV.ramp("#8a5a3a"), { flat = true, gloss = false }); c:part(c:ellipse(bx + 7, by - 16, 3, 3), GV.ramp("#8a5a3a"), { flat = true, gloss = false })
c:part(c:ellipse(bx, by - 8, 4, 3), GV.ramp("#d8b888"), { flat = true, gloss = false, outline = false })
c:eye(bx - 6, by - 14, true); c:eye(bx + 1, by - 14, true); c:px(bx - 1, by - 9, "#2a1a10"); c:px(bx, by - 9, "#2a1a10")
c:part(c:rect(bx - 6, by - 20, bx + 6, by - 18), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false })   -- towel on head
c:px(bx - 3, by - 24, "#f4f0fa"); c:px(bx + 2, by - 27, "#f4f0fa"); c:px(bx - 1, by - 30, "#f4f0fa")  -- steam wisps
c:ground(bx, by + 10, 10, 2, "#9ab8d8")
c:ground(172, 101, 30, 2, "#c8dcf0")
L.finish(c, "haven-northern-lights-sauna")
