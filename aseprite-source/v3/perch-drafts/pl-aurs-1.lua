-- pl-aurs-1 perch: chibi version of x/pal.png on its own little perch.
-- Phase 5 TEXTURE: shade bands fixed (deep > cres), hand-placed material marks.
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurs-1-perch-20261120-164141/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0 }

local BODY = GV.ramp("#bd6651", { shade = "#994036", deep = "#67302e", bounce = "#a05a43" })
local FLAME = GV.ramp("#e8502a", { gloss = "#ffd84a", dot = "#fff0a0", rim = "#ee983a", shade = "#a8323f", deep = "#7a232c" })
local CHAR = GV.ramp("#4e1929", { rim = "#994036", gloss = "#8a4048", bounce = "#5c3340" })
local SOIL = GV.ramp("soil")
local GOLD = GV.ramp("#d0a24a", { gloss = "#f0d488", dot = "#fff0c0", rim = "#eec36a" })
local MITT = GV.ramp("#b5c1a9", { deep = "#816c64" })

local flame = c:ascii({
  "....XX.X...",
  "...XXXXXX..",
  "..XXXXXXXX.",
  ".XXXXXXXXXX",
  "XXXXXXXXXXX",
  "XXXXXXXXXXX",
  "XXXXXXXXXXX",
}, 12, 3)

local body = c:ellipse(17.5, 17, 9.5, 9.3)
local base = c:ellipse(17.5, 28, 7, 2.5)
local handle = c:rect(29, 5, 30, 23)
local bristles = c:ascii({
  ".XXXXXX",
  ".XXXXXX",
  "XXXXXXX",
  "XXXXXXX",
  "XXXXXXX",
  "XXXXXXX",
  "XXXXXXX",
}, 25, 23)

c:build{
  { "handle",   handle,   SOIL,  { flat = true, gloss = false, contact = false } },
  { "bristles", bristles, GOLD,  { cres = 1, deep = 2, gloss = false, contact = false } },
  { "base",     base,     CHAR,  { cres = 2, deep = 3, gloss = false, bounce = true, contact = false } },
  { "flame",    flame,    FLAME, { cres = 1, deep = 2, bounce = false, contact = false } },
  { "body",     body,     BODY,  { cres = 2, deep = 3, bounce = true, contact = true } },
  { "footL",    c:rrect(12, 26, 14, 27, 1), CHAR, { flat = true, gloss = false, contact = false } },
  { "footR",    c:rrect(21, 26, 23, 27, 1), CHAR, { flat = true, gloss = false, contact = false } },
  { "mitt",     c:rrect(7, 19, 9, 22, 1), MITT, { flat = true, gloss = false, contact = false } },
}

-- texture: chestnut pit speckles on the body (tone-on-tone, follow the form)
for _, p in ipairs({{12, 11}, {21, 10}, {14, 9}, {10, 15}}) do c:px(p[1], p[2], BODY.shade) end
-- texture: 1px dither only where the body light/shade band is soft (upper crescent edge)
for _, p in ipairs({{22, 18}, {9, 18}}) do c:px(p[1], p[2], BODY.shade) end

-- texture: charcoal cracks + lit lip on the base
for _, p in ipairs({{13, 27}, {12, 28}, {20, 28}, {17, 29}}) do c:px(p[1], p[2], CHAR.deep) end
for _, p in ipairs({{11, 26}, {12, 25}, {15, 25}}) do c:px(p[1], p[2], CHAR.rim) end

-- texture: broom handle grain
for _, p in ipairs({{29, 9}, {30, 13}, {29, 17}, {30, 20}}) do c:px(p[1], p[2], SOIL.shade) end

-- texture: teal band across the bristles (from the pal's broom)
for _, p in ipairs({{25, 25}, {26, 25}, {27, 25}, {28, 25}, {29, 25}, {30, 25}, {31, 25}}) do
  if bristles:has(p[1], p[2]) then c:px(p[1], p[2], (p[1] >= 29) and "#79d8d0" or "#8fdccf") end
end
c:px(31, 26, "#79d8d0")

-- face: wide-set eyes (3x3 cream, 2x2 pupil, 1px glint), tiny mouth, blush
c:eye(11, 13, true); c:eye(22, 13, true)
c:px(12, 14, "#f2e4c0"); c:px(23, 14, "#f2e4c0")
c:px(17, 18, "#2b1c26"); c:px(18, 18, "#2b1c26")
c:px(8, 17, "#f5a0b8"); c:px(9, 17, "#f5a0b8")
c:px(24, 17, "#f5a0b8"); c:px(25, 17, "#f5a0b8")

-- detail: bead strand across the chest (gold + teal pairs, from the pal)
for _, b in ipairs({{10, 19, "#f0d488"}, {11, 19, "#79d8d0"}, {14, 20, "#f0d488"}, {15, 20, "#79d8d0"}, {18, 21, "#f0d488"}, {19, 21, "#79d8d0"}, {22, 21, "#f0d488"}, {23, 21, "#79d8d0"}}) do
  c:px(b[1], b[2], b[3])
end

-- detail: flame gloss comma + 2 floating sparks
c:px(15, 4, "#ffd84a"); c:px(16, 3, "#fff0a0")
c:px(24, 4, "#ffd84a"); c:px(25, 7, "#ee983a")

-- detail: ember glow on the base lip, clear of the feet
c:px(12, 28, "#ee983a"); c:px(13, 28, "#e8502a"); c:px(19, 27, "#a8323f")

-- soft shadow ellipse over ground
c:ground(18, 30.7, 11, 1.8, "#4a3a68")

-- 1px selective outline in the pal's dark tones, over empty px only
do
  local grown = c.sil:grow(1)
  grown:each(function(x, y)
    if not c.sil:has(x, y) and not c:get(x, y) and x >= 0 and y >= 0 and x < 36 and y < 36 then
      local s = (x - 18) + (y - 18)
      c:px(x, y, s < -10 and "#67302e" or (s < -1 and "#4e1929" or "#2b1c26"))
    end
  end)
end

local t = c:save(D .. "out/pl-aurs-1-perch.aseprite", D .. "out/pl-aurs-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
