-- wonder-pink-river-dolphin-pools.lua : flooded Amazon forest pools, pink river dolphins rolling, seeds drifting, a dolphin nudging a seed bundle to you.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 62
local WAT = { "#6aa89a", "#5a9a90", "#4a8a84", "#3f7a78", "#356a6c", "#2d5a5e" }

-- sky strip + treeline
c:bands(c:rect(0, 0, W - 1, HOR), { "#9ad0d8", "#b0dce0", "#c8e8e0", "#dcf0d8" }, { dir = "v" })
L.cloud(c, 150, 16, 20, "#f4f0e0", "#cfd8e4"); L.cloud(c, 40, 24, 14, "#f4f0e0", "#cfd8e4")
-- distant forest wall (layers)
local function treeline(base, amp, col, ph)
  c:part(L.below(c, function(x) return base + amp * math.sin(x / 9 + ph) + amp * 0.6 * math.sin(x / 4 + ph) end), GV.ramp(col), { gloss = false, rim = false, bounce = false, outline = false, cres = 3, deep = 4 })
end
treeline(36, 4, "#4a8a3e", 0); treeline(46, 3, "#3a7a36", 2)
-- water
c:bands(c:rect(0, HOR, W - 1, H - 1), WAT, { dir = "v" })
c:fill(c:rect(0, HOR, W - 1, HOR + 1), "#2f5a2a")
-- trunks standing in the water with buttress roots, hanging vines
local function tree(x, w, top, y)
  c:part(c:poly({ {x - 4, y}, {x - 1, y - 6}, {x - 1, top}, {x + w + 1, top}, {x + w + 1, y - 6}, {x + w + 4, y} }), GV.ramp("#8a4f2a"), { cres = 3, deep = 5, gloss = false })
  c:seam({ {x + 1, top + 4}, {x + 1, y - 8} }, { free = true, on = 2, off = 3, gap = "#5e2f1e" })
end
tree(14, 6, 4, 76); tree(74, 5, 14, 70); tree(196, 6, 6, 72); tree(232, 5, 10, 76)
for _, v in ipairs({ {30,0,22},{58,0,30},{100,0,20},{150,0,26},{176,0,18},{212,0,28},{240,0,16} }) do
  c:fill(c:rect(v[1], v[2], v[1], v[2] + v[3]), "#4a8a3e"); c:px(v[1] - 1, v[2] + v[3], "#7ab55c"); c:px(v[1] + 1, v[2] + v[3] - 1, "#7ab55c"); c:px(v[1], v[2] + v[3] + 1, "#a4b86a")
end
for _, b in ipairs({ {0,0,26,10},{60,-2,34,10},{120,-2,30,9},{180,0,34,10},{240,0,22,12} }) do
  c:part(c:ellipse(b[1], b[2], b[3], b[4]), GV.ramp("#3a7a36"), { gloss = false, outline = false, cres = 5, deep = 8 })
