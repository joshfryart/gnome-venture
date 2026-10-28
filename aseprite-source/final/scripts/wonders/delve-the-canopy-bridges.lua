-- delve-the-canopy-bridges: rope bridges strung between huge walnut and spruce trunks high above a Tian Shan valley. WCA, dawn.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local HOR = 78

L.sky(c, "dawn", HOR)
L.cloud(c, 60, 30, 16, "#f0aa98", "#d49ab8"); L.cloud(c, 170, 22, 20, "#f8c890", "#f0aa98"); L.cloud(c, 120, 48, 12, "#fbe0a8", "#f0aa98")
c:fill(c:ellipse(120, HOR - 6, 12, 12):clip(c:rect(0, 0, W, HOR - 8)), "#fff1c8")
-- snowy peaks, rose-lit on the left faces
local function peak(x0, x1, top, base, col)
  local m = c:poly({ {x0, base}, {(x0 + x1) // 2 - 4, top + 6}, {(x0 + x1) // 2, top}, {(x0 + x1) // 2 + 6, top + 8}, {x1, base} })
  c:part(m, GV.ramp(col), { outline = false, gloss = false, rim = false, bounce = false, cres = 6, deep = 9 })
  c:fill(c:poly({ {(x0 + x1) // 2 - 9, top + 12}, {(x0 + x1) // 2 - 4, top + 6}, {(x0 + x1) // 2, top}, {(x0 + x1) // 2 + 6, top + 8}, {(x0 + x1) // 2 + 10, top + 14}, {(x0 + x1) // 2 + 3, top + 11}, {(x0 + x1) // 2 - 2, top + 16}, {(x0 + x1) // 2 - 5, top + 11} }), "#fdf2d8")
end
peak(20, 110, 40, HOR + 6, "#6a6aa8"); peak(90, 190, 32, HOR + 6, "#7a7ab8"); peak(160, 250, 46, HOR + 6, "#6a6aa8")
-- far spruce forest band
c:part(c:poly({ {0,HOR+8},{0,HOR-2},{W,HOR-2},{W,HOR+8} }), GV.ramp("#3a6a58"), { outline = false, gloss = false, rim = false, bounce = false })
for x = 2, W, 5 do local h = 5 + (x * 7) % 5; c:fill(c:poly({ {x - 3, HOR - 1}, {x, HOR - 1 - h}, {x + 3, HOR - 1} }), (x % 10 == 2) and "#2f5a48" or "#3a6a58") end
-- valley floor: meadow bands, river, a tiny yurt
c:bands(c:rect(0, HOR + 1, W - 1, H - 1), { "#a8c47a", "#8fb468", "#7ab55c", "#6a9a4a", "#4a8a3e", "#3a7a38" }, { dir = "v" })
c:fill(c:poly({ {96,HOR+1},{108,HOR+1},{150,H},{74,H} }), "#8fcbd8")
for i, y in ipairs({ HOR + 6, HOR + 12, HOR + 20, HOR + 30, HOR + 42 }) do c:fill(c:rect(104 - i * 3, y, 108 + i * 4, y), "#c8ecdc") end
-- mist stripes
c:fill(c:rect(0, HOR + 4, W - 1, HOR + 5), "#e2f0e0"); c:fill(c:rect(0, HOR + 12, 80, HOR + 12), "#d4e8d8"); c:fill(c:rect(150, HOR + 10, W - 1, HOR + 10), "#d4e8d8")
-- yurt
c:part(c:rect(180, HOR + 18, 198, HOR + 28), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 4, gloss = false, pale = true })
c:part(c:poly({ {178,HOR+19},{189,HOR+10},{200,HOR+19} }), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 4, gloss = false, pale = true })
c:fill(c:rect(186, HOR + 21, 191, HOR + 28), "#d6322b"); c:fill(c:rect(178, HOR + 18, 200, HOR + 18), "#3f8fb0")
c:fill(c:rect(189, HOR + 6, 189, HOR + 9), "#c3b2ea")  -- smoke
c:px(190, HOR + 4, "#c3b2ea")
-- grazing horses (2 px dots) and sheep specks
for _, p in ipairs({ {30,HOR+16},{40,HOR+19},{184,HOR+36},{196,HOR+40},{18,HOR+30} }) do c:fill(c:rect(p[1], p[2], p[1] + 3, p[2] + 1), "#f2e4c0"); c:fill(c:rect(p[1], p[2] + 2, p[1], p[2] + 3), "#5e2f1e") end

-- distant bridge between two spruces ---------------------------------------------------------------------------------------------------------
local function trunk(x0, x1, top, base, col)
  c:part(c:rect(x0, top, x1, base), GV.ramp(col), { cres = 3, deep = 5, gloss = false, rim = false })
  for y = top + 4, base - 4, 7 do c:fill(c:line({ {x0 + 2, y}, {x0 + 2, y + 3} }, 1), "#3d2a1c"); c:px(x1 - 3, y + 2, "#3d2a1c") end
end
trunk(60, 66, 20, H, "#5e3f2a"); trunk(164, 170, 20, H, "#5e3f2a")
local function conifer(cx, cy, w, h, layers)
  for i = 0, layers - 1 do
    local y = cy + i * (h // layers); local ww = w * (0.45 + 0.55 * i / (layers - 1))
    c:part(c:poly({ {cx - ww, y + h // layers + 2}, {cx, y - 2}, {cx + ww, y + h // layers + 2} }), GV.ramp("#2f6a4a"), { cres = 2, deep = 3, gloss = false, rim = false, outline = (i == 0) })
  end
end
conifer(63, 6, 18, 26, 4); conifer(167, 6, 18, 26, 4)
-- far bridge: a thin sagging deck
for x = 66, 164, 3 do
  local t = (x - 66) / 98; local y = 52 + math.floor(10 * math.sin(math.pi * t) + 0.5)
  c:fill(c:rect(x, y, x + 1, y + 1), (x % 6 == 0) and "#d9a660" or "#b07a45")
  if x % 12 == 0 then c:fill(c:rect(x, y - 8, x, y), "#7a4a1f") end
end
for x = 66, 164, 2 do local t = (x - 66) / 98; local y = 52 + math.floor(10 * math.sin(math.pi * t) + 0.5); c:px(x, y - 8, "#c9a96e") end

-- big near trunks with platforms and the main bridge -----------------------------------------------------------------------------------------------
trunk(0, 30, 0, H, "#7a4a1f"); trunk(208, 238, 0, H, "#7a4a1f")
-- walnut canopy at the top corners
for _, p in ipairs({ {12,4,26,10},{44,0,18,8},{228,4,24,10},{196,0,20,8} }) do
  c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#4a8a3e"), { cres = 4, deep = 6, gloss = false })
end
for _, p in ipairs({ {20,14,8,5},{214,14,8,5},{34,8,7,4},{204,8,7,4} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#7ab55c"), { flat = true, gloss = false, outline = false }) end
-- platforms
c:part(c:rect(0, 76, 44, 82), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(194, 76, 239, 82), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
for x = 6, 44, 6 do c:px(x, 79, "#7a4a1f") end
for x = 198, 238, 6 do c:px(x, 79, "#7a4a1f") end
-- supports (rope hangs from the trunk)
c:fill(c:line({ {30, 80}, {4, 100} }, 2), "#7a4a1f"); c:fill(c:line({ {208, 80}, {236, 100} }, 2), "#7a4a1f")
-- main bridge
local function deck_y(x) local t = (x - 44) / 150; return 80 + math.floor(13 * math.sin(math.pi * t) + 0.5) end
for x = 44, 194, 4 do
  local y = deck_y(x)
  c:part(c:rect(x, y, x + 3, y + 2), GV.ramp("#d9a660"), { flat = true, gloss = false, contour = "#3d2a1c" })
end
for x = 44, 194, 2 do c:px(x, deck_y(x) + 3, "#5e2f1e") end
-- rails and posts
for x = 46, 192, 2 do local y = deck_y(x) - 14 + 0; c:fill(c:rect(x, y, x + 1, y + 1), "#c9a96e") end
for x = 44, 194, 14 do
  local y = deck_y(x)
  c:fill(c:rect(x, y - 14, x + 1, y), "#7a4a1f")
end
for x = 52, 188, 14 do local y = deck_y(x); c:fill(c:rect(x, y - 8, x, y), "#c9a96e") end
-- hanging lantern on the bridge (felt, gold)
local lx = 150; local ly = deck_y(lx) - 14
c:fill(c:rect(lx, ly, lx, ly + 4), "#5e2f1e")
c:part(c:rect(lx - 3, ly + 4, lx + 3, ly + 11), GV.ramp("#e0501f"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(lx - 1, ly + 6, lx + 1, ly + 9), "#f5cf6a"); c:fill(c:rect(lx - 3, ly + 7, lx + 3, ly + 7), "#e8a317")

-- the marmot crossing, with a walnut ----------------------------------------------------------------------------------------------------------------
local MX = 96; local MY = deck_y(MX)
c:part(c:ellipse(MX - 10, MY - 4, 6, 3), GV.ramp("#8a6a4a"), { cres = 2, gloss = false })                    -- tail
c:part(c:ellipse(MX, MY - 8, 10, 9), GV.ramp("#c9a96e"), { cres = 4, deep = 6 })                             -- body
c:part(c:ellipse(MX + 1, MY - 7, 6, 6), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, pale = true }) -- belly
c:part(c:ellipse(MX - 6, MY - 25, 3, 3), GV.ramp("#8a6a4a"), { flat = true, gloss = false }); c:part(c:ellipse(MX + 8, MY - 25, 3, 3), GV.ramp("#8a6a4a"), { flat = true, gloss = false })
c:part(c:ellipse(MX + 1, MY - 19, 12, 9), GV.ramp("#c9a96e"), { cres = 4, deep = 6 })                        -- head
c:eye(MX - 6, MY - 23); c:eye(MX + 3, MY - 23)
c:part(c:ellipse(MX + 1, MY - 15, 4, 3), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, pale = true })
c:fill(c:rect(MX, MY - 17, MX + 2, MY - 16), "#2a1a10"); c:fill(c:rect(MX, MY - 14, MX + 2, MY - 12), "#f2e4c0"); c:px(MX + 1, MY - 14, "#d8c496")
-- holding a walnut up
c:part(c:ellipse(MX + 12, MY - 10, 5, 4.5), GV.ramp("#9a6b3f"), { cres = 2, deep = 3 }); c:fill(c:line({ {MX + 10, MY - 12}, {MX + 14, MY - 8} }, 1), "#5e2f1e")
c:part(c:ellipse(MX + 8, MY - 9, 2.5, 2.5), GV.ramp("#8a6a4a"), { flat = true, gloss = false })
c:ground(MX, MY + 3, 12, 1)

-- falling leaves
for _, p in ipairs({ {70,40},{130,70},{34,50},{200,56},{150,34} }) do c:fill(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), "#f08a24"); c:px(p[1] + 3, p[2] + 2, "#d6322b") end

L.finish(c, "delve-the-canopy-bridges")
