-- travel-cloak-b: Travel Cloak, cut b "stitched patch" icon (Opus third pass, richness). 64x64.
-- Base: the game's plain ph/travel-cloak.png (folded moss-wool cloak, pixels unchanged) + a sewn tartan patch,
-- built like its finished siblings flood-boots-b / work-gloves-b.
-- Third pass: the patch moved right onto the cloak's right panel, so it no longer covers the brown lapel marks;
-- the drawstring cord is laid back on top of its corner (patch under the cord, real depth); the tartan gets a fine
-- 1 px weft line between the over-checks and a sun-faded lit corner; cream whip stitches, darker hem, contact shadow.
-- quirk (fixed, it was a pale speck): a big, fully outlined clothes moth with spread tan wings, eye-spots, a fuzzy
-- body and feathery antennae perches on the patch's top corner, half off the cloak's edge; next to it a fresh
-- nibbled hole in the wool shows it is still hungry.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_p.lua")
local px, w, h = O.loadIcon("travel-cloak")

local GOLD = { "#f2c24e", "#dca23a", "#b67e2c" }   -- lit, mid, shade
local GLT  = { "#ffd870", "#f2c24e", "#dca23a" }   -- sun-faded corner
local RUST = { "#d0583a", "#b4442f", "#8e3428" }
local DARK = { "#5a3a2a", "#4a2e24", "#3a221e" }
local HEM  = { "#a8702a", "#8a5822", "#6e421c" }
local WOOL_DOWN = { ["#86b464"] = "#5e9452", ["#5e9452"] = "#45784b", ["#45784b"] = "#335f43", ["#335f43"] = "#264a3c",
  ["#264a3c"] = "#1c3530", ["#1c3530"] = "#16282a", ["#e6bd7e"] = "#b07a46", ["#b07a46"] = "#9e6239", ["#dca266"] = "#b07a46" }
local WOOL = { ["#86b464"] = true, ["#5e9452"] = true, ["#45784b"] = true, ["#335f43"] = true, ["#264a3c"] = true }

local x0, y0, x1, y1 = 44, 22, 54, 30
-- leave off cells outside the cloak or on its outline; remember the drawstring cord pixels to lay back on top
local CORD = { ["#e6bd7e"] = true, ["#b07a46"] = true, ["#1c3530"] = true }
local skip, cord = {}, {}
for y = y0, y1 do for x = x0, x1 do
  local hx = px[y * 64 + x]
  if not hx or hx == O.INK or (x >= x1 - 1 and not WOOL[hx]) then skip[(x - x0) .. "," .. (y - y0)] = true end
  if hx and CORD[hx] and x < x0 + 4 then cord[y * 64 + x] = hx end
end end
for y = y0, y1 do for x = x0, x1 do
  local k = y * 64 + x
  if not px[k + 1] or px[k + 1] == O.INK then for xx = x, x1 do skip[(xx - x0) .. "," .. (y - y0)] = true end end
end end

O.patch(px, {
  x0 = x0, y0 = y0, x1 = x1, y1 = y1,
  skip = skip,
  cloth = function(i, j, z)
    local vi, hj = (i % 4 == 1), (j % 4 == 1)
    if vi and hj then return DARK[z] end
    if vi or hj then return RUST[z] end
    if (i % 4 == 3) and (j % 2 == 0) then return GOLD[math.min(3, z + 1)] end   -- fine weft line
    if (j % 4 == 3) and (i % 2 == 1) then return GOLD[math.min(3, z + 1)] end
    if i + j <= 3 then return GLT[z] end
    return GOLD[z]
  end,
  edgeFn = function(i, j, z)
    local d = (j == y1 - y0 or i == x1 - x0) and 1 or 0
    return HEM[math.min(3, z + d)]
  end,
  thread = "#f2e2c0",
  shadow = function(hx) return WOOL_DOWN[hx] or hx end,
})

-- the drawstring cord lies on top of the patch: lay its pixels back over the cloth (and its stitches)
for k, hx in pairs(cord) do px[k] = hx end

-- a fresh nibbled hole in the wool on the middle fold, with a frayed pale lip
O.paint(px, { ".ll.", "lhhl", "lhhh", ".hl." }, 38, 35, { l = "#86b464", h = "#16282a" })

-- quirk: a clothes moth perched on the patch's top corner, half off the cloak's edge
local M = {
  ["1"] = "#efdcb4", ["2"] = "#cdb07e", ["3"] = "#9e7e5a", s = "#6e5240",
  b = "#806048", h = "#5e4636", e = "#2b1c26", f = "#7a5a44", g = "#fff4d6",
}
local rows = {
  "..f.....f..",
  "...f...f...",
  "1112hgh2111",
  "12s22b22s21",
  ".12223222 1",
  "..123b321..",
  "...3.b.3...",
}
rows[5] = ".1222b2221."
local mx, my = 47, 16
local moth = {}
for j, row in ipairs(rows) do for i = 1, #row do
  local ch = row:sub(i, i)
  if M[ch] then local k = (my + j - 1) * 64 + mx + i - 1 px[k] = M[ch] moth[k] = true end
end end
-- feathery antenna tips
px[(my) * 64 + mx + 1] = M.f moth[(my) * 64 + mx + 1] = true
px[(my) * 64 + mx + 9] = M.f moth[(my) * 64 + mx + 9] = true
-- full ink ring round the moth (over wool and over empty space) so it reads as its own little creature
local ring = {}
for k in pairs(moth) do
  local x, y = k % 64, k // 64
  for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    local nk = (y + d[2]) * 64 + x + d[1]
    if not moth[nk] then ring[nk] = true end
  end
end
for k in pairs(ring) do px[k] = O.INK end
O.saveIcon("travel-cloak-b", px, w, h)
