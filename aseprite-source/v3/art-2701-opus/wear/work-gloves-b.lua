-- work-gloves-b: Work Gloves, cut b "Knuckle Down" icon (Opus pass, art-2701). 64x64.
-- Base: the game's plain work-gloves.png (unchanged pixels), plus a sewn cloth patch across the back of the front glove
-- instead of the old gem-like block: blue-and-cream mattress ticking (vertical stripes, so it reads as woven cloth),
-- a darker turned-under hem, red whip stitches biting into the leather, shading lit left / shade right like the glove,
-- and a contact shadow below/right. No bevel, no specular. quirk: the last stitch has come loose and a red thread
-- tail dangles down over the cuff.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local px, w, h = O.loadIcon("work-gloves")
local CREAM = { "#f4ead2", "#e4d6b8", "#c2b294", "#9c8c72" }
local NAVY  = { "#5a7cc8", "#3e5ca8", "#2e4482", "#243464" }
local DOWN = { ["#f0c98a"] = "#dca566", ["#dca566"] = "#c4864c", ["#c4864c"] = "#a5673a", ["#a5673a"] = "#80492c", ["#80492c"] = "#55301f" }
local x0, y0, x1, y1 = 20, 33, 29, 41
O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = { ["9,8"] = true },
  cloth = function(i, j, z)
    if i % 3 == 1 then return NAVY[z] end
    if i % 3 == 2 and j % 4 == 0 then return CREAM[math.min(3, z + 1)] end   -- slub in the weave
    return CREAM[z]
  end,
  edgeFn = function(i, j, z)   -- turned-under hem: the same stripes, a step darker (two on the bottom/right)
    local d = (j == y1 - y0 or i == x1 - x0) and 2 or 1
    return (i % 3 == 1) and NAVY[math.min(4, z + d)] or CREAM[math.min(4, z + d)]
  end,
  thread = "#d23c3c",
  shadow = function(hx) return DOWN[hx] or hx end,
  noStitch = function(x, y) return x >= x1 - 1 and y >= y1 - 1 end,
})
-- the loose thread: out of the bottom-right corner, down over the cuff seam, ending in a little curl
local T = { "#e8573f", "#8a2a3d" }
for n, q in ipairs{ { 29, 42 }, { 29, 43 }, { 28, 44 }, { 28, 45 }, { 28, 46 }, { 29, 47 }, { 30, 46 } } do
  px[q[2] * 64 + q[1]] = T[(n % 2) + 1]
end
O.saveIcon("work-gloves-b", px, w, h)
