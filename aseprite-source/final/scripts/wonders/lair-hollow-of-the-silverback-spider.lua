-- lair-hollow-of-the-silverback-spider.lua : boss lair, WCA steppe at dusk. A silver-backed spider in a rock hollow behind a web.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-hollow-of-the-silverback-spider"

L.sky(c, "dusk", 96)
L.stars(c, 26, 38, 5)
L.cloud(c, 36, 54, 16, "#8c6ab8", "#c98fb0"); L.cloud(c, 206, 48, 18, "#8c6ab8", "#c98fb0")
-- snowy far range
local function peak(pts, rock, snow, line)
  local m = c:poly(pts); c:fill(m, rock); c:fill(m:copy():clip(c:rect(0, 0, W, line)), snow)
end
peak({ {0,100},{0,76},{22,60},{40,72},{66,52},{92,76},{112,100} }, "#6a4fa8", "#d8c0e8", 66)
peak({ {140,100},{160,70},{186,50},{208,68},{228,60},{W,74},{W,100} }, "#6a4fa8", "#d8c0e8", 64)
-- steppe
local st = L.below(c, function(x) return 94 + 3 * math.sin(x / 26) end)
c:fill(st, "#a8905a"); c:fill(st:copy():clip(c:rect(0, 108, W, H)), "#98804a"); c:fill(st:copy():clip(c:rect(0, 122, W, H)), "#88703c")
for i = 0, 44 do local x = (i * 67 + 9) % W; local y = 98 + (i * 11) % 32; c:px(x, y, "#c8b070"); c:px(x + 1, y - 1, "#d8c890"); c:px(x + 2, y, "#c8b070") end
-- a far yurt with a lit door
local yx, yy = 34, 98
c:part(c:ellipse(yx, yy - 4, 11, 8):clip(c:rect(0, 0, W, yy)), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 4, deep = 6, pale = true })
c:part(c:poly({ {yx - 12, yy - 6}, {yx, yy - 17}, {yx + 12, yy - 6} }), GV.ramp("#d6322b"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(yx - 2, yy - 6, yx + 2, yy - 1), "#f5b860"); c:px(yx, yy - 18, "#e8a317")
c:seam({ {yx - 11, yy - 6}, {yx + 11, yy - 6} }, { free = true })
c:px(yx - 3, yy - 22, "#c3b2ea"); c:px(yx - 2, yy - 24, "#8c6ab8")   -- smoke

-- the rock outcrop with the hollow
local rock = c:poly({ {64,112},{70,80},{80,52},{100,32},{130,24},{158,34},{176,56},{184,82},{190,112} })
c:part(rock, GV.ramp("#8b8f96"), { cres = 9, deep = 14, gloss = false })
c:fill(c:poly({ {100,32},{130,24},{158,34},{150,36},{134,30},{116,36},{106,38} }), "#c8b8d8")
for _, l in ipairs({ { {74,76},{84,72},{90,80} }, { {160,58},{170,62},{174,72} }, { {96,40},{104,46} } }) do c:seam(l, { free = true, on = 3, off = 0, gap = "#2a1a10" }) end
-- hollow (arch)
local arch = c:ellipse(126, 78, 38, 38):clip(c:rect(0, 40, W, 78)); arch:add(c:rect(88, 79, 164, 114))
c:fill(arch, "#3e2f66")
local arch2 = c:ellipse(126, 80, 33, 33):clip(c:rect(0, 40, W, 80)); arch2:add(c:rect(93, 81, 159, 114))
c:fill(arch2, "#291d4a")
c:fill(c:rect(90, 112, 162, 114), "#a8905a")
-- the web across the hollow
local webc = "#cfd6e8"
local ax, ay = 126, 74
for _, e in ipairs({ {90,48},{104,42},{126,40},{148,42},{162,48},{93,76},{159,76},{92,104},{160,104} }) do
  c:seam({ {ax, ay}, {e[1], e[2]} }, { free = true, on = 3, off = 0, gap = webc })
end
for _, r in ipairs({ 12, 22, 32 }) do
  local pts = {}
  for a = -2, 2 do local ang = math.pi + a * math.pi / 4 + math.pi / 2 * 0; pts[#pts + 1] = { math.floor(ax + r * 1.2 * math.cos(ang)), math.floor(ay - r * math.sin(ang) * -1) } end
end
for _, r in ipairs({ 12, 22, 32 }) do
  local px0, py0
  for a = 0, 16 do
    local ang = math.pi + a * math.pi / 16
    local x, y = math.floor(ax + r * 1.1 * math.cos(ang) + 0.5), math.floor(ay + r * math.sin(ang) * 0.95 + 0.5)
    if px0 and (r < 33) then c:seam({ {px0, py0}, {x, y} }, { free = true, on = 3, off = 0, gap = webc }) end
    px0, py0 = x, y
  end
end
for _, p in ipairs({ {112,60},{140,58},{100,70},{152,70},{126,46} }) do c:px(p[1], p[2], "#8fcbd8"); c:px(p[1] + 1, p[2], "#f2fbf8") end

-- the Silverback Spider
local SX, SY = 126, 84
local legc = GV.ramp("#4a3a5a")
local legs = { { {SX-10,SY-2},{SX-30,SY-24},{SX-44,SY+4} }, { {SX-12,SY+2},{SX-38,SY-8},{SX-54,SY+16} },
               { {SX-12,SY+6},{SX-40,SY+8},{SX-50,SY+26} }, { {SX-8,SY+10},{SX-26,SY+22},{SX-32,SY+34} } }
for _, l in ipairs(legs) do
  c:limb(l, 3)
  local m = {}; for i, p in ipairs(l) do m[i] = { 2 * SX - p[1], p[2] } end; c:limb(m, 3)
end
-- abdomen with the silver saddle (the "silverback")
c:part(c:ellipse(SX, SY - 22, 19, 15), GV.ramp("#4a3a5a", { rim = "#8a7aa8", gloss = "#a894dc" }), { cres = 6, deep = 9 })
c:part(c:ellipse(SX, SY - 24, 13, 10), GV.ramp("#cfd6e8", { dot = "#fff3c8", rim = "#e8eef8" }), { cres = 4, deep = 6, pale = true, outline = false, contour = "#291d4a" })
for _, p in ipairs({ {0,-30},{0,-24},{-6,-24},{6,-24},{0,-18} }) do c:fill(c:rect(SX + p[1], SY + p[2], SX + p[1] + 1, SY + p[2] + 1), "#8a96b8") end
-- head
c:part(c:ellipse(SX, SY, 18, 14), GV.ramp("#4a3a5a", { rim = "#8a7aa8", gloss = "#a894dc" }), { cres = 6, deep = 9 })
-- eyes: two big, two small, set wide
for _, dx in ipairs({ -8, 8 }) do c:eye(SX + dx - 2, SY - 8) end
for _, dx in ipairs({ -3, 2 }) do c:fill(c:rect(SX + dx, SY - 11, SX + dx + 1, SY - 10), "#cfd6e8") end
-- little fangs and a pursed mouth
c:part(c:poly({ {SX - 7, SY + 5}, {SX - 3, SY + 5}, {SX - 5, SY + 11} }), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:poly({ {SX + 3, SY + 5}, {SX + 7, SY + 5}, {SX + 5, SY + 11} }), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:fill(c:rect(SX - 2, SY + 7, SX + 1, SY + 7), "#2a1a10")
-- silvery fur tufts
for _, x in ipairs({ SX - 16, SX - 12, SX + 12, SX + 16 }) do c:px(x, SY - 12, "#cfd6e8"); c:px(x + 1, SY - 13, "#cfd6e8") end

-- a lost felt hat and a bobble caught in the web (the spider's trophies, gnome-scale)
c:part(c:poly({ {96,58},{104,58},{100,50} }), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:part(c:ellipse(100, 49, 2, 2), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:rect(150, 60, 153, 63), GV.ramp("#4e8a9a"), { flat = true, gloss = false })
-- foreground stones and feather grass
for _, p in ipairs({ {20,124,6,3},{52,128,4,2},{206,126,7,3},{226,122,4,2} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#8b8f96"), { flat = true, gloss = false }) end
for _, x in ipairs({ 8, 40, 190, 214, 232, 70 }) do
  local y = 120 + (x % 7)
  for i = 0, 7 do c:px(x + math.floor(i / 3), y - i, "#e8d890"); c:px(x + 3 - math.floor(i / 3), y - i, "#c8b070") end
  c:px(x + 1, y - 9, "#fff1c8"); c:px(x + 2, y - 8, "#fff1c8")
end
L.finish(c, SLUG)
