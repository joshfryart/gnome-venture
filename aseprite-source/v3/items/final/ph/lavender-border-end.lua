-- lavender-border-end (final, Opus single pass). The run of lavender stops against a squat stone pier with a capping
-- slab and a ball finial: bed of three mounds on the left (flat cut end), the pier closing it on the right.
-- Material: bevelled kerb and coursed pier blocks (mortar, lit left arris, shade right, AO at the foot), a sphere
-- finial with specular and cool bounce, needle-leaf mounds and whorled violet spikes.
-- quirk: a little snail is climbing the pier face.
local NAME = "lavender-border-end"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local c = A.new(NAME)
local ST = A.STONE
local bed = A.bed(c, c:rect(9, 38, 45, 42), { fh = 4, seed = 5 })
local bushes = {
  { 15, 42, 6, 6, { { -3, -3, 14, 6 }, { 0, 0, 18, 8 }, { 3, 4, 15, 7 } }, 7 },
  { 27, 42, 6, 7, { { -3, -3, 17, 7 }, { 0, 0, 20, 8 }, { 3, 3, 14, 6 } }, 8 },
  { 38, 42, 5, 6, { { -2, -2, 15, 7 }, { 1, 1, 18, 8 } }, 9 },
}
for _, b in ipairs(bushes) do local m = A.bush(c, b[1], b[2], b[3], b[4], b[5], b[6]) A.contact(c, bed, m) end
A.refront(c, bed)

-- pier
local ptok = { r = { name = "pier" } }
local px0, px1 = 46, 54
local face = c:rect(px0, 31, px1, 48)
face:each(function(x, y)
  local i = 3
  local course = (y - 31) % 5
  local row = (y - 31) // 5
  local jx = (row % 2 == 0) and 50 or 48
  if course == 0 then i = 2 end                                  -- bed joint
  if x == jx and course ~= 0 then i = 1 end                      -- perp joint
  if course == 1 and x ~= jx then i = 4 end                      -- lit top of each course
  if x == px0 then i = min(6, i + 2) elseif x == px0 + 1 and i >= 3 then i = i + 1 end
  if x == px1 then i = max(1, i - 1) end
  if y >= 47 then i = max(1, i - 1) end                          -- AO at the foot
  if course > 1 and x ~= jx and A.h(x, y, 21) < 0.08 then i = max(1, i - 1) end
  c:put(x, y, ST[min(6, i)], ptok)
end)
-- shadow the pier casts on the bed kerb/soil to its left? light is upper-left: no. AO where bed meets pier:
for y = 36, 48 do local x = px0 - 1 if bed.top:has(x, y) or bed.face:has(x, y) then c:put(x, y, (y >= 45) and ST[1] or A.SOIL[1], bed.tok) end end
-- capping slab with overhang
local cap = c:rect(px0 - 1, 28, px1 + 1, 30)
cap:each(function(x, y)
  local i = (y == 28) and 6 or (y == 29 and 4 or 2)
  if x == px0 - 1 and y > 28 then i = 5 end
  if x == px1 + 1 then i = max(1, i - 2) end
  c:put(x, y, ST[i], ptok)
end)
c:put(px0 + 1, 28, A.CREAM, ptok)
-- ball finial on a short neck
c:fillMask(c:rect(48, 26, 52, 27), ST[3]) c:put(48, 26, ST[4]) c:put(52, 27, ST[2]) c:put(52, 26, ST[2])
local bm, bn = A.oval(50, 21, 4.2, 4.2, 0)
local v = X.light(bn, { amb = 0.06, wrap = 0.2 })
local btok = { r = { name = "ball" } }
local bidx = X.tone(c, bm, v, ST, { cuts = A.CUTS, tok = btok })
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.55 and x > 50 and y > 21 then c:put(x, y, "#8a93b8", btok) end end)
c:put(48, 19, A.CREAM, btok) c:put(49, 19, ST[6], btok) c:put(48, 20, ST[6], btok)
-- neck shadow on cap
c:put(53, 28, ST[4], ptok)

-- quirk: snail climbing the pier face (shell spiral, soft body, eye stalks)
local sx, sy = 49, 39
local map = {
  "...gGg..",
  "..gGOGd.",
  "..GoOgd.",
  "..gGGdd.",
  "BbbbbbbB",
}
local SC = { g = "#f5b82e", G = "#ffe38a", O = "#d98322", o = "#8f4a1f", d = "#a85a28", b = "#c9a68a", B = "#a8826a" }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if SC[ch] then c:put(sx + xx - 4, sy + yy - 3, SC[ch]) end end end
c:put(sx - 3, sy + 1, "#c9a68a") c:put(sx - 4, sy, "#c9a68a") c:put(sx - 4, sy - 1, A.INK)
A.save(c, NAME)
