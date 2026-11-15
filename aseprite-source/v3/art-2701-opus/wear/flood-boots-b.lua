-- flood-boots-b: Flood Boots, cut b "Sure Foot" icon (Opus pass, art-2701). 64x64.
-- Base: the game's plain flood-boots.png (unchanged pixels), plus a sewn cloth patch on the front shaft instead of the old
-- gem-like block: red-and-cream gingham (2 px checks, so it can only read as cloth), a darker turned-under hem,
-- gold whip stitches biting into the rubber all round, shading that follows the shaft (lit left, shade right),
-- and a soft contact shadow below/right. No bevel, no specular. quirk: the top-right corner has come unstitched and
-- curls forward (dog-ear showing the plain back of the cloth).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local px, w, h = O.loadIcon("flood-boots")
local CREAM = { "#fbe6cc", "#efd2b6", "#c9ab9c" }
local MID   = { "#f0705a", "#dc4e40", "#b03c48" }
local DARK  = { "#c43c44", "#a3303e", "#7e2a3e" }
local GREEN_DOWN = { ["#9cd27a"] = "#5eab55", ["#5eab55"] = "#3f8a4c", ["#3f8a4c"] = "#2e6b45", ["#2e6b45"] = "#22503f", ["#22503f"] = "#1b3533" }
local x0, y0, x1, y1 = 15, 29, 25, 38
local P = O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = { ["10,0"] = true, ["9,0"] = true, ["8,0"] = true, ["10,1"] = true, ["9,1"] = true, ["10,2"] = true },     -- the lifted corner
  cloth = function(i, j, z)
    local a, b = (i // 2) % 2 == 0, ((j + 1) // 2) % 2 == 0
    if a and b then return DARK[z] elseif a or b then return MID[z] end
    return CREAM[z]
  end,
  edge = { "#a3303e", "#86283d", "#6e2038" },
  thread = "#f5b82e",
  shadow = function(hx) return GREEN_DOWN[hx] or hx end,
  noStitch = function(x, y) return x >= x1 - 3 and y <= y0 + 3 end,   -- the stitches are gone at the torn corner
})
-- dog-ear: the corner folds forward and down over the patch (mirror of the missing corner across the fold),
-- showing the plain back of the cloth: pale fold edge, mid flap, a dark shadow line under its lower edge
local BACK = { "#f2cbb4", "#dca48e", "#b97c70" }
local function at(i, j, c) px[(y0 + j) * 64 + x0 + i] = c end
at(7, 1, BACK[1]) at(8, 2, BACK[1]) at(9, 3, BACK[1])      -- fold edge, catches the light
at(7, 2, BACK[2]) at(8, 3, BACK[2]) at(7, 3, BACK[3])
at(7, 4, "#6e2038") at(8, 4, "#6e2038") at(9, 4, "#86283d") at(10, 4, "#86283d") at(6, 3, "#6e2038") at(6, 2, "#86283d")
-- the base flood-boots water drip now runs onto the patch top: keep it, it ends at the hem
O.saveIcon("flood-boots-b", px, w, h)
