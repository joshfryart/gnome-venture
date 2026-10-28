-- wonder-fairy-ring-clearing.lua : night forest clearing, a glowing ring of mushrooms, mycelium underneath, a little door opens with a tiny hand and a gift.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

-- background: deep forest in night teal-green, bands
c:bands(c:rect(0, 0, W - 1, 100), { "#16203a", "#1a2a44", "#1e3450", "#22405a", "#274c62", "#2d5a68" }, { dir = "v" })
L.stars(c, 14, 20, 5)
-- glimpse of moon through canopy
c:fill(c:ellipse(120, 22, 9, 9), "#2d4a72"); c:fill(c:ellipse(120, 22, 6, 6), "#c3b2ea"); c:fill(c:ellipse(119, 21, 3, 3), "#fff1c8")
-- far trees (flat silhouettes) and near trunks
local function trunk(x, w, col, top)
  c:part(c:rect(x, top, x + w, 104), GV.ramp(col), { gloss = false, outline = false, cres = math.max(2, w // 3), deep = math.max(3, w // 2) })
end
for _, x in ipairs({ 6, 44, 82, 150, 196, 228 }) do trunk(x, 5, "#2a4a50", 0) end
for _, x in ipairs({ 22, 66, 170, 212 }) do trunk(x, 3, "#356060", 0) end
-- canopy blobs at top (leaf layers)
for _, b in ipairs({ {20,2,26,9}, {70,0,30,10}, {120,-2,20,8}, {170,2,30,10}, {222,0,26,10}, {-6,6,20,12}, {250,6,18,10} }) do
  c:part(c:ellipse(b[1], b[2], b[3], b[4]), GV.ramp("#2f5a2a"), { gloss = false, outline = false, cres = 5, deep = 8 })
end
-- light rays: sparse glowing dots
for _, f in ipairs({ {100,40},{140,52},{60,60},{186,46},{30,78},{214,70},{120,72},{88,84},{160,80} }) do c:px(f[1], f[2], "#a4e8c8"); c:px(f[1], f[2] + 1, "#5a9a88") end

-- ground (moss clearing) to row 118, cutaway soil beneath
local grass = c:rect(0, 100, W - 1, 118)
c:part(grass, "moss", { gloss = false, rim = false, outline = false, cres = 6, deep = 10 })
c:fill(c:rect(0, 100, W - 1, 101), "#4a8a3e")
for i = 0, 36 do local x = (i * 47 + 5) % W; local y = 102 + (i * 13) % 15; c:px(x, y, "#a4b86a"); c:px(x + 1, y - 1, "#c8d77a") end
-- soil cutaway with roots and mycelium
c:bands(c:rect(0, 119, W - 1, H - 1), { "#5e2f1e", "#4a2c1a", "#3d2a1c", "#2f2018" }, { dir = "v" })
c:fill(c:rect(0, 119, W - 1, 119), "#2a1a10")
for i = 0, 24 do local x = (i * 41 + 9) % W; local y = 122 + (i * 17) % 10; c:px(x, y, "#7a4a1f"); c:px(x + 1, y, "#7a4a1f") end
-- mycelium network: glowing cream/gold threads, ring-shaped below ring
local GL, GL2 = "#f2e4c0", "#8fe8c8"
local function thread(pts, col) c:seam(pts, { free = true, on = 3, off = 0, gap = col }) end
for _, t in ipairs({
  { {10,128},{40,126},{70,130},{100,126},{130,129},{160,125},{190,129},{230,126} },
  { {20,134},{50,131},{86,133},{120,131},{150,134},{180,131},{220,133} },
  { {60,130},{64,124},{70,120} }, { {100,126},{104,121} }, { {150,134},{156,128},{160,121} }, { {120,131},{118,125},{116,120} },
  { {40,126},{36,121} }, { {190,129},{196,124},{200,120} }, { {86,133},{80,128} }, { {210,126},{214,121} },
}) do thread(t, GL2) end
for _, n in ipairs({ {40,126},{100,126},{160,125},{190,129},{70,130},{130,129},{86,133},{150,134},{220,133} }) do
  c:fill(c:rect(n[1] - 1, n[2] - 1, n[1] + 1, n[2] + 1), GL); c:px(n[1], n[2], "#fff1c8")
end
-- tiny tunnel to the door below the stump
c:fill(c:rect(0, H - 8, W - 1, H - 1), "#2f2018")

-- mushroom helper
local function mush(x, y, s, cap, spot)
  local sw, sh = math.max(3, math.floor(3 * s)), math.floor(7 * s)
  c:ground(x, y, sw + 2, 1.2, "#2f5a2a")
  c:part(c:rrect(x - sw // 2, y - sh, x + sw // 2 + 1, y, 1), GV.ramp("#f2e4c0"), { gloss = false, cres = 2, deep = 3, pale = true })
  local rx, ry = math.floor(6 * s), math.floor(5 * s)
  local m = c:ellipse(x + 0.5, y - sh, rx, ry); m:cut(c:rect(x - rx - 2, y - sh + 1, x + rx + 2, y + 3))
  c:part(m, GV.ramp(cap), { cres = 3, deep = 4 })
  local sp = math.max(2, math.floor(2 * s))
  c:fill(c:rect(x - rx + 2, y - sh - 2, x - rx + 1 + sp, y - sh - 1), spot)
  c:fill(c:rect(x + 1, y - sh - ry + 2, x + sp, y - sh - ry + 1 + sp), spot)
  if s > 0.9 then c:fill(c:rect(x + rx - 3, y - sh - 1, x + rx - 2, y - sh), spot) end
  return rx
end
-- glow on grass under ring
local cx, cy, rx, ry = 120, 108, 88, 10
c:fill(c:ellipse(cx, cy, rx, ry):cut(c:ellipse(cx, cy, rx - 6, ry - 3)), "#a4e8c8")
-- ring of mushrooms, back to front
local ms = {}
for i = 0, 11 do
  local a = i * (2 * math.pi / 12) + 0.2
  ms[#ms + 1] = { x = math.floor(cx + rx * math.cos(a)), y = math.floor(cy + ry * math.sin(a)), i = i }
end
table.sort(ms, function(a, b) return a.y < b.y end)
local caps = { "#d6322b", "#e0501f", "#e46a9b" }
for _, m in ipairs(ms) do
  local t = (m.y - (cy - ry)) / (2 * ry)
  mush(m.x, m.y + 2, 1.1 + 0.7 * t, caps[(m.i % 3) + 1], "#fff3c8")
end
-- a few lone mushrooms and sprites outside the ring
mush(14, 112, 1.0, "#e46a9b", "#fff3c8"); mush(226, 114, 0.9, "#d6322b", "#fff3c8")
mush(28, 108, 0.6, "#e0501f", "#fff3c8")
-- the little door: at the ring's edge, a tiny tree-stump house on the right, door open, glowing, a tiny hand with a gift
local sx, sy = 196, 112
c:ground(sx, sy + 1, 18, 2, "#2f5a2a")
local stump = c:poly({ {sx-14,sy},{sx-12,sy-22},{sx-6,sy-27},{sx+6,sy-27},{sx+12,sy-22},{sx+14,sy} })
c:part(stump, GV.ramp("#8a4f2a"), { cres = 5, deep = 8, gloss = false })
c:seam({ {sx-9,sy-6},{sx-9,sy-20} }, { free = true, on = 2, off = 2, gap = "#5e2f1e" })
c:part(c:ellipse(sx, sy - 27, 7, 3), GV.ramp("#d9a660"), { flat = true, gloss = false })
-- door frame + glowing opening
c:part(c:rrect(sx - 5, sy - 16, sx + 5, sy - 1, 4), GV.ramp("#5e2f1e"), { gloss = false, cres = 2 })
c:fill(c:rrect(sx - 3, sy - 14, sx + 3, sy - 1, 3), "#f5cf6a"); c:fill(c:rrect(sx - 2, sy - 12, sx + 2, sy - 1, 2), "#fff1c8")
-- tiny hand reaching out holding a gift (wrapped, with a gold bow)
c:limb({ {sx - 1, sy - 7}, {sx - 8, sy - 6} }, 2)
c:part(c:rect(sx - 12, sy - 9, sx - 9, sy - 6), GV.ramp("#e9b98a"), { flat = true, gloss = false })
c:part(c:rect(sx - 15, sy - 14, sx - 9, sy - 9), GV.ramp("#e46a9b"), { cres = 2, gloss = false })
c:fill(c:rect(sx - 12, sy - 14, sx - 12, sy - 9), "#f5cf6a"); c:fill(c:rect(sx - 15, sy - 12, sx - 9, sy - 12), "#f5cf6a")
c:px(sx - 13, sy - 15, "#f5cf6a"); c:px(sx - 11, sy - 15, "#f5cf6a")
-- stump steps and glow motes
c:part(c:rect(sx - 6, sy - 1, sx + 6, sy + 1), GV.ramp("#9a6b3f"), { flat = true, gloss = false })
for _, f in ipairs({ {176,92},{182,84},{190,78},{170,100},{206,88},{214,96},{184,100} }) do c:px(f[1], f[2], "#fff1c8"); c:px(f[1] + 1, f[2], "#f5cf6a") end
-- ring-light motes drifting up from the mushrooms
for _, f in ipairs({ {44,96},{60,88},{90,92},{120,84},{148,92},{168,88},{30,92},{100,80},{136,78} }) do c:px(f[1], f[2], "#a4e8c8") end
L.finish(c, "wonder-fairy-ring-clearing")
