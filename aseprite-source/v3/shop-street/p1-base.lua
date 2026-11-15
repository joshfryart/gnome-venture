-- Shop Street pass 1 (base): sky, far haze, street, Mossbottom terrace + stair, flat building masses,
-- mushroom caps, clock tower. Flat ramp colours only: no outlines, textures, windows or signs (later passes).
-- Signature: return function(c, L, X) ... end
return function(c, L, X)
  local floor, max, min, sin = math.floor, math.max, math.min, math.sin
  local RA, look, hub = X.RAMPS, X.look, X.HUB
  local BASE = 250          -- ground / building feet
  local LOC_VP = { 240, 20, 0.12 }   -- local side vanishing point and lean factor
  local HUB_VP = { 300, 0, 0.16 }    -- Mossbottom vanishing point and lean factor

  local function fp(pts, hex) c:fillMask(c:poly(X.P(pts)), hex) end

  -- one building: box {x0,y0,x1,y1} from the layout. The side face is on the inner (centre-facing) side.
  -- Top edges lean toward the vanishing point; the lean is clamped so the whole mass stays inside its box.
  local function building(box, o)
    local x0, y0, x1, y1 = box[1], box[2], box[3], box[4]
    local m, yb = o.mirror, y1
    local yt = o.roof and (y0 + o.roof) or y0
    local xc = (x0 + x1) / 2
    local frac = (yb - y0) / (yb - o.vy)
    local D = max(2, floor((x1 - x0) * 0.30 + .5))
    local d = floor(min(math.abs((o.vx - xc) * o.k * frac), D * 0.9) + .5)
    -- local coords are drawn as if the inner side is on the right; mirror maps them for the other side
    local function T(x, y) if m then return x0 + x1 - x, y end return x, y end
    local function P(pts) local r = {} for i, p in ipairs(pts) do r[i] = { T(p[1], p[2]) } end return r end
    fp(P{ {x0, yb}, {x1 - D, yb}, {x1 - D + d, yt}, {x0 + d, yt} }, o.front)     -- front face
    fp(P{ {x1 - D, yb}, {x1, yb}, {x1, yt}, {x1 - D + d, yt} }, o.side)          -- inner side face
    if o.roof then                                                               -- roof block
      fp(P{ {x0 + d - 2, yt}, {x0 + d + 1, y0}, {x1, y0}, {x1, yt} }, o.roofHex)
    end
    -- door at the base of the front face
    local dx0 = x0 + floor((x1 - D - x0) * 0.3)
    local dw = max(5, floor((x1 - D - x0) * 0.34))
    local ra, rb = T(dx0, 0), T(dx0 + dw, 0)
    c:fillMask(c:rect(min(ra, rb), yb - 22, max(ra, rb), yb - 1), o.door)
    if o.cap then -- mushroom cap dome over the top, with a darker underside rim
      local cx = T((x0 + d + x1) / 2, 0)
      local rx = floor((x1 - x0) / 2) + 1
      local cap = c:ellipse(cx, y0 + 7, rx, 8):clip(c:rect(x0 - 2, y0 - 1, x1 + 2, y0 + 8))
      c:fillMask(cap, o.cap[4])
      c:fillMask(cap:copy():clip(c:rect(x0 - 2, y0 + 6, x1 + 2, y0 + 8)), o.cap[2])
    end
  end

  -- 1. sky bands, far haze ridge, dark back alley fill
  local sky = look.sky
  c:stripes(0, 95, sky, { 3, 3, 2 })
  local haze = X.mix(sky[3], RA.STONE[5], .35)
  c:terrain(function(x) return 80 + 5 * sin(x / 19) + 3 * sin(x / 6.1) + ((x % 37 < 4) and -6 or 0) end, haze, 95)
  c:fillMask(c:rect(0, 96, 479, 299), look.frame[2])

  -- 2. pavement, then the cobbled street narrowing to the clock tower
  c:fillMask(c:rect(0, BASE, 479, 299), RA.STONE[2])
  fp({ { 0, 300 }, { 480, 300 }, { 268, BASE }, { 212, BASE } }, RA.COB[5])

  -- Mossbottom upper row (drawn first: it sits up the slope behind the front row)
  local byk = L.byk
  local upperCaps = { ["hub-dyes"] = hub.cap.petal, ["hub-pets"] = hub.cap.ember, ["hub-more"] = hub.cap.moss }
  for _, k in ipairs({ "hub-dyes", "hub-pets", "hub-more" }) do
    building(byk[k].box, { mirror = true, vx = HUB_VP[1], vy = HUB_VP[2], k = HUB_VP[3],
      front = hub.wall[4], side = hub.wall[3], cap = upperCaps[k], door = RA.OAK[2] })
  end

  -- back ledge of the terrace (the step up from the front row to the upper row)
  c:fillMask(c:rect(286, 140, 479, 150), RA.STONE[2])

  -- terrace front face (raised ~40px above the street), stepping down at the corner; the lower right
  -- corner [380,262]-[480,300] stays open street, and the stand points stay on the street or stair
  fp({ { 306, BASE }, { 480, BASE }, { 480, 260 }, { 380, 260 }, { 318, 292 }, { 306, 292 } }, RA.STONE[3])
  -- crooked stair from the terrace top down to the street
  fp({ { 286, BASE }, { 306, BASE }, { 306, 292 }, { 292, 292 } }, RA.STONE[5])

  -- Mossbottom front row
  local frontCaps = { ["hub-seeds"] = hub.cap.moss, ["hub-food"] = hub.cap.ember,
    ["hub-florist"] = hub.cap.petal, ["hub-decor"] = hub.cap.moss }
  for _, k in ipairs({ "hub-seeds", "hub-food", "hub-florist", "hub-decor" }) do
    building(byk[k].box, { mirror = true, vx = HUB_VP[1], vy = HUB_VP[2], k = HUB_VP[3],
      front = hub.wall[4], side = hub.wall[3], cap = frontCaps[k], door = RA.OAK[2] })
  end

  -- 3. Here (local) shops: timber/stone fronts, roof blocks, doors; they shrink as they recede to the centre
  for _, k in ipairs({ "loc-4", "loc-3", "loc-2", "loc-1" }) do
    building(byk[k].box, { mirror = false, vx = LOC_VP[1], vy = LOC_VP[2], k = LOC_VP[3], roof = 10,
      front = look.wall[4], side = look.wall[3], roofHex = look.roof[3], door = look.frame[2] })
  end

  -- 4. base archway shop of the clock tower (loc-more), then the crooked clock tower above it
  building(byk["loc-more"].box, { mirror = false, vx = LOC_VP[1], vy = LOC_VP[2], k = LOC_VP[3], roof = 10,
    front = look.wall[4], side = look.wall[3], roofHex = look.roof[3], door = look.frame[2] })
  fp({ { 210, BASE }, { 252, BASE }, { 246, 70 }, { 206, 70 } }, RA.STONE[4])   -- tower front
  fp({ { 252, BASE }, { 258, BASE }, { 250, 70 }, { 246, 70 } }, RA.STONE[2])   -- tower side (lean ~5px)
  fp({ { 202, 72 }, { 250, 72 }, { 226, 30 } }, look.roof[4])                   -- crooked spire roof
  c:fillMask(c:rect(222, 228, 238, 249), look.frame[1])                         -- archway
  c:fillMask(c:ellipse(230, 228, 8, 6), look.frame[1])

  return c
end
