-- ico-sparkle (final, Opus). A big faceted gold four-point star with concave flanks, creased ridges on its axes
-- (eight facets lit per pixel from the upper left), a bright rim on the lit edges and a cream glint at the heart;
-- a smaller ember-peach star upper-right and a tiny sky-blue twinkle lower-right, each with their own facets.
-- quirk: the big star is winking.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-sparkle")
local GO = { "#7a3a1c", "#b0581e", "#de8a26", "#f5b82e", "#ffd95e", "#fff0a6" }
local PE = { "#7d2c4a", "#b8404a", "#e8693e", "#ff9358", "#ffbc86", "#ffe2c0" }
local SK = { "#3a5fa8", "#5f9ad0", "#8bc4ea", "#c4ecff" }

local function star(cx, cy, ax, by, p, H, ramp, cuts, rimHi)
  local m, n = A.star(cx, cy, ax, by, p, H)
  local tok = { r = { name = "star" .. cx } }
  local idx = A.shade(c, m, n, ramp, { amb = 0.1, wrap = 0.3, tok = tok, cuts = cuts })
  -- lit rim: outer edge pixels whose facet faces the light get the top tone
  m:edge():each(function(x, y) local k = K(x, y)
    local dx, dy = x - cx, y - cy
    if (dx < 0 and dy <= 0) or (dx <= 0 and dy < 0) then
      if idx[k] and idx[k] >= #ramp - 2 then c:put(x, y, ramp[#ramp], tok) end
    elseif dx > 0 and dy > 0 then c:put(x, y, ramp[max(1, (idx[k] or 2) - 1)], tok) end
  end)
  return m, idx, tok
end

-- main star
local CX, CY = 27, 35
local mm, midx, mtok = star(CX, CY, 19, 20.5, 0.68, 7, GO, { 0.2, 0.36, 0.52, 0.68, 0.84 })
-- ridge crease: one tone lighter on the lit halves of the axes, darker on the shade halves
for d = 3, 19 do
  if mm:has(CX, CY - d) then A.step(c, midx, GO, CX, CY - d, 1, mtok) end
  if mm:has(CX - d, CY) then A.step(c, midx, GO, CX - d, CY, 1, mtok) end
  if mm:has(CX, CY + d) then A.step(c, midx, GO, CX, CY + d, -1, mtok) end
  if mm:has(CX + d, CY) then A.step(c, midx, GO, CX + d, CY, -1, mtok) end
end
-- heart glint (cream 2x2 + streak up the lit ridge)
c:put(CX - 1, CY - 3, A.CREAM, mtok) c:put(CX, CY - 4, A.CREAM, mtok) c:put(CX - 1, CY - 4, GO[6], mtok)
for d = 6, 9 do c:put(CX - 1, CY - d, GO[6], mtok) end
-- quirk: wink (2x3 pill eye left, ^ closed eye right), tiny smile, cheek
c:eyeSmall(CX - 5, CY - 1)
c:px(CX + 3, CY, A.INK) c:px(CX + 4, CY - 1, A.INK) c:px(CX + 5, CY, A.INK)
c:px(CX - 2, CY + 4, A.INK) c:px(CX - 1, CY + 5, A.INK) c:px(CX, CY + 5, A.INK) c:px(CX + 1, CY + 4, A.INK)
c:px(CX + 5, CY + 2, "#f07a5a") c:px(CX + 6, CY + 2, "#f07a5a")
c:px(CX - 7, CY + 2, "#f07a5a") c:px(CX - 6, CY + 2, "#f07a5a")

-- companion star, upper right
local sm, sidx, stok = star(48, 14, 8.5, 9.5, 0.66, 4, PE, { 0.2, 0.36, 0.52, 0.68, 0.84 })
c:put(47, 12, PE[6], stok) c:put(47, 13, A.CREAM, stok)
-- tiny twinkle, lower right
local tm, tidx, ttok = star(51, 49, 4.5, 5.5, 0.7, 2.5, SK, { 0.3, 0.55, 0.78 })
c:put(51, 48, "#f2fbff", ttok)
A.save(c, "ico-sparkle")
