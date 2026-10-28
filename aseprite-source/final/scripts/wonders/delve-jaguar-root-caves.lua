-- delve-jaguar-root-caves.lua : CA zone 2 delve. "Twisting caves under the jungle floor."
-- Cutaway cave under the jungle: root-hung ceiling, a sunlit mouth to the jungle (right), a glow-mushroom side tunnel (left),
-- and a chibi jaguar guarding the twisting path.  Warm underground light.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local function lm(pts, w, hex)
  for _, p in ipairs(pts) do p[1] = math.floor(p[1] + 0.5); p[2] = math.floor(p[2] + 0.5) end
  c:part(c:line(pts, w), GV.ramp(hex or "#a8582f"), { flat = true, gloss = false, outline = false })
end
local SLUG = "delve-jaguar-root-caves"

-- cave back wall: dark umber-violet, warmer toward the middle (hard concentric steps)
c:fill(c:rect(0, 0, W - 1, H - 1), "#2a1d2e")
local wall = { "#33233a", "#3d2a40", "#4a3248", "#573a4c", "#654452" }
for i, col in ipairs(wall) do c:fill(c:ellipse(120, 78, 128 - i * 18, 70 - i * 9), col) end
-- rock strata lines on the wall
for _, l in ipairs({ {{8,40},{30,44},{52,41}}, {{190,36},{214,40},{236,37}}, {{14,96},{40,99}}, {{200,92},{226,96}} }) do
  c:seam(l, { free = true, on = 3, off = 0, gap = "#2a1a10" })
end

-- sunlit jungle mouth, right (arched)
local mouth = c:mask()
mouth:add(c:rect(176, 52, 222, 112)); mouth:add(c:ellipse(199, 52, 23, 17))
c:fill(mouth, "#a4d0a0")
c:fill(mouth:copy():clip(c:rect(0, 52, W, 78)), "#8fc4a0")
c:fill(mouth:copy():clip(c:rect(0, 78, W, 130)), "#7ab55c")
-- jungle beyond: far trees, big leaves, sun spill
c:fill(c:ellipse(210, 70, 6, 6), "#f5e6a0"); c:fill(c:ellipse(210, 70, 3, 3), "#fff1c8")
c:fill(c:poly({ {176,92},{186,76},{196,92} }):clip(mouth), "#4a8a3e")
c:fill(c:poly({ {190,96},{204,70},{216,96} }):clip(mouth), "#2f5a2a")
c:fill(c:poly({ {208,100},{218,82},{228,100} }):clip(mouth), "#4a8a3e")
c:fill(c:rect(176, 100, 222, 112):clip(mouth), "#4f9a45")
c:fill(c:rect(176, 108, 222, 112):clip(mouth), "#2f5a2a")
-- rim of the opening: mossy stone frame
local frame = mouth:grow(4); frame:cut(mouth)
frame:clip(c:rect(0, 0, W, 118))
c:part(frame, GV.ramp("#5b6470"), { cres = 3, deep = 5, gloss = false, rim = false })
-- jungle floor roots hanging across the mouth top
for _, x in ipairs({ 182, 192, 204, 214 }) do
  lm({ {x, 38}, {x + 1, 48}, {x - 1, 56 + (x % 5)} }, 2)
end

-- ceiling with jagged underside
local ceil = c:poly({ {0,0},{W,0},{W,22},{226,28},{214,24},{196,34},{172,26},{150,36},{130,28},{108,40},{88,30},{66,38},{44,26},{22,34},{0,26} })
c:part(ceil, GV.ramp("#5a3a2a"), { cres = 5, deep = 8, gloss = false })
-- stalactites
for _, s in ipairs({ {58,38,9},{114,40,12},{146,36,8},{28,34,8} }) do
  c:part(c:poly({ {s[1]-3, s[2]-4}, {s[1]+3, s[2]-4}, {s[1], s[2]+s[3]} }), GV.ramp("#8b8f96"), { cres = 2, deep = 3, gloss = false })
end
-- hanging roots from the jungle floor above (wood, with wiggle)
local roots = { {18,26,56},{40,30,70},{84,32,60},{126,36,80},{164,32,66},{232,26,60},{100,38,52} }
for _, r in ipairs(roots) do
  local x, y0, y1 = r[1], r[2], r[3]
  lm({ {x, y0}, {x + 2, y0 + (y1 - y0) * 0.4}, {x - 1, y0 + (y1 - y0) * 0.75}, {x + 1, y1} }, 3)
  lm({ {x + 1, y0 + 8}, {x + 6, y0 + 14}, {x + 7, y0 + 22} }, 2)
end
-- woody tint overlay for roots: recolor lit top cheaply
for _, r in ipairs(roots) do c:px(r[1], r[3], "#d9a660") end

-- left side tunnel with glow mushrooms (twisting away)
local tun = c:ellipse(30, 98, 22, 20); tun:clip(c:rect(0, 70, 60, 118))
c:fill(tun, "#1c1426")
c:fill(c:ellipse(28, 100, 15, 14):clip(tun), "#241a30")
c:fill(c:ellipse(26, 103, 8, 8):clip(tun), "#33263f")
for _, m in ipairs({ {12,108,4},{22,111,3},{36,106,3},{44,110,4},{8,100,2} }) do
  c:part(c:ellipse(m[1], m[2] - m[3] * 0.5, m[3], m[3] * 0.8):clip(c:rect(0, 0, W, m[2])), GV.ramp("#5ec8c0", { rim = "#c8ecdc" }), { cres = 1, deep = 2, gloss = false })
  c:fill(c:rect(m[1] - 1, m[2], m[1], m[2] + 3), "#c8ecdc")
  c:px(m[1] - 1, m[2] - m[3], "#ffffcc")
