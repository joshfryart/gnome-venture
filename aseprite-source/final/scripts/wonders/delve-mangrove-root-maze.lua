-- delve-mangrove-root-maze.lua : CB zone 4 delve. "Tangled roots over dark water."
-- Late-afternoon green gloom: a tangle of stilt roots arching over dark tidal water, a gap of warm sky, and a little tree frog
-- keeping watch on a root with a firefly lantern.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local SLUG = "delve-mangrove-root-maze"
local function rt(pts, w, hex, o)
  for _, p in ipairs(pts) do p[1] = math.floor(p[1] + 0.5); p[2] = math.floor(p[2] + 0.5) end
  local opts = { cres = 2, deep = 3, gloss = false }
  if o then for k, v in pairs(o) do opts[k] = v end end
  c:part(c:line(pts, w), GV.ramp(hex or "#8a4f2a"), opts)
end

-- sky gap (warm hazy) behind everything
c:bands(c:rect(0, 0, W - 1, 78), { "#6aa890", "#7eb89a", "#98c8a4", "#b8d8a8", "#dce4a8", "#f0dca0" }, { dir = "v" })
-- far tree line (mangrove canopy silhouette, layered greens)
c:part(L.below(c, function(x) return 70 + math.sin(x / 9) * 3 + math.sin(x / 4) * 1.5 end):clip(c:rect(0, 60, W, 82)), GV.ramp("#4a8a5a"), { gloss = false, rim = false, bounce = false, outline = false, cres = 3, deep = 4 })
c:part(L.below(c, function(x) return 76 + math.sin(x / 13 + 2) * 2 end):clip(c:rect(0, 70, W, 84)), GV.ramp("#2f5a3a"), { gloss = false, rim = false, bounce = false, outline = false, cres = 2, deep = 3 })
-- cloud wisps
L.cloud(c, 70, 24, 14, "#f4f0d0", "#e6e0b0"); L.cloud(c, 176, 34, 12, "#f4f0d0", "#e6e0b0")
-- egrets in the distance
for _, g in ipairs({ {110,46},{122,42},{96,52} }) do
  c:px(g[1], g[2], "#f2e4c0"); c:px(g[1]+1, g[2]+1, "#f2e4c0"); c:px(g[1]+2, g[2], "#f2e4c0"); c:px(g[1]+3, g[2]+1, "#f2e4c0"); c:px(g[1]+4, g[2], "#f2e4c0")
end

-- dark water
local WATER = { "#2f6a6a", "#285e60", "#225256", "#1c464c", "#173a42", "#122f38" }
c:bands(c:rect(0, 80, W - 1, H - 1), WATER, { dir = "v" })
-- sky reflection dashes
for i, x in ipairs({ 90, 110, 130, 100, 120, 150, 80, 140 }) do
  c:fill(c:rect(x, 84 + (i % 4) * 4, x + 6 + (i % 3) * 3, 84 + (i % 4) * 4), "#98b890")
end
for i = 0, 22 do
  local x = (i * 41 + 7) % 226; local y = 90 + (i * 13) % 38
  c:fill(c:rect(x, y, x + 5 + (i % 3) * 3, y), "#3a7a7a")
end
-- duckweed / lily pads
for _, p in ipairs({ {56,108},{88,118},{160,112},{196,120},{30,122} }) do
  c:part(c:ellipse(p[1], p[2], 5, 2), GV.ramp("#7ab55c"), { flat = true, gloss = false })
end
c:part(c:ellipse(160, 111, 2, 1), GV.ramp("#f6b8cf"), { flat = true, gloss = false })

-- mid trunks with stilt roots (left and right clusters)
local function tree(x, ytop, ybase, wd)
  -- trunk
  rt({ {x, ytop}, {x, ybase - 14} }, wd, "#7a4a1f", { cres = 3, deep = 4 })
  -- stilt roots splaying down into water
  rt({ {x, ybase - 16}, {x - 8, ybase - 8}, {x - 14, ybase + 4} }, 3, "#8a4f2a")
  rt({ {x, ybase - 16}, {x + 8, ybase - 8}, {x + 14, ybase + 4} }, 3, "#8a4f2a")
  rt({ {x, ybase - 16}, {x - 2, ybase - 4}, {x - 3, ybase + 6} }, 2, "#a8582f")
  rt({ {x, ybase - 16}, {x + 3, ybase - 4}, {x + 4, ybase + 6} }, 2, "#a8582f")