end
-- a scarlet macaw on a branch (colour, life)
c:part(c:ellipse(150, 40, 4, 5), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(150, 35, 3, 3), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:fill(c:rect(147, 44, 148, 50), "#3f8fb0"); c:fill(c:rect(147, 50, 148, 51), "#e8a317")
c:px(149, 34, "#f2e4c0"); c:px(150, 34, "#2a1a10"); c:px(152, 36, "#e8a317"); c:px(153, 37, "#e8a317")
c:fill(c:rect(138, 44, 160, 45), "#5e2f1e")
-- sandbar / muddy bank dividing pools
c:part(c:poly({ {0,84},{34,80},{60,86},{40,92},{0,94} }), GV.ramp("#c9a96e"), { cres = 3, deep = 5, gloss = false, outline = false })
c:part(c:poly({ {170,82},{214,78},{W,80},{W,92},{190,90} }), GV.ramp("#c9a96e"), { cres = 3, deep = 5, gloss = false, outline = false })
-- lily pads with flowers
local function pad(x, y, r)
  c:part(c:ellipse(x, y, r, r * 0.4), GV.ramp("#6a9a3a"), { cres = 2, deep = 3, gloss = false, outline = false })
  c:px(x, y - 1, "#2f5a2a")
end
for _, p in ipairs({ {70,76,7},{88,98,8},{150,76,7},{226,100,9},{20,104,8},{44,118,8},{200,120,8},{236,112,6} }) do pad(p[1], p[2], p[3]) end
for _, p in ipairs({ {88,97},{226,99},{44,117} }) do c:fill(c:rect(p[1] - 1, p[2] - 2, p[1] + 1, p[2]), "#f6b8cf"); c:px(p[1], p[2] - 3, "#fff1c8") end
-- water lines
for i = 0, 26 do local x = (i * 41 + 7) % (W - 10); local y = HOR + 4 + (i * 13) % (H - HOR - 10); c:fill(c:rect(x, y, x + 4 + i % 4, y), "#8fcbd8") end

-- dolphin ------------------------------------------------------------------------------------------
local function dolphin(x, y, s, rot)
  local body = c:ellipse(x, y, 24 * s, 10 * s)
  body:add(c:ellipse(x + 26 * s, y + 3 * s, 9 * s, 3.5 * s))      -- snout (beak)
  body:add(c:ellipse(x + 17 * s, y - 5 * s, 8 * s, 7 * s))        -- melon forehead
  body:add(c:poly({ {x - 20 * s, y - 2 * s}, {x - 36 * s, y - 10 * s}, {x - 34 * s, y - 15 * s}, {x - 28 * s, y - 12 * s}, {x - 26 * s, y - 16 * s}, {x - 18 * s, y - 8 * s} }))
  local dorsal = c:poly({ {x - 6 * s, y - 8 * s}, {x - 2 * s, y - 17 * s}, {x + 5 * s, y - 8 * s} })
  body:add(dorsal)
  c:part(body, GV.ramp("#f08aa8"), { cres = math.floor(5 * s), deep = math.floor(8 * s) })
  c:fill(body:copy():clip(c:rect(x - 20 * s, y + 4 * s, x + 40 * s, y + 12 * s)), "#f8c8d0")
  -- pectoral fin
  c:part(c:poly({ {x + 2 * s, y + 4 * s}, {x - 6 * s, y + 14 * s}, {x + 6 * s, y + 10 * s} }), GV.ramp("#e46a9b"), { cres = 2, deep = 3, gloss = false })
  -- eye and smile
  if s > 0.7 then c:eye(math.floor(x + 18 * s) - 2, math.floor(y - 3 * s) - 2) else c:eye(math.floor(x + 18 * s) - 1, math.floor(y - 3 * s) - 1, true) end
  c:fill(c:rect(math.floor(x + 24 * s), math.floor(y + 4 * s), math.floor(x + 33 * s), math.floor(y + 4 * s)), "#8a2a44")
  c:px(math.floor(x + 34 * s), math.floor(y + 3 * s), "#8a2a44")
end
local function ripple(x, y, rx)
  c:fill(c:rect(x - rx, y, x + rx, y), "#cfe8f0"); c:fill(c:rect(x - rx - 5, y + 3, x - rx + 3, y + 3), "#8fcbd8"); c:fill(c:rect(x + rx - 3, y + 3, x + rx + 5, y + 3), "#8fcbd8")
end
-- back dolphin leaping (right), smaller, tilted by placing high
dolphin(190, 70, 0.55)
for _, d in ipairs({ {170,78},{176,82},{210,76},{214,82},{196,90} }) do c:px(d[1], d[2], "#cfe8f0"); c:px(d[1], d[2] + 1, "#8fcbd8") end
ripple(190, 92, 16)
-- left dolphin rolling: just the arched back and fin
dolphin(48, 98, 0.7)
ripple(46, 112, 26)
-- foreground dolphin nudging the seed bundle toward the viewer
dolphin(100, 108, 1.0)
ripple(100, 118, 30)
-- the seed bundle: leaf-wrapped, tied with gold thread, seeds peeking
local bx, by = 160, 112
c:part(c:ellipse(bx, by, 9, 6), "moss", { cres = 3, deep = 5 })
c:fill(c:rect(bx - 1, by - 5, bx, by + 5), "#e8a317")
c:seam({ {bx - 7, by}, {bx + 7, by} }, { free = true, on = 1, off = 1 })
for _, p in ipairs({ {bx - 5, by - 6}, {bx - 2, by - 7}, {bx + 2, by - 7}, {bx + 5, by - 6} }) do c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#d9a660"); c:px(p[1], p[2], "#fff1c8") end
ripple(bx, by + 8, 11)
-- sparkle trail and squeak marks
for _, p in ipairs({ {138,106},{146,102},{150,108} }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#f5cf6a") end
c:px(136, 88, "#fff1c8"); c:px(138, 84, "#fff1c8"); c:px(142, 88, "#fff1c8")
-- drifting seeds with tiny ripples
for _, p in ipairs({ {30,70},{110,80},{128,92},{206,108},{226,122},{16,124},{72,122},{180,100},{240,96} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#d9a660"); c:px(p[1], p[2], "#fff1c8"); c:fill(c:rect(p[1] - 2, p[2] + 2, p[1] + 3, p[2] + 2), "#8fcbd8")
end
L.finish(c, "wonder-pink-river-dolphin-pools")
