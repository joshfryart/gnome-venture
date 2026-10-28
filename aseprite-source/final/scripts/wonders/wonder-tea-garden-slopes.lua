-- wonder-tea-garden-slopes.lua : CSA zone 3. Rows of tea on a mist-wrapped slope; pickers move like a slow river; the head picker hands over the best two leaves and a bud.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

-- soft misty morning sky
c:bands(c:rect(0, 0, W - 1, 70), { "#a8c8d0", "#b8d4d4", "#c8dcd8", "#d6e6dc", "#e4eee0", "#f0f4e4" }, { dir = "v" })
c:fill(c:ellipse(188, 20, 8, 8), "#fff8e0")
L.cloud(c, 60, 16, 14, "#f4f0e0", "#d6e6dc")
-- layered far mountains
c:fill(L.below(c, function(x) return 34 + 14 * math.sin(x / 31 + 2) + 5 * math.sin(x / 11) end), "#9cc0c4")
c:fill(L.below(c, function(x) return 46 + 10 * math.sin(x / 24) + 4 * math.sin(x / 8 + 1) end), "#86b0b0")
c:fill(c:ellipse(60, 52, 70, 3), "#d6e6dc"); c:fill(c:ellipse(190, 58, 60, 3), "#d6e6dc")   -- mist between ranges
c:fill(L.below(c, function(x) return 58 + 6 * math.sin(x / 19 + 4) end), "#6a9c94")
-- a few pines on the far ridge
for _, p in ipairs({ {14,54},{22,56},{214,58},{224,55},{150,58} }) do
  c:part(c:poly({ {p[1]-4, p[2]+6}, {p[1], p[2]-6}, {p[1]+4, p[2]+6} }), GV.ramp("#2f5a2a"), { cres = 2, deep = 3, gloss = false, outline = false })
end

-- terraced tea slope ---------------------------------------------------------------------------------
local HEDGE = { "#3f7a3a", "#468440", "#4e8e44", "#58985a", "#62a258", "#6cac5c" }
local function ty(k, x) return 62 + k * 11 + 3 * math.sin(x / 28 + k * 1.3) + 1.5 * math.sin(x / 9 + k) end
for k = 0, 5 do
  local f = function(x) return ty(k, x) end
  c:fill(L.below(c, f), HEDGE[k + 1])
  -- hedge shadow underside, then the pale path
  c:fill(L.below(c, function(x) return f(x) + 6 end), "#2f5a2a")
  c:fill(L.below(c, function(x) return f(x) + 8 end), "#c9a96e")
  c:fill(L.below(c, function(x) return f(x) + 10 end), "#a8884e")
  -- bush mounds along the hedge top (light on upper left) with bud flecks
  for x = 2 + (k % 2) * 3, W, 6 do
    local y = math.floor(f(x) + 3.5)
    c:fill(c:ellipse(x, y, 3.5, 3), "#" .. (k % 2 == 0 and "5aa05a" or "6cb064"))
    c:px(x - 1, y - 2, "#a4d07a"); c:px(x + 1, y - 1, "#c8d77a")
  end
