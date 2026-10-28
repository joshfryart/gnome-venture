-- wonder-lighthouse-of-the-lost-lantern.lua : unique-location scene (off-path "wonder"), 480 x 270 = 240 x 135 grid at 2x.
-- Brief (wonder_text.txt): "The old lighthouse has gone dark. Its keeper, a retired crab, looks up hopefully, holding a wick."
-- Thing to do: relight the lamp (check). Dusk, because the dark lamp must read. Scene mode: no black border, hem stitch top and bottom.
-- Params: out=<png path> ase=<.aseprite path>   (--script-param BEFORE --script)
local REPO = "/home/user/gnome-venture/"
local GV = dofile(REPO .. "aseprite-source/gvlib/gvlib.lua")
local P = app.params
local PNG = P.out or (REPO .. "game/assets/img/wonders/wonder-lighthouse-of-the-lost-lantern.png")
local ASE = P.ase or (REPO .. "aseprite-source/final/aseprite/wonders/wonder-lighthouse-of-the-lost-lantern.aseprite")

local W, H = 240, 135
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
local HOR = 80 -- horizon row

-- palette (dusk: dusk + water + stone families from the style guide, gold for the thread and the little lights)
local SKY = { "#2a2250", "#352a68", "#4e3a8a", "#6a4fa8", "#8c6ab8", "#b784b4", "#e39a86", "#f5b878" }
local SEA = { "#3a5f9a", "#2f6290", "#2b5a86", "#25507a", "#25446e", "#2a3c6c" }
local CREAM, CREAMS, RED = "#f2e4c0", "#d8c496", "#d6322b"

-- sky ------------------------------------------------------------------------------------------
c:bands(c:rect(0, 0, W - 1, HOR), SKY, { dir = "v" })
-- stars (single pixels, a few 2-px crosses)
local stars = { {12,6},{30,14},{47,5},{66,19},{85,9},{101,24},{120,7},{139,16},{158,5},{176,22},{196,8},{214,14},{229,5},
  {22,30},{58,36},{93,41},{128,34},{150,40},{205,33},{235,28},{40,48},{110,50},{182,46} }
for _, s in ipairs(stars) do c:px(s[1], s[2], "#fff1c8") end
for _, s in ipairs({ {47,5},{139,16},{214,14},{101,24} }) do
  c:px(s[1]-1, s[2], "#c3b2ea"); c:px(s[1]+1, s[2], "#c3b2ea"); c:px(s[1], s[2]-1, "#c3b2ea"); c:px(s[1], s[2]+1, "#c3b2ea")
end
-- crescent moon, upper left
local moon = c:ellipse(34, 22, 9, 9); moon:cut(c:ellipse(39, 19, 8, 8))
c:fill(moon, "#fff1c8")
c:fill(moon:copy():clip(c:rect(0, 24, W, 40)), "#f5cf6a")
-- cloud streaks (hard bands, warm underside)
local function cloud(cx, cy, rx, top, under)
  local m = c:ellipse(cx, cy, rx, 2.2); m:add(c:ellipse(cx - rx * 0.4, cy - 1.5, rx * 0.5, 2.2)); m:add(c:ellipse(cx + rx * 0.3, cy - 2, rx * 0.45, 2.4))
  c:fill(m, top); c:fill(m:copy():clip(c:rect(0, cy + 1, W, H)), under)
end
cloud(80, 58, 15, "#8c6ab8", "#b784b4"); cloud(196, 52, 17, "#8c6ab8", "#c98fb0"); cloud(24, 66, 12, "#b784b4", "#e39a86")
-- far gulls
for _, g in ipairs({ {60,40},{70,36},{150,30} }) do
  c:px(g[1], g[2], "#2a1a10"); c:px(g[1]+1, g[2]+1, "#2a1a10"); c:px(g[1]+2, g[2], "#2a1a10"); c:px(g[1]+3, g[2]+1, "#2a1a10"); c:px(g[1]+4, g[2], "#2a1a10")
end

-- sea ------------------------------------------------------------------------------------------
c:bands(c:rect(0, HOR + 1, W - 1, H - 1), SEA, { dir = "v" })
-- sunset glow strip on the water, broken into dashes
for i, x in ipairs({ 6, 22, 40, 14, 52, 32, 66, 80, 94 }) do
  local y = HOR + 2 + (i % 4) * 3
  c:fill(c:rect(x, y, x + 6 + (i % 3) * 3, y), "#e39a86")
