-- pl-ambr-2-perch : 36x36 perch sprite (green bead-blob pal)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-2-perch-20261120-161959/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

local body  = GV.ramp("#7ec454")
local frond = GV.ramp("#9bc96a")
local stone = GV.ramp("#56706d", { shade = "#46595a", deep = "#3a4a48" })
local gold  = GV.R.gold
local ink   = "#2b1729"

local p = c:build{
  -- perch: single small tidepool stone
  { "perch", c:ellipse(16.5, 29, 7, 3.2):cut(c:rect(0, 31, 35, 35)), stone, { gloss = false, cres = 2, deep = 2 } },
  -- spikes (behind head top, tips visible)
  { "sp1", c:line({{16, 7},{16, 4}}, 2), frond, { flat = true } },
  { "sp2", c:line({{12, 8},{11, 5}}, 2), frond, { flat = true } },
  { "sp3", c:line({{21, 8},{22, 5}}, 2), frond, { flat = true } },
  -- chibi body: big head + squat lower mass, sitting ON the perch
  { "head",  c:ellipse(16.5, 11.5, 9, 7.5),  body, { gloss = false } },
  { "belly", c:ellipse(16.5, 21, 6.5, 5),    body, { gloss = false, cres = 2, deep = 1, contour = false } },
  -- bead accents: one trailing right, one resting on the perch rim
  { "bead",  c:ellipse(28.8, 20.5, 1.5, 1.5), gold, { flat = true } },
  { "bead2", c:ellipse(22, 27.5, 1.6, 1.6),   gold, { flat = true } },
}

c:ground(16.5, 30, 9, 1)

-- texture: 1px dither along the head crescent border (base -> shade)
local hm = p.head.m
hm:each(function(x, y)
  if c:get(x, y) == body.base and not hm:has(x + 2, y + 2) and ((x + y) % 2 == 0) then
    c:px(x, y, body.shade)
  end
end)

-- texture: stone speckles + lit top edge on the perch
c:px(11, 27, stone.shade); c:px(21, 29, stone.shade)
c:px(13, 26, stone.rim);   c:px(10, 28, stone.rim)
c:px(10, 29, stone.gloss); c:px(11, 26, stone.gloss); c:px(12, 27, stone.gloss)

-- texture: bead gloss dots
c:px(28, 19, gold.dot); c:px(21, 26, gold.dot)

-- face: big dark oval eyes with a cream glint, tiny mouth
c:paint({
  ".o.",
  "ooo",
  "ogo",
  "ooo",
  ".o.",
}, 11, 11, { o = ink, g = "#e5e5c7" })
c:paint({
  ".o.",
  "ooo",
  "ogo",
  "ooo",
  ".o.",
}, 20, 11, { o = ink, g = "#e5e5c7" })
c:paint({ ".m.", ".mm" }, 15, 16, { m = ink })

-- head gloss comma on the lit upper-left + enamel dot
c:px(11, 9, body.gloss); c:px(12, 9, body.gloss); c:px(12, 10, body.gloss)
c:px(13, 7, body.dot)

local t = c:save("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-2-perch-20261120-161959/out/pl-ambr-2-perch.aseprite",
                 "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-2-perch-20261120-161959/out/pl-ambr-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
