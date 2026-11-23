-- pl-drft-4-perch.lua : chibi carnival prize booth perch, 36x36
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-4-perch-20261120-174607/"
local GV = dofile(D .. "gvlib/gvlib.lua")
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#2b1c26", "#2b1c26", "#2b1c26" -- pal outline, 1 px selective
GV.C.halo = "#fff6e0"                                          -- eye-disc cream (pal window cream)
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, cres = 2, deep = 1 }

-- ---- parts (back to front)
local AWN = GV.ramp("#eda4a8", { gloss = "#f7edd8", dot = "#fff6e0", rim = "#f2c0ca" })
local P = c:build{
  { "mat",     c:rrect(7, 27, 28, 30, 2), GV.ramp("#4a3a68"), { cres = 1 } },
  { "step",    c:rrect(8, 24, 27, 26, 1), GV.ramp("#c28a44") },
  { "ball1",   c:ellipse(4, 19, 1.5, 1.5), GV.ramp("#eda4a8", { gloss = "#f7edd8", dot = "#fff6e0", rim = "#f2c0ca" }), { flat = true } },
  { "ball2",   c:ellipse(7, 21, 1.5, 1.5), GV.ramp("#e7c579"), { flat = true } },
  { "wall",    c:rrect(9, 12, 26, 23, 2), GV.ramp("#c99152"), { gloss = false } },
  { "pole1",   c:rect(11, 3, 12, 6), GV.R.gold, { flat = true } },
  { "pole2",   c:rect(17, 3, 18, 6), GV.R.gold, { flat = true } },
  { "pole3",   c:rect(23, 3, 24, 6), GV.R.gold, { flat = true } },
  { "flag1",   c:ascii({"X.","XXX"}, 8, 3), "#aa3071", { flat = true, rim = false, contact = false } },
  { "flag2",   c:ascii({"X.","XXX"}, 8, 3):shift(6, 0), "#aa3071", { flat = true, rim = false, contact = false } },
  { "flag3",   c:ascii({"X.","XXX"}, 8, 3):shift(12, 0), "#aa3071", { flat = true, rim = false, contact = false } },
}
-- awning drawn last with a big light mask: crescent measured against wall too,
-- so the scallop bump bottoms stay lit and only bounce tints their edge.
local AWNM = c:ascii({".####################.","######################","######################","######################",".####################.",".#####...#####...####."}, 7, 6)
local LIT = c:mask():add(P.wall.m):add(AWNM)
P.awning = c:part(AWNM, AWN, { gloss = false, cres = 2, light = LIT })

-- ---- texture: gold stripes on the awning, thread seam on the wall hem
local GS = GV.ramp("#e7c579")
local STRIPE = { [AWN.base] = GS.base, [AWN.shade] = GS.shade, [AWN.deep] = "#521b21" }
P.awning.m:each(function(x, y)
  if (x - 9) % 6 < 3 and x >= 0 and y >= 0 then
    local cur = c:get(x, y)
    if STRIPE[cur] then c:px(x, y, STRIPE[cur]) end
  end
end)
c:seam({ { 10, 21 }, { 25, 21 } })

-- ---- face: cream eyes, arch mouth; auto gloss comma sits above the eyes; balloon strings
c:eye(12, 15, true); c:eye(21, 15, true)
c:px(13, 16, GV.C.halo); c:px(22, 16, GV.C.halo) -- 1 px cream glint at each pupil's upper-left
c:paint({ ".W.", "WWW" }, 16, 19, { W = "#521b21" })
c:px(5, 21, "#825d53"); c:px(6, 22, "#825d53"); c:px(7, 23, "#825d53")

local t = c:save(D .. "out/pl-drft-4-perch.aseprite", D .. "out/pl-drft-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
