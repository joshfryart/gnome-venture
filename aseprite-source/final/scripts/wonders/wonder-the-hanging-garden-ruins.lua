-- wonder-the-hanging-garden-ruins.lua : terraces of old stone, crops still growing; golden-hour MENA light.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local FLAT = { gloss = false, rim = false, bounce = false, outline = false }
local STONE = GV.ramp("#d9bb82", { shade = "#b08a5a", deep = "#7a5a3c", rim = "#f0d8a0" })
local STONE2 = GV.ramp("#c9a672", { shade = "#a07c52", deep = "#6e4e34", rim = "#e8cc92" })

L.sky(c, "warm", 100)
-- sun, hazy
c:fill(c:ellipse(40, 30, 10, 10), "#fff1c8"); c:fill(c:ellipse(40, 30, 7, 7), "#fff8e0")
L.cloud(c, 150, 22, 18, "#fdf0d8", "#f2c898"); L.cloud(c, 210, 40, 14, "#fdf0d8", "#f2c898"); L.cloud(c, 90, 48, 12, "#fdf0d8", "#f2c898")
-- far dunes and a far skyline of domes
c:part(c:poly({ {0,84},{0,74},{30,68},{70,76},{120,70},{170,76},{210,68},{240,74},{240,84} }), GV.ramp("#e0b080"), FLAT)
c:part(c:poly({ {0,90},{0,82},{40,78},{90,84},{150,80},{200,84},{240,80},{240,90} }), GV.ramp("#d89c6c"), FLAT)
c:part(c:ellipse(20, 76, 4, 4):cut(c:rect(0, 77, 40, 90)), GV.ramp("#cfa478"), FLAT); c:fill(c:rect(19, 66, 20, 72), "#cfa478")
c:part(c:rect(226, 70, 229, 80), GV.ramp("#cfa478"), FLAT); c:part(c:poly({ {225,70},{227.5,64},{230,70} }), GV.ramp("#cfa478"), FLAT)
-- ground
c:part(L.below(c, function(x) return 100 + 2 * math.sin(x / 17) end), GV.ramp("#e6c88c"), { cres = 6, deep = 9, gloss = false })

