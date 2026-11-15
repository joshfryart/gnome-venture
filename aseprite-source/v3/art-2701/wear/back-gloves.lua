-- back-gloves (Work Gloves avatar layer, back view) redo. 512x80 = 8 frames of 64x80, lined up with the gnome25 body.
-- Was: two plain tan blobs, no thumb. Now each glove has a stitched cuff, three knuckle bumps, finger seams and a THUMB
-- on the inner side (the thumb tucks against the tunic, pointing down-forward). Same silhouette and swing as before
-- (the old layer's glove pixels give the hand shape per frame). quirk: stitched leather patch on the right glove.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = dofile(DIR .. "/_strip.lua")
local W = S.W
local L = { hi="#f6d9a4", lt="#e6bd80", base="#cf9c5f", sh="#a3713f", dp="#6e4529" }
local PATCH = { base="#8c5640", sh="#704234", thread="#f6d9a4" }
local function K(x, y) return y * W + x end

local frames = {}
for f = 0, 7 do
  local px = {}
  -- collect the old glove's material pixels (not ink) per side
  local comp = { {}, {} }
  for y = 0, S.H - 1 do for x = 0, W - 1 do
    local h = S.hex("back", "gloves", f, x, y)
    if h and h ~= S.INK then table.insert(comp[x < 32 and 1 or 2], { x, y }) end
  end end
  for side = 1, 2 do
    local pts, m, rows = comp[side], {}, {}
    local ytop = 1e9
    for _, q in ipairs(pts) do
      m[K(q[1], q[2])] = true
      local r = rows[q[2]]; if not r then r = { q[1], q[1] }; rows[q[2]] = r end
      if q[1] < r[1] then r[1] = q[1] end; if q[1] > r[2] then r[2] = q[1] end
      if q[2] < ytop then ytop = q[2] end
    end
    local ybot = ytop
    for y in pairs(rows) do if y > ybot then ybot = y end end
    local inner = (side == 1) and 1 or -1       -- left glove: inner side is to the right
    for y = ytop, ybot do
      local r = rows[y]
      if r then
        for x = r[1], r[2] do
          local u = (x - r[1]) / math.max(1, r[2] - r[1])
          local c
          if y == ytop then c = L.lt; if x == r[1] then c = L.hi end
          elseif y == ytop + 1 then c = L.sh
            if (x - r[1]) % 2 == 1 then c = L.hi end          -- stitch dashes on the cuff band
          else
            c = L.base
            if u < 0.25 then c = L.lt end
            if u > 0.75 then c = L.sh end
            if y == ytop + 2 and (x - r[1]) % 2 == 0 and x > r[1] and x < r[2] then c = L.hi end   -- knuckle bumps
            if y >= ytop + 4 and (x - r[1]) % 2 == 1 and x > r[1] and x < r[2] then c = L.sh end    -- finger seams
            if y == ybot then c = L.dp end
          end
          px[K(x, y)] = c
        end
      end
    end
    -- the thumb: 2 wide, 3 tall, on the inner side, from the knuckle row down
    local y1 = ytop + 3
    local edge = (inner == 1) and rows[y1 + 1][2] or rows[y1 + 1][1]
    local tx = edge + inner
    for y = y1, y1 + 2 do
      local r = rows[y] or rows[y1 + 1]
      local from = (inner == 1) and (r[2] + 1) or (tx + (y > y1 and -inner or 0))
      -- bridge any gap between the hand and the thumb
      local a, b = (inner == 1) and (r[2] + 1) or (tx + (y > y1 and -inner or 0)), (inner == 1) and (tx + (y > y1 and inner or 0)) or (r[1] - 1)
      if a > b then a, b = b, a end
      for x = a, b do
        local last = (inner == 1 and x == b) or (inner == -1 and x == a)
        local c = L.base
        if y == y1 then c = L.lt end
        if last then c = L.sh end
        if y == y1 + 2 then c = L.dp end
        px[K(x, y)] = c
      end
    end
    -- thumb seam where it meets the palm
    local r = rows[y1 + 1]
    px[K(inner == 1 and r[2] or r[1], y1 + 1)] = L.sh
    -- patch on the right glove (quirk): leather patch, thread at two corners
    if side == 2 then
      local px0, py0 = rows[ytop + 3][1] + 2, ytop + 3
      px[K(px0, py0)] = PATCH.thread; px[K(px0 + 1, py0)] = PATCH.base
      px[K(px0, py0 + 1)] = PATCH.base; px[K(px0 + 1, py0 + 1)] = PATCH.thread
    end
  end
  local body = S.mask("back", S.BODY, f)
  frames[#frames + 1] = S.finish(px, body)
end
S.save("back-gloves", frames)