end
-- wave dashes
local waves = { {8,92,9},{34,97,12},{70,90,8},{96,100,10},{20,106,11},{58,110,9},{88,114,12},{4,120,10},{40,124,13},{74,128,9},{110,118,8},{128,126,11} }
for _, w in ipairs(waves) do c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2]), "#5a86b8") end
-- far shore + a bobbing small light (the lost lantern? the keeper hopes)
c:part(c:poly({ {0,HOR+1},{14,HOR-5},{34,HOR-3},{52,HOR-7},{74,HOR-3},{92,HOR+1} }), GV.ramp("#4e3a8a"), { gloss = false, rim = false, bounce = false, outline = false })
-- bobbing light on the water
c:fill(c:ellipse(40, 94, 3, 1), "#c3b2ea")
c:fill(c:rect(39, 91, 40, 93), "#f5cf6a"); c:px(39, 91, "#fff1c8")
c:fill(c:rect(37, 96, 43, 96), "#f5cf6a"); c:fill(c:rect(36, 98, 44, 98), "#e39a86")

-- headland (right) -------------------------------------------------------------------------------
local rock = c:poly({ {118,H},{128,112},{142,102},{156,98},{190,96},{214,100},{232,92},{W,88},{W,H} })
c:part(rock, GV.ramp("#8b8f96"), { cres = 6, deep = 9 })
-- ledges / cracks on the rock (umber lines)
for _, l in ipairs({ { {142,112},{154,110},{162,114} }, { {176,108},{190,106},{202,110} }, { {214,112},{226,108} }, { {150,122},{170,120},{184,124} } }) do
  c:seam(l, { free = true, on = 3, off = 0, gap = "#2a1a10" }) -- solid dark crack
end
for _, l in ipairs({ { {144,110},{153,108} }, { {178,106},{188,104} } }) do c:seam(l, { free = true, on = 3, off = 0 }) end
-- grass tufts on the crown
for _, x in ipairs({ 152, 160, 205, 212, 226 }) do
  local y = (x < 190) and 97 or ((x > 220) and 91 or 99)
  c:px(x, y, "#7ab55c"); c:px(x + 1, y - 1, "#a4b86a"); c:px(x + 2, y, "#7ab55c")
end

