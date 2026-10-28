-- haven-thatchtop-tearoom.lua : "Thatchtop Tearoom. Scones and rest. Sells heirloom seed packets." NWE, cosy cottage garden, soft afternoon.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 76
local NF = { gloss = false, rim = false, bounce = false, outline = false }
local function nf(t) local o = {}; for k, v in pairs(NF) do o[k] = v end; for k, v in pairs(t or {}) do o[k] = v end; return o end

L.sky(c, "day", HOR)
L.cloud(c, 40, 22, 18, "#f4f0e0", "#cfd8e4"); L.cloud(c, 120, 12, 14, "#f4f0e0", "#cfd8e4"); L.cloud(c, 200, 30, 16, "#f4f0e0", "#cfd8e4")
-- rolling green hills with hedgerow fields
c:part(L.below(c, function(x) return 66 + math.sin(x / 30) * 5 end), GV.ramp("#8cc060"), nf{ cres = 3, deep = 5 })
c:part(L.below(c, function(x) return 74 + math.sin(x / 23 + 2) * 4 end), GV.ramp("#6aa850"), nf{ cres = 3, deep = 5 })
for i = 0, 8 do local x = i * 30 + 8; c:fill(c:rect(x, 80, x + 12, 80), "#4a8a3a"); c:fill(c:rect(x + 4, 77, x + 8, 77), "#4a8a3a") end
-- garden lawn
c:part(L.below(c, function(x) return 82 end), GV.ramp("#7ab55c"), nf{ cres = 4, deep = 8 })
for i = 0, 44 do local x = (i * 53 + 3) % W; local y = 90 + (i * 37) % 40; c:px(x, y, "#4a8a3a"); c:px(x + 1, y - 1, "#a4d070"); c:px(x + 2, y, "#4a8a3a") end

