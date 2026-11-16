-- tunnel (32x32 trail map marker, Opus pass). A grey rock hill with a mossy cap, cut by a timber-framed
-- tunnel mouth (two posts, a lintel with pale end grain) that falls away into darkness; a dirt road runs in.
-- A gold lantern hangs off the lintel (the lantern tier this road needs), lighting the post below it.
-- quirk: two little yellow eyes blink back from deep inside the dark.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("tunnel")

-- hill
local ST = { "#3c3d58", "#535470", "#6c6d86", "#8a8aa0", "#a8a7b8", "#cac8d6" }
local hill = c:ellipse(15.5, 26, 14.5, 21):clip(c:rect(0, 0, 31, 27))
T.fill(c, hill, ST[2])
-- the hill is a heap of boulders, each lit as a little sphere, with a dark seam where it meets the last
local function boulder(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry):clip(hill)
  m:each(function(x, y)
    local nx, ny = (x - cx) / (rx + 0.5), (y - cy) / (ry + 0.5)
    local nz = math.sqrt(math.max(0, 1 - nx * nx - ny * ny))
    local L = -0.6 * nx - 0.55 * ny + 0.45 * nz
    local i = L > 0.75 and 6 or L > 0.4 and 5 or L > 0.05 and 4 or L > -0.3 and 3 or 2
    if cx > 16 then i = math.max(2, i - 1) end
    c:put(x, y, ST[i])
  end)
  m:each(function(x, y) if not m:has(x + 1, y) or not m:has(x, y + 1) then
    if hill:has(x + 1, y + 1) or hill:has(x, y + 1) then c:put(x, y, ST[1]) end end end)
end
for _, b in ipairs{
  { 15.5, 9, 6, 4 }, { 8, 11, 4, 4 }, { 23, 11, 4, 4 }, { 4, 17, 3.5, 4 }, { 27, 17, 3.5, 4 },
  { 4, 24, 4, 3.5 }, { 27, 24, 4, 3.5 },
} do boulder(b[1], b[2], b[3], b[4]) end
-- mossy cap
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local cap = c:ellipse(15.5, 7, 7.5, 2.6):clip(hill)
T.vol(c, cap, MOSS, { k = 1.3, bias = 0.15 })
for _, p in ipairs{ { 9, 9 }, { 11, 10 }, { 20, 10 }, { 22, 9 } } do c:put(p[1], p[2], MOSS[2]) end

-- dark mouth
local mouth = c:rect(10, 14, 21, 27)
T.fill(c, mouth, "#2e2238")
c:rect(11, 16, 20, 27):each(function(x, y) c:put(x, y, "#261c30") end)
c:rect(13, 18, 18, 27):each(function(x, y) c:put(x, y, "#20172a") end)
-- inner walls recede: lit left wall face, the road runs on into the dark
c:poly{ { 10, 14 }, { 12, 16 }, { 12, 25 }, { 10, 27 } }:each(function(x, y) c:put(x, y, "#4a3a58") end)
c:poly{ { 21, 14 }, { 19, 16 }, { 19, 25 }, { 21, 27 } }:each(function(x, y) c:put(x, y, "#2a1f33") end)
c:poly{ { 10, 14 }, { 21, 14 }, { 19, 16 }, { 12, 16 } }:each(function(x, y) c:put(x, y, "#3a2c47") end)
c:poly{ { 12, 25 }, { 19, 25 }, { 21, 27 }, { 10, 27 } }:each(function(x, y) c:put(x, y, "#4a3230") end)
c:line({ { 13, 25 }, { 18, 25 } }, 1):each(function(x, y) c:put(x, y, "#3a2a2c") end)

-- timber frame
local WD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
for _, px in ipairs{ 8, 22 } do
  local post = c:rect(px, 14, px + 1, 27)
  T.fill(c, post, WD[2])
  c:line({ { px, 14 }, { px, 27 } }, 1):each(function(x, y) c:put(x, y, WD[3]) end)
  c:put(px + 1, 27, WD[1])
end
local lint = c:rect(6, 12, 25, 13)
T.fill(c, lint, WD[3])
c:line({ { 6, 13 }, { 25, 13 } }, 1):each(function(x, y) c:put(x, y, WD[2]) end)
c:put(6, 12, WD[4]) c:put(6, 13, "#c9925a") c:put(25, 12, WD[4]) c:put(25, 13, "#c9925a") -- end grain
c:put(11, 12, WD[4]) c:put(12, 12, WD[4]) -- pop
c:put(16, 13, WD[1]) c:put(20, 12, WD[2]) -- grain

-- road running in
local road = c:poly{ { 10, 26 }, { 21, 26 }, { 25, 30 }, { 6, 30 } }
local RD = { "#7a4f37", "#96653f", "#b5835a", "#c99a6e" }
T.fill(c, road, RD[2])
road:each(function(x, y) if y == 26 or y == 27 then c:put(x, y, RD[1]) end if y >= 29 then c:put(x, y, RD[3]) end end)
c:put(13, 28, RD[4]) c:put(18, 29, RD[1]) c:put(9, 29, RD[4])
for _, px in ipairs{ 8, 22 } do c:put(px, 27, WD[2]) c:put(px + 1, 27, WD[1]) end

-- lantern on the lintel
T.grid(c, 18, 14, {
  ".k.",
  "kgk",
  "gcg",
  "gYg",
  "kgk",
}, { k = "#5a3a2a", g = "#d98322", c = "#fff4d6", Y = "#ffe38a" })
c:put(19, 14, "#2b1c26")
-- lamplight on the right post
c:put(22, 18, "#e0a050") c:put(22, 19, "#e0a050") c:put(22, 20, "#c98a48")

-- eyes in the dark
for _, e in ipairs{ { 13, 20 }, { 16, 20 } } do c:put(e[1], e[2], "#ffe38a") c:put(e[1] + 1, e[2], "#f5b82e") end

T.done(c)
