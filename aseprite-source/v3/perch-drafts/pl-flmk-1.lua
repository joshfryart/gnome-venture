-- pl-flmk-1-perch : chibi chef pal on its wooden stump perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flmk-1-perch-20261120-183952/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- ramps: 2-3 tone stops per material, all from the pal's palette (+ its own accents)
local bodyR  = GV.ramp("#d79c84", { shade = "#b7604f", deep = "#7c2028" })          -- body peach
local hatR   = GV.ramp("#dfd1cf", { rim = "#f2eadb", gloss = "#fff6e0", dot = "#fff6e0", shade = "#b8b0cc", deep = "#9890b4", bounce = "#d8d0e0" })
local bandR  = GV.ramp("#f2eadb", { gloss = "#fff6e0", dot = "#fff6e0", rim = "#dfd1cf" })
local sashR  = GV.ramp("#97c8c8", { shade = "#638e9d" })                            -- teal sash
local woodR  = GV.ramp("#9f6b48")                                                   -- stump + paddle handle
local topR   = GV.ramp("#e5d1a7", { rim = "#f0e0b8", shade = "#9f6b48", deep = "#5b3a2c", bounce = "#c9b183" }) -- cut-wood face
local steelR = GV.ramp("#638e9d", { deep = "#514051", rim = "#8fb3c0" })            -- paddle head
local footR  = GV.ramp("#2e3a4a")
local leafR  = GV.ramp("#5fae4a", { rim = "#8fd05a", shade = "#3f8a4a" })           -- herb sprig

-- perch props (behind the chef)
local p = c:build{
  { "handle", c:line({ { 29, 13 }, { 30, 29 } }, 2), woodR, { flat = true, contact = false } },
  { "phead",  c:rrect(26, 8, 31, 14, 2), steelR, { gloss = { 27, 10 } } },
  { "leaf1",  c:rrect(4, 26, 6, 29, 1), leafR, { flat = true, contact = false } },
  { "leaf2",  c:rrect(7, 25, 9, 27, 1), leafR, { flat = true, contact = false } },
}

-- perch: wooden stump
local sideM = c:rrect(11, 25, 24, 31, 2)
local topM  = c:ellipse(17.5, 25.5, 6.5, 1.7)
local q = c:build{
  { "side", sideM, woodR, {} },
  { "top",  topM, topR, { gloss = false, contour = false, contact = false, cres = 1, deep = 1, light = c:mask():add(sideM):add(topM) } },
}

-- chibi chef
local bodyM = c:ellipse(17.5, 15, 7.5, 7)          -- rows 8..22
local hatM  = c:ellipse(17.5, 6.7, 7.5, 4.1)       -- rows 3..11
local r = c:build{
  { "footL", c:rrect(13, 22, 16, 24, 1), footR, { flat = true } },
  { "footR", c:rrect(19, 22, 22, 24, 1), footR, { flat = true } },
  { "body",  bodyM, bodyR, { gloss = false, light = c:mask():add(bodyM):add(hatM) } },
  { "sash",  c:rect(10, 18, 25, 20):clip(bodyM), sashR, { gloss = false, contour = false, light = c:mask():add(bodyM):add(hatM), bounce = false } },
  { "hat",   hatM, hatR, { gloss = { 12, 4 }, contour = false } },
  { "band",  c:rect(12, 11, 23, 12), bandR, { flat = true, contour = false } },
}

c:ground(17.5, 31, 11.5, 1.2, "#514051")

-- texture: hand-placed, subtle, ≤1 tone step, following the form
-- body: dither the terminator + sparse mottling (pal's smooth radish skin)
c:px(21, 15, "#c87a55") c:px(22, 14, "#c87a55") c:px(22, 17, "#c87a55") c:px(21, 16, "#c87a55")
c:px(14, 16, "#dbbf91") c:px(16, 19, "#dbbf91")
-- hat: 1px dither into the light side of the puff's right shade
c:px(22, 6, "#d8d0e0") c:px(21, 7, "#9890b4")
-- stump: vertical grain dashes + dither at the bounce edge
c:px(15, 29, "#835a3b") c:px(15, 30, "#835a3b") c:px(20, 29, "#835a3b") c:px(20, 28, "#835a3b")
c:px(16, 28, "#bca76c") c:px(13, 30, "#bca76c")
-- cut face: two short grain dashes
c:px(14, 26, "#9f6b48") c:px(15, 26, "#9f6b48") c:px(20, 27, "#9f6b48") c:px(21, 27, "#9f6b48")
-- sprig: shade px under leaf tips
c:px(8, 27, "#3f8a4a") c:px(5, 29, "#3f8a4a")
-- critique: break the hard deep band at the stump foot; break the sash rim streak at its right end
c:px(14, 31, "#9f6b48") c:px(19, 31, "#9f6b48")
c:px(21, 18, "#97c8c8")

-- detail: the pal's face — dark bean eyes wide-set with a cream glint, tiny mouth
for _, e in ipairs({ 13, 20 }) do
  for j = 14, 16 do for i = 0, 1 do c:px(e + i, j, "#2b1c26") end end
  c:px(e, 14, "#fff6e0") -- glint inside the top-left
end
c:px(17, 17, "#2b1c26") c:px(18, 17, "#2b1c26")

local t = c:save(D .. "out/pl-flmk-1-perch.aseprite", D .. "out/pl-flmk-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
