-- wonder-the-labyrinth-isle.lua : "A hedge maze on a green island, with a stone gnome at its heart who has been asking the same riddle for centuries."
-- Thing to do: answer the riddle. Bright day, sea all around, South Europe (cypress, white gate).
local K = dofile("/home/user/gnome-venture/aseprite-source/final/scripts/wonders/w5lib.lua")
local L, GV, TINY = K.L, K.GV, K.TINY
local W, H = L.W, L.H
local c = L.new()
local function R(h, o) return GV.ramp(h, o) end
local HOR = 54

L.sky(c, "day", HOR)
L.cloud(c, 40, 20, 18, "#f4f0e0", "#cfd8e4"); L.cloud(c, 170, 14, 20, "#f4f0e0", "#cfd8e4"); L.cloud(c, 120, 34, 12, "#f4f0e0", "#cfd8e4"); L.cloud(c, 214, 36, 11, "#f4f0e0", "#cfd8e4")
-- sea
L.water(c, HOR + 1, "day")
c:fill(c:rect(0, HOR + 1, W - 1, HOR + 1), "#8fcbd8")
-- far headlands and a sail
c:fill(L.below(c, function(x) return HOR - 5 + 3 * math.sin(x / 9) end):clip(c:rect(0, HOR - 8, 44, HOR)), "#a894dc")
c:fill(L.below(c, function(x) return HOR - 4 + 2 * math.sin(x / 7 + 2) end):clip(c:rect(196, HOR - 8, W - 1, HOR)), "#a894dc")
c:fill(c:poly({ { 66, HOR - 9 }, { 66, HOR - 1 }, { 72, HOR - 1 } }), "#fff3c8"); c:fill(c:rect(65, HOR, 73, HOR), "#8a4f2a")
for _, g in ipairs({ { 30, 40 }, { 38, 36 }, { 196, 44 } }) do
  c:px(g[1], g[2], "#2a1a10"); c:px(g[1] + 1, g[2] + 1, "#2a1a10"); c:px(g[1] + 2, g[2], "#2a1a10"); c:px(g[1] + 3, g[2] + 1, "#2a1a10"); c:px(g[1] + 4, g[2], "#2a1a10")
end

-- the island ------------------------------------------------------------------------------------------
local CX, CY = 120, 94
c:part(c:ellipse(CX, CY + 4, 108, 32), R("#c9a96e"), { gloss = false, cres = 6, deep = 8 })            -- beach + low cliff
c:part(c:ellipse(CX, CY, 102, 28), R("#7ab55c"), { gloss = false, outline = false, cres = 5, deep = 7 }) -- meadow
-- corridor floor
c:fill(c:ellipse(CX, CY, 90, 24), "#e9d9a8")
c:fill(c:ellipse(CX, CY, 90, 24):cut(c:ellipse(CX, CY - 1, 89, 23)), "#d9c488")

local function ring(rx, ry, gaps)
  local function band(dy)
    return c:ellipse(CX, CY + dy, rx, ry):cut(c:ellipse(CX, CY + dy, rx - 5, ry - 3))
  end
  local front = band(5):add(band(3)):add(band(1))
  local top = band(0)
  for _, g in ipairs(gaps) do front:cut(c:rect(g[1], g[2], g[3], g[4])); top:cut(c:rect(g[1], g[2], g[3], g[4])) end
  c:fill(front, "#2f5a2a")
  K.fur(c, top, "#6a9a3a", "#4a8a3e", "#3a7a34")
  -- leafy speckle
  top:each(function(x, y) if (x * 7 + y * 13) % 11 == 0 then c:px(x, y, "#a4b86a") end end)
  front:cut(top):each(function(x, y) if (x * 5 + y * 9) % 13 == 0 then c:px(x, y, "#4a8a3e") end end)
