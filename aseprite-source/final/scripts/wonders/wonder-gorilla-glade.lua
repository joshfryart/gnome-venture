-- wonder-gorilla-glade.lua : "Quiet giants share a glade of forest fruit. They watch you politely, waiting for your manners."
-- Thing to do: greet them properly (Charm); the largest hands you a fruit like a visiting aunt. Misty green morning.
local K = dofile("/home/user/gnome-venture/aseprite-source/final/scripts/wonders/w5lib.lua")
local L, GV, TINY = K.L, K.GV, K.TINY
local W, H = L.W, L.H
local c = L.new()
local function R(h, o) return GV.ramp(h, o) end
local FUR = "#4a4a5a"
local function fur(m, o) c:part(m, R(FUR, { rim = "#7a7a8a" }), o or { gloss = false, cres = 5, deep = 8 }) end
local HOR = 70

-- misty forest backdrop ---------------------------------------------------------------------------------------------------
c:bands(c:rect(0, 0, W - 1, HOR + 6), { "#2f5a2a", "#3a6a34", "#4a8a3e", "#6a9a3a", "#8ab070", "#b0cfa0", "#d0e4c0" }, { dir = "v" })
for _, s in ipairs({ { 60, 40 }, { 150, 120 } }) do
  c:fill(c:poly({ { s[1], 0 }, { s[1] + 12, 0 }, { s[2] + 30, 100 }, { s[2], 100 } }), "#8ab070")
  c:fill(c:poly({ { s[1] + 4, 0 }, { s[1] + 8, 0 }, { s[2] + 20, 100 }, { s[2] + 10, 100 } }), "#b0cfa0")
end
-- far trunks
for _, x in ipairs({ 8, 36, 74, 108, 168, 198, 226 }) do
  c:fill(c:rect(x, 0, x + 4, HOR + 6), "#3a6a34"); c:fill(c:rect(x, 0, x, HOR + 6), "#4a8a3e"); c:fill(c:rect(x + 4, 0, x + 4, HOR + 6), "#2f5a2a")
end
-- canopy clumps
for _, p in ipairs({ { 12, 4, 20 }, { 62, 0, 22 }, { 112, 2, 20 }, { 164, 0, 24 }, { 214, 4, 22 } }) do
  c:part(c:ellipse(p[1], p[2], p[3], 11), R("#2f5a2a"), { gloss = false, outline = false, cres = 4, deep = 6 })
