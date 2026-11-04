-- scorpion-plate (first draft, Sonnet). A dorsal armour plate of a scorpion: a broad shield stacked from four overlapping
-- chitin bands, amber-brown with a raised central keel, granulated bumps on every band and a bright bevel along
-- the top edge.
-- quirk: two tiny median eyes sit on the top band like a face.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("scorpion-plate")
local floor = math.floor
c:groundShadow(32, 57, 20, 3)
local R = A.R("#b87a32")
local bands = { { 8, 22, 16 }, { 20, 33, 21 }, { 31, 44, 24 }, { 42, 55, 21 } }   -- y0 y1 halfwidth
for i, b in ipairs(bands) do
  local m = c:rrect(32 - b[3], b[1], 32 + b[3] - 1, b[2], 4)
  A.lit(c, m, R, 5, { amb = .08, wrap = .3 })
  -- granules
  m:each(function(x, y) if (x * 3 + y * 5) % 7 == 0 and (y - b[1]) > 2 and (y - b[1]) < (b[2] - b[1]) - 1 then c:px(x, y, R[5]) c:px(x + 1, y + 1, R[2]) end end)
  -- lower overlap line
  for x = 32 - b[3] + 2, 32 + b[3] - 3 do c:px(x, b[2], R[1]) end
  for x = 32 - b[3] + 3, 32 + b[3] - 4 do c:px(x, b[1] + 1, R[6]) end
end
-- keel
for y = 10, 54 do c:px(32, y, "#f0b060") c:px(33, y, "#8a5224") end
c:fillMask(c:rect(31, 21, 34, 21), "#6a3a1c") c:fillMask(c:rect(31, 32, 34, 32), "#6a3a1c") c:fillMask(c:rect(31, 43, 34, 43), "#6a3a1c")
-- eyes
A.sph(c, 28, 13, 2, "#2b1c26", { nospec = true }) A.sph(c, 37, 13, 2, "#2b1c26", { nospec = true })
c:px(27, 12, "#fff4d6") c:px(36, 12, "#fff4d6")
A.fin()
