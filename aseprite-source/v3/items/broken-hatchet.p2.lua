-- broken-hatchet (pass 2, final). Side-on hatchet: flat-topped bearded head with a bright bevelled bit and a
-- small poll; gently bellied handle with a hooked butt. Snapped under the head: head + stub knocked up-right,
-- matching zigzag splinters, one chip flying. quirk: gold thread wrapped round the grip, loose end unravelling
-- into a curl.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "broken-hatchet" }
-- handle: crisp 2:1 staircase, 6 px wide (rows), flaring 1 px at the butt
local function handleRows(y0, y1)
  local m = HP.mask()
  for y = y0, y1 do
    local l = 42 - (y - 12) // 2
    local w = 6
    if y >= 52 then l, w = l - 1, 7 end                  -- butt flare
    if y == 56 then l, w = l + 1, 5 end                  -- rounded end
    m:add(c:rect(l, y, l + w - 1, y))
  end
  return m
end
local zig = { {26,30},{31,35},{33,32},{35,36},{37,33},{39,37},{41,34},{44,38} }   -- break line (left to right)
local below, above = { {0,63},{63,63} }, { {0,0},{63,0} }
local function side(extra) local t = {} for _, p in ipairs(zig) do t[#t+1] = p end
  t[#t+1] = extra[2] t[#t+1] = extra[1] return t end

-- lower handle: below the break
local low = handleRows(12, 56):clip(c:poly(side(below)))
c:part(low, "wood", { band = 2, pop = { x = 30, y = 37 } })

-- upper piece (head + stub), knocked up-right by (2,-3)
local SX, SY = 2, -3
local stub = handleRows(12, 40):clip(c:poly(side(above))):cut(c:rect(0, 34, 63, 63))
stub = stub:cut(HP.poly(side(below)):shift(0, -1))      -- 1 px gap along the zigzag
c:part(stub:shift(SX, SY), "wood", { band = 1, nopop = true })
local head = c:poly{ {39,12},{30,13},{21,12},{15,9},{12,10},{10,15},{10,22},{12,28},{15,32},{19,30},{24,26},{30,22},{39,22} }
head:add(c:rrect(37, 11, 48, 23, 2))                    -- eye + short poll
c:part(head:shift(SX, SY), "stone", { band = 3, nopop = true })
-- bright bevel: the 3 leftmost px of every row of the bit, plus the pop on its upper part
local bevel = head:copy():cut(head:shift(3, 0)):clip(c:rect(0, 0, 21, 63))
c:fillMask(bevel:shift(SX, SY), P.stone.hi)
c:fillMask(c:rect(13 + SX, 12 + SY, 13 + SX, 13 + SY), P.cream)                      -- the one sparkle on the edge

-- one chip flying off right of the break
c:part(c:poly{ {47,31},{51,29},{53,32},{50,35},{47,34} }, "wood", { band = 1, pop = { x = 49, y = 31 } })

-- quirk: gold thread, 3 wraps on the grip (rising 1 px per 2 px, shade on the right 2 px) + loose end curling off
for _, y0 in ipairs{ 44, 47, 50 } do
  local l = 42 - (y0 - 12) // 2
  for i = 0, 5 do
    local x, y = l + i, y0 - i // 2
    if low:has(x, y) then c:px(x, y, i >= 4 and P.gold.shade or P.gold.base) end
  end
end
c:paint({
  "gg..........",
  "..gg........",
  "....gg....g.",
  "......g....g",
  ".......g...g",
  "........ggg.",
}, 30, 48, { g = "gold.base" })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "broken-hatchet.aseprite", png = out .. "broken-hatchet.png" }