end
-- tea house, high left, with red roof
local hx, hy = 34, 66
c:part(c:rect(hx - 9, hy - 8, hx + 9, hy + 2), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5, gloss = false, contour = "#74462a" })
c:part(c:poly({ {hx - 14, hy - 8}, {hx, hy - 18}, {hx + 14, hy - 8} }), GV.ramp("#a8452f"), { cres = 3, deep = 5 })
c:part(c:rect(hx - 2, hy - 5, hx + 2, hy + 2), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
c:px(hx - 6, hy - 4, "#f5cf6a"); c:px(hx + 6, hy - 4, "#f5cf6a")
c:fill(c:rect(hx + 8, hy - 24, hx + 8, hy - 19), "#c9c5bc"); c:px(hx + 9, hy - 26, "#e4eee0"); c:px(hx + 10, hy - 29, "#f0f4e4")
-- drifting mist wreaths, hard-edged
for _, m in ipairs({ {70,70,34,3},{200,80,30,3},{30,92,36,3},{150,60,26,2},{120,98,40,3},{214,112,26,2} }) do
  c:fill(c:ellipse(m[1], m[2], m[3], m[4]), "#e4eee0"); c:fill(c:ellipse(m[1] - 4, m[2] - 3, m[3] - 12, m[4] - 1), "#f0f4e4")
end

-- pickers ----------------------------------------------------------------------------------------------
local function picker(x, y, s, robe)
  local r = math.max(3, math.floor(5 * s))
  c:ground(x, y + r, r + 2, 1)
  c:part(c:rect(x + 3 * s - 1, y - r - 2, x + r + 4, y + r - 3), GV.ramp("#a8582f"), { flat = true, gloss = false })  -- basket on the back
  for _, d in ipairs({ -1, 1 }) do c:px(x + r + 2 + d, y - r - 3, "#7ab55c") end
  c:part(c:ellipse(x, y, r, r), GV.ramp(robe), { cres = 2, deep = 4, gloss = false })
  local hr = math.max(3, math.floor(4 * s + 0.5))
  c:part(c:ellipse(x, y - r - hr + 1, hr, hr), GV.ramp("#e9b98a"), { cres = 2, deep = 3, gloss = false })
  c:part(c:ellipse(x, y - r + 1, hr - 1, 2), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
  c:part(c:poly({ {x - hr - 4, y - r - hr + 1}, {x + hr + 4, y - r - hr + 1}, {x, y - r - hr - 6} }), GV.ramp("#e2c88a", { rim = "#f9e8b0" }), { cres = 2, deep = 3, gloss = false })
  if s >= 0.9 then c:px(x - 2, y - r - hr + 1, "#2a1a10"); c:px(x + 2, y - r - hr + 1, "#2a1a10") end
end
picker(80, 78, 0.6, "#d6322b"); picker(94, 80, 0.6, "#3f8fb0"); picker(108, 79, 0.6, "#e46a9b")
picker(150, 89, 0.8, "#7b66b4"); picker(166, 91, 0.8, "#f08a24"); picker(182, 90, 0.8, "#d6322b")
picker(62, 99, 0.9, "#3f8fb0"); picker(88, 101, 0.9, "#e8a317"); picker(112, 102, 0.9, "#e46a9b")

-- foreground: the head picker (big, chibi) with two leaves and a bud, and a basket ------------------------
local bx, by = 196, 112
c:ground(bx, by + 12, 16, 2)
c:part(c:ellipse(bx, by, 12, 12), GV.ramp("#2f7a5a"), { cres = 5, deep = 8, gloss = false })
c:part(c:rect(bx - 6, by - 4, bx + 6, by + 3), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:seam({ {bx - 6, by + 3}, {bx + 6, by + 3} }, { free = true })
c:part(c:ellipse(bx, by - 15, 10, 9), GV.ramp("#e9b98a"), { cres = 3, deep = 5 })
c:part(c:ellipse(bx, by - 9, 7, 5):clip(c:rect(0, by - 9, W, H)), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
c:eye(bx - 8, by - 19); c:eye(bx + 2, by - 19)
c:part(c:poly({ {bx - 16, by - 20}, {bx + 16, by - 20}, {bx, by - 40} }), GV.ramp("#e2c88a", { rim = "#f9e8b0" }), { cres = 4, deep = 6 })
c:seam({ {bx - 12, by - 22}, {bx + 12, by - 22} }, { free = true })
-- raised hand holding the best two leaves and a bud
c:limb({ {bx - 10, by - 2}, {bx - 18, by - 6}, {bx - 20, by - 14} }, 3)
c:part(c:ellipse(bx - 21, by - 17, 3, 3), GV.ramp("#e9b98a"), { flat = true, gloss = false })
c:part(c:ellipse(bx - 25, by - 23, 3, 5), GV.ramp("#7ab55c"), { flat = true, gloss = false })
c:part(c:ellipse(bx - 18, by - 24, 3, 5), GV.ramp("#7ab55c"), { flat = true, gloss = false })
c:part(c:ellipse(bx - 21, by - 27, 2, 4), GV.ramp("#c8d77a"), { flat = true, gloss = false })
-- little gold-thread pouch: the head picker's treasure
c:part(c:ellipse(bx + 14, by + 6, 5, 5), GV.ramp("#e8a317"), { cres = 2, deep = 4 })
c:seam({ {bx + 10, by + 3}, {bx + 18, by + 3} }, { free = true })
-- big basket of leaves, bottom left; and a cup of tea with steam
local kx, ky = 40, 118
c:part(c:ellipse(kx, ky - 6, 15, 7), GV.ramp("#7ab55c"), { cres = 3, deep = 5, gloss = false })
c:part(c:poly({ {kx - 16, ky - 6}, {kx + 16, ky - 6}, {kx + 11, ky + 8}, {kx - 11, ky + 8} }), GV.ramp("#b07a45"), { cres = 3, deep = 5, gloss = false })
for y = ky - 2, ky + 6, 4 do c:fill(c:rect(kx - 12, y, kx + 12, y), "#8a4f2a") end
for x = kx - 8, kx + 10, 6 do c:fill(c:rect(x, ky - 6, x, ky + 7), "#8a4f2a") end
for _, l in ipairs({ {-8,-10},{0,-12},{8,-10},{-4,-8} }) do c:part(c:ellipse(kx + l[1], ky + l[2], 3, 2), GV.ramp("#a4b86a"), { flat = true, gloss = false, outline = false }) end
local cx2, cy2 = 90, 124
c:part(c:ellipse(cx2, cy2, 6, 5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 2, deep = 3 })
c:fill(c:ellipse(cx2, cy2 - 3, 4, 1.5), "#a8582f")
c:px(cx2 - 1, cy2 - 8, "#f0f4e4"); c:px(cx2, cy2 - 10, "#f0f4e4"); c:px(cx2 - 1, cy2 - 12, "#f0f4e4")

L.finish(c, "wonder-tea-garden-slopes")
