-- delve-the-red-rock-songlines: a dotted songline path across the red desert to the great rock, a kangaroo wayfarer. OC, warm.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local HOR = 74

L.sky(c, "warm", HOR)
-- low sun and hard glow rings
c:fill(c:ellipse(190, HOR - 4, 20, 20):clip(c:rect(0, 0, W, HOR)), "#fbe8c0")
c:fill(c:ellipse(190, HOR - 4, 13, 13):clip(c:rect(0, 0, W, HOR)), "#fff1c8")
c:fill(c:ellipse(190, HOR - 4, 8, 8):clip(c:rect(0, 0, W, HOR)), "#ffe9a0")
L.cloud(c, 40, 20, 18, "#fbe8c0", "#f0be80"); L.cloud(c, 120, 34, 14, "#fbe8c0", "#f0be80"); L.cloud(c, 214, 16, 12, "#fdf2d8", "#f5cc92")
-- galahs (pink birds) in the sky
for _, g in ipairs({ {70,26},{80,22},{90,28} }) do
  c:px(g[1], g[2], "#e46a9b"); c:px(g[1]+1, g[2]+1, "#e46a9b"); c:px(g[1]+2, g[2], "#e46a9b"); c:px(g[1]+3, g[2]+1, "#e46a9b"); c:px(g[1]+4, g[2], "#e46a9b")
end
-- desert plain, hard bands from far haze to near red
c:bands(c:rect(0, HOR + 1, W - 1, H - 1), { "#e0a070", "#d98a5a", "#cf7a4a", "#c26a3e", "#b05a34", "#9a4a2c" }, { dir = "v" })
-- far ranges
c:part(c:poly({ {0,HOR+1},{0,HOR-6},{24,HOR-10},{60,HOR-4},{96,HOR-8},{120,HOR+1} }), GV.ramp("#c98a6a"), { outline = false, gloss = false, rim = false, bounce = false })
c:part(c:poly({ {150,HOR+1},{170,HOR-5},{200,HOR-9},{232,HOR-4},{W,HOR-6},{W,HOR+1} }), GV.ramp("#c98a6a"), { outline = false, gloss = false, rim = false, bounce = false })

-- the great rock (a long red monolith) with streaked flanks -----------------------------------------------
local rock = c:poly({ {26,HOR+3},{34,HOR-8},{50,HOR-14},{74,HOR-18},{104,HOR-20},{134,HOR-17},{158,HOR-12},{172,HOR-3},{180,HOR+3} })
c:part(rock, GV.ramp("#c4452a"), { cres = 9, deep = 14, gloss = false })
for _, x in ipairs({ 50, 62, 78, 92, 108, 122, 138, 150 }) do
  c:fill(c:line({ {x, HOR - 12 + (x % 5)}, {x + 2, HOR - 6}, {x + 1, HOR + 1} }, 1), "#8a2a24")
end
-- a small cave mouth and a patch of rock-art on its face
c:fill(c:ellipse(112, HOR - 1, 7, 6):clip(c:rect(0, 0, W, HOR + 1)), "#4a1a1a")

-- spinifex and desert oaks in the midground ------------------------------------------------------------------
local function tuft(x, y)
  c:px(x, y, "#a4b86a"); c:px(x - 2, y + 1, "#a4b86a"); c:px(x + 2, y + 1, "#a4b86a"); c:px(x - 1, y, "#7ab55c"); c:px(x + 1, y, "#7ab55c"); c:fill(c:rect(x - 2, y + 2, x + 2, y + 2), "#6a9a3a")
end
for _, p in ipairs({ {14,86},{40,96},{190,90},{222,100},{176,112},{10,106},{210,126},{70,128},{230,84},{48,84} }) do tuft(p[1], p[2]) end
local function oak(x, y, s)
  c:fill(c:rect(x - 1, y - s, x, y), "#5e2f1e")
  c:part(c:ellipse(x, y - s - 2, s, s * 0.6), GV.ramp("#6a9a3a"), { cres = 3, deep = 4, gloss = false, rim = false })
end
oak(24, 90, 8); oak(214, 94, 10); oak(196, 84, 6)