-- the cottage (cream plaster, timber frame) with a deep thatched roof
local x0, x1 = 54, 186
c:part(c:rect(x0, 62, x1, 108), GV.ramp("#f2e4c0"), { cres = 5, deep = 9, gloss = false, pale = true })
for _, bx in ipairs({ x0 + 1, 96, 144, x1 - 1 }) do c:fill(c:rect(bx - 1, 62, bx, 108), "#6a4420") end
c:fill(c:rect(x0, 84, x1, 85), "#6a4420"); c:seam({ {x0, 84}, {x1, 84} }, { free = true, on = 2, off = 1 })
c:seam({ {96, 85}, {120, 108} }, { free = true, on = 3, off = 0, gap = "#6a4420" })
-- thatch: big golden roof, with eyebrow dormer and a ragged lower fringe, straw-line seams
local roof = c:poly({ {x0 - 14, 66}, {x0 + 14, 30}, {x1 - 14, 30}, {x1 + 14, 66} })
roof:add(c:rect(x0 - 12, 60, x1 + 12, 68))
for x = x0 - 12, x1 + 12, 4 do roof:add(c:rect(x, 66, x + 2, 70 + (x * 7 % 3))) end
c:part(roof, GV.ramp("#d6a040"), { cres = 6, deep = 10, gloss = false })
for y = 38, 62, 6 do c:seam({ {x0 - 10 + (y - 38) * 0.3, y}, {x1 + 10 - (y - 38) * 0.3, y} }, { free = true, on = 4, off = 1, gap = "#a8782a" }) end
c:seam({ {x0 + 14, 31}, {x1 - 14, 31} }, { free = true, on = 3, off = 0, gap = "#f0c870" })
-- ridge tuft + chimney
c:part(c:rect(150, 14, 160, 34), GV.ramp("#b8643a"), { cres = 3, deep = 5, gloss = false })
c:part(c:rect(148, 12, 162, 15), GV.ramp("#8a8a90"), { flat = true, gloss = false })
-- chimney smoke
c:fill(c:ellipse(154, 8, 4, 3), "#fbf8ee"); c:fill(c:ellipse(158, 3, 3, 2), "#fbf8ee"); c:fill(c:rect(151, 9, 157, 10), "#d8e2ea")
-- eyebrow dormer window in the thatch (rounded)
c:part(c:rrect(106, 44, 134, 62, 8), GV.ramp("#d6a040"), { cres = 3, deep = 5, gloss = false })
c:part(c:rrect(113, 50, 127, 62, 4), GV.ramp("#f5cf6a"), { cres = 2, deep = 3, gloss = false, contour = "#2a1a10" })
c:fill(c:rect(120, 50, 120, 62), "#6a4420"); c:fill(c:rect(113, 56, 127, 56), "#6a4420")
-- round door (green) and leaded windows, warm
c:part(c:rrect(108, 84, 132, 108, 10), GV.ramp("#3a8a6a"), { cres = 4, deep = 7, gloss = false })
c:part(c:ellipse(120, 96, 8, 10), GV.ramp("#3a8a6a"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(124, 98, 1.5, 1.5), GV.ramp("#e8a317"), { flat = true, gloss = false, outline = false })
c:part(c:rrect(114, 88, 126, 94, 2), GV.ramp("#f5cf6a"), { flat = true, gloss = false, outline = false })
for _, wx in ipairs({ 70, 150 }) do
  c:part(c:rrect(wx, 88, wx + 22, 104, 3), GV.ramp("#f5cf6a"), { cres = 3, deep = 5, gloss = false, contour = "#2a1a10" })
  c:fill(c:rect(wx + 11, 88, wx + 11, 104), "#6a4420"); c:fill(c:rect(wx, 96, wx + 22, 96), "#6a4420")
  c:part(c:rect(wx - 2, 104, wx + 24, 107), GV.ramp("#8a5a2e"), { gloss = false, cres = 2, deep = 3 })   -- window box
  for k = 0, 4 do c:part(c:ellipse(wx + 1 + k * 5, 103, 2, 2), GV.ramp(k % 2 == 0 and "#e0709a" or "#f5cf6a"), { flat = true, gloss = false, outline = false }) end
end
-- low garden wall (stone) at the edges, hollyhocks
c:part(c:rect(0, 100, 52, 110), GV.ramp("#b8a890"), { cres = 3, deep = 5, gloss = false })
c:part(c:rect(190, 100, W - 1, 110), GV.ramp("#b8a890"), { cres = 3, deep = 5, gloss = false })
for _, wy in ipairs({ 104 }) do for x = 6, 234, 12 do if x < 50 or x > 192 then c:px(x, wy, "#8a7a64"); c:fill(c:rect(x + 3, wy - 3, x + 3, wy - 3), "#8a7a64") end end end
for _, hx in ipairs({ 10, 24, 40, 198, 214, 228 }) do
  c:fill(c:rect(hx, 82, hx, 100), "#3a8a3a")
  for k = 0, 3 do c:part(c:ellipse(hx + (k % 2) , 84 + k * 4, 2.5, 2.5), GV.ramp(({ "#e0709a", "#f2e4c0", "#d6322b", "#b070d0" })[(hx % 4) + 1]), { flat = true, gloss = false, outline = false }) end
end
-- stone path
c:part(c:poly({ {108,108},{132,108},{150,H},{90,H} }), GV.ramp("#d8c8a8"), nf{ cres = 3, deep = 5 })
for _, s in ipairs({ {118,114},{124,120},{116,125},{128,128} }) do c:fill(c:ellipse(s[1], s[2], 4, 1.5), "#b8a888") end
-- foreground tea table (checked cloth) with the tiered scone stand, teapot, seed packets
c:part(c:ellipse(172, 122, 28, 8), GV.ramp("#e0e8f0"), { cres = 3, deep = 5, gloss = false })
for k = 0, 8 do c:fill(c:rect(150 + k * 5, 118 + (k % 2), 152 + k * 5, 119 + (k % 2)), "#d6322b") end
-- tiered stand
c:fill(c:rect(171, 100, 172, 118), "#a8a8b0")
for _, t in ipairs({ { 106, 10 }, { 112, 7 }, { 118, 12 } }) do end
c:part(c:ellipse(172, 117, 11, 3), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:ellipse(172, 108, 8, 2.5), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:ellipse(172, 100, 5, 2), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
for _, s in ipairs({ { 166, 113 }, { 172, 112 }, { 178, 113 }, { 169, 104 }, { 175, 104 } }) do
  c:part(c:ellipse(s[1], s[2], 3, 2.5), GV.ramp("#d6a040"), { flat = true, gloss = false, outline = false }); c:px(s[1] - 1, s[2] - 1, "#f0c870")
end
c:part(c:ellipse(172, 97, 2, 2), GV.ramp("#d6322b"), { flat = true, gloss = false, outline = false })   -- cherry on top
-- teapot, cup
c:part(c:ellipse(152, 116, 7, 6), GV.ramp("#f2e4c0"), { cres = 3, deep = 4 })
c:part(c:poly({ {159, 113}, {165, 109}, {162, 116} }), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:rect(150, 108, 154, 110), GV.ramp("#d6322b"), { flat = true, gloss = false }); c:fill(c:ellipse(152, 116, 3, 1), "#e0709a")
c:fill(c:rect(151, 105, 152, 107), "#fbf8ee")
-- seed packet stand on the left: little coloured packets propped on a crate (heirloom seeds for sale)
c:part(c:rrect(18, 112, 44, 126, 2), GV.ramp("#b07a45"), { cres = 3, deep = 5, gloss = false })
for i, col in ipairs({ "#d6322b", "#f5cf6a", "#6aa04a", "#e0709a", "#4e8a9a" }) do
  c:part(c:rect(18 + i * 4 - 1, 100 + (i % 2) * 2, 18 + i * 4 + 2, 112), GV.ramp(col), { flat = true, gloss = false })
  c:fill(c:rect(18 + i * 4, 104 + (i % 2) * 2, 18 + i * 4 + 1, 106 + (i % 2) * 2), "#f2e4c0")
end
-- chibi hedgehog guest on the path
local hx, hy = 98, 114
-- spiky back: a zigzag crown of quills so it reads as a hedgehog, not a round lump
local back = c:ellipse(hx - 2, hy, 10, 8)
for k = 0, 6 do local sx = hx - 12 + k * 3; back:add(c:poly({ {sx, hy - 4 + math.abs(k - 3)}, {sx + 2, hy - 11 + math.abs(k - 3)}, {sx + 4, hy - 4 + math.abs(k - 3)} })) end
c:part(back, GV.ramp("#6a4a30"), { cres = 4, deep = 6, gloss = false })
for k = 0, 6 do local sx = hx - 11 + k * 3; local ty = hy - 10 + math.abs(k - 3); c:fill(c:rect(sx, ty, sx + 1, hy - 6), "#4a3020"); c:px(sx, ty - 1, "#2a1a10") end
for k = 0, 5 do c:fill(c:rect(hx - 9 + k * 3, hy - 4 + (k % 2) * 2, hx - 9 + k * 3, hy - 1 + (k % 2) * 2), "#4a3020") end
-- pale face and pointed snout
c:part(c:ellipse(hx + 7, hy + 2, 6, 5), GV.ramp("#e8c8a0"), { cres = 3, deep = 4, gloss = false })
c:part(c:poly({ {hx + 11, hy}, {hx + 16, hy + 3}, {hx + 11, hy + 6} }), GV.ramp("#e8c8a0"), { flat = true, gloss = false, outline = false })
c:fill(c:rect(hx + 15, hy + 2, hx + 16, hy + 3), "#2a1a10")   -- nose
c:eye(hx + 8, hy, true); c:px(hx + 8, hy - 2, "#2a1a10")
c:px(hx + 6, hy + 4, "#e0709a")   -- blush
c:part(c:ellipse(hx + 4, hy - 8, 4, 2), GV.ramp("#e0709a"), { flat = true, gloss = false, outline = false })   -- bonnet
c:ground(hx, hy + 8, 10, 2)
c:ground(172, 128, 24, 2)
L.finish(c, "haven-thatchtop-tearoom")