-- lighthouse (dark tower; lamp dead) --------------------------------------------------------------
local TX = 174            -- tower centre x
local base_y, top_y = 96, 44
local tower = c:poly({ {TX-12,base_y},{TX-7,top_y},{TX+7,top_y},{TX+12,base_y} })
c:part(tower, GV.ramp("#e8d9b0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#f5b860" }), { cres = 6, deep = 9, pale = true })
-- stripes (separate parts, no outline, share the tower's light)
local function stripe(y0, y1)
  local m = tower:copy():clip(c:rect(TX - 14, y0, TX + 14, y1))
  c:part(m, "red", { outline = false, contour = false, gloss = false, cres = 4, deep = 7 })
end
stripe(54, 63); stripe(74, 83); stripe(92, 96)
-- door and two windows
c:part(c:rrect(TX-3, 86, TX+3, 96, 2), GV.ramp("#7a4a1f"), { outline = false, gloss = false, contour = "#2a1a10" })
c:px(TX + 2, 91, "#f5cf6a")
for _, wy in ipairs({ 48, 68 }) do c:fill(c:rect(TX - 1, wy, TX + 1, wy + 3), "#291d4a"); c:px(TX - 1, wy, "#4e3a8a") end
-- gallery (rail) and lantern room
c:part(c:rect(TX-11, 41, TX+11, 43), GV.ramp("#5b6470"), { cres = 2, gloss = false })
for x = TX - 10, TX + 10, 3 do c:rect(x, 38, x, 41); c:fill(c:rect(x, 38, x, 41), "#2a1a10") end
c:fill(c:rect(TX-10, 38, TX+10, 38), "#2a1a10")
local lamp = c:rect(TX-6, 28, TX+6, 40)
c:part(lamp, GV.ramp("#291d4a", { rim = "#4e3a8a" }), { cres = 3, gloss = false })
-- cold lamp: glass panes, dead lens in the middle
c:fill(c:rect(TX-4, 31, TX+4, 38), "#35285c")
c:fill(c:ellipse(TX, 34.5, 3, 3), "#4e3a8a"); c:fill(c:ellipse(TX, 34.5, 1.5, 1.5), "#6a4fa8")
c:px(TX - 3, 32, "#8c6ab8"); c:px(TX - 3, 33, "#8c6ab8")
for _, x in ipairs({ TX - 6, TX + 6 }) do c:rect(x, 28, x, 40); c:fill(c:rect(x, 28, x, 40), "#2a1a10") end
-- roof
c:part(c:poly({ {TX-8,28},{TX,17},{TX+8,28} }), "red", { cres = 4, deep = 6 })
c:part(c:ellipse(TX, 15, 2.5, 2.5), GV.ramp("#e8a317"), { flat = true })
c:fill(c:rect(TX, 10, TX, 13), "#2a1a10")
c:px(TX + 1, 10, "#2a1a10"); c:px(TX + 2, 11, "#2a1a10")   -- cold vane

-- foreground shore, left (stone/sand) with the keeper -------------------------------------------------
local shore = c:poly({ {0,H},{0,114},{16,110},{40,108},{64,111},{86,116},{110,H} })
c:part(shore, GV.ramp("#c9a96e"), { cres = 5, deep = 8, gloss = false })
-- pebbles
for _, p in ipairs({ {12,120,3,1},{30,126,4,2},{58,122,3,1},{74,128,5,2},{98,126,3,1},{44,117,2,1} }) do
  c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#8b8f96"), { flat = true, gloss = false })
end
-- crate and a mug of tea: the keeper has been waiting a while
c:part(c:rrect(20, 111, 34, 123, 1), GV.ramp("#b07a45"), { gloss = false, cres = 3 })
c:seam({ {22, 117}, {32, 117} }, { on = 2, off = 1 })
c:part(c:rect(25, 105, 29, 110), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:px(30, 107, "#f2e4c0"); c:px(31, 107, "#f2e4c0"); c:px(31, 108, "#f2e4c0"); c:px(30, 109, "#f2e4c0")
c:px(26, 102, "#c3b2ea"); c:px(27, 100, "#8c6ab8"); c:px(26, 98, "#c3b2ea")   -- steam

-- the keeper: a retired crab in a knitted cap, holding a wick up toward the dark lamp ------------------------
local CX, CY = 76, 110
local crab_body = c:ellipse(CX, CY, 16, 9)
for i = -1, 1 do   -- legs, behind the body
  c:limb({ {CX - 12 + i * 4, CY + 5}, {CX - 18 + i * 4, CY + 9}, {CX - 17 + i * 4, CY + 14} }, 2)
  c:limb({ {CX + 12 - i * 4, CY + 5}, {CX + 18 - i * 4, CY + 9}, {CX + 17 - i * 4, CY + 14} }, 2)
end
-- left claw rests on the hip
c:limb({ {CX - 14, CY}, {CX - 22, CY - 2}, {CX - 23, CY - 8} }, 3)
local lc = c:ellipse(CX - 23, CY - 12, 5, 4.5); lc:cut(c:poly({ {CX - 25, CY - 18}, {CX - 21, CY - 18}, {CX - 23, CY - 13} }))
c:part(lc, GV.ramp("#d6322b"), { cres = 3, deep = 5 })
-- right claw lifts the wick toward the lamp
c:limb({ {CX + 14, CY - 2}, {CX + 21, CY - 9}, {CX + 22, CY - 17} }, 3)
local rc = c:ellipse(CX + 22, CY - 21, 5, 4.5); rc:cut(c:poly({ {CX + 20, CY - 27}, {CX + 24, CY - 27}, {CX + 22, CY - 22} }))
c:part(rc, GV.ramp("#d6322b"), { cres = 3, deep = 5 })
-- the wick: pale cord, tip unlit with one faint ember of hope
c:fill(c:rect(CX + 22, CY - 36, CX + 22, CY - 24), "#f2e4c0")
c:fill(c:rect(CX + 23, CY - 36, CX + 23, CY - 24), "#d8c496")
c:px(CX + 22, CY - 37, "#4a2c1a"); c:px(CX + 23, CY - 37, "#4a2c1a"); c:px(CX + 22, CY - 38, "#e0501f")
-- body
c:part(crab_body, GV.ramp("#d6322b"), { cres = 5, deep = 8 })
c:seam({ {CX - 11, CY + 4}, {CX + 11, CY + 4} }, { on = 2, off = 1 })
-- eyes on short stalks, set wide, looking up
for _, ex in ipairs({ CX - 8, CX + 8 }) do
  c:fill(c:rect(ex - 1, CY - 12, ex, CY - 6), "#b8452f")
  c:eye(ex - 2, CY - 18)
  c:px(ex - 1, CY - 16, "#cfd6e8")  -- eye turned up, pupil on the upper row
end
-- knitted cap perched on the shell between the stalks, with a bobble
c:part(c:ellipse(CX, CY - 9, 7, 5.5):cut(c:rect(CX - 9, CY - 5, CX + 9, CY - 3)), GV.ramp("#4e8a9a", { rim = "#8fcbd8" }), { cres = 3, deep = 5, outline = false, contour = "#2a1a10" })
c:part(c:rect(CX - 6, CY - 6, CX + 6, CY - 5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
c:seam({ {CX - 4, CY - 10}, {CX + 4, CY - 10} }, { free = true })
c:part(c:ellipse(CX, CY - 15, 2.5, 2.5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
-- hopeful little smile
c:px(CX - 3, CY + 1, "#2a1a10"); c:px(CX - 2, CY + 2, "#2a1a10"); c:px(CX - 1, CY + 2, "#2a1a10"); c:px(CX, CY + 2, "#2a1a10"); c:px(CX + 1, CY + 2, "#2a1a10"); c:px(CX + 2, CY + 1, "#2a1a10")
c:ground(CX, CY + 17, 18, 2)

-- gold hem stitch top and bottom
c:seam({ {0, 1}, {W - 1, 1} }, { free = true })
c:seam({ {0, H - 2}, {W - 1, H - 2} }, { free = true })

local t = c:save(ASE, PNG)
print(GV.report(t))
