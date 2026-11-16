-- trail-pack-b: Trail Pack, cut b "stitched patch" icon (Opus second pass). 64x64.
-- Base: the game's plain ph/trail-pack.png (pixels unchanged) + a sewn cloth patch on the front pocket, beside the
-- buckle, built like its finished siblings flood-boots-b / work-gloves-b (art-2701-opus/wear): indigo denim with a
-- diagonal twill (so it can only read as woven cloth), a darker turned-under hem, moss-green whip stitches biting into
-- the oat canvas all round, shading lit left / shade right like the pack, and a contact shadow below/right on the
-- canvas. No bevel, no specular (Haiku's patch was a flat blue tile with a gold frame: read as a gem or a screen).
-- quirk: a cream trail-blaze arrow is embroidered on the patch, pointing up the way.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_p.lua")
local px, w, h = O.loadIcon("trail-pack")

local DEN   = { "#5a7ac4", "#4762a8", "#36508c", "#2a3e70" }   -- lit, mid, shade, deep
local TWILL = { "#7a98d8", "#6280c0", "#4a64a2", "#384e86" }
local HEM   = { "#33488a", "#2a3c74", "#22305c" }
local CANVAS_DOWN = { ["#e4d8b0"] = "#c9bb92", ["#c9bb92"] = "#ad9e7a", ["#ad9e7a"] = "#8e7e62", ["#8e7e62"] = "#6c5c4a",
  ["#6c5c4a"] = "#4a3c34", ["#4a3c34"] = "#3a2e2a", ["#efe2c2"] = "#c9bb92", ["#b8a690"] = "#8e7e62" }
local x0, y0, x1, y1 = 38, 43, 48, 52
O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = { ["0,0"] = true, ["10,9"] = true },   -- softly rounded opposite corners (cut cloth, not a tile)
  cloth = function(i, j, z)
    if (i + j) % 3 == 0 then return TWILL[z] end
    if (i - j) % 7 == 0 and j > 1 then return DEN[math.min(4, z + 1)] end   -- faint wale
    return DEN[z]
  end,
  edgeFn = function(i, j, z)
    local d = (j == y1 - y0 or i == x1 - x0) and 1 or 0
    return HEM[math.min(3, z + d)]
  end,
  thread = "#3f9150",
  shadow = function(hx) return CANVAS_DOWN[hx] or hx end,
})
-- quirk: embroidered trail-blaze arrow (cream thread, a shade-side step on its lower-right), pointing up-right
local A = { "#f6ead0", "#d8c8a8" }
local function at(i, j, c) px[(y0 + j) * 64 + x0 + i] = c end
for _, q in ipairs{ { 2, 7 }, { 3, 6 }, { 4, 5 }, { 5, 4 }, { 6, 3 } } do at(q[1], q[2], A[1]) at(q[1] + 1, q[2] + 1, A[2]) end
for _, q in ipairs{ { 4, 2 }, { 5, 2 }, { 6, 2 }, { 7, 2 }, { 7, 3 }, { 7, 4 }, { 7, 5 } } do at(q[1], q[2], A[1]) end
at(4, 3, A[2]) at(5, 3, A[2]) at(8, 3, A[2]) at(8, 4, A[2]) at(8, 5, A[2]) at(8, 6, A[2])
O.saveIcon("trail-pack-b", px, w, h)