-- crops on a terrace top surface (x0..x1, surface rows y0..y1)
local function crops(x0, x1, y0, y1, kind)
  c:part(c:rect(x0, y0, x1, y1), GV.ramp("#8a6a3c", { shade = "#6a4a2a", deep = "#4a2c1a" }), FLAT)
  for x = x0 + 2, x1 - 3, 7 do
    local k = (x // 7 + kind) % 4
    if k == 0 then      -- pomegranate shrub
      c:part(c:ellipse(x + 2, y0 + 1, 4, 3), GV.ramp("#4a8a3e"), { flat = true, gloss = false, outline = false })
      c:px(x + 1, y0 - 1, "#d6322b"); c:px(x + 4, y0, "#d6322b"); c:px(x + 2, y0 + 1, "#f08a24")
    elseif k == 1 then  -- wheat
      for i = 0, 3 do c:fill(c:rect(x + i * 2, y0 - 1 - (i % 2), x + i * 2, y1), "#e8c860"); c:px(x + i * 2, y0 - 2 - (i % 2), "#f5e090") end
    elseif k == 2 then  -- vine on a stick
      c:fill(c:rect(x + 2, y0 - 3, x + 2, y1), "#7a4a1f")
      c:part(c:ellipse(x + 2, y0 - 1, 3, 3), GV.ramp("#7ab55c"), { flat = true, gloss = false, outline = false })
      c:px(x + 1, y0 + 1, "#7a4a8a"); c:px(x + 3, y0 + 1, "#7a4a8a")
    else                -- melons
      c:part(c:ellipse(x + 1, y0 + 2, 3, 2.5), GV.ramp("#6a9a3a"), { flat = true, gloss = false, outline = false })
      c:part(c:ellipse(x + 5, y0 + 2, 2.5, 2), GV.ramp("#f0c040"), { flat = true, gloss = false, outline = false })
    end
  end
end
-- terraces, top (far) first. k = 0 lowest
local T = {}
for k = 4, 0, -1 do
  local x0, x1 = 22 + k * 22, 218 - k * 22
  local yt = 106 - k * 13 - 8
  local face = (k % 2 == 0) and STONE or STONE2
  c:part(c:rect(x0, yt + 6, x1, yt + 22), face, { cres = 4, deep = 6, gloss = false })
  -- block joints
  local row = 0
  for y = yt + 11, yt + 21, 5 do
    local off = (row % 2) * 6
    for x = x0 + 4 + off, x1 - 3, 12 do c:fill(c:rect(x, y, x, y + 4), (face == STONE) and "#a07c52" or "#8a6a44") end
    c:fill(c:rect(x0 + 2, y, x1 - 2, y), (face == STONE) and "#b8966a" or "#a88a5e"); row = row + 1
  end
  crops(x0 + 2, x1 - 2, yt + 1, yt + 5, k)
end
-- broken notches: missing stone at the edge of terraces (sky/dune shows through as crumbled steps)
for _, n in ipairs({ { 22, 80, 30, 86 }, { 204, 54, 212, 60 }, { 66, 54, 72, 59 } }) do
  c:part(c:poly({ {n[1],n[2]},{n[3],n[2]+2},{n[3],n[4]},{n[1],n[4]} }), GV.ramp("#d9bb82"), FLAT)
end
-- fallen blocks at the feet
c:part(c:rrect(12, 104, 24, 112, 1), STONE, { cres = 3, gloss = false }); c:part(c:rrect(196, 106, 210, 114, 1), STONE2, { cres = 3, gloss = false })

-- the summit: a ruined arch with a palm
local TOP = 106 - 4 * 13 - 8   -- terrace-4 surface row
c:part(c:rect(104, TOP - 22, 110, TOP + 4), STONE, { cres = 3, deep = 5 }); c:part(c:rect(130, TOP - 14, 136, TOP + 4), STONE, { cres = 3, deep = 5 })
c:part(c:poly({ {104,TOP-22},{108,TOP-30},{124,TOP-30},{128,TOP-22},{128,TOP-17},{110,TOP-17},{110,TOP-22} }), STONE, { cres = 3, deep = 5 })  -- broken lintel
c:seam({ {106, TOP - 8}, {108, TOP - 8} }, { free = true, on = 2, off = 0, gap = "#7a5a3c" })
-- vine hanging from the arch
c:fill(c:rect(118, TOP - 17, 118, TOP - 8), "#4a8a3e"); c:fill(c:rect(121, TOP - 17, 121, TOP - 11), "#4a8a3e")
c:px(118, TOP - 8, "#7a4a8a"); c:px(119, TOP - 9, "#7a4a8a"); c:px(121, TOP - 11, "#d6322b")
-- date palm on the left of the summit
c:part(c:line({ {88, TOP + 2}, {89, TOP - 8}, {87, TOP - 16} }, 3), GV.ramp("#8a5a2f"), { flat = true, gloss = false })
for _, f in ipairs({ { -11, 2 }, { 11, 2 }, { -7, -5 }, { 7, -5 }, { 0, -8 } }) do
  c:part(c:poly({ {87,TOP-17},{87+f[1]*0.6,TOP-17+f[2]-4},{87+f[1],TOP-17+f[2]},{87+f[1]*0.5,TOP-17+f[2]+3} }), GV.ramp("#5a9a44"), { flat = true, gloss = false, outline = false })
end
c:px(85, TOP - 15, "#e8a317"); c:px(89, TOP - 15, "#e8a317")

-- an old irrigation channel zigzagging down the middle, still trickling
local ch = { {120,TOP+5},{120,TOP+12},{126,TOP+12},{126,TOP+25},{114,TOP+25},{114,TOP+38},{122,TOP+38},{122,TOP+51},{116,TOP+51},{116,102} }
c:fill(c:line(ch, 2), "#8fcbd8")
for i = 1, #ch - 1 do end
for _, p in ipairs({ {120,TOP+9},{126,TOP+18},{114,TOP+32},{122,TOP+44},{116,TOP+58} }) do c:px(p[1], p[2], "#e0f4ee") end
-- pool at the base
c:part(c:ellipse(116, 106, 13, 3), GV.ramp("#3f8fb0"), { flat = true, gloss = false })
c:fill(c:ellipse(116, 106, 9, 1.5), "#8fcbd8"); c:px(112, 106, "#e0f4ee"); c:px(119, 105, "#e0f4ee")

-- foreground: broken column drums with vines, a heap of the finest produce ----------------------------------------
local col = c:rect(14, 100, 30, 121)
c:part(c:rect(14, 106, 30, 126), STONE, { cres = 5, deep = 8 })
for y = 112, 124, 6 do c:fill(c:rect(14, y, 30, y), "#a07c52") end
c:part(c:rect(11, 101, 33, 107), STONE2, { cres = 3, deep = 5 })
for i = 0, 3 do c:fill(c:rect(16 + i * 4, 108, 16 + i * 4, 111), "#c0a070") end
-- vine wrapping
c:part(c:line({ {13, 118}, {20, 114}, {26, 118}, {32, 113} }, 2), GV.ramp("#5a9a44"), { flat = true, gloss = false, outline = false })
c:px(20, 112, "#d6322b"); c:px(27, 116, "#7a4a8a"); c:px(16, 121, "#d6322b")
-- produce heap, right foreground: pomegranates, melon, wheat sheaf
local function fruit(x, y, rx, ry, col) c:part(c:ellipse(x, y, rx, ry), GV.ramp(col), { cres = rx > 4 and 3 or 2, deep = rx > 4 and 5 or 3 }) end
c:part(c:rrect(178, 114, 218, 126, 3), GV.ramp("#a8582f"), { cres = 4, deep = 6, gloss = false })   -- basket
c:seam({ {181, 119}, {215, 119} }, { on = 2, off = 1 })
fruit(186, 111, 6, 5, "#d6322b"); fruit(198, 108, 7, 6, "#6a9a3a"); fruit(209, 111, 5, 4.5, "#f0a030"); fruit(193, 113, 4, 3.5, "#9a3a6a")
c:px(185, 108, "#fff1c8"); c:px(196, 105, "#c8d77a")
c:part(c:poly({ {200,99},{203,90},{206,99} }), GV.ramp("#e8c860"), { flat = true, gloss = false })
c:part(c:poly({ {205,99},{210,91},{211,99} }), GV.ramp("#f0d070"), { flat = true, gloss = false })
c:fill(c:rect(201, 100, 209, 102), "#7a4a1f")
-- a lizard sunning on the column (cute), eyes small
c:part(c:ellipse(26, 99, 4, 2.5), GV.ramp("#7ab55c"), { cres = 2, deep = 3 })
c:part(c:ellipse(31, 98, 2.5, 2.5), GV.ramp("#7ab55c"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(30, 97, 31, 98), "#fff1c8"); c:px(31, 98, "#2a1a10")
c:fill(c:rect(18, 100, 22, 100), "#7ab55c")
-- birds
for _, g in ipairs({ {70,30},{80,26},{170,36} }) do c:px(g[1], g[2], "#7a5a3c"); c:px(g[1]+1, g[2]+1, "#7a5a3c"); c:px(g[1]+2, g[2], "#7a5a3c") end
L.finish(c, "wonder-the-hanging-garden-ruins")
