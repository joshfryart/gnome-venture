-- banner-SE-pets.lua : Cat Fish pet shop banner for "The Olive Pantry Pets" (Olivewhistle Shore, SE).
-- A warm ochre shop front in the market town: terracotta tile eave, a hanging gold cat-head sign (no text),
-- olive-and-cream striped awning, a lit shop window full of cat goods, an open arched door with warm light,
-- a ginger cat on the step, a potted lemon tree, cream neighbours with shutters and bougainvillea, sea beyond.
-- House banner format: 240x60 grid written at 2x (480x120), scene mode (no border), gold hem top and bottom.
-- Run: AppRun -b --script banner-SE-pets.lua  -> ../out/banner-SE-pets.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 240, h = 60, mode = "scene", out = 2 }

-- one shared palette (<= 24 colours): every ramp reuses these hexes
local function R(t) t.dot = t.dot or t.gloss; t.bounce = t.bounce or t.shade; return t end
local CREAM = R{ base = "#f1ece0", rim = "#fff1c8", gloss = "#fff1c8", shade = "#e9b98a", deep = "#c9a96e", pale = true }
local OCHRE = R{ base = "#e9b98a", rim = "#fff1c8", gloss = "#fff1c8", shade = "#d9885a", deep = "#c47a52", pale = false }
local TERRA = R{ base = "#c47a52", rim = "#d9885a", gloss = "#e9b98a", dot = "#fff1c8", shade = "#8a4f2a", deep = "#5e2f1e", pale = false }
local OLIVE = R{ base = "#6a9a3a", rim = "#a4b86a", gloss = "#c8d77a", shade = "#4a8a3e", deep = "#2f5a2a", pale = false }
local DKGRN = R{ base = "#4a8a3e", rim = "#6a9a3a", gloss = "#a4b86a", shade = "#2f5a2a", deep = "#2f5a2a", pale = false }
local GOLD  = R{ base = "#e8a317", rim = "#f5cf6a", gloss = "#fff1c8", shade = "#d9885a", deep = "#c47a52", pale = false }
local PINK  = R{ base = "#e46a9b", rim = "#e46a9b", gloss = "#fff1c8", shade = "#c47a52", deep = "#8a4f2a", pale = false }
local SEA   = R{ base = "#3f8fb0", rim = "#8fcbd8", gloss = "#c8ecdc", shade = "#2f5a2a", deep = "#2f5a2a", pale = false }

-- recolour the shaded pixels of one ramp inside a mask to the same tones of another ramp
local KEYS = { "base", "rim", "shade", "deep", "bounce", "gloss" }
local function remap(m, from, to)
  m:each(function(x, y)
    local h = c:get(x, y)
    for _, k in ipairs(KEYS) do if h == from[k] then c:px(x, y, to[k]) return end end
  end)
end

