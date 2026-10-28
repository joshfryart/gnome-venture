-- wonder-sunken-gnome-galleon.lua : CB zone 2. A tiny ship lies on its side in the reef shallows, hold full of barnacled chests and one very surprised octopus.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

-- clear Caribbean shallows, lit from above
c:bands(c:rect(0, 0, W - 1, H - 1), { "#b8e8e0", "#8fd8dc", "#6cc6d4", "#4eb2cc", "#3c9ec0", "#318ab0", "#2a78a0", "#256890" }, { dir = "v" })
-- sun shafts
for _, s in ipairs({ {20,60},{70,50},{140,56},{200,64} }) do
  c:fill(c:poly({ {s[1],0},{s[1]+14,0},{s[1]+s[2]+8,100},{s[1]+s[2]-18,100} }), "#8fd8dc")
end
c:fill(c:poly({ {74,0},{80,0},{120,100},{108,100} }), "#b8e8e0")
-- surface glitter along the top
for x = 4, 230, 14 do c:fill(c:rect(x, 4, x + 5, 4), "#e6f8f0") end
-- distant reef silhouettes
c:fill(c:ellipse(30, 96, 30, 14), "#3c8aac"); c:fill(c:ellipse(210, 92, 34, 16), "#3c8aac")

-- sandy floor
local floor = L.below(c, function(x) return 108 + 4 * math.sin(x / 19) + 2 * math.sin(x / 7) end)
c:part(floor, GV.ramp("#e2c88a"), { cres = 5, deep = 8, gloss = false, outline = false })
for _, r in ipairs({ {20,118,8},{70,122,10},{120,126,12},{170,120,8},{214,124,10},{44,128,6} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#c9a96e") end

-- the galleon, heeled over --------------------------------------------------------------------------
local ANG = math.rad(-22)
local OX, OY = 104, 82
local function R(x, y) return OX + x * math.cos(ANG) - y * math.sin(ANG), OY + x * math.sin(ANG) + y * math.cos(ANG) end
local function RP(pts) local o = {}; for _, p in ipairs(pts) do local x, y = R(p[1], p[2]); o[#o + 1] = { math.floor(x + 0.5), math.floor(y + 0.5) } end; return o end
-- mast and torn sail (behind hull)
local mx0, my0 = R(6, -6); local mx1, my1 = R(6, -58)
c:fill(c:line({ {math.floor(mx0), math.floor(my0)}, {math.floor(mx1), math.floor(my1)} }, 3), "#5e2f1e")
c:part(c:poly(RP({ {10,-52},{40,-46},{34,-34},{42,-24},{12,-16} })), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 4, deep = 6, gloss = false, contour = "#74462a" })
c:seam(RP({ {14,-44},{34,-40} }), { free = true, on = 2, off = 1 })
-- bowsprit-ish yard
local yx0, yy0 = R(-18, -48); local yx1, yy1 = R(30, -50)
c:fill(c:line({ {math.floor(yx0), math.floor(yy0)}, {math.floor(yx1), math.floor(yy1)} }, 2), "#7a4a1f")
-- crow's nest
c:part(c:poly(RP({ {0,-62},{14,-62},{12,-56},{2,-56} })), GV.ramp("#a8582f"), { cres = 2, deep = 3, gloss = false })
-- hull
local hull = c:poly(RP({ {-62,-8},{-40,-14},{56,-14},{74,-26},{64,6},{46,22},{-44,22},{-60,10} }))
c:part(hull, GV.ramp("#b07a45"), { cres = 6, deep = 10, gloss = false, contour = "#4a2c1a" })
-- plank seams and a gold wale
for _, y in ipairs({ -2, 8, 16 }) do c:seam(RP({ {-54,y},{62,y} }), { free = true, on = 3, off = 0, gap = "#5e2f1e" }) end
c:seam(RP({ {-58,-8},{66,-12} }), { free = true })
-- portholes
for _, x in ipairs({ -38, -12, 22, 44 }) do
  local px, py = R(x, 3)
  c:part(c:ellipse(math.floor(px), math.floor(py), 3, 3), GV.ramp("#2a3c6c"), { flat = true, gloss = false })
end
-- the hole in the hull (where the octopus lives)
local hx, hy = R(-18, 6)
hx, hy = math.floor(hx), math.floor(hy)
c:part(c:ellipse(hx, hy, 12, 9), GV.ramp("#2a1a10"), { flat = true, gloss = false })
-- barnacles on the hull and gold stern lantern
for _, b in ipairs({ {30,14},{36,8},{50,4},{-48,14},{-30,18},{58,-6} }) do
  local x, y = R(b[1], b[2]); c:fill(c:ellipse(math.floor(x), math.floor(y), 1, 1), "#f2e4c0"); c:px(math.floor(x), math.floor(y), "#c9c5bc")
end
-- anchor-chain & seaweed draped on hull
local sx, sy = R(60, -10)
-- the octopus: surprised, half out of the hole
local OC = GV.ramp("#e46a54")
local function tentacle(pts)
  for i, p in ipairs(pts) do c:part(c:ellipse(p[1], p[2], i > #pts - 2 and 2 or 3, i > #pts - 2 and 2 or 3), OC, { flat = true, gloss = false, outline = (i == 1) }) end
end
tentacle({ {hx+10,hy+8},{hx+16,hy+12},{hx+22,hy+14},{hx+28,hy+12},{hx+32,hy+8},{hx+34,hy+4} })
tentacle({ {hx-8,hy+8},{hx-14,hy+12},{hx-20,hy+16},{hx-27,hy+16},{hx-31,hy+12} })
tentacle({ {hx+4,hy+9},{hx+6,hy+16},{hx+4,hy+22},{hx+8,hy+26},{hx+13,hy+27} })
c:part(c:ellipse(hx, hy - 2, 11, 10), OC, { cres = 5, deep = 8 })
c:part(c:ellipse(hx, hy - 12, 5, 4), OC, { flat = true, gloss = false, outline = false })
-- big startled eyes, brows up, tiny round mouth
c:eye(hx - 8, hy - 6); c:eye(hx + 3, hy - 6)
c:px(hx - 8, hy - 9, "#7a2a2a"); c:px(hx - 7, hy - 9, "#7a2a2a"); c:px(hx + 3, hy - 9, "#7a2a2a"); c:px(hx + 4, hy - 9, "#7a2a2a")
c:fill(c:ellipse(hx - 2, hy + 4, 2, 2), "#2a1a10"); c:px(hx - 2, hy + 4, "#8a2a3a")
for _, s in ipairs({ {hx-10,hy-2},{hx+9,hy-3},{hx+8,hy+3} }) do c:px(s[1], s[2], "#f6b8a8") end
-- little exclamation bubbles
for _, b in ipairs({ {hx+18,hy-16},{hx+22,hy-24},{hx+19,hy-31} }) do c:part(c:ellipse(b[1], b[2], 2, 2), GV.ramp("#8fd8dc"), { flat = true, gloss = false }); c:px(b[1] - 1, b[2] - 1, "#fff1c8") end

-- chests in the sand (foreground / midground) --------------------------------------------------------
local function chest(x, y, w, open)
  local bw = w
  c:part(c:rrect(x, y, x + bw, y + 10, 1), GV.ramp("#8a4f2a"), { cres = 3, deep = 5, gloss = false })
  if open then
    c:part(c:poly({ {x, y}, {x + bw, y}, {x + bw - 2, y - 7}, {x + 2, y - 7} }), GV.ramp("#a8582f"), { cres = 2, deep = 3, gloss = false })
    c:fill(c:rect(x + 2, y - 3, x + bw - 2, y), "#e8a317"); c:fill(c:rect(x + 3, y - 4, x + bw - 3, y - 3), "#f5cf6a")
    for _, g in ipairs({ {x + 4, y - 7}, {x + bw - 4, y - 6} }) do c:px(g[1], g[2], "#fff1c8"); c:px(g[1] - 1, g[2], "#fff1c8"); c:px(g[1] + 1, g[2], "#fff1c8"); c:px(g[1], g[2] - 1, "#fff1c8") end
  else
    c:part(c:ellipse(x + bw / 2, y, bw / 2 + 0.5, 4):clip(c:rect(0, 0, W, y)), GV.ramp("#a8582f"), { cres = 2, deep = 3, gloss = false })
  end
  c:fill(c:rect(x, y + 3, x + bw, y + 4), "#e8a317"); c:button(x + bw / 2 - 2, y + 2)
  for _, b in ipairs({ {x + 2, y + 8}, {x + bw - 3, y + 7}, {x + 5, y + 1} }) do c:px(b[1], b[2], "#f2e4c0") end
end
chest(28, 112, 20, false); chest(160, 108, 18, false); chest(190, 118, 22, true)
c:ground(38, 124, 14, 1.5, "#c9a96e"); c:ground(200, 130, 14, 1.5, "#c9a96e")

-- coral, kelp, bubbles, fish ------------------------------------------------------------------------
local function coral(x, y, col, h)
  c:part(c:rect(x - 1, y - h, x + 1, y), GV.ramp(col), { flat = true, gloss = false })
  c:part(c:rect(x - 6, y - h + 6, x - 4, y - 4), GV.ramp(col), { flat = true, gloss = false })
  c:part(c:rect(x + 4, y - h + 3, x + 6, y - 4), GV.ramp(col), { flat = true, gloss = false })
  c:part(c:rect(x - 6, y - 5, x + 6, y - 3), GV.ramp(col), { flat = true, gloss = false })
  for _, p in ipairs({ {x, y - h - 1}, {x - 5, y - h + 4}, {x + 5, y - h + 1} }) do c:part(c:ellipse(p[1], p[2], 2, 2), GV.ramp(col), { flat = true, gloss = false }) end
end
coral(8, 120, "#e46a9b", 22); coral(228, 112, "#f08a24", 26); coral(72, 126, "#f08a24", 14); coral(150, 124, "#e46a9b", 16)
local function kelp(x, y, h)
  for i = 0, h, 3 do c:fill(c:rect(x + (i // 6 % 2), y - i, x + 1 + (i // 6 % 2), y - i + 2), "#4a8a3e") end
end
kelp(52, 118, 30); kelp(56, 120, 22); kelp(176, 114, 28); kelp(214, 124, 18)
local function fish(x, y, col, dir)
  c:part(c:ellipse(x, y, 5, 3), GV.ramp(col), { flat = true, gloss = false })
  c:part(c:poly({ {x - 5 * dir, y}, {x - 9 * dir, y - 3}, {x - 9 * dir, y + 3} }), GV.ramp(col), { flat = true, gloss = false })
  c:px(x + 3 * dir, y - 1, "#2a1a10")
end
fish(30, 50, "#f5cf6a", 1); fish(46, 56, "#f5cf6a", 1); fish(38, 64, "#f5cf6a", 1)
fish(200, 40, "#e46a9b", -1); fish(216, 76, "#e8a317", -1)
for _, b in ipairs({ {176,36},{178,30},{175,24},{14,70},{16,62},{132,40} }) do c:fill(c:ellipse(b[1], b[2], 1.5, 1.5), "#e6f8f0"); c:px(b[1], b[2], "#8fd8dc") end

L.finish(c, "wonder-sunken-gnome-galleon")
