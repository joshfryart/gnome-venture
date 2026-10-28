-- haven-turtle-nesting-beach : Caribbean beach at night. Hatchlings scurry from the nest to the moonlit sea; a gnome lights the way.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 58
local SHELL, SKINT = "#7ab55c", "#c8d77a"

L.sky(c, "night", HOR)
L.stars(c, 40, 50, 11)
for _, s in ipairs({ {30,12},{150,8},{210,30} }) do
  c:px(s[1], s[2], "#fff1c8"); c:px(s[1]-1, s[2], "#c3b2ea"); c:px(s[1]+1, s[2], "#c3b2ea"); c:px(s[1], s[2]-1, "#c3b2ea"); c:px(s[1], s[2]+1, "#c3b2ea")
end
-- full moon with glow rings
local MX, MY = 150, 30
c:fill(c:ellipse(MX, MY, 22, 22):clip(c:rect(0, 0, W, HOR)), "#26225a")
c:fill(c:ellipse(MX, MY, 17, 17), "#322c6c")
c:part(c:ellipse(MX, MY, 11, 11), GV.ramp("#f5cf6a", { gloss = "#fff1c8", rim = "#fff1c8" }), { cres = 3, deep = 4, gloss = false, outline = false })
c:fill(c:ellipse(MX - 3, MY - 2, 2, 2), "#f5cf6a"); c:fill(c:ellipse(MX + 3, MY + 3, 2, 1.5), "#f5cf6a"); c:px(MX + 2, MY - 5, "#f5cf6a")
L.cloud(c, 60, 30, 14, "#3e3680", "#322c6c"); L.cloud(c, 215, 18, 12, "#3e3680", "#322c6c")

-- sea ------------------------------------------------------------------------------------------------------
c:bands(c:rect(0, HOR + 1, W - 1, 100), L.SEA.night, { dir = "v" })
for i, w in ipairs({ {142,6,14},{136,10,8},{146,14,10},{139,18,12},{144,22,8},{138,26,14},{141,30,10} }) do
  c:fill(c:rect(w[1], HOR + w[2], w[1] + w[3], HOR + w[2]), i % 2 == 0 and "#f5cf6a" or "#c3b2ea")
end
for i = 0, 10 do local x = (i * 41 + 5) % 220; local y = HOR + 4 + (i * 7) % 34; c:fill(c:rect(x, y, x + 6, y), "#3a5f9a") end
-- distant island
c:part(c:poly({ {10,HOR+1},{22,HOR-6},{44,HOR-4},{60,HOR+1} }), GV.ramp("#26225a"), { gloss = false, rim = false, bounce = false, outline = false })

-- sand (moonlit) -----------------------------------------------------------------------------------------------
c:part(c:poly({ {0,H},{0,88},{60,84},{130,90},{190,86},{W,90},{W,H} }), GV.ramp("#8c88b0", { gloss = "#c3b2ea", rim = "#b0a4d0" }), { cres = 5, deep = 8, gloss = false, rim = false, outline = false })
c:fill(c:rect(0, 88, 60, 88), "#8fcbd8"); c:fill(c:rect(130, 90, 190, 90), "#8fcbd8")
for i, x in ipairs({ 6, 40, 86, 120, 174, 220 }) do c:fill(c:rect(x, 85 + i % 3, x + 12, 85 + i % 3), "#cfe8f0") end
-- sand speckles and dune grass
for _, p in ipairs({ {20,100},{66,106},{110,98},{160,104},{210,100},{30,126},{100,122},{180,124},{226,118},{90,112},{140,114},{50,114} }) do c:px(p[1], p[2], "#b0a4d0"); c:px(p[1] + 3, p[2] + 1, "#6a6490") end
for _, x in ipairs({ 6, 12, 222, 230, 214 }) do
  for k = -1, 1 do c:fill(c:rect(x + k * 2, 108 + math.abs(k) * 2, x + k * 2, 118), k == 0 and "#7ab55c" or "#4a8a3e") end
end

