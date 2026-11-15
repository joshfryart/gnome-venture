-- travel-cloak-b: Travel Cloak, cut b "stitched patch" icon (Opus second pass). 64x64.
-- Base: the game's plain ph/travel-cloak.png (folded moss-wool cloak, pixels unchanged) + a sewn cloth patch on the
-- upper right panel, sewn across the lapel edge, built like its finished siblings flood-boots-b / work-gloves-b:
-- a mustard-and-rust tartan (crossing over-checks, so it reads as woven wool at once), a darker turned-under hem,
-- cream whip stitches biting into the green wool, shading lit left / shade right, and a contact shadow below/right
-- on the cloak. No bevel, no specular (Haiku's patch was a violet tile with a gold button: read as a gem).
-- quirk: a little clothes moth sits on the patch's top corner, looking very pleased with itself (it made the hole).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_p.lua")
local px, w, h = O.loadIcon("travel-cloak")

local GOLD = { "#f2c24e", "#dca23a", "#b67e2c" }   -- lit, mid, shade
local RUST = { "#d0583a", "#b4442f", "#8e3428" }
local DARK = { "#5a3a2a", "#4a2e24", "#3a221e" }
local HEM  = { "#a8702a", "#8a5822", "#6e421c" }
local WOOL_DOWN = { ["#86b464"] = "#5e9452", ["#5e9452"] = "#45784b", ["#45784b"] = "#335f43", ["#335f43"] = "#264a3c",
  ["#264a3c"] = "#1c3530", ["#1c3530"] = "#16282a", ["#e6bd7e"] = "#b07a46", ["#b07a46"] = "#9e6239", ["#dca266"] = "#b07a46" }
local x0, y0, x1, y1 = 40, 21, 50, 29
O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = { ["0,8"] = true },
  cloth = function(i, j, z)
    local vi, hj = (i % 5 == 2), (j % 5 == 2)
    if vi and hj then return DARK[z] end
    if vi or hj then return ((i + j) % 2 == 0) and RUST[z] or DARK[z] end
    if (i % 5 == 4) or (j % 5 == 4) then return RUST[z] end
    return GOLD[z]
  end,
  edgeFn = function(i, j, z)
    local d = (j == y1 - y0 or i == x1 - x0) and 1 or 0
    return HEM[math.min(3, z + d)]
  end,
  thread = "#f2e2c0",
  shadow = function(hx) return WOOL_DOWN[hx] or hx end,
})
-- quirk: a clothes moth perched on the top-right corner of the patch, wings spread, poking past the cloak's edge
local base = {}
for k in pairs(px) do base[k] = true end
local M = { w1 = "#e8d6b0", w2 = "#c4aa82", w3 = "#8e7458", b = "#5e4636", e = "#2b1c26", a = "#5e4636" }
O.paint(px, {
  "a.....a",
  ".a.b.a.",
  "11bbb11",
  "121b121",
  "221b122",
  ".2.b.2.",
  "...3...",
}, 48, 14, { a = M.a, b = M.b, ["1"] = M.w1, ["2"] = M.w2, ["3"] = M.w3 })
px[16 * 64 + 51] = M.e   -- tiny eye glint row: dark head
-- ink ring only around the moth pixels that stick out into empty space
local ring = {}
for k, hx in pairs(px) do
  if not base[k] then
    local x, y = k % 64, k // 64
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local nk = (y + d[2]) * 64 + x + d[1]
      if not px[nk] then ring[nk] = true end
    end
  end
end
for k in pairs(ring) do px[k] = O.INK end
O.saveIcon("travel-cloak-b", px, w, h)