-- songline: a winding path of dots toward the great rock -----------------------------------------------------------
local pts = {}
for i = 0, 40 do
  local t = i / 40
  local y = H - 8 - t * (H - 8 - (HOR + 6))
  local x = 108 + math.sin(t * 7) * (42 * (1 - t) ^ 0.8)
  pts[#pts + 1] = { x, y, t }
end
local cols = { "#f2e4c0", "#f5cf6a", "#fff1c8", "#e8a317", "#f6b8cf" }
for i, p in ipairs(pts) do
  local r = (p[3] < 0.35) and 2 or ((p[3] < 0.7) and 1 or 0)
  local x, y = math.floor(p[1]), math.floor(p[2])
  c:fill(c:rect(x - r - 1, y - (r > 0 and 1 or 0), x + r, y), cols[(i % #cols) + 1])
  if r > 0 then c:px(x - r + 1, y - 1, "#fff1c8") end
end
-- drifting song notes along the path (gold, 2-3 px)
for _, n in ipairs({ {146,92},{122,104},{96,92},{110,84} }) do
  c:fill(c:rect(n[1], n[2], n[1] + 2, n[2] + 2), "#f5cf6a"); c:fill(c:rect(n[1] + 2, n[2] - 5, n[1] + 2, n[2]), "#e8a317"); c:px(n[1] + 3, n[2] - 5, "#e8a317"); c:px(n[1] + 4, n[2] - 4, "#e8a317")
end

-- rock-art boulder, right foreground: concentric dot circles --------------------------------------------------------
local b = c:poly({ {158,H},{160,112},{172,100},{194,96},{222,98},{W,104},{W,H} })
c:part(b, GV.ramp("#b8452f"), { cres = 6, deep = 10, gloss = false })
local function ring(cx, cy, r, col) 
  for a = 0, 11 do local x = math.floor(cx + math.cos(a * math.pi / 6) * r + 0.5); local y = math.floor(cy + math.sin(a * math.pi / 6) * r * 0.9 + 0.5); c:px(x, y, col) end
end
ring(190, 114, 8, "#f2e4c0"); ring(190, 114, 4, "#f5cf6a"); c:px(190, 114, "#fff1c8")
ring(214, 108, 5, "#f2e4c0"); c:px(214, 108, "#f5cf6a")
for i = 0, 8 do c:px(166 + i * 3, 122 + ((i % 2) * 2), "#f2e4c0") end
for i = 0, 7 do c:px(198 + i * 4, 126 - ((i % 2) * 2), "#f5cf6a") end

-- the wayfarer: a little kangaroo with its paw pointed along the song -------------------------------------------------------
local KX, KY = 44, 126
c:part(c:ellipse(KX - 12, KY - 4, 9, 3), GV.ramp("#c98a4a"), { cres = 2, gloss = false })        -- tail
c:part(c:ellipse(KX, KY - 12, 10, 12), GV.ramp("#d9a660"), { cres = 5, deep = 8 })               -- body
c:part(c:ellipse(KX + 2, KY - 11, 5, 7), GV.ramp("#f2e4c0"), { flat = true, gloss = false })     -- belly
c:part(c:ellipse(KX - 5, KY, 5, 2.5), GV.ramp("#b07a45"), { cres = 1, gloss = false })           -- big foot
c:part(c:ellipse(KX + 8, KY, 5, 2.5), GV.ramp("#b07a45"), { cres = 1, gloss = false })
c:part(c:poly({ {KX - 5,KY - 30},{KX - 2,KY - 41},{KX + 1,KY - 30} }), GV.ramp("#d9a660"), { flat = true, gloss = false })  -- ears
c:part(c:poly({ {KX + 6,KY - 30},{KX + 9,KY - 41},{KX + 12,KY - 30} }), GV.ramp("#d9a660"), { flat = true, gloss = false })
c:part(c:ellipse(KX + 4, KY - 25, 10, 8), GV.ramp("#d9a660"), { cres = 4, deep = 6 })            -- head
c:eye(KX - 3, KY - 29); c:eye(KX + 5, KY - 29)
c:fill(c:rect(KX + 3, KY - 23, KX + 5, KY - 22), "#4a2c1a")                                    -- nose
c:px(KX + 3, KY - 20, "#2a1a10"); c:px(KX + 4, KY - 19, "#2a1a10"); c:px(KX + 5, KY - 20, "#2a1a10")
c:part(c:ellipse(KX + 18, KY - 15, 4, 2.5), GV.ramp("#d9a660"), { flat = true, gloss = false }) -- pointing paw
c:ground(KX, KY + 2, 16, 2)

L.finish(c, "delve-the-red-rock-songlines")