end
local function ringy(rx, ry) return CY - ry end
ring(86, 23, { { CX - 6, CY + 14, CX + 6, CY + 40 }, { CX + 62, CY - 14, CX + 90, CY - 6 }, { CX - 90, CY - 2, CX - 70, CY + 8 } })
ring(64, 17, { { CX - 30, CY - 22, CX - 20, CY - 8 }, { CX + 20, CY + 8, CX + 36, CY + 28 }, { CX - 70, CY - 6, CX - 50, CY + 6 } })
ring(42, 11, { { CX + 4, CY - 16, CX + 16, CY - 4 }, { CX - 14, CY + 6, CX - 2, CY + 24 } })
-- inner lawn
c:fill(c:ellipse(CX, CY, 33, 7), "#a4b86a"); c:fill(c:ellipse(CX, CY, 33, 7):cut(c:ellipse(CX, CY - 1, 32, 6)), "#c8d77a")
-- stepping stones
for _, p in ipairs({ { CX, CY + 18 }, { CX + 2, CY + 14 }, { CX - 8, CY + 6 }, { CX - 14, CY + 2 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#c9c5bc") end

-- stone gnome on a plinth -------------------------------------------------------------------------------
local GX, GY = CX, CY + 3
c:part(c:rrect(GX - 9, GY - 5, GX + 9, GY + 1, 1), R("#c9c5bc"), { gloss = false, cres = 3, deep = 4 })
c:part(c:rrect(GX - 7, GY - 8, GX + 7, GY - 4, 1), R("#8b8f96"), { gloss = false, cres = 2, deep = 3 })
c:part(c:rrect(GX - 5, GY - 20, GX + 5, GY - 7, 3), R("#b6b8bd"), { gloss = false, outline = false, cres = 4, deep = 5 })
c:part(c:ellipse(GX, GY - 25, 8, 6.5), R("#b6b8bd"), { gloss = false, outline = false, cres = 4, deep = 5 })
c:part(c:poly({ { GX - 6, GY - 21 }, { GX + 7, GY - 21 }, { GX + 1, GY - 10 } }), R("#e8e4dc"), TINY) -- beard
c:part(c:poly({ { GX - 9, GY - 29 }, { GX + 10, GY - 29 }, { GX + 4, GY - 48 } }), R("#8b8f96"), { gloss = false, outline = false, cres = 3, deep = 4 })
-- raised finger and open mouth: the riddle
c:fill(c:rect(GX + 6, GY - 19, GX + 8, GY - 14), "#b6b8bd"); c:fill(c:rect(GX + 7, GY - 24, GX + 8, GY - 19), "#b6b8bd")
c:fill(c:rect(GX - 1, GY - 18, GX + 2, GY - 16), "#2a1a10")
-- sleepy-heavy eyes
c:eye(GX - 7, GY - 31); c:eye(GX + 2, GY - 31)
c:fill(c:rect(GX - 7, GY - 31, GX - 3, GY - 30), "#b6b8bd"); c:fill(c:rect(GX + 2, GY - 31, GX + 6, GY - 30), "#b6b8bd")
c:fill(c:rect(GX - 7, GY - 29, GX - 3, GY - 29), "#8b8f96"); c:fill(c:rect(GX + 2, GY - 29, GX + 6, GY - 29), "#8b8f96")
c:part(c:ellipse(GX, GY - 24, 2, 1.5), R("#b6b8bd"), TINY)
-- moss
for _, p in ipairs({ { -4, -9 }, { -3, -9 }, { -4, -10 }, { 5, -26 }, { 6, -25 }, { -6, -31 }, { 3, -8 }, { 4, -9 }, { 7, -6 } }) do c:px(GX + p[1], GY + p[2], "#7ab55c") end
-- riddle bubble
local bx, by = GX + 17, GY - 46
c:part(c:ellipse(bx, by, 8, 6), R("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:fill(c:poly({ { bx - 6, by + 4 }, { bx - 3, by + 4 }, { bx - 8, by + 9 } }), "#f2e4c0")
c:fill(c:rect(bx - 2, by - 4, bx + 1, by - 4), "#2a1a10"); c:fill(c:rect(bx + 1, by - 3, bx + 2, by - 2), "#2a1a10"); c:px(bx, by - 1, "#2a1a10"); c:px(bx - 1, by, "#2a1a10"); c:px(bx - 1, by + 1, "#2a1a10")
c:px(bx - 1, by + 3, "#2a1a10")

-- white gate (front entrance) -----------------------------------------------------------------------------
c:part(c:rect(CX - 11, CY + 18, CX - 8, CY + 29), R("#f1ece0", { dot = "#fff3c8" }), { gloss = false, cres = 2, deep = 3 })
c:part(c:rect(CX + 8, CY + 18, CX + 11, CY + 29), R("#f1ece0", { dot = "#fff3c8" }), { gloss = false, cres = 2, deep = 3 })
c:part(c:ellipse(CX - 9.5, CY + 16, 2, 2), R("#e8a317"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(CX + 9.5, CY + 16, 2, 2), R("#e8a317"), { flat = true, gloss = false, outline = false })
-- cypress sentries and flower tufts on the meadow edge
for _, t in ipairs({ { 22, 93 }, { 218, 93 }, { 34, 108 }, { 206, 108 } }) do
  c:part(c:ellipse(t[1], t[2] - 12, 4, 13), R("#2f5a2a"), { gloss = false, outline = false, cres = 3, deep = 5 })
  c:fill(c:rect(t[1], t[2] + 1, t[1] + 1, t[2] + 2), "#5e2f1e")
end
for _, p in ipairs({ { 10, 96 }, { 16, 104 }, { 230, 98 }, { 226, 106 }, { 60, 118 }, { 180, 119 }, { 100, 121 } }) do
  c:px(p[1], p[2], "#f6b8cf"); c:px(p[1] + 1, p[2] + 1, "#fff1c8")
end

-- jetty and rowboat, foreground -------------------------------------------------------------------------------
c:part(c:rect(CX - 8, CY + 28, CX + 8, CY + 36), R("#b07a45"), { gloss = false, cres = 3, deep = 4 })
for x = CX - 6, CX + 6, 4 do c:fill(c:rect(x, CY + 29, x, CY + 35), "#8a4f2a") end
c:part(c:poly({ { 28, 118 }, { 62, 118 }, { 56, 128 }, { 34, 128 } }), R("#d6322b"), { gloss = false, cres = 3, deep = 4 })
c:fill(c:rect(30, 118, 60, 119), "#f2e4c0")
c:fill(c:rect(44, 106, 45, 118), "#8a4f2a"); c:fill(c:poly({ { 46, 106 }, { 46, 116 }, { 58, 116 } }), "#fff3c8")
c:fill(c:rect(10, 126, 22, 126), "#8fcbd8"); c:fill(c:rect(64, 129, 78, 129), "#8fcbd8"); c:fill(c:rect(190, 124, 206, 124), "#8fcbd8"); c:fill(c:rect(170, 130, 186, 130), "#8fcbd8")
L.finish(c, "wonder-the-labyrinth-isle")
