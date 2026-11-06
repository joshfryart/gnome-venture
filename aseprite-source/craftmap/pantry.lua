-- pantry.lua : crafting-area map tile "pantry" (claude/craftmap-art-brief.md), 64x64, gvlib "icon" mode,
-- Stitched Toy (art-style-guide Part D). Subject: a glass jar of plum jam with a gingham cloth lid tied with
-- gold twine and a bow. Dominant colour plum/purple.
-- Run: AppRun -b --script pantry.lua      Writes out/pantry.png + out/pantry.aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/out/"

-- felt(hex): gvlib ramp with deep = shade and bounce = base (house look from cf_icons.lua)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
local function onPart(c, m, P, hex, from)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and (from == nil or from[c:get(x, y)]) then c:px(x, y, hex) end
  end)
end

local PLUM = felt("#8e3a86", { gloss = "#f0b8e0", dot = "#f0b8e0", rim = "#b862a8", shade = "#5e2468" })
local JAM = felt("#6a1f5e", { gloss = "#e88ac0", dot = "#e88ac0", rim = "#9a3a86", shade = "#44143f" })
local GLASS = felt("#bcd8e4", { gloss = "#f2fbf6", dot = "#f2fbf6", rim = "#e2f2f2", shade = "#8aa8c4", pale = false })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local CHECK_LT = "#e6c2dc"   -- gingham cream-lilac squares

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- shapes
local jar = c:rrect(13, 25, 50, 55, 6)
local neck = c:rrect(17, 19, 46, 27, 2)
local jam = c:rrect(16, 31, 47, 52, 4)
-- cloth: domed top over the neck, then a skirt with pointed corners hanging over the shoulders
local cloth = c:ellipse(31.5, 16, 17, 9):cut(c:rect(0, 17, 63, 63))
cloth:add(c:poly({ {14, 16}, {50, 16}, {55, 34}, {47, 29}, {40, 33}, {32, 29}, {24, 33}, {17, 29}, {9, 34} }))
local twine = c:rect(14, 21, 49, 23)
local loopL = c:ellipse(24.5, 20, 5.5, 3.5)
local loopR = c:ellipse(38.5, 20, 5.5, 3.5)
local knot = c:rrect(29, 19, 34, 24, 1)
local tails = c:line({ {30, 24}, {25, 35} }, 3):add(c:line({ {33, 24}, {38, 35} }, 3))

local p = c:build{
  { "jar",   jar:add(neck), GLASS, { cres = 4, gloss = false } },
  { "jam",   jam, JAM, { cres = 4, gloss = false, contact = false } },
  { "cloth", cloth, PLUM, { cres = 4, gloss = false } },
  { "twine", twine, GOLD, { cres = 1, gloss = false, contact = false } },
  { "tails", tails, GOLD, { flat = true, contact = false } },
  { "loopL", loopL, GOLD, { cres = 2, gloss = false } },
  { "loopR", loopR, GOLD, { cres = 2, gloss = false } },
  { "knot",  knot, GOLD, { cres = 2, gloss = false } },
}

-- bow loop holes
c:paint({ "uu", "uu" }, 23, 19, { u = "ol2" }); c:paint({ "uu", "uu" }, 39, 19, { u = "ol2" })
-- gingham: 3 px bands; where two plum bands cross -> shade, no band -> light check
local base = { [PLUM.base] = true }
cloth:each(function(x, y)
  local bx, by = (x // 3) % 2 == 0, ((y + 1) // 3) % 2 == 0
  local k = c:key(x, y)
  if c.own[k] == p.cloth and c:get(x, y) == PLUM.base then
    if bx and by then c:px(x, y, PLUM.shade) elseif not bx and not by then c:px(x, y, CHECK_LT) end
  end
end)
-- (no hem seam: the gold twine and bow are the thread accent; a hem seam muddied the bow tails)

-- glass: tall glint stripes on the lit left, short ones on the right, rim line at the neck
c:paint({ "gg", "g.", "g.", "g.", "g.", "g.", "g.", "g.", "g.", "g.", "g." }, 14, 36, { g = GLASS.gloss })
c:paint({ "g", "g", "g" }, 18, 44, { g = JAM.gloss })
-- jam: seeds and a gloss comma
c:paint({
  "..ggg",
  ".gg..",
  "gg...",
  "g....",
}, 19, 36, { g = JAM.gloss })
for _, q in ipairs({ {30, 40}, {38, 37}, {35, 46}, {26, 49}, {42, 44} }) do c:px(q[1], q[2], JAM.rim) end
-- cloth gloss on the dome
c:paint({ "..gg", "gg..", "g..." }, 19, 9, { g = PLUM.gloss })

local t = c:save(OUT .. "pantry.aseprite", OUT .. "pantry.png")
print("pantry " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3, "pantry check failed")
