-- _o5.lua: helpers for the Opus redraw of the cut-b Travel Cloak family (batch5, opus3), 64x64.
-- Reuses (read only) ../../../art-2701-batch4b/wear/opus2/_o4.lua (load, get, px, paint, reink, save4).
-- O.texture(img): the opus3 cloak family texture (twill fleck, rim light, teal bounce), same rules as
--   art-2701-batch3/wear/opus3/travel-cloak-fine.lua, so the base cut-b matches its Lined/Fine.
-- O.patchB(img): the cut-b mark: a stitched tartan patch on the shaded right skirt, its contact shadow,
--   and the quirk: a moth-nibbled hole in the lit left skirt with the culprit moth fluttering off the edge.
-- O.cutb(): returns baseT (base + texture) and baseB (baseT + patch) built from the hanging Opus cloak.
-- O.graftB(img): pastes every pixel where baseB differs from baseT (patch, shadow, hole, moth) onto img.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/../../../art-2701-batch4b/wear/opus2/_o4.lua")
O.DIR5 = DIR
O.OUT = (app.params and app.params.out) or (DIR .. "/")
O.BASE = O.V3 .. "/art-2701-opus/wear/travel-cloak.png"

function O.texture(img)
  local UP = { ["#5e9452"] = "#6a9e58", ["#45784b"] = "#507f50", ["#335f43"] = "#3c6a48", ["#264a3c"] = "#2d5442" }
  O.each(img, 4, 13, 58, 58, function(x, y, h)
    if UP[h] and (x - y * 2) % 5 == 0 and y % 2 == 0 then return UP[h] end
  end)
  local function rim(side, hex, only, box)
    local d = ({ left = { -1, 0 }, top = { 0, -1 }, right = { 1, 0 }, bottom = { 0, 1 } })[side]
    local pts = {}
    for y = box[2], box[4] do for x = box[1], box[3] do
      if O.isBody(img, x, y) and not O.isBody(img, x + d[1], y + d[2]) and only[O.get(img, x, y)] then pts[#pts + 1] = { x, y } end
    end end
    for _, p in ipairs(pts) do O.px(img, p[1], p[2], hex) end
  end
  rim("left", "#a8cc7a", { ["#86b464"] = 1, ["#5e9452"] = 1, ["#6a9e58"] = 1, ["#45784b"] = 1 }, { 4, 24, 26, 49 })
  rim("top", "#a8cc7a", { ["#86b464"] = 1, ["#5e9452"] = 1, ["#6a9e58"] = 1 }, { 6, 12, 22, 40 })
  rim("right", "#2f6a64", { ["#1c3530"] = 1, ["#264a3c"] = 1, ["#2d5442"] = 1 }, { 40, 40, 58, 56 })
  rim("bottom", "#2f6a64", { ["#1c3530"] = 1, ["#264a3c"] = 1, ["#2d5442"] = 1 }, { 38, 50, 58, 58 })
end

-- one tone down on the moss ramp (contact shadow)
local DOWN = { ["#a8cc7a"] = "#86b464", ["#86b464"] = "#5e9452", ["#6a9e58"] = "#45784b", ["#5e9452"] = "#45784b",
  ["#507f50"] = "#335f43", ["#45784b"] = "#335f43", ["#3c6a48"] = "#264a3c", ["#335f43"] = "#264a3c",
  ["#2d5442"] = "#1c3530", ["#264a3c"] = "#1c3530", ["#2f6a64"] = "#264a3c" }

O.PX0, O.PY0 = 39, 34   -- patch ring top-left (10x10 incl. the seam ring)
function O.patchB(img)
  local x0, y0 = O.PX0, O.PY0
  -- contact shadow: right column and bottom row, one tone down
  for y = y0 + 1, y0 + 10 do local h = O.get(img, x0 + 10, y) if h and DOWN[h] then O.px(img, x0 + 10, y, DOWN[h]) end end
  for x = x0 + 1, x0 + 9 do local h = O.get(img, x, y0 + 10) if h and DOWN[h] then O.px(img, x, y0 + 10, DOWN[h]) end end
  -- tartan cloth: rust red ground, ochre stripe, plum over-check; 3 lighting levels (upper-left light)
  local RED = { "#e8705a", "#c84a3c", "#a0362e" }
  local OCH = { "#f8c860", "#e0a03c", "#b87a2a" }
  local CROSS = { "#ffe0a0", "#ffd27a", "#e0a03c" }
  local PLUM = { "#9a3a48", "#7a2438", "#5e1430" }
  local PO = { "#c87a3c", "#a8581e", "#8f4a1f" }   -- plum crossing ochre
  for v = 0, 7 do for u = 0, 7 do
    local s = u + v
    local t = (s <= 3) and 1 or ((s >= 11 or u == 7 or v == 7) and 3 or 2)
    local oc, ov = (u == 2), (v == 2)
    local pc_, pv = (u == 5), (v == 5)
    local col
    if oc and ov then col = CROSS[t]
    elseif (oc and pv) or (ov and pc_) then col = PO[t]
    elseif oc or ov then col = OCH[t]
    elseif pc_ and pv then col = "#4a1028"
    elseif pc_ or pv then col = PLUM[t]
    else col = RED[t] end
    O.px(img, x0 + 1 + u, y0 + 1 + v, col)
  end end
  -- seam ring (turned-under edge) with cream running stitch, 2 on 1 off; shade side uses darker thread
  local ring = {}
  for x = x0, x0 + 9 do ring[#ring + 1] = { x, y0 } end
  for y = y0 + 1, y0 + 9 do ring[#ring + 1] = { x0 + 9, y } end
  for x = x0 + 8, x0, -1 do ring[#ring + 1] = { x, y0 + 9 } end
  for y = y0 + 8, y0 + 1, -1 do ring[#ring + 1] = { x0, y } end
  for i, p in ipairs(ring) do
    local shade = (p[1] == x0 + 9) or (p[2] == y0 + 9)
    local on = ((i - 1) % 3) ~= 2
    if on then O.px(img, p[1], p[2], shade and "#e6bd7e" or "#f6dca6")
    else O.px(img, p[1], p[2], shade and "#5e1430" or "#6e2a1c") end
  end
  -- one loose corner: the top-right stitch has come undone and the corner lifts (lit edge, dark gap)
  O.px(img, x0 + 9, y0, "#f8a848") O.px(img, x0 + 8, y0, "#e8705a")
  O.px(img, x0 + 10, y0 + 1, "#1c3530")

  -- quirk: moth-nibbled hole in the lit left skirt (scalloped bite edge, dark inside, lit lower lip,
  -- pale frayed fibres)
  O.paint(img, 16, 35, {
    ".f..f..",
    ".sHsHf.",
    "fH##Hs.",
    ".sHHHl.",
    "..lHl..",
    "...f...",
  }, { f = "#c4dc8e", s = "#264a3c", H = "#1c3530", l = "#86b464" })
  -- the moth, fluttering just off the left edge (own ink outline, pale wings, dark spots)
  -- (interior only: the re-ink closes its outline; two splayed ink antennae stand free above)
  O.paint(img, 1, 29, {
    ".wh.b.hw.",
    "whhwbwWWW",
    "wWvWbWvWS",
    ".WWSbSWS.",
    "..S.b.S..",
  }, { h = "#f6e6c4", w = "#e6d0a8", W = "#d2b386", S = "#a8845e", v = "#9c8270", b = "#6e5040" })

end

-- moth antennae: free ink pixels above the head; called after every re-ink (which clears lone ink)
function O.antennae(img) O.px(img, 3, 27, O.INK) O.px(img, 7, 27, O.INK) end

function O.cutb()
  local baseT = O.load(O.BASE)
  O.texture(baseT)
  local baseB = baseT:clone()
  O.patchB(baseB)
  O.reink(baseB)
  O.antennae(baseB)
  return baseT, baseB
end

function O.graftB(img, baseT, baseB)
  for y = 0, 63 do for x = 0, 63 do
    local a = baseB:getPixel(x, y)
    if a ~= baseT:getPixel(x, y) then img:putPixel(x, y, a) end
  end end
end
return O