end
tree(40, 30, 98, 6); tree(204, 28, 98, 6); tree(112, 50, 92, 4); tree(160, 56, 90, 4)
-- tangled cross-roots arching between the trees (the maze)
rt({ {44, 70}, {70, 60}, {96, 70}, {112, 80} }, 3, "#a8582f")
rt({ {160, 76}, {180, 62}, {200, 70} }, 3, "#a8582f")
rt({ {112, 72}, {134, 58}, {158, 70} }, 2, "#8a4f2a")
rt({ {30, 56}, {44, 46}, {64, 50} }, 2, "#8a4f2a")
-- canopy: big leaf masses top left / top right, drooping
local function leaves(cx, cy, rx, ry)
  c:part(c:ellipse(cx, cy, rx, ry), GV.ramp("#4a8a3e"), { cres = 4, deep = 7, gloss = false })
  c:part(c:ellipse(cx - rx * 0.5, cy + 2, rx * 0.6, ry * 0.7), GV.ramp("#6a9a3a"), { cres = 3, deep = 5, gloss = false })
end
leaves(24, 10, 34, 14); leaves(80, 4, 24, 10); leaves(204, 10, 36, 16); leaves(150, 3, 22, 9); leaves(8, 36, 14, 10); leaves(232, 38, 14, 10)
-- hanging aerial roots (thin, from canopy)
for _, x in ipairs({ 18, 34, 58, 76, 190, 210, 222 }) do
  local y1 = 36 + (x % 7) * 3
  c:fill(c:rect(x, 14, x + 1, y1), "#a8582f"); c:fill(c:rect(x, 14, x, y1), "#d9a660")
end
-- reflections of trunks in water (dashes)
for _, t in ipairs({ 40, 204, 112, 160 }) do
  for k = 0, 3 do c:fill(c:rect(t - 3 + (k % 2) * 2, 106 + k * 5, t + 2 + (k % 2) * 2, 106 + k * 5), "#173a42") end
end

-- foreground big arching root frames (left and right), with the frog log centre
local fl = c:mask(); fl:add(c:ellipse(120, 140, 70, 24))
c:part(fl:clip(c:rect(0, 96, W, 134)), GV.ramp("#7a4a1f"), { cres = 5, deep = 8, gloss = false })
rt({ {-4, 90}, {12, 100}, {30, 128}, {40, 138} }, 6, "#8a4f2a", { cres = 3, deep = 5 })
rt({ {244, 88}, {226, 100}, {208, 126}, {198, 138} }, 6, "#8a4f2a", { cres = 3, deep = 5 })
rt({ {-4, 112}, {20, 114}, {50, 126} }, 4, "#a8582f")
rt({ {244, 112}, {220, 116}, {190, 128} }, 4, "#a8582f")
-- moss bits on the log
for _, x in ipairs({ 84, 100, 132, 150 }) do c:fill(c:rect(x, 107 - (x % 3), x + 4, 108 - (x % 3)), "#7ab55c") end

-- the tree frog on the log, holding a firefly lantern
local FX, FY = 120, 104
local G = GV.ramp("#7ab55c", { shade = "#4a8a3e", deep = "#2f5a2a" })
-- back legs
c:part(c:ellipse(FX - 12, FY + 2, 5, 4), G, { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(FX + 12, FY + 2, 5, 4), G, { cres = 2, deep = 3, gloss = false })
-- body + head
c:part(c:ellipse(FX, FY, 12, 8), G, { cres = 4, deep = 6 })
c:part(c:ellipse(FX, FY + 3, 7, 5):clip(c:rect(0, FY + 1, W, H)), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
-- eye bumps on top
for _, dx in ipairs({ -8, 4 }) do
  c:part(c:ellipse(FX + dx + 2, FY - 8, 5, 5), G, { cres = 2, deep = 3, gloss = false })
  c:eye(FX + dx, FY - 10)
end
-- mouth: wide smile
for dx = -7, 7 do c:px(FX + dx, FY + 1 + ((math.abs(dx) > 5) and -1 or 0) + ((math.abs(dx) < 3) and 1 or 0), "#2a1a10") end
c:px(FX - 4, FY - 3, "#4a8a3e"); c:px(FX + 4, FY - 3, "#4a8a3e")
-- front feet
for _, dx in ipairs({ -8, 6 }) do c:part(c:ellipse(FX + dx + 1, FY + 8, 3, 2), G, { flat = true, gloss = false }) end
-- the firefly lantern: a little glass jar held on a twig above
c:fill(c:rect(FX + 16, FY - 24, FX + 16, FY - 8), "#7a4a1f")
c:part(c:rrect(FX + 12, FY - 22, FX + 20, FY - 14, 2), GV.ramp("#a9d6ea"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(FX + 14, FY - 20, FX + 18, FY - 16), "#fff1c8"); c:px(FX + 16, FY - 18, "#ffffff" == "" and "#fff1c8" or "#f5cf6a")
c:fill(c:rect(FX + 13, FY - 24, FX + 19, FY - 23), "#b07a45")
-- fireflies glowing around
for _, p in ipairs({ {70,62},{54,80},{176,50},{190,84},{96,66},{150,78},{26,70},{222,66},{134,36},{168,66} }) do
  c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#c8d77a")
end
c:ground(FX, FY + 12, 14, 2)

L.finish(c, SLUG)
