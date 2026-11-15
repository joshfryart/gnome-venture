-- wayfarers-hat-b: Wayfarer's Hat, cut b "Tip Back" (soothe) stitched-patch icon (Opus second pass, art-2701-rest). 64x64.
-- Base: the game's PLAIN ph/wayfarers-hat.png (pixels unchanged). The Haiku pass started from wayfarers-hat-b.png,
-- which still carries the old blue gem block on the brim; the patch now replaces that gem, like the finished siblings
-- (flood-boots-b, work-gloves-b, trail-pack-b, travel-cloak-b all start from the plain base).
-- Patch: a big 11x10 piece of sage corduroy sewn on the lit front of the crown, above the red band: vertical wales
-- (lit rib / dark groove), shading lit left / shade right like the crown, a sun-faded upper-left corner, a darker
-- turned-under hem, gold whip stitches biting into the felt, and a 1-2 px contact shadow on the felt.
-- quirk: a cream crescent moon is embroidered on the patch (a calm "tip your hat back" charm), satin-stitched with a
-- shade side.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_p.lua")
local px, w, h = O.loadIcon("wayfarers-hat")

local CORD = { "#a8d488", "#86ba68", "#64984f" }   -- rib: lit, mid, shade
local GROOVE = { "#7aa85e", "#5a8a48", "#44703c" } -- wale groove: lit, mid, shade
local FADE = { "#c4e2a2", "#a6cc86" }
local HEM = { "#4e7e46", "#3c6a3e", "#2c5234" }
local FELT_DOWN = { ["#c48a5a"] = "#a66a45", ["#a66a45"] = "#8a5239", ["#8a5239"] = "#704033",
  ["#704033"] = "#552f2c", ["#552f2c"] = "#3a2026" }

local x0, y0, x1, y1 = 23, 21, 33, 30
O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = { ["0,0"] = true, ["10,9"] = true },   -- softly rounded opposite corners, cut cloth
  cloth = function(i, j, z)
    local fade = (i + j) <= 2
    if i % 2 == 1 then return fade and FADE[2] or GROOVE[z] end
    return fade and FADE[1] or CORD[z]
  end,
  edgeFn = function(i, j, z)
    local d = (j == y1 - y0 or i == x1 - x0) and 1 or 0
    return HEM[math.min(3, z + d)]
  end,
  thread = "#f5b82e",
  shadow = function(hx) return FELT_DOWN[hx] or hx end,
})
-- second row of contact shadow below the bottom hem
for x = x0 + 1, x1 + 1 do
  local k = (y1 + 2) * 64 + x
  if px[k] and px[k] ~= O.INK and px[k] ~= "#f5b82e" then px[k] = FELT_DOWN[px[k]] or px[k] end
end

-- quirk: embroidered crescent moon (cream satin stitch, shade on its lower-right), centred on the patch
local M = { "#fff0d4", "#e6d4b0", "#c8b48e" }
local function at(i, j, c) px[(y0 + j) * 64 + x0 + i] = c end
local moon = {
  "...ab",
  ".aab.",
  "aab..",
  "aab..",
  "abc..",
  ".bbc.",
  "...cc",
}
for j, row in ipairs(moon) do
  for i = 1, #row do
    local ch = row:sub(i, i)
    if ch ~= "." then at(1 + i, j, ch == "a" and M[1] or (ch == "b" and M[2] or M[3])) end
  end
end
-- a tiny gold cross-stitch star beside the moon
at(7, 3, "#ffe38a") at(8, 4, "#f5b82e") at(7, 4, "#ffe38a") at(6, 4, "#f5b82e") at(7, 5, "#f5b82e")
O.saveIcon("wayfarers-hat-b", px, w, h)
