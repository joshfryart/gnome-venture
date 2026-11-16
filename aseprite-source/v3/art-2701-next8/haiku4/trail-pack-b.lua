-- trail-pack-b: Trail Pack, cut b "stitched patch" icon (Opus third pass, richness). 64x64.
-- Base: the game's plain ph/trail-pack.png (pixels unchanged) + a sewn indigo denim patch on the front pocket, beside
-- the buckle, built like its finished siblings flood-boots-b / work-gloves-b (art-2701-opus/wear).
-- Third pass: the patch is bigger (11x12, the whole pocket face right of the strap) so it reads at 16 px; the whip
-- stitches are brick-red thread (they were low-contrast moss green on the oat canvas); the denim gets a real 2/1
-- twill, a sun-faded worn patch on its lit upper-left, a frayed top edge with three loose pale threads, and a 2 px
-- contact shadow on the canvas.
-- quirk: a bold cream trail-blaze arrow is embroidered on the patch, pointing up the way, with one loose end of
-- thread left dangling from its tail.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_p.lua")
local px, w, h = O.loadIcon("trail-pack")

local DEN   = { "#5a7ac4", "#4762a8", "#36508c", "#2a3e70" }   -- lit, mid, shade, deep
local TWILL = { "#7a98d8", "#6280c0", "#4a64a2", "#384e86" }
local FADE  = { "#8aa6dc", "#7290cc", "#5a78b4" }
local HEM   = { "#33488a", "#2a3c74", "#22305c" }
local CANVAS_DOWN = { ["#e4d8b0"] = "#c9bb92", ["#c9bb92"] = "#ad9e7a", ["#ad9e7a"] = "#8e7e62", ["#8e7e62"] = "#6c5c4a",
  ["#6c5c4a"] = "#4a3c34", ["#4a3c34"] = "#3a2e2a", ["#efe2c2"] = "#c9bb92", ["#b8a690"] = "#8e7e62",
  ["#a0601e"] = "#6e3a1c", ["#d98322"] = "#a0601e", ["#f5b82e"] = "#d98322" }
local x0, y0, x1, y1 = 37, 43, 47, 54
O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = { ["0,0"] = true, ["10,11"] = true },   -- softly rounded opposite corners (cut cloth, not a tile)
  cloth = function(i, j, z)
    local fade = (i + j) <= 4 and i >= 1 and j >= 1
    if (i + j) % 3 == 0 then return fade and FADE[1] or TWILL[z] end
    if fade then return FADE[2] end
    if (i - j) % 7 == 0 and j > 1 then return DEN[math.min(4, z + 1)] end   -- faint wale
    return DEN[z]
  end,
  edgeFn = function(i, j, z)
    local d = (j == y1 - y0 or i == x1 - x0) and 1 or 0
    if j == 0 and i % 3 == 1 then return FADE[3] end   -- frayed top edge, threads showing
    return HEM[math.min(3, z + d)]
  end,
  thread = "#b8322c",
  shadow = function(hx) return CANVAS_DOWN[hx] or hx end,
})
-- second row of contact shadow (2 px deep below the bottom hem)
for x = x0 + 1, x1 + 1 do
  local k = (y1 + 2) * 64 + x
  if px[k] and px[k] ~= O.INK and px[k] ~= "#b8322c" then px[k] = CANVAS_DOWN[px[k]] or px[k] end
end
-- frayed threads poking up from the top edge
for _, x in ipairs{ x0 + 2, x0 + 5, x0 + 8 } do
  local k = (y0 - 1) * 64 + x
  if px[k] and px[k] ~= O.INK then px[k] = "#9ab4e4" end
end
-- quirk: embroidered trail-blaze arrow pointing up (cream satin stitch, a shade step on its right side)
local A = { "#fff0d4", "#e2d0ae", "#c4b08c" }
local function at(i, j, c) px[(y0 + j) * 64 + x0 + i] = c end
-- head
at(5, 2, A[1])
at(4, 3, A[1]) at(5, 3, A[1]) at(6, 3, A[2])
at(3, 4, A[1]) at(4, 4, A[1]) at(5, 4, A[1]) at(6, 4, A[2]) at(7, 4, A[2])
at(2, 5, A[1]) at(3, 5, A[1]) at(4, 5, A[1]) at(5, 5, A[1]) at(6, 5, A[2]) at(7, 5, A[2]) at(8, 5, A[3])
-- shaft (2 px: lit left, shade right) and the satin stitch lines
for j = 6, 9 do at(4, j, A[1]) at(5, j, A[2]) end
at(4, 8, A[2])
-- loose thread end dangling from the tail
at(5, 10, A[3]) at(6, 11, A[3])
O.saveIcon("trail-pack-b", px, w, h)