---------------------------------------------------------------- sky, sea, street (no outline)
c:bands(c:rect(0, 0, 239, 31), { "#8fcbd8", "#8fcbd8", "#8fcbd8", "#c8ecdc", "#c8ecdc", "#fff1c8" }, { dir = "v" })
-- low afternoon sun, upper left
c:part(c:ellipse(30, 7, 3.5, 3.5), GOLD, { outline = false, gloss = false, flat = true })
c:px(28, 5, "#fff1c8"); c:px(29, 5, "#fff1c8"); c:px(28, 6, "#fff1c8")
-- far headland on the left horizon
c:fill(c:poly({ { 0, 30 }, { 6, 26 }, { 14, 25 }, { 22, 28 }, { 26, 31 }, { 0, 31 } }), "#a4b86a")
-- sea strip
c:fill(c:rect(0, 31, 239, 40), "#3f8fb0")
for _, p in ipairs({ { 2, 33, 4 }, { 9, 36, 3 }, { 226, 34, 4 }, { 233, 37, 3 }, { 15, 34, 2 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + p[3] - 1, p[2]), "#c8ecdc")
end
-- quay wall + cobbled street
c:fill(c:rect(0, 41, 239, 59), "#c9a96e")
c:fill(c:rect(0, 41, 239, 41), "#e9b98a")
for row = 0, 5 do
  local y = 44 + row * 3
  local off = (row % 2) * 3
  for x = off, 239, 6 do c:fill(c:rect(x, y, x + 3, y), "#e9b98a") end
end

---------------------------------------------------------------- far props
-- olive tree, far left
c:part(c:rect(7, 36, 8, 47), TERRA, { flat = true })
c:part(c:ellipse(8, 30, 7, 5.5), OLIVE, { gloss = false })
c:fill(c:rect(4, 27, 6, 27), "#c8d77a"); c:fill(c:rect(10, 26, 11, 26), "#c8d77a")
-- cypress, far right
c:part(c:rect(231, 41, 232, 47), TERRA, { flat = true })
c:part(c:ellipse(231.5, 26, 4.5, 15), DKGRN, { gloss = false })

---------------------------------------------------------------- left neighbour (cream house, green shutters)
c:part(c:rect(18, 16, 77, 48), CREAM, { gloss = false })
c:part(c:rect(15, 12, 80, 15), TERRA, { gloss = false })
for x = 17, 79, 4 do c:fill(c:rect(x, 13, x, 14), "#8a4f2a") end
-- shuttered window (two closed olive shutters with slats)
c:part(c:rect(28, 21, 33, 31), OLIVE, { outline = false, gloss = false, flat = true })
c:part(c:rect(35, 21, 40, 31), OLIVE, { outline = false, gloss = false, flat = true })
for y = 23, 30, 2 do c:fill(c:rect(29, y, 32, y), "#4a8a3e"); c:fill(c:rect(36, y, 39, y), "#4a8a3e") end
c:part(c:rect(26, 32, 42, 33), CREAM, { outline = false, flat = true })
-- geranium box on the sill
c:part(c:rect(28, 34, 40, 36), TERRA, { outline = false, flat = true })
for _, x in ipairs({ 29, 33, 37 }) do c:fill(c:rect(x, 32, x + 2, 33), "#e46a9b") end
-- small arched blue-grey door
local ldoor = c:rect(52, 35, 61, 48):add(c:ellipse(56.5, 35, 4.5, 3.5))
c:part(ldoor, TERRA, { outline = false, gloss = false })
c:fill(c:rect(56, 33, 56, 48), "#8a4f2a")

---------------------------------------------------------------- right neighbour (cream house, bougainvillea)
c:part(c:rect(163, 19, 224, 48), CREAM, { gloss = false })
c:part(c:rect(161, 15, 227, 18), TERRA, { gloss = false })
for x = 163, 226, 4 do c:fill(c:rect(x, 16, x, 17), "#8a4f2a") end
-- open window with shutters folded back
c:part(c:rect(178, 25, 189, 37), TERRA, { outline = false, gloss = false })
c:fill(c:rect(180, 27, 187, 37), "#5e2f1e")
c:fill(c:rect(183, 27, 184, 37), "#8a4f2a")
c:part(c:rect(172, 25, 176, 37), OLIVE, { outline = false, gloss = false, flat = true })
c:part(c:rect(191, 25, 195, 37), OLIVE, { outline = false, gloss = false, flat = true })
for y = 27, 36, 2 do c:fill(c:rect(173, y, 175, y), "#4a8a3e"); c:fill(c:rect(192, y, 194, y), "#4a8a3e") end
-- bougainvillea tumbling over the right of the house
local bush = c:ellipse(212, 22, 13, 8):add(c:ellipse(219, 33, 7, 9)):add(c:ellipse(203, 17, 7, 4))
c:part(bush, DKGRN, { gloss = false })
for _, p in ipairs({ { 203, 16 }, { 208, 19 }, { 214, 15 }, { 219, 20 }, { 211, 24 }, { 205, 22 }, { 217, 27 },
                     { 221, 32 }, { 216, 35 }, { 220, 39 }, { 222, 25 }, { 198, 18 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#e46a9b")
  c:px(p[1], p[2], "#fff1c8")
end

---------------------------------------------------------------- the shop: The Olive Pantry Pets
local wall = c:rect(81, 9, 159, 48)
c:part(wall, OCHRE, { gloss = false })
-- terracotta tile eave
local eave = c:rect(77, 4, 163, 9)
c:part(eave, TERRA, { gloss = false })
for x = 79, 162, 4 do c:fill(c:rect(x, 5, x, 8), "#8a4f2a") end
for x = 78, 162, 4 do c:px(x, 9, "#8a4f2a"); c:px(x + 1, 9, "#8a4f2a") end
c:fill(c:rect(78, 6, 162, 6), "#d9885a")
-- corner stone quoins
for y = 12, 46, 6 do
  c:fill(c:rect(82, y, 84, y + 2), "#fff1c8"); c:fill(c:rect(156, y, 158, y + 2), "#d9885a")
end

-- hanging sign: gold oval plaque with a cat-head cut-out, on two short chains
c:fill(c:rect(113, 10, 113, 11), "#4a2c1a"); c:fill(c:rect(127, 10, 127, 11), "#4a2c1a")
c:part(c:ellipse(120, 15.5, 8, 4), GOLD, { gloss = false })
c:paint({
  "u.......u",
  "uu.....uu",
  "uuuuuuuuu",
  "uucuuucuu",
  "uuuuuuuuu",
  ".uuuyuuu.",
  "..uuuuu..",
}, 116, 12, { u = "#8a4f2a", c = "#fff1c8", y = "#e46a9b" })

-- striped awning: olive and cream, flaring out, scalloped hem
local function awx(y) local t = (y - 20) / 8 return 85 - t * 4, 155 + t * 4 end
local awn = c:poly({ { 85, 20 }, { 156, 20 }, { 160, 28 }, { 80, 28 } })
for i = 0, 13 do awn:add(c:ellipse(83 + i * 5.7, 28, 2.5, 1.6)) end
awn:cut(c:rect(0, 31, 239, 59))
local aw = c:part(awn, CREAM, { gloss = false })
local stripes = c:mask()
awn:each(function(x, y)
  local l, r = awx(math.min(y, 28))
  local i = math.floor((x - l) / ((r - l) / 14))
  if i % 2 == 0 then stripes:set(x, y) end
end)
remap(stripes, CREAM, OLIVE)
c:seam({ { 86, 21 }, { 154, 21 } })

-- shop window: olive frame, warm lit interior with cat goods
local win = c:rect(86, 32, 113, 46)
c:part(win, OLIVE, { outline = false, gloss = false })
c:fill(c:rect(88, 34, 111, 44), "#f5cf6a")
c:fill(c:rect(88, 42, 111, 44), "#e8a317")   -- display shelf
c:fill(c:rect(88, 41, 111, 41), "#d9885a")
-- amphora
c:part(c:ellipse(91.5, 38, 2.5, 3):add(c:rect(91, 34, 92, 35)), TERRA, { outline = false, gloss = false, flat = true })
c:fill(c:rect(90, 34, 93, 34), "#8a4f2a")
-- yarn ball
c:part(c:ellipse(97, 39.5, 2, 2), PINK, { outline = false, gloss = false, flat = true })
c:px(96, 39, "#fff1c8")
-- hanging felt fish on a thread
c:fill(c:rect(102, 34, 102, 35), "#4a2c1a")
c:part(c:ellipse(102, 37.5, 2.5, 1.5), SEA, { outline = false, gloss = false, flat = true })
c:fill(c:rect(105, 36, 105, 39), "#3f8fb0")
-- catgrass pot
c:part(c:rect(106, 38, 110, 41), TERRA, { outline = false, gloss = false, flat = true })
c:fill(c:rect(106, 36, 106, 37), "#6a9a3a"); c:fill(c:rect(108, 35, 108, 37), "#6a9a3a"); c:fill(c:rect(110, 36, 110, 37), "#6a9a3a")
-- mullion
c:fill(c:rect(99, 34, 100, 44), "#4a8a3e")
-- stone sill
c:part(c:rect(84, 46, 115, 47), CREAM, { outline = false, flat = true })

-- open arched door, warm light inside
local arch = c:rect(121, 35, 139, 48):add(c:ellipse(130, 35, 9, 5):cut(c:rect(0, 36, 239, 59)))
c:part(arch:grow(1), CREAM, { outline = false, gloss = false, flat = true })
c:fill(arch, "#f5cf6a")
c:fill(c:rect(121, 45, 139, 48):clip(arch), "#e8a317")
-- door leaf swung open to the left
local leaf = c:poly({ { 121, 33 }, { 127, 35 }, { 127, 49 }, { 121, 49 } }):clip(arch)
c:part(leaf, OLIVE, { outline = false, gloss = false })
c:fill(c:rect(123, 37, 124, 40), "#f5cf6a")
c:px(126, 42, "#e8a317")
-- doorstep
c:part(c:rect(117, 48, 160, 50), CREAM, { gloss = false })

-- ginger cat sitting on the step, looking out
local tail = c:line({ { 157, 48 }, { 159, 45 }, { 159, 42 } }, 2)
local body = c:ellipse(151.5, 44.5, 4.5, 4)
local head = c:ellipse(150.5, 37.5, 5.5, 4.5)
local ears = c:poly({ { 145, 35 }, { 146, 30 }, { 149, 34 } }):add(c:poly({ { 152, 34 }, { 155, 30 }, { 156, 35 } }))
c:part(tail, GOLD, { flat = true })
c:part(body, GOLD, { gloss = false })
c:part(ears:add(head), GOLD, { gloss = { 147, 35 } })
c:fill(c:rect(152, 41, 153, 46), "#fff1c8")         -- cream bib
c:px(146, 34, "#e46a9b"); c:px(154, 34, "#e46a9b")  -- inner ears
c:eye(146, 36, true); c:eye(151, 36, true)
c:px(150, 40, "#8a4f2a")
-- stripes on the head
c:px(150, 34, "#c47a52"); c:px(150, 35, "#c47a52"); c:px(148, 34, "#c47a52"); c:px(152, 34, "#c47a52")

-- potted lemon tree on the street, left of the window
c:part(c:rect(73, 34, 74, 43), TERRA, { flat = true })
c:part(c:ellipse(74, 29, 6.5, 6), OLIVE, { gloss = false })
for _, p in ipairs({ { 70, 27 }, { 75, 25 }, { 77, 30 }, { 71, 31 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#e8a317"); c:px(p[1], p[2], "#fff1c8")
end
c:part(c:poly({ { 68, 42 }, { 80, 42 }, { 78, 49 }, { 70, 49 } }), TERRA, { gloss = false })
c:fill(c:rect(68, 43, 79, 43), "#d9885a")

-- sardine crate on the street, right of the step
c:part(c:rect(163, 43, 172, 49), TERRA, { gloss = false })
c:fill(c:rect(163, 46, 172, 46), "#8a4f2a")
for x = 164, 170, 3 do c:fill(c:rect(x, 42, x + 1, 43), "#3f8fb0"); c:px(x, 42, "#c8ecdc") end

---------------------------------------------------------------- hem
c:seam({ { 3, 1 }, { 236, 1 } }, { free = true })
c:seam({ { 3, 58 }, { 236, 58 } }, { free = true })

local t = c:save(OUT .. "banner-SE-pets.aseprite", OUT .. "banner-SE-pets.png")
print(GV.report(t))
