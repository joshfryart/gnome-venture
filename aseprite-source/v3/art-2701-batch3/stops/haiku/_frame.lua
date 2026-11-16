-- _frame.lua : shared Maplewold gate-view frame for the stop-type looks (art-2701 batch 3, Haiku first pass).
-- Built from v3/here-gate/pilot-market.lua: same palette (grassland_maplewold), same horizon, road, ground,
-- sky, gate beam, posts, bunting and lanterns, so every stop look sits in the same frame as the Maplewold market.
-- Usage (in a stop script):
--   local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR }
--   ... draw the stop's objects on F.c (after the background, before the gate frame) ...
--   F.finish()
local M = {}

function M.build(o)
  local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
  local floor, sin, abs = math.floor, math.sin, math.abs

  local function rp(s) -- "hi base shade deep edge"
    local t = {} for h in s:gmatch("#%x+") do t[#t + 1] = h end
    return { hi = t[1], base = t[2], shade = t[3], deep = t[4], edge = t[5] or t[4] }
  end
  local L = {
    sky = { "#eaa774", "#f1bd84", "#f6d39b", "#f9e4b6" }, skyStyle = "clouds",
    cloud = { top = "#fdf1d6", under = "#f3cfa2" },
    hillFar = "#e6c08e", hillMid = "#d4a466", hillMidShade = "#c08c52", hillStyle = "hills",
    farTree = rp("#f4b884 #e39a64 #cc7c56 #b0664c #8e5444"),
    ground = rp("#ecc977 #d9ab55 #bd8a40 #946634 #6a4428"), groundFar = "#e8c584",
    road = rp("#e4d8c4 #cbbaa2 #ab9881 #86746a #5a4c4a"), slabRatio = 1.06, slabK = 15,
    stone = rp("#e4ddd2 #bab2a6 #908890 #686078 #433b52"),
    plaster = rp("#fff4dc #f0e0bf #d3bd9b #a89080 #6a5458"),
    wall2 = rp("#d6e4c2 #aac89a #85a37e #607f68 #3e5650"),
    timber = rp("#b07a50 #885636 #663e2a #4a2b22 #2e1a1c"),
    roof = rp("#f6d070 #e0a948 #ba8136 #8c5a2a #5c3a20"),
    roof2 = rp("#e88660 #c95c3e #a24034 #742e2e #4a1c26"),
    awnA = rp("#f08a7a #d9524a #b03a3c #822a36 #521a28"),
    awnB = rp("#fff6e0 #f6e6c4 #dcc7a0 #b09c84 #6e5c58"),
    accent = rp("#86d0bc #4fa494 #3a7c76 #2b5a5c #1c3a44"),
    foliage = rp("#ffc457 #f08c32 #cc5c2a #983c26 #5e2420"),
    foliage2 = rp("#f69064 #d9533a #ac3a32 #7a282c #4a1824"),
    leaf = rp("#c4d878 #93b552 #6a903e #4a6a36 #2e4428"),
    water = rp("#cdeef0 #8fcfd8 #5ea4bc #43769c #2e4a72"),
    glow = rp("#fff6c0 #ffd870 #f6aa42 #d27a30 #8a4a24"),
    soil = rp("#a87a58 #855a40 #66422f #4a2e24 #2e1a18"),
    board = rp("#e8bc88 #c99462 #a6744c #7c553c #4e3428"),
    produce = rp("#ffb04a #f07c22 #c85a1e #943e1c #5e2618"),
    shadow = "#a07068", shadowRoad = "#958590",
    flora = "maple", roofStyle = "gable", wallStyle = "timber", roofTex = "thatch",
  }

  local W, H, HZ, VX = 480, 270, 112, 240
  local ROAD_TOP = 124
  local function xl(y) return 234 - (y - ROAD_TOP) * 0.3 end
  local function xr(y) return 246 + (y - ROAD_TOP) * 0.3 end

  local c = HP.canvas{ w = W, h = H, scale = 1, name = o.name or "stop" }
  local roadM

  local function hash(a, b, s)
    local n = (a * 374761393 + b * 668265263 + (s or 0) * 1442695041) & 0x7fffffff
    n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
    return (n % 10007) / 10007
  end
  local function px(x, y, h) c:put(x, y, h) end
  local function rect(a, b, cc, d) return c:rect(a, b, cc, d) end
  local function poly(t) return c:poly(t) end
  local function fill(m, h) c:fillMask(m, h) return m end
  local function part(m, r, opts) return c:part(m, r, opts) end
  local function hline(x0, x1, y, h) for x = x0, x1 do px(x, y, h) end end
  local function vline(x, y0, y1, h) for y = y0, y1 do px(x, y, h) end end
  local function union(...) local m = HP.mask() for _, a in ipairs({ ... }) do m:add(a) end return m end
  local function rimOf(m, r) c:rim(m, r.edge) end

  local function shadow(x0, x1, yb, dx, dy) -- light upper-left: shadow falls lower-right
    local m = poly{ { x0, yb - 2 }, { x1, yb - 2 }, { x1 + dx, yb + dy }, { x0 + dx, yb + dy } }
    m:each(function(x, y) px(x, y, (roadM and roadM:has(x, y)) and L.shadowRoad or L.shadow) end)
  end
  local function courses(m, y0, rowH, bw, r, seed)
    m:each(function(x, y)
      local row = (y - y0) // rowH
      local off = (row % 2) * (bw // 2) + (seed or 0)
      local ry, rx = (y - y0) % rowH, (x + off) % bw
      if ry == 0 or rx == 0 then px(x, y, r.deep)
      elseif ry == 1 and rx == 1 then px(x, y, r.hi)
      elseif ry == rowH - 1 and hash(x // bw, row, 7) < .5 then px(x, y, r.shade) end
    end)
  end
  local function speckle(m, r, dens, seed)
    m:each(function(x, y)
      local v = hash(x, y, seed or 3)
      if v < dens then px(x, y, r.hi) elseif v > 1 - dens then px(x, y, r.deep) end
    end)
  end
  local function window(x0, y0, x1, y1, fr, arched)
    local f = arched and c:rrect(x0 - 1, y0 - 1, x1 + 1, y1 + 4, 3):clip(rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1)) or rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1)
    fill(f, fr.deep)
    local g = f:shrink(1)
    fill(g, L.glow.base)
    g:each(function(x, y) if not g:has(x + 1, y + 1) then px(x, y, L.glow.shade) end end)
    px(x0 + 1, y0 + 1, L.glow.hi) px(x0 + 2, y0 + 1, L.glow.hi)
    vline((x0 + x1) // 2, y0, y1, fr.base)
    if y1 - y0 > 5 then hline(x0, x1, (y0 + y1) // 2, fr.base) end
    hline(x0 - 2, x1 + 2, y1 + 2, fr.hi) hline(x0 - 2, x1 + 2, y1 + 3, fr.deep)
  end
  local function door(x0, y0, x1, y1, r, arched)
    local m = arched and c:rrect(x0, y0, x1, y1 + 6, 4):clip(rect(x0, y0, x1, y1)) or rect(x0, y0, x1, y1)
    part(m, r, { inner = false })
    c:edgeIn(m, r.edge)
    for x = x0 + 3, x1 - 2, 3 do vline(x, y0 + 3, y1 - 1, r.shade) end
    px(x1 - 2, (y0 + y1) // 2 + 2, L.glow.hi)
    return m
  end
  local function crown(cx, cy, rx, ry, r, seed) -- lumpy crown, never a circle
    local pts, n = {}, 16
    for i = 0, n - 1 do
      local a = i / n * 2 * math.pi
      local k = .78 + .34 * hash(i, seed, 11)
      pts[#pts + 1] = { cx + math.cos(a) * rx * k, cy + sin(a) * ry * k }
    end
    local m = poly(pts)
    rimOf(m, r)
    part(m, r)
    m:each(function(x, y)
      local v = hash(x, y, seed)
      local ul = (x - cx) / rx + (y - cy) / ry < -.2
      if v < .10 then px(x, y, ul and r.hi or r.base)
      elseif v > .88 then px(x, y, ul and r.base or r.deep) end
    end)
    return m
  end
  local function maple(x, yb, h, r, seed, far)
    local tr = far and L.farTree or L.timber
    local t = rect(x - 2, yb - h // 2, x + 1, yb)
    if not far then rimOf(t, tr) end
    part(t, tr, { nopop = true })
    crown(x, yb - h * .62, h * .45, h * .36, far and L.farTree or r, seed)
  end
  local function tree(x, yb, h, seed, far) -- a Maplewold tree (foliage alternates)
    maple(x, yb, h, seed % 2 == 0 and L.foliage or L.foliage2, seed, far)
  end

  -- a timber-framed or plaster building; gable roof with a king post, or flat parapet
  local function building(b)
    local x0, x1, yb, wh, rh, wr = b.x0, b.x1, b.yb, b.wh, b.rh, b.wall
    local top, cx = yb - wh, (x0 + x1) // 2
    local wallM = rect(x0, top, x1, yb)
    local rr = b.roof or L.roof
    local roofM = poly{ { x0 - 3, top + 3 }, { cx, top - rh }, { x1 + 3, top + 3 } }
    roofM:add(rect(x0 - 3, top, x1 + 3, top + 3))
    local gableM = poly{ { x0 + 5, top }, { cx, top - rh + 8 }, { x1 - 5, top } }
    roofM:cut(gableM)
    local sil = union(wallM, roofM, gableM)
    shadow(x0 + 2, x1, yb, 10, 5)
    rimOf(sil, wr)
    part(wallM, wr)
    part(gableM, wr, { nopop = true })
    part(roofM, rr, { sep = true })
    roofM:each(function(x, y) if (y + (x // 5) % 2) % 3 == 0 then px(x, y, rr.shade) elseif hash(x, y, 5) < .07 then px(x, y, rr.hi) end end)
    hline(x0 - 3, x1 + 3, top + 3, rr.deep)
    vline(cx, top - rh + 10, top - 1, L.timber.base)
    -- timber frame: sills and posts
    local beams = union(rect(x0, top, x1, top + 1), rect(x0, yb - 2, x1, yb), rect(x0, top, x0 + 1, yb), rect(x1 - 1, top, x1, yb))
    for x = x0 + 12, x1 - 10, 14 do beams:add(rect(x, top, x + 1, yb)) end
    part(beams, L.timber, { nopop = true, noshade = true })
    return top, cx
  end

  local function palm(x, yb, h, lean, seed, far)
    local tr = far and L.farTree or L.timber
    local top = { x + lean, yb - h }
    local trunk = c:line({ { x, yb }, { x + lean * .35, yb - h * .5 }, top }, far and 2 or 3)
    if not far then rimOf(trunk, tr) end
    part(trunk, tr, { nopop = true, noshade = true })
  end

  ---------------------------------------------------------------- BACKGROUND
  c:stripes(0, HZ, L.sky, { 3, 3, 3, 2 })
  for _, cl in ipairs({ { 120, 44, 40 }, { 300, 30, 52 }, { 400, 66, 30 }, { 40, 80, 26 } }) do
    local x, y, w = cl[1], cl[2], cl[3]
    local m = c:rrect(x, y - 6, x + w, y, 3):add(c:rrect(x + w // 5, y - 12, x + w * 3 // 4, y - 4, 4)):add(c:rrect(x + w // 2, y - 15, x + w * 3 // 4 + 4, y - 8, 3))
    fill(m, L.cloud.top) hline(x + 2, x + w - 2, y, L.cloud.under)
  end
  local function fFar(x) return HZ - 16 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end
  local function fMid(x) return HZ - 6 + 4 * sin(x / 29 + 2) + 3 * sin(x / 11) end
  c:terrain(fFar, L.hillFar, HZ)
  for i, tx in ipairs({ 24, 52, 196, 290, 318, 352, 440 }) do tree(tx, floor(fMid(tx)) + 2, 22, i, true) end
  local midM = c:terrain(fMid, L.hillMid, HZ)
  midM:each(function(x, y) if (x + y * 3) % 23 == 0 then px(x, y, L.hillMidShade) end end)
  c:stripes(HZ + 1, H - 1, { L.groundFar, L.ground.hi, L.ground.base, L.ground.base }, { 1, 2, 4, 6 })
  for y = HZ + 1, H - 1 do
    local d = y - HZ + 2
    for x = 0, W - 1 do
      local u = (x - VX) / d * 7
      if y < 168 and abs(u - floor(u + .5)) < .06 + 1.2 / d then px(x, y, L.ground.shade)
      elseif hash(x, y, 1) < .02 + y / 9000 then px(x, y, L.ground.shade) px(x, y - 1, L.ground.hi) end
    end
  end
  -- road: one-point perspective slabs
  roadM = poly{ { xl(ROAD_TOP), ROAD_TOP }, { xr(ROAD_TOP), ROAD_TOP }, { xr(H + 2), H + 2 }, { xl(H + 2), H + 2 } }
  local function cell(x, y)
    local d = y - HZ + 6
    local row = floor(math.log(d) / math.log(L.slabRatio))
    local u = (x - VX) / d * L.slabK + (row % 2) * .5
    return row, floor(u)
  end
  roadM:each(function(x, y)
    local r1, u1 = cell(x, y)
    local r2, u2 = cell(x - 1, y)
    local r3, u3 = cell(x, y - 1)
    local h
    if r1 ~= r3 or u1 ~= u2 then h = L.road.deep
    else
      local v = hash(r1, u1, 21)
      h = v < .18 and L.road.hi or (v > .8 and L.road.shade or L.road.base)
    end
    px(x, y, h)
  end)
  for y = ROAD_TOP, H - 1 do
    px(floor(xl(y)), y, L.road.edge) px(floor(xl(y)) - 1, y, L.ground.deep)
    px(floor(xr(y) + .99), y, L.road.edge) px(floor(xr(y) + .99) + 1, y, L.ground.deep)
  end

  ---------------------------------------------------------------- the gate frame (drawn last, in finish)
  local function gate()
    local G = L.stone
    -- overhanging foliage at the top corners
    crown(56, 18, 34, 12, L.foliage, 91) crown(110, 14, 22, 8, L.foliage2, 92)
    crown(428, 18, 34, 12, L.foliage2, 93) crown(378, 14, 20, 8, L.foliage, 94)
    local beam = rect(0, 0, W - 1, 12)
    local postL, postR = rect(0, 0, 15, 222), rect(W - 16, 0, W - 1, 222)
    local plL, plR = rect(0, 218, 18, 228), rect(W - 19, 218, W - 1, 228)
    local brL = poly{ { 16, 13 }, { 34, 13 }, { 16, 31 } }
    local brR = poly{ { W - 17, 13 }, { W - 35, 13 }, { W - 17, 31 } }
    rimOf(union(beam, postL, postR, plL, plR, brL, brR), L.timber)
    part(postL, G) part(postR, G)
    courses(union(postL, postR), 0, 9, 16, G)
    part(plL, G, { sep = true }) part(plR, G, { sep = true })
    part(brL, L.timber, { nopop = true }) part(brR, L.timber, { nopop = true })
    part(beam, L.timber, { band = 2 })
    hline(0, W - 1, 1, L.timber.hi)
    for x = 30, W - 30, 60 do fill(rect(x, 4, x + 2, 6), L.timber.deep) px(x, 4, L.timber.hi) end
    -- bunting
    local function by(x) local t = (x - VX) / 224 return 15 + 16 * (1 - t * t) end
    for x = 16, W - 17 do px(x, floor(by(x)), L.timber.deep) end
    local cols = { L.awnA, L.awnB, L.accent, L.roof }
    local i = 0
    for x = 20, W - 28, 12 do
      i = i + 1
      local y = floor(by(x + 4))
      local tri = poly{ { x, y }, { x + 8, y }, { x + 4, y + 7 } }
      local r = cols[i % 4 + 1]
      fill(tri, r.base) hline(x, x + 8, y, r.hi)
    end
    -- lanterns hanging from the beam
    for _, lx in ipairs({ 34, W - 35 }) do
      vline(lx, 13, 19, L.timber.edge)
      local cap = rect(lx - 5, 20, lx + 5, 22)
      local body = rect(lx - 4, 23, lx + 4, 33)
      local base = rect(lx - 5, 34, lx + 5, 35)
      rimOf(union(cap, body, base), L.timber)
      part(cap, L.timber, { nopop = true }) part(base, L.timber, { nopop = true })
      fill(body, L.glow.base) vline(lx - 4, 23, 33, L.timber.base) vline(lx + 4, 23, 33, L.timber.base)
      fill(rect(lx - 3, 24, lx - 1, 32), L.glow.hi) vline(lx + 3, 24, 33, L.glow.shade) vline(lx, 23, 33, L.timber.deep)
    end
    -- keep the compass corner calm: plain ground re-laid
    for y = 230, H - 1 do for x = 380, W - 1 do
      px(x, y, hash(x, y, 99) < .04 and L.ground.shade or L.ground.base)
    end end
  end

  -- shared stop furniture ------------------------------------------------
  local F = {
    c = c, L = L, HP = HP, W = W, H = H, HZ = HZ, VX = VX, ROAD_TOP = ROAD_TOP,
    px = px, rect = rect, poly = poly, fill = fill, part = part, hline = hline, vline = vline,
    union = union, rimOf = rimOf, hash = hash, shadow = shadow, courses = courses, speckle = speckle,
    window = window, door = door, crown = crown, maple = maple, tree = tree, palm = palm,
    building = building, roadM = function() return roadM end, xl = xl, xr = xr,
  }

  -- a wooden sign on one post, text-free (a board with a few pins)
  function F.sign(x, yTop, w, h)
    local post = rect(x, yTop + h, x + 1, yTop + h + 12)
    local board = rect(x - w // 2, yTop, x + w // 2, yTop + h)
    rimOf(union(post, board), L.timber)
    part(post, L.timber, { nopop = true }) part(board, L.board, { sep = true })
    for k = 0, w // 6 do px(x - w // 2 + 2 + k * 4, yTop + 2, L.produce.base) end
    hline(x - w // 2 + 2, x + w // 2 - 2, yTop + h // 2, L.board.deep)
  end

  -- a striped awning over a stall front, x0..x1 at y (top edge)
  function F.awning(x0, x1, y, r1, r2)
    local m = poly{ { x0, y }, { x1, y }, { x1 + 3, y + 8 }, { x0 - 3, y + 8 } }
    rimOf(m, r1)
    for x = x0 - 3, x1 + 3 do
      local r = ((x - x0) // 6) % 2 == 0 and r1 or r2
      for yy = y, y + 8 do if m:has(x, yy) then px(x, yy, yy == y and r.hi or (yy == y + 8 and r.deep or r.base)) end end
    end
    hline(x0 - 3, x1 + 3, y + 8, r1.deep)
  end

  -- a pond / stream blob with lighter ripple dashes
  function F.pond(m)
    rimOf(m, L.water)
    part(m, L.water, { inner = false })
    m:each(function(x, y) if hash(x, y, 31) < .03 then px(x, y, L.water.hi) end end)
  end

  -- a cask or basket on the ground
  function F.barrel(x, yb, r)
    local m = c:rrect(x - 4, yb - 9, x + 4, yb, 3)
    rimOf(m, L.timber) part(m, r or L.timber, { nopop = true })
    hline(x - 4, x + 4, yb - 6, L.roof.deep) hline(x - 4, x + 4, yb - 2, L.roof.deep)
  end

  -- finish: gate frame, outline, check, save (.aseprite + .png at native size)
  function F.finish()
    gate()
    c:finish{ outline = false }
    HP.assertClean(c)
    local base = o.out .. o.name
    c:save{ aseprite = base .. ".aseprite", png = base .. ".png", scale = 1 }
    print("saved " .. base)
  end

  return F
end

return M
