-- cf_test.lua : Cat Fish test art, pass 2 (grey cat idle A, plain plushie fish, cat wand rod).
-- Run: AppRun -b --script cf_test.lua      (Stitched Toy, art-style-guide Part D, via gvlib)
--
-- GREY CAT TEMPLATE TONES (the recolour script tools/catfish_recolor.py maps exactly these 4 hex values):
--   shade  #6c6680   crescent, deep, contact shadow, toe lines
--   base   #9c98a6   body felt, bounce line
--   light  #c8c4cc   rim, muzzle pads, belly patch, chest
--   gloss  #eee8e0   enamel comma and dot
-- Everything else on the cat is a FIXED accent and is never recoloured:
--   pink #e8909e / #c66a80 (nose, inner ear), eye cream #f2e4c0, umber #2a1a10 #4a2c1a #74462a,
--   thread gold #f5cf6a #e8a317, button hole #8a4a1c, border #000000.
-- Parts stay separate (tail, earL, earR, body, head, paws) so folded ears and bobtail can replace them later.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

local GREY = { shade = "#6c6680", base = "#9c98a6", light = "#c8c4cc", gloss = "#eee8e0" }
local function coat(t) -- 4-tone ramp in gvlib's 7 slots
  return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base }
end
local PINK, PINKS = "#e8909e", "#c66a80"

-- recolour pixels of `from` inside mask m to `to` (keeps the crescent and contours intact)
local function tint(c, m, from, to)
  m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end)
end

-- ===== cat body, grey template, idle A (64x64 sticker) =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local head = c:ellipse(31.5, 22.5, 14.5, 10):add(c:ellipse(31.5, 26, 15.5, 7.5))
  local earL = c:poly({ {17, 23}, {19, 8}, {30, 13} }):grow(1)
  local earR = c:poly({ {33, 13}, {44, 8}, {46, 23} }):grow(1)
  local body = c:ellipse(31.5, 47, 16.5, 9):add(c:ellipse(31.5, 43, 13, 8))
  local tail = c:line({ {45, 53}, {50, 52}, {53, 48}, {54, 42}, {52, 37} }, 5)
  c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { stitch = { side = "lit" }, gloss = { 17, 43 } } },
    { "earL", earL, g, { cres = 2, gloss = false } },
    { "earR", earR, g, { cres = 2, gloss = false } },
    { "head", head, g, { gloss = { 21, 15 } } },
  }
  -- inner ears (pink, only where the ear shows)
  c:fill(c:poly({ {20, 20}, {21, 11}, {28, 14} }):cut(head), PINK)
  c:fill(c:poly({ {35, 14}, {42, 11}, {43, 20} }):cut(head), PINK)
  -- belly patch (light tone on the lit felt only), then paws on top
  tint(c, c:ellipse(31.5, 47, 7, 6.5):cut(head:grow(1)), GREY.base, GREY.light)
  local pawL = c:ellipse(25, 54, 5, 2.5)
  local pawR = c:ellipse(38, 54, 5, 2.5)
  c:part(pawL, g, { flat = true }); c:part(pawR, g, { flat = true })
  c:paint({ "s.s", "s.s" }, 24, 55, { s = GREY.shade })                    -- toe lines
  c:paint({ "s.s", "s.s" }, 37, 55, { s = GREY.shade })
  -- belly seam with a button at its head (front join of the two body halves)
  c:button(30, 36)
  c:seam({ { 31, 40 }, { 31, 50 } })
  -- face: muzzle, nose, mouth, locked eyes set wide
  c:fill(c:ellipse(31.5, 30, 3.5, 1.5), GREY.light)
  c:paint({ ".pppp.", "..qq.." }, 29, 27, { p = PINK, q = PINKS })
  c:paint({ "u.uu.u", ".u..u." }, 29, 29, { u = "ol1" })
  c:eye(20, 21); c:eye(39, 21)
  local t = c:save(OUT .. "cf-cat-grey-idleA.aseprite", OUT .. "cf-cat-grey-idleA.png")
  print("cat  " .. GV.report(t))