-- turtle helpers ---------------------------------------------------------------------------------------------
local function hatch(x, y, flip)
  local d = flip and -1 or 1
  c:fill(c:rect(x - 4, y + 1, x - 3, y + 2), SKINT); c:fill(c:rect(x + 3, y + 1, x + 4, y + 2), SKINT)
  c:part(c:ellipse(x, y, 4, 3), GV.ramp(SHELL), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
  c:fill(c:rect(x - 1, y - 3, x + 1, y - 2), SKINT); c:px(x, y - 4, SKINT)
  c:px(x - 1, y - 3, "#2a1a10"); c:px(x + 1, y - 3, "#2a1a10")
  c:px(x - 2, y - 1, "#c8d77a")
end
-- sand nest with eggshells (foreground left)
local NX, NY = 52, 112
c:part(c:ellipse(NX, NY, 20, 8), GV.ramp("#6e6a96", { rim = "#8c88b0" }), { cres = 3, deep = 5, gloss = false, rim = false })
c:part(c:ellipse(NX, NY - 1, 14, 5), GV.ramp("#3d2a4c"), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
for _, e in ipairs({ {-8,-1},{-2,1},{5,-1},{10,1} }) do
  c:part(c:ellipse(NX + e[1], NY + e[2], 3, 2.5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
end
hatch(NX - 4, NY - 4); hatch(NX + 6, NY - 5)
-- the trail of hatchlings marching to the sea
local trail = { {74,108},{98,106},{84,98},{112,100},{68,94},{98,92},{124,94},{82,87},{116,87} }
for i, p in ipairs(trail) do hatch(p[1], p[2]) end
-- flipper tracks
for _, t in ipairs({ {66,108},{70,104},{78,102},{90,100},{104,97},{114,93} }) do c:px(t[1], t[2], "#6a6490"); c:px(t[1] + 6, t[2], "#6a6490") end
-- gull silhouette? no: crab chasing shadow (a ghost crab blocking path, cute)
c:part(c:ellipse(130, 120, 6, 4), GV.ramp("#d9885a"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(122, 120, 123, 123), "#c47a52"); c:fill(c:rect(137, 120, 138, 123), "#c47a52")
c:part(c:ellipse(123, 114, 3, 2.5), GV.ramp("#e0501f"), { flat = true, gloss = false }); c:part(c:ellipse(137, 114, 3, 2.5), GV.ramp("#e0501f"), { flat = true, gloss = false })
c:eye(126, 114, true); c:eye(131, 114, true)

-- mother turtle in the shallows (right) -----------------------------------------------------------------------------------
local TX, TY = 166, 98
c:limb({ {TX - 14, TY + 4}, {TX - 22, TY + 9}, {TX - 20, TY + 13} }, 3)
c:limb({ {TX + 14, TY + 4}, {TX + 22, TY + 9}, {TX + 20, TY + 13} }, 3)
c:part(c:ellipse(TX - 18, TY - 8, 6, 3), GV.ramp(SKINT), { flat = true, gloss = false })   -- back flipper wave
c:part(c:ellipse(TX + 20, TY - 4, 5, 3), GV.ramp(SKINT), { flat = true, gloss = false })
c:part(c:ellipse(TX, TY, 18, 12), GV.ramp("#7ab55c", { shade = "#4a8a3e", deep = "#2f5a2a" }), { cres = 6, deep = 9 })
for _, hx in ipairs({ -8, 0, 8 }) do c:seam({ {TX + hx, TY - 8}, {TX + hx - 2, TY + 8} }, { free = true, on = 1, off = 0, gap = "#2f5a2a" }) end
c:seam({ {TX - 12, TY - 1}, {TX + 12, TY - 1} }, { free = true, on = 1, off = 0, gap = "#2f5a2a" })
c:part(c:ellipse(TX - 21, TY - 1, 7, 6), GV.ramp(SKINT), { cres = 3, deep = 5, gloss = false })
c:eye(TX - 25, TY - 4)
-- a happy tear-free smile
c:px(TX - 24, TY + 3, "#2a1a10"); c:px(TX - 23, TY + 4, "#2a1a10"); c:px(TX - 22, TY + 4, "#2a1a10"); c:px(TX - 21, TY + 3, "#2a1a10")
-- waves lapping over her
c:fill(c:rect(TX - 30, TY + 14, TX + 28, TY + 14), "#8fcbd8")
c:fill(c:rect(TX - 24, TY + 17, TX + 22, TY + 17), "#5a86b8")

-- the helper gnome with a lantern, kneeling by the trail ----------------------------------------------------------------------------
local gx, gy = 214, 122
c:part(c:ellipse(gx, gy - 5, 7, 6), GV.ramp("#d6322b"), { cres = 3, deep = 4, gloss = false })
c:part(c:ellipse(gx, gy - 15, 6, 5.5), "skin", { cres = 3, deep = 4, gloss = false })
c:part(c:poly({ {gx - 7, gy - 20}, {gx - 4, gy - 35}, {gx + 7, gy - 20} }), GV.ramp("#3f8fb0"), { cres = 3, deep = 4, gloss = false })
c:eye(gx - 5, gy - 18, true); c:eye(gx + 2, gy - 18, true)
c:fill(c:rect(gx - 4, gy - 12, gx + 4, gy - 9), "#f2e4c0")
c:px(gx - 1, gy - 14, "#d9885a"); c:px(gx, gy - 14, "#d9885a")
-- lantern on a stick, pooling warm light low (soft red-ish so hatchlings are not confused)
c:fill(c:rect(gx - 14, gy - 12, gx - 13, gy + 2), "#8a4f2a")
c:fill(c:ellipse(gx - 13, gy + 2, 9, 3), "#6e6a96")
c:part(c:rrect(gx - 17, gy - 22, gx - 10, gy - 12, 2), GV.ramp("#e0501f"), { cres = 2, gloss = false })
c:fill(c:rect(gx - 15, gy - 20, gx - 12, gy - 15), "#f5cf6a"); c:px(gx - 15, gy - 20, "#fff1c8")
c:limb({ {gx - 6, gy - 8}, {gx - 10, gy - 12}, {gx - 12, gy - 14} }, 3)
c:ground(gx, gy + 1, 10, 2)
-- charm sparkles drifting from the nest
for _, p in ipairs({ {40,84},{62,78},{116,76},{188,72},{204,86} }) do
  c:px(p[1], p[2], "#fff1c8"); c:px(p[1] - 1, p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#f5cf6a"); c:px(p[1], p[2] - 1, "#f5cf6a"); c:px(p[1], p[2] + 1, "#f5cf6a")
end

L.finish(c, "haven-turtle-nesting-beach")
