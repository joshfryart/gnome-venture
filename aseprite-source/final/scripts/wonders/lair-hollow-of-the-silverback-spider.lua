-- lair-hollow-of-the-silverback-spider.lua : boss lair, WCA (Greatcanopy): a buttress-root tree hollow in the Congo forest, silver-backed spider and its web.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-hollow-of-the-silverback-spider"

-- filtered green light: deep canopy at top, brighter haze low
c:bands(c:rect(0, 0, W - 1, 100), { "#16382c", "#1d4a36", "#256040", "#2f7648", "#3f8c52", "#58a460", "#7cbc72" }, { dir = "v" })
-- light shafts
for _, s in ipairs({ {20,0,34,0,60,100,40,100}, {60,0,70,0,92,100,80,100}, {176,0,188,0,214,100,198,100}, {206,0,214,0,236,100,226,100} }) do
  c:fill(c:poly({ {s[1],s[2]},{s[3],s[4]},{s[5],s[6]},{s[7],s[8]} }), "#8cc878")
end
-- far trunks and hanging lianas
for _, x in ipairs({ 8, 44, 56, 188, 222 }) do c:fill(c:rect(x, 0, x + 5, 104), "#1d4a36"); c:fill(c:rect(x + 3, 0, x + 5, 104), "#16382c") end
for _, x in ipairs({ 30, 70, 172, 204, 236 }) do for y = 0, 40 + (x % 17) do c:px(x + math.floor(math.sin(y / 6) * 1.5 + 0.5), y, "#2f7648") end end
-- canopy leaf blobs across the top
for i = 0, 20 do
  local cx = i * 12 + 2; local cy = 3 + (i * 7) % 9
  c:part(c:ellipse(cx, cy, 14, 10), GV.ramp(i % 2 == 0 and "#2f7a44" or "#3a8a4c"), { cres = 3, deep = 5, gloss = false })
end
-- glimpsed bright blossoms
for _, p in ipairs({ {30,22},{214,26},{82,18} }) do c:part(c:ellipse(p[1], p[2], 2, 2), GV.ramp("#e8794a"), { flat = true, gloss = false }) end

-- red laterite ground
local gr = L.below(c, function(x) return 100 + 2 * math.sin(x / 20) end)
c:fill(gr, "#a8442c"); c:fill(gr:copy():clip(c:rect(0, 114, W, H)), "#963a26"); c:fill(gr:copy():clip(c:rect(0, 126, W, H)), "#823020")
for i = 0, 40 do local x = (i * 61 + 7) % W; local y = 104 + (i * 13) % 26; c:px(x, y, "#c85c3a"); c:px(x + 1, y, "#c85c3a") end

-- the buttress-root tree with the hollow
local trunk = c:poly({ {50,116},{72,96},{84,60},{88,22},{100,0},{150,0},{162,22},{166,60},{178,96},{204,116} })
c:part(trunk, GV.ramp("#5e4430"), { cres = 9, deep = 14, gloss = false })
-- buttress ridges
for _, l in ipairs({ { {88,26},{84,64},{70,98} }, { {162,26},{166,64},{180,98} }, { {104,10},{100,50} }, { {146,10},{150,48} } }) do c:seam(l, { free = true, on = 3, off = 0, gap = "#2e2016" }) end
-- moss
for _, m in ipairs({ {92,24,12,3},{150,32,12,3},{86,70,6,3},{166,74,6,3},{126,12,18,3} }) do c:part(c:ellipse(m[1], m[2], m[3], m[4]), GV.ramp("#5aa84a"), { flat = true, gloss = false }) end
-- hollow arch
local arch = c:ellipse(126, 70, 34, 34):clip(c:rect(0, 36, W, 70)); arch:add(c:rect(92, 71, 160, 114))
c:fill(arch, "#2a2418")
local arch2 = c:ellipse(126, 72, 29, 29):clip(c:rect(0, 43, W, 72)); arch2:add(c:rect(97, 73, 155, 114))
c:fill(arch2, "#15180f")
c:fill(c:rect(94, 112, 158, 114), "#a8442c")
-- web (silver-grey / cream) across the hollow
local webc = "#d8dcd0"
local ax, ay = 126, 70
for _, e in ipairs({ {96,48},{108,40},{126,38},{144,40},{156,48},{97,72},{155,72},{98,102},{154,102} }) do
  c:fill(c:line({ {ax, ay}, {e[1], e[2]} }, 1), webc)