end
-- fruit tree (left) and (right)
local function ftree(x, y, fr)
  c:part(c:rrect(x - 3, y - 26, x + 3, y, 2), R("#8a4f2a"), { gloss = false, outline = false, cres = 2, deep = 3 })
  c:part(c:ellipse(x, y - 34, 20, 14), R("#4a8a3e"), { gloss = false, outline = false, cres = 5, deep = 7 })
  for i, d in ipairs({ { -12, -36 }, { -4, -30 }, { 6, -40 }, { 12, -32 }, { -8, -42 }, { 0, -36 }, { 14, -38 } }) do
    c:part(c:ellipse(x + d[1], y + d[2], 2.5, 2.5), R(fr[(i % #fr) + 1]), { flat = true, gloss = false, outline = false })
    c:px(x + d[1] - 1, y + d[2] - 1, "#fff1c8")
  end
end
ftree(30, 76, { "#f08a24", "#e46a9b", "#f5cf6a" })
ftree(212, 78, { "#e46a9b", "#f5cf6a", "#f08a24" })
ftree(120, 70, { "#f5cf6a", "#f08a24" })

-- the glade floor ---------------------------------------------------------------------------------------------------------------
local ground = L.below(c, function(x) return HOR + 4 + 3 * math.sin(x / 21) end)
c:fill(ground, "#7ab55c")
c:fill(ground:copy():clip(c:rect(0, 0, W, 90)), "#8ec468")
for i = 0, 90 do
  local x, y = (i * 47 + 5) % W, 78 + (i * 13) % 56
  c:px(x, y, "#a4b86a"); c:px(x + 1, y - 1, "#6a9a3a")
end
-- flowers
for _, p in ipairs({ { 20, 96 }, { 90, 88 }, { 176, 92 }, { 232, 100 }, { 70, 126 }, { 200, 124 }, { 150, 82 } }) do c:px(p[1], p[2], "#f6b8cf"); c:px(p[1] + 1, p[2], "#fff1c8"); c:px(p[1], p[2] + 1, "#f5cf6a") end

-- the juvenile (far right), munching a fruit -------------------------------------------------------------------------------------------
local JX, JY = 206, 112
c:part(c:ellipse(JX, JY, 12, 10), R(FUR), { gloss = false, cres = 4, deep = 6 })
c:part(c:ellipse(JX, JY - 14, 10, 8), R(FUR, { rim = "#7a7a8a" }), { gloss = false, cres = 4, deep = 6 })
c:part(c:ellipse(JX, JY - 11, 5.5, 3.5), R("#6a6a78"), { flat = true, gloss = false, outline = false })
c:eye(JX - 7, JY - 19, true); c:eye(JX + 3, JY - 19, true)
c:fill(c:rect(JX - 7, JY - 20, JX - 3, JY - 20), "#2a2a36"); c:fill(c:rect(JX + 3, JY - 20, JX + 7, JY - 20), "#2a2a36")
c:fill(c:rect(JX - 2, JY - 11, JX + 1, JY - 10), "#2a1a10")
c:part(c:ellipse(JX - 14, JY - 4, 4, 4), R("#e46a9b"), { flat = true, gloss = false }); c:px(JX - 15, JY - 5, "#fff1c8")
c:limb({ { JX - 9, JY + 2 }, { JX - 13, JY - 1 } }, 3)

-- mother and baby (left) ----------------------------------------------------------------------------------------------------------------
local MX, MY = 50, 112
fur(c:ellipse(MX, MY, 18, 14))
fur(c:ellipse(MX, MY - 24, 12, 10))
c:part(c:ellipse(MX, MY - 21, 7, 4.5), R("#6a6a78"), { flat = true, gloss = false, outline = false })
c:fill(c:rect(MX - 10, MY - 28, MX + 10, MY - 28), "#2a2a36")
c:eye(MX - 9, MY - 27); c:eye(MX + 4, MY - 27)
c:fill(c:rect(MX - 9, MY - 28, MX - 5, MY - 28), "#2a2a36"); c:fill(c:rect(MX + 4, MY - 28, MX + 8, MY - 28), "#2a2a36")
c:fill(c:rect(MX - 3, MY - 20, MX + 2, MY - 20), "#2a1a10"); c:px(MX - 4, MY - 21, "#2a1a10"); c:px(MX + 3, MY - 21, "#2a1a10")
c:part(c:ellipse(MX, MY - 6, 10, 8), R("#6a6a78"), { flat = true, gloss = false, outline = false })
-- baby clinging to her side
local BX, BY = 74, 112
c:part(c:ellipse(BX, BY, 7, 6), R(FUR), { gloss = false, cres = 2, deep = 3 })
c:part(c:ellipse(BX + 1, BY - 11, 7, 6), R(FUR, { rim = "#7a7a8a" }), { gloss = false, cres = 2, deep = 3 })
c:part(c:ellipse(BX + 1, BY - 9, 4, 2.5), R("#6a6a78"), { flat = true, gloss = false, outline = false })
c:eye(BX - 3, BY - 14, true); c:eye(BX + 2, BY - 14, true)
c:part(c:ellipse(BX - 8, BY + 1, 3, 3), R("#f5cf6a"), { flat = true, gloss = false }); c:px(BX - 9, BY, "#fff1c8")

-- the great silverback (centre right), offering a fruit ------------------------------------------------------------------------------------
local GX, GY = 142, 104
fur(c:ellipse(GX, GY, 30, 22), { gloss = false, cres = 7, deep = 11 })
-- silver saddle across the shoulders
c:part(c:ellipse(GX, GY - 16, 22, 7):clip(c:rect(0, 0, W, GY - 8)), R("#b6b8bd", { rim = "#e8e4dc" }), { flat = true, gloss = false, outline = false })
fur(c:ellipse(GX, GY - 32, 15, 12), { gloss = false, cres = 5, deep = 8 })
c:part(c:ellipse(GX, GY - 28, 9, 6), R("#6a6a78"), { flat = true, gloss = false, outline = false })
c:part(c:poly({ { GX - 3, GY - 45 }, { GX + 3, GY - 45 }, { GX + 1, GY - 38 }, { GX - 1, GY - 38 } }), R("#b6b8bd"), TINY)   -- silver crest
-- brow ridge and gentle eyes
c:fill(c:rect(GX - 12, GY - 36, GX + 12, GY - 36), "#2a2a36"); c:fill(c:rect(GX - 12, GY - 35, GX - 8, GY - 35), "#2a2a36"); c:fill(c:rect(GX + 8, GY - 35, GX + 12, GY - 35), "#2a2a36")
c:eye(GX - 11, GY - 35); c:eye(GX + 6, GY - 35)
c:fill(c:rect(GX - 11, GY - 35, GX - 7, GY - 35), "#4a4a5a"); c:fill(c:rect(GX + 6, GY - 35, GX + 10, GY - 35), "#4a4a5a")
c:fill(c:rect(GX - 1, GY - 31, GX, GY - 30), "#2a2a36")
c:fill(c:rect(GX - 5, GY - 25, GX + 4, GY - 25), "#2a1a10"); c:px(GX - 6, GY - 26, "#2a1a10"); c:px(GX + 5, GY - 26, "#2a1a10")   -- polite little smile
-- chest
c:part(c:ellipse(GX, GY - 4, 12, 9), R("#6a6a78"), { flat = true, gloss = false, outline = false })
-- arms: left arm (his right) rests, other reaches out to us with a big fruit
c:part(c:line({ { GX - 26, GY - 8 }, { GX - 30, GY + 6 }, { GX - 24, GY + 20 } }, 9), R(FUR, { rim = "#7a7a8a" }), { gloss = false, cres = 3, deep = 5 })
c:part(c:line({ { GX + 22, GY - 8 }, { GX + 20, GY + 4 }, { GX + 8, GY + 10 }, { GX - 12, GY + 12 } }, 8), R(FUR, { rim = "#7a7a8a" }), { gloss = false, cres = 3, deep = 5 })
c:part(c:ellipse(GX - 24, GY + 12, 7, 6), R("#6a6a78"), { gloss = false, cres = 2, deep = 3 })
-- the offered fruit
c:part(c:ellipse(GX - 24, GY + 6, 8, 7), R("#f08a24", { rim = "#fbc060" }), { cres = 3, deep = 4 })
c:fill(c:rect(GX - 25, GY - 1, GX - 24, GY - 1), "#4a8a3e"); c:fill(c:rect(GX - 24, GY - 3, GX - 23, GY - 2), "#4a8a3e")
c:part(c:ellipse(GX - 21, GY + 13, 4.5, 4.5), R("#6a6a78"), { gloss = false, cres = 1, deep = 2 })   -- fingers curled under

-- fruit pile on a leaf (foreground) -----------------------------------------------------------------------------------------------------------------
c:part(c:ellipse(86, 127, 20, 4), R("#4a8a3e"), { gloss = false, cres = 2, deep = 3 })
for i, p in ipairs({ { 76, 122 }, { 84, 122 }, { 92, 122 }, { 98, 123 }, { 80, 117 }, { 88, 117 }, { 84, 112 } }) do
  c:part(c:ellipse(p[1], p[2], 4, 4), R(({ "#f08a24", "#e46a9b", "#f5cf6a", "#7a4a9a", "#f08a24", "#f5cf6a", "#e46a9b" })[i]), { gloss = false, cres = 1, deep = 2, outline = false })
  c:px(p[1] - 1, p[2] - 2, "#fff1c8")
end
-- ferns
local function fern(x, y, n, col)
  for i = -n, n do
    local len = 12 - math.abs(i) * 2
    c:fill(c:line({ { x, y }, { x + i * 4, y - len } }, 2), col); c:px(x + i * 4, y - len - 1, "#c8d77a")
  end
end
fern(14, 130, 2, "#4a8a3e"); fern(188, 130, 2, "#4a8a3e"); fern(232, 130, 2, "#6a9a3a"); fern(122, 128, 1, "#6a9a3a")
-- falling leaves / butterflies
for _, p in ipairs({ { 80, 48 }, { 180, 56 }, { 124, 96 }, { 28, 100 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2] - 1, "#f6b8cf") end
L.finish(c, "wonder-gorilla-glade")