end

-- ===== plain plushie fish (48x48 sticker) =====
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = GV.ramp("#e0872a", { gloss = "#ffc27a", dot = "#fff1c8" }) -- gloss kept clear of thread gold
  local fin = GV.ramp("#f2c14e")
  local body = c:ellipse(20, 24, 13, 9)
  c:build{
    { "tail", c:poly({ {29, 24}, {39, 14}, {41, 19}, {38, 24}, {41, 29}, {39, 34} }), fin, { cres = 2 } },
    { "fin",  c:poly({ {13, 18}, {17, 11}, {24, 11}, {28, 18} }), fin, { cres = 2, gloss = false } },
    { "body", body, f, { stitch = { side = "lit" }, gloss = { 20, 17 } } },
  }
  tint(c, c:ellipse(19, 31, 9, 3), f.base, "#f4b46a")                                      -- belly
  c:paint({ "s.s", ".s." }, 20, 21, { s = f.shade })                                       -- scale stitches
  c:paint({ "s.s", ".s." }, 25, 19, { s = f.shade })
  c:paint({ "s.s", ".s." }, 25, 25, { s = f.shade })
  c:paint({ "s.s", ".s." }, 30, 22, { s = f.shade })
  c:seam({ { 14, 16 }, { 16, 19 }, { 17, 23 }, { 16, 28 }, { 14, 31 } })                              -- gill seam
  c:eye(9, 19)
  c:paint({ "uu", "u." }, 8, 27, { u = "ol2" })                                            -- mouth
  local t = c:save(OUT .. "cf-fish-1.aseprite", OUT .. "cf-fish-1.png")
  print("fish " .. GV.report(t))
end

-- ===== cat wand rod (48x64 sticker). String is drawn in code from the eye-loop at the tip. =====
-- Axis runs (35,11) -> (15,51), slope 1:2. Eye-loop hole at (35,9): attach the string there.
do
  local c = GV.canvas{ w = 48, h = 64, mode = "sticker" }
  local function quad(ax, ay, bx, by, hw) -- capsule-ish band along the axis, half width hw
    local nx, ny = 2 / math.sqrt(5) * hw, 1 / math.sqrt(5) * hw
    return c:poly({ {ax - nx, ay - ny}, {ax + nx, ay + ny}, {bx + nx, by + ny}, {bx - nx, by - ny} })
  end
  local loop  = c:ellipse(35, 9, 2.5):cut(c:rect(34, 8, 36, 10))
  local stick = c:line({ { 34, 13 }, { 21, 39 } }, 3)
  local grip  = quad(22, 36, 16.5, 47, 3.2):shrink(1):grow(1)
  local pom   = c:ellipse(14.5, 50.5, 3.5)
  local bowL  = c:ellipse(28, 16, 2.5, 2)
  local bowR  = c:ellipse(36, 20, 2.5, 2)
  c:build{
    { "loop",  loop, "gold", { flat = true } },
    { "stick", stick, "wood", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "bowL",  bowL, "water", { flat = true } },
    { "bowR",  bowR, "water", { flat = true } },
    { "tailL", c:line({ { 31, 19 }, { 29, 22 }, { 29, 24 } }, 2), "water", { flat = true } },
    { "tailR", c:line({ { 33, 20 }, { 34, 23 }, { 36, 25 } }, 2), "water", { flat = true } },
    { "knot",  c:rect(31, 17, 33, 19), "water", { flat = true } },
    { "grip",  grip, "red", { cres = 2, stitch = { side = "lit" }, gloss = { 19, 40 } } },
    { "pom",   pom, "red", { cres = 2 } },
  }
  c:seam({ { 19, 35 }, { 25, 38 } })                                                       -- grip hem
  local t = c:save(OUT .. "cf-rod.aseprite", OUT .. "cf-rod.png")
  print("rod  " .. GV.report(t))
end
