-- haven-market-of-a-thousand-chilies : Central American market plaza, bright day. Chili stalls, ristras, cocoa house.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local RED, CREAM = "#d6322b", "#f2e4c0"

local function gnome(x, y, hat, shirt)
  c:part(c:ellipse(x, y - 5, 6, 6), GV.ramp(shirt), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x, y - 14, 6, 5.5), "skin", { cres = 3, deep = 4, gloss = false })
  c:part(c:poly({ {x - 7, y - 19}, {x + 1, y - 34}, {x + 7, y - 19} }), GV.ramp(hat), { cres = 3, deep = 4, gloss = false })
  c:eye(x - 5, y - 17, true); c:eye(x + 2, y - 17, true)
  c:fill(c:rect(x - 4, y - 11, x + 4, y - 8), "#f2e4c0")
  c:px(x - 1, y - 13, "#d9885a"); c:px(x, y - 13, "#d9885a")
end
local function awning(x0, x1, y0, y1, a, b)
  local m = c:poly({ {x0, y0}, {x1, y0}, {x1 + 4, y1}, {x0 - 4, y1} })
  c:part(m, GV.ramp(a), { cres = 3, deep = 4, gloss = false })
  local i = 0
  for x = x0 - 4, x1 + 4, 6 do
    if i % 2 == 1 then c:fill(m:copy():clip(c:rect(x, y0, x + 5, y1)), b) end
    i = i + 1
  end
  -- scallops
  for x = x0 - 3, x1 + 3, 6 do
    c:part(c:ellipse(x + 1.5, y1 + 1, 3, 2.5), GV.ramp(((x - x0) // 6) % 2 == 0 and a or b), { flat = true, gloss = false })
  end
end
local function ristra(x, y, n)
  c:fill(c:rect(x, y - 3, x, y), "#7a4a1f")
  for i = 0, n - 1 do
    local yy = y + i * 5
    c:part(c:ellipse(x + (i % 2) * 1 - 1, yy + 3, 2, 3), GV.ramp(i % 3 == 0 and "#e0501f" or RED), { flat = true, gloss = false })
    c:px(x, yy, "#4a8a3e")
  end
end
local function pile(cx, cy, rx, ry, col, spots)
  c:part(c:ellipse(cx, cy, rx, ry):cut(c:rect(cx - rx - 1, cy + 2, cx + rx + 1, cy + ry + 2)), GV.ramp(col), { cres = 3, deep = 4, gloss = false })
  for i, s in ipairs(spots) do
    c:fill(c:rect(cx + s[1], cy + s[2], cx + s[1] + 2, cy + s[2] + 1), s[3] or "#f08a24")
    c:px(cx + s[1] - 1, cy + s[2], "#4a8a3e")
  end
end
local function basket(cx, cy, rx, h, filling, spots)
  pile(cx, cy - h + 1, rx - 1, 4, filling, spots)
  c:part(c:rrect(cx - rx, cy - h + 2, cx + rx, cy, 2), GV.ramp("#c9a96e"), { cres = 3, deep = 4, gloss = false })
  c:seam({ {cx - rx + 2, cy - h + 6}, {cx + rx - 2, cy - h + 6} }, { on = 2, off = 1 })
end

-- sky, volcano, hills -------------------------------------------------------------------------
L.sky(c, "day", 78)
L.cloud(c, 40, 22, 16); L.cloud(c, 170, 14, 18); L.cloud(c, 120, 34, 11)
c:part(c:poly({ {120,80},{148,42},{156,36},{162,36},{170,42},{200,80} }), GV.ramp("#6a8ab8"), { cres = 4, gloss = false, rim = false, outline = false })
c:fill(c:rect(154, 33, 164, 35), "#e8d9d0"); c:px(158, 30, "#e8d9d0")  -- wisp of smoke
c:fill(c:ellipse(160, 28, 4, 2), "#f4f0e0"); c:fill(c:ellipse(166, 23, 3, 2), "#f4f0e0")
c:part(c:poly({ {0,80},{0,64},{24,54},{52,62},{80,70},{96,80} }), GV.ramp("#4a8a3e"), { cres = 4, gloss = false, rim = false, outline = false })
c:part(c:poly({ {190,80},{210,66},{240,58},{240,80} }), GV.ramp("#6a9a3a"), { cres = 4, gloss = false, rim = false, outline = false })

-- back row of adobe houses -----------------------------------------------------------------------
local function house(x0, x1, y0, col, roof)
  c:part(c:rect(x0, y0, x1, 90), GV.ramp(col), { cres = 4, deep = 6, gloss = false })
  c:part(c:rect(x0 - 2, y0 - 4, x1 + 2, y0 - 1), GV.ramp(roof), { cres = 2, deep = 3, gloss = false })
  local mx = (x0 + x1) // 2
  c:part(c:rect(mx - 3, y0 + 8, mx + 3, y0 + 18), GV.ramp("#2f5a8a"), { cres = 2, gloss = false, outline = false, contour = "#2a1a10" })
  c:fill(c:rect(mx - 1, y0 + 9, mx + 1, y0 + 12), "#8fcbd8")
end
house(6, 44, 62, "#f08a24", "#a8582f")
house(46, 82, 58, "#e46a9b", "#8a4f2a")
house(168, 204, 60, "#f5cf6a", "#a8582f")
house(206, 238, 64, "#8fcbd8", "#8a4f2a")
-- bunting between houses
for x = 10, 232, 8 do
  local y = 52 + math.floor(3 * math.sin(x / 38)) + 18
  c:fill(c:rect(x, y, x + 3, y + 1), (x // 8) % 3 == 0 and RED or ((x // 8) % 3 == 1 and "#f5cf6a" or "#3f8fb0"))
  c:px(x + 1, y + 2, (x // 8) % 3 == 0 and RED or ((x // 8) % 3 == 1 and "#f5cf6a" or "#3f8fb0"))
end

-- plaza ground ----------------------------------------------------------------------------------
c:part(c:rect(0, 90, W - 1, H - 1), GV.ramp("#c9a96e"), { cres = 5, deep = 8, gloss = false, rim = false, outline = false })
for _, p in ipairs({ {20,100},{60,106},{110,98},{150,104},{200,100},{30,126},{100,122},{170,124},{224,118},{70,114} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 4, p[2]), "#9a6b3f"); c:px(p[1] + 1, p[2] + 1, "#9a6b3f")
end

-- left stall: chili stall ----------------------------------------------------------------------
c:part(c:rect(14, 66, 17, 100), GV.ramp("#8a4f2a"), { cres = 2, gloss = false })
c:part(c:rect(76, 66, 79, 100), GV.ramp("#8a4f2a"), { cres = 2, gloss = false })
c:part(c:rect(14, 90, 79, 100), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })
c:seam({ {16, 95}, {77, 95} }, { on = 2, off = 1 })
awning(14, 79, 60, 70, RED, CREAM)
for i, x in ipairs({ 22, 32, 62, 72 }) do ristra(x, 73, 3 + (i % 2)) end
pile(30, 89, 8, 5, RED, { {-4,-2,"#e0501f"},{0,-4},{3,-1,"#f5cf6a"},{-6,0,"#f5cf6a"} })
pile(46, 89, 8, 5, "#4a8a3e", { {-4,-2,"#a4b86a"},{1,-3,"#c8d77a"},{4,0,"#a4b86a"} })
pile(62, 89, 8, 5, "#f08a24", { {-4,-2,RED},{0,-4,"#f5cf6a"},{3,-1,RED} })

-- right: cocoa house (little stone hut with a steaming pot) ------------------------------------
c:part(c:rect(150, 64, 218, 104), GV.ramp("#e8d9b0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#f5b860" }), { cres = 5, deep = 8, pale = true, gloss = false })
c:part(c:poly({ {146,66},{150,52},{218,52},{222,66} }), GV.ramp("#a8582f"), { cres = 4, deep = 6, gloss = false })
for x = 154, 214, 6 do c:seam({ {x, 55}, {x + 2, 63} }, { free = true, on = 1, off = 0, gap = "#5e2f1e" }) end
c:part(c:rect(190, 38, 197, 52), GV.ramp("#8b8f96"), { cres = 3, gloss = false })
c:fill(c:ellipse(195, 34, 3, 2), "#f4f0e0"); c:fill(c:ellipse(198, 29, 3, 2), "#e8e4e0"); c:fill(c:ellipse(195, 24, 2, 2), "#f4f0e0")
c:part(c:rect(160, 70, 182, 96), GV.ramp("#3d2a1c"), { cres = 3, deep = 4, gloss = false, outline = false, contour = "#2a1a10" })
c:fill(c:rect(163, 73, 179, 93), "#7a4a1f")
c:fill(c:rect(163, 73, 179, 76), "#9a6b3f")
-- cocoa pot and cups inside window
c:part(c:ellipse(171, 86, 8, 6), GV.ramp("#5b6470"), { cres = 3, deep = 4, gloss = false })
c:fill(c:rect(165, 80, 177, 82), "#4a2c1a")
for _, x in ipairs({ 167, 172, 176 }) do c:px(x, 77, "#f2e4c0"); c:px(x + 1, 75, "#e8d9d0") end
c:part(c:rect(198, 76, 214, 96), GV.ramp("#2f5a8a"), { cres = 3, gloss = false, outline = false })
c:fill(c:rect(201, 79, 211, 93), "#f5cf6a"); c:fill(c:rect(201, 79, 206, 80), "#fff1c8")
c:seam({ {206, 79}, {206, 93} }, { free = true, on = 2, off = 1, gap = "#e8a317" })
-- counter
c:part(c:rect(150, 98, 222, 106), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })
for _, x in ipairs({ 156, 168, 180, 196, 208 }) do
  c:part(c:rect(x, 92, x + 4, 98), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
  c:px(x + 5, 94, "#f2e4c0"); c:px(x + 5, 95, "#f2e4c0")
  c:px(x + 1, 90, "#e8e4e0"); c:px(x + 2, 88, "#f4f0e0")
end
awning(152, 216, 44, 50, "#3f8fb0", CREAM)

-- middle: vendors ----------------------------------------------------------------------------
gnome(46, 103, "#e46a9b", "#2f6290")   -- chili vendor behind her counter
gnome(134, 112, "#3f8fb0", "#d6322b")   -- cocoa-seeker customer
-- sign flag on pole (no text): chili emblem
c:part(c:rect(98, 52, 99, 104), GV.ramp("#8a4f2a"), { cres = 1, gloss = false, outline = false })
c:part(c:poly({ {100,54},{122,58},{100,66} }), GV.ramp(RED), { cres = 3, gloss = false })
c:fill(c:rect(104, 58, 109, 59), "#4a8a3e"); c:fill(c:rect(110, 59, 116, 60), "#fff1c8")

-- foreground baskets ----------------------------------------------------------------------------
basket(30, 128, 18, 14, RED, { {-10,-2,"#e0501f"},{-3,-4},{4,-2,"#f5cf6a"},{9,0,"#e0501f"},{-8,2},{0,2,"#e0501f"} })
basket(78, 130, 16, 12, "#4a8a3e", { {-8,-2,"#a4b86a"},{-2,-4,"#c8d77a"},{5,-2,"#a4b86a"},{8,1,"#c8d77a"} })
basket(122, 128, 18, 14, "#f08a24", { {-10,-2,RED},{-3,-4,"#f5cf6a"},{4,-2,RED},{9,0,"#f5cf6a"} })
-- sack of cocoa beans, foreground right
c:part(c:ellipse(206, 122, 15, 10):cut(c:rect(190, 130, 224, 140)), GV.ramp("#c9a96e"), { cres = 4, deep = 6, gloss = false })
c:part(c:rrect(197, 111, 214, 115, 2), GV.ramp("#c9a96e"), { cres = 2, gloss = false })
for _, p in ipairs({ {200,118},{206,116},{212,119},{203,123},{209,124} }) do c:fill(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), "#5e2f1e"); c:px(p[1], p[2], "#8a4f2a") end
-- little hen scratching, for life
c:part(c:ellipse(160, 120, 7, 5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, gloss = false })
c:part(c:ellipse(152, 114, 4, 4), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 2, gloss = false })
c:fill(c:rect(150, 108, 153, 110), RED); c:px(147, 115, "#f5cf6a"); c:px(148, 115, "#f5cf6a")
c:eye(150, 113, true)
c:fill(c:rect(158, 125, 158, 128), "#e8a317"); c:fill(c:rect(163, 125, 163, 128), "#e8a317")
c:ground(160, 129, 9, 1.5)

L.finish(c, "haven-market-of-a-thousand-chilies")