end
for _, r in ipairs({ 12, 22, 30 }) do
  local px0, py0
  for a = 0, 16 do
    local ang = math.pi + a * math.pi / 16
    local x, y = math.floor(ax + r * 1.1 * math.cos(ang) + 0.5), math.floor(ay + r * math.sin(ang) * 0.95 + 0.5)
    if px0 then c:fill(c:line({ {px0, py0}, {x, y} }, 1), webc) end
    px0, py0 = x, y
  end
end
for _, p in ipairs({ {112,56},{140,54},{102,66},{150,66},{126,44} }) do c:px(p[1], p[2], "#a8e0d8"); c:px(p[1] + 1, p[2], "#f4faf0") end

-- the Silverback Spider
local SX, SY = 126, 80
local legs = { { {SX-10,SY-2},{SX-30,SY-24},{SX-44,SY+4} }, { {SX-12,SY+2},{SX-38,SY-8},{SX-54,SY+16} },
               { {SX-12,SY+6},{SX-40,SY+8},{SX-50,SY+26} }, { {SX-8,SY+10},{SX-26,SY+22},{SX-32,SY+34} } }
local body = "#4a3a38"
for _, l in ipairs(legs) do
  c:part(c:line(l, 3), GV.ramp("#5a4a46"), { flat = true, contact = false })
  local m = {}; for i, p in ipairs(l) do m[i] = { 2 * SX - p[1], p[2] } end; c:part(c:line(m, 3), GV.ramp("#5a4a46"), { flat = true, contact = false })
end
c:part(c:ellipse(SX, SY - 22, 19, 15), GV.ramp(body, { rim = "#8a7a74", gloss = "#a89890" }), { cres = 6, deep = 9 })
c:part(c:ellipse(SX, SY - 24, 13, 10), GV.ramp("#cfd4cc", { dot = "#f4f4e8", rim = "#e8ece0" }), { cres = 4, deep = 6, pale = true, outline = false, contour = "#2a1a10" })
for _, p in ipairs({ {0,-30},{0,-24},{-6,-24},{6,-24},{0,-18} }) do c:fill(c:rect(SX + p[1], SY + p[2], SX + p[1] + 1, SY + p[2] + 1), "#8a9488") end
c:part(c:ellipse(SX, SY, 18, 14), GV.ramp(body, { rim = "#8a7a74", gloss = "#a89890" }), { cres = 6, deep = 9 })
for _, dx in ipairs({ -8, 8 }) do c:eye(SX + dx - 2, SY - 8) end
for _, dx in ipairs({ -3, 2 }) do c:fill(c:rect(SX + dx, SY - 11, SX + dx + 1, SY - 10), "#d8dcd0") end
c:part(c:poly({ {SX - 7, SY + 5}, {SX - 3, SY + 5}, {SX - 5, SY + 11} }), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:poly({ {SX + 3, SY + 5}, {SX + 7, SY + 5}, {SX + 5, SY + 11} }), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:fill(c:rect(SX - 2, SY + 7, SX + 1, SY + 7), "#2a1a10")
for _, x in ipairs({ SX - 16, SX - 12, SX + 12, SX + 16 }) do c:px(x, SY - 12, "#d8dcd0"); c:px(x + 1, SY - 13, "#d8dcd0") end

-- trophies in the web: a lost felt hat and a bobble
c:part(c:poly({ {98,58},{106,58},{102,50} }), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:part(c:ellipse(102, 49, 2, 2), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:rect(150, 58, 153, 61), GV.ramp("#e8a317"), { flat = true, gloss = false })

-- foreground: roots, ferns, mushrooms
for _, p in ipairs({ {14,122,8,3},{44,128,5,2},{206,126,8,3},{230,122,5,2} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#6a4a34"), { flat = true, gloss = false }) end
for _, x in ipairs({ 10, 34, 196, 220, 66, 188 }) do
  local y = 122 + (x % 5)
  for i = 0, 8 do
    c:px(x - i // 2, y - i, "#3f9a4a"); c:px(x + i // 2 + 1, y - i, "#2f7a3c")
    if i > 2 then c:px(x - i, y - i // 2 - 2, "#58b85a"); c:px(x + i + 1, y - i // 2 - 2, "#58b85a") end
  end
end
for _, m in ipairs({ {78,124},{176,126} }) do
  c:part(c:ellipse(m[1], m[2], 4, 3):clip(c:rect(0, 0, W, m[2])), GV.ramp("#e8794a", { dot = "#fff3c8" }), { flat = true, gloss = false })
  c:fill(c:rect(m[1] - 1, m[2], m[1] + 1, m[2] + 3), "#f2e4c0")
end
L.finish(c, SLUG)
