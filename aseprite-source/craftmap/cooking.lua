-- cooking.lua : crafting area map tile "cooking" (claude/craftmap-art-brief.md), 64x64 gvlib "icon" mode,
-- Stitched Toy (art-style-guide Part D). Dominant colour red/orange.
-- Subject: a round red-enamel cast-iron stew pot with dark iron rim and lug handles, sitting on a tiny
-- flame, a wooden spoon standing in the stew and a cream steam curl rising.
-- Run: AppRun -b --script cooking.lua      Writes out/cooking.png + out/cooking.aseprite.
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
-- rotated ellipse mask, angle a in radians (screen coords, y down)
local function rell(c, cx, cy, rx, ry, a)
  local m, ca, sa, R = c:mask(), math.cos(a), math.sin(a), math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do
    for x = math.floor(cx - R), math.ceil(cx + R) do
      local dx, dy = x - cx, y - cy
      local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end

local RED = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a", shade = "#ae2a2a" })
local IRON = felt("#4e5262", { gloss = "#b8c0d0", dot = "#b8c0d0", rim = "#767c90", shade = "#34343f" })
local STEW = felt("#e0701f", { gloss = "#ffc27a", dot = "#ffc27a", rim = "#f08a24", shade = "#b8452f" })
local WOOD = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
local FIRE = felt("#f08a24", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", shade = "#e0501f" })
local STEAM = felt("#f1ece0", { gloss = "#fff3c8", dot = "#ffffff", rim = "#fff3c8", shade = "#c9b89a" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- shapes
local steam = c:line({ {24, 21}, {20, 18}, {19, 15}, {21, 12}, {24, 10}, {25, 8}, {24, 7} }, 3)
local spoonBowl = rell(c, 46.5, 13.5, 6, 4.2, -0.85)
local spoonStem = c:line({ {43, 17}, {35, 26} }, 3)
local rimBack = c:ellipse(31.5, 24, 21, 5.5)
local stew = c:ellipse(31.5, 23.5, 17, 3)
local body = c:rrect(12, 26, 51, 43, 7)
local lip = c:rrect(10, 26, 53, 30, 2)
local lugL = c:rrect(7, 28, 12, 34, 2)
local lugR = c:rrect(51, 28, 56, 34, 2)
local flame = c:rrect(22, 51, 41, 55, 2)
flame:add(c:poly({ {21, 54}, {21, 48}, {24, 44}, {28, 52} }))                       -- left tongue
flame:add(c:poly({ {27, 53}, {29, 46}, {32, 41}, {35, 46}, {37, 53} }))              -- tall middle tongue
flame:add(c:poly({ {36, 52}, {40, 44}, {43, 48}, {43, 54} }))                        -- right tongue

c:build{
  { "flame", flame, FIRE, { cres = 2, gloss = false, bounce = false } },
  { "steam", steam, STEAM, { cres = 1, deep = 0, gloss = false, bounce = false } },
  { "rimBack", rimBack, IRON, { cres = 2, gloss = false } },
  { "stew", stew, STEW, { cres = 1, gloss = false, bounce = false, contact = false } },
  { "spoonStem", spoonStem, WOOD, { cres = 1, deep = 0, gloss = false } },
  { "spoonBowl", spoonBowl, WOOD, { cres = 2, gloss = false } },
  { "lugL", lugL, IRON, { cres = 2, gloss = false } },
  { "lugR", lugR, IRON, { cres = 2, gloss = false } },
  { "body", body, RED, { cres = 5, gloss = { 16, 33 } } },
  { "lip", lip, IRON, { cres = 2, gloss = false } },
}

-- stew bits: carrot and herb flecks
c:px(25, 23, STEW.shade); c:px(26, 23, STEW.shade); c:px(31, 22, STEW.gloss); c:px(32, 22, STEW.gloss)
c:px(38, 24, STEW.shade); c:px(39, 24, STEW.shade)
-- gold seam round the belly band, button at its head
c:seam({ { 14, 35 }, { 49, 35 } }, { gap = RED.shade })
c:button(29, 37)
-- glints
c:paint({ "gg", "g." }, 43, 11, { g = WOOD.gloss })
c:paint({ "ggg" }, 13, 27, { g = IRON.gloss })
c:paint({ ".y.", "yyy", "yyy" }, 31, 49, { y = FIRE.rim })                         -- flame core
c:paint({ "y", "y" }, 23, 49, { y = FIRE.rim }); c:paint({ "y", "y" }, 40, 49, { y = FIRE.rim })
c:paint({                                                                            -- enamel comma
  "...ggdd",
  ".ggdd..",
  "gdd....",
  "gd.....",
  "g......",
}, 15, 31, { g = RED.gloss, d = RED.dot })

local t = c:save(OUT .. "cooking.aseprite", OUT .. "cooking.png")
print("cooking  " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3, "check failed")