end
c:px(18, 90, "#c8ecdc"); c:px(32, 86, "#c8ecdc"); c:px(26, 94, "#8fcbd8")

-- floor: packed soil with a winding root-path
local floor = L.below(c, function(x) return 108 + math.sin(x / 22) * 3 end)
c:part(floor, GV.ramp("#7a4a1f"), { cres = 6, deep = 10, gloss = false })
-- path (lighter dirt) winding toward the sunny mouth
local path = c:poly({ {60,H},{86,114},{120,110},{150,112},{176,108},{200,112},{220,116},{232,H} })
c:part(path, GV.ramp("#c9a96e"), { cres = 4, deep = 7, gloss = false, rim = false })
-- footprints (jaguar paws) on the path
for _, p in ipairs({ {82,124},{96,120},{110,124},{128,119} }) do
  c:px(p[1], p[2], "#9a6b3f"); c:px(p[1] + 2, p[2], "#9a6b3f"); c:px(p[1] + 1, p[2] + 1, "#9a6b3f"); c:px(p[1] + 1, p[2] + 2, "#9a6b3f")
end
-- big arching root across the floor, foreground left and right
local arc = c:mask(); arc:add(c:ellipse(150, 126, 34, 14)); arc:cut(c:ellipse(150, 129, 28, 12)); arc:clip(c:rect(0, 100, W, 125))
c:part(arc, GV.ramp("#a8582f"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(20, 124, 14, 5), GV.ramp("#a8582f"), { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(228, 126, 12, 4), GV.ramp("#a8582f"), { cres = 2, deep = 4, gloss = false })
-- leaf litter + bones-free pebbles
for _, p in ipairs({ {70,128,3,1},{104,127,2,1},{190,128,4,1},{210,122,2,1} }) do
  c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#8b8f96"), { flat = true, gloss = false })
end
for _, p in ipairs({ {46,120},{176,120},{216,118},{64,114} }) do
  c:part(c:poly({ {p[1],p[2]},{p[1]+3,p[2]-2},{p[1]+6,p[2]},{p[1]+3,p[2]+2} }), GV.ramp("#7ab55c"), { flat = true, gloss = false })
end

-- the jaguar: chibi, sitting on a mossy boulder in the middle, tail curled
local JX, JY = 108, 98
local rock = c:ellipse(JX, JY + 16, 22, 8); 
c:part(c:poly({ {JX-24,JY+22},{JX-18,JY+10},{JX-4,JY+7},{JX+12,JY+8},{JX+24,JY+14},{JX+26,JY+22} }), GV.ramp("#8b8f96"), { cres = 5, deep = 8 })
c:part(c:poly({ {JX-18,JY+10},{JX-6,JY+7},{JX+4,JY+8},{JX+2,JY+11},{JX-10,JY+10} }), GV.ramp("#7ab55c"), { flat = true, gloss = false, outline = false })
local J = GV.ramp("#e8a317", { shade = "#c47a30", deep = "#8a4a20" })
-- tail (behind)
lm({ {JX+14, JY+8}, {JX+26, JY+8}, {JX+30, JY-2}, {JX+26, JY-8} }, 3, "#e8a317")
c:fill(c:rect(JX+25, JY-9, JX+27, JY-7), "#35161f")
-- body
c:part(c:ellipse(JX, JY, 14, 12), J, { cres = 5, deep = 8 })
-- belly patch
c:part(c:ellipse(JX, JY + 3, 7, 7):clip(c:rect(0, JY + 1, W, H)), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
-- front paws
for _, dx in ipairs({ -8, 4 }) do c:part(c:ellipse(JX + dx + 2, JY + 11, 4, 3), J, { cres = 2, deep = 3, gloss = false }) end
-- spots (rosettes: dark bean + glint)
for _, s in ipairs({ {-11,-4},{-9,4},{10,-3},{11,5},{-3,-9},{4,-8} }) do
  c:fill(c:rect(JX + s[1], JY + s[2], JX + s[1] + 2, JY + s[2] + 1), "#35161f"); c:px(JX + s[1], JY + s[2], "#5e2a3a")
end
-- head (big)
c:part(c:ellipse(JX, JY - 15, 13, 10), J, { cres = 4, deep = 7 })
-- ears
for _, dx in ipairs({ -10, 10 }) do
  c:part(c:ellipse(JX + dx, JY - 24, 4, 3.5), J, { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(JX + dx - 1, JY - 25, JX + dx + 1, JY - 23), "#35161f")
end
-- muzzle
c:part(c:ellipse(JX, JY - 11, 6, 4), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
c:fill(c:rect(JX - 1, JY - 13, JX + 1, JY - 12), "#d9885a")
c:px(JX, JY - 11, "#2a1a10"); c:px(JX - 2, JY - 9, "#2a1a10"); c:px(JX + 2, JY - 9, "#2a1a10"); c:px(JX - 1, JY - 9, "#2a1a10"); c:px(JX + 1, JY - 9, "#2a1a10")
-- forehead rosettes
c:px(JX - 3, JY - 23, "#35161f"); c:px(JX - 2, JY - 23, "#35161f"); c:px(JX + 2, JY - 23, "#35161f"); c:px(JX + 3, JY - 23, "#35161f"); c:px(JX, JY - 24, "#35161f")
-- eyes
c:eye(JX - 9, JY - 20); c:eye(JX + 4, JY - 20)
c:ground(JX, JY + 24, 24, 2)

-- fireflies / dust motes in the light
for _, p in ipairs({ {160,70},{150,84},{166,92},{140,60},{76,64},{90,76},{60,56} }) do c:px(p[1], p[2], "#fff1c8") end
for _, p in ipairs({ {164,70},{146,62} }) do c:px(p[1], p[2], "#f5cf6a") end

L.finish(c, SLUG)
