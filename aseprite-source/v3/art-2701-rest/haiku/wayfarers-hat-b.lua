-- wayfarers-hat-b: Wayfarer's Hat, cut b "stitched patch" icon (Haiku first pass, art-2701-rest). 64x64.
-- Base: the game's plain ph/wayfarers-hat-b.png (pixels unchanged) + a sewn cloth patch on the brown crown, above the red band,
-- built like its siblings (flood-boots-b, work-gloves-b): moss-green and cream 3 px check, a dark hem turned under the
-- patch, gold whip stitches biting into the felt. Shading follows the crown (lit left, shade right) and a 1 px contact shadow.
-- quirk: a small gold star is embroidered in the middle of the patch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_p.lua")
local px, w, h = O.loadIcon("wayfarers-hat-b")

local GREEN = { "#9cd27a", "#7cc35a", "#5eab55" }   -- lit, mid, shade (moss)
local CREAM = { "#fff4d6", "#f6e6c2", "#e4d8b0" }
local HEM   = { "#3f9150", "#2e6b45", "#22503f" }
local FELT_DOWN = { ["#a66a45"] = "#8a5239", ["#8a5239"] = "#704033", ["#704033"] = "#552f2c",
  ["#c48a5a"] = "#a66a45", ["#552f2c"] = "#3a2026", ["#a66a45"] = "#8a5239" }

local x0, y0, x1, y1 = 23, 22, 31, 30
O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = { ["0,0"] = true, ["8,0"] = true, ["0,8"] = true, ["8,8"] = true },   -- rounded corners, cut cloth
  cloth = function(i, j, z)
    if ((i // 3) + (j // 3)) % 2 == 0 then return GREEN[z] end
    return CREAM[z]
  end,
  edgeFn = function(i, j, z) return HEM[math.min(3, z + ((j == y1 - y0 or i == x1 - x0) and 1 or 0))] end,
  thread = "#f5b82e",
  shadow = function(hx) return FELT_DOWN[hx] or hx end,
})
-- quirk: embroidered gold star in the centre of the patch
local cx, cy = x0 + 4, y0 + 4
for _, p in ipairs{ { 0, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, 1 } } do
  px[(cy + p[2]) * 64 + cx + p[1]] = "#ffe38a"
end
px[(cy - 1) * 64 + cx - 1] = "#fff4d6"
O.saveIcon("wayfarers-hat-b", px, w, h)
