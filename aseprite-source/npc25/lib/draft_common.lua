-- Generic blocky DRAFT figure shared by species files. Replace per species with real art (stage 3).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local M = {}
-- sp fields: body (ramp), skin (ramp), cap (hex ramp name 'hat'), quirk{color,w,h,x,y}, bw (body width), top (head top idle)
function M.draw(img, view, f, sp)
  local o = N.offsets(sp, f)
  local c = sp.c
  local cx = 32
  local bw, bh = sp.bw, 26
  local bx, by = cx - bw // 2, 36 + o.body
  local hx, hy = cx - 8, sp.top + o.head + (sp.headdrop or 0)
  local side = view == "side"
  if side then bx = bx + 2 end
  -- feet (sole row 70, outline gives 71); raised feet move up
  local lowL, lowR = 70 + o.footL, 70 + o.footR
  local swap = f >= 6 -- phase tell so mirrored walk frames differ
  local fl, fr = swap and c.fshade or c.fbase, swap and c.fbase or c.fshade
  local fxl, fxr = bx + 2, bx + bw - 8
  if side then fxl, fxr = bx + 3 + (o.footL ~= 0 and 3 or 0), bx + bw - 9 - (o.footR ~= 0 and 3 or 0) end
  N.rect(img, fxl, lowL - 3, 6, 4, fl)
  N.rect(img, fxr, lowR - 3, 6, 4, fr)
  if lowL < 70 then N.rect(img, fxl + 1, 62 + o.body, 4, lowL - 62 - o.body - 3, fl) end
  if lowR < 70 then N.rect(img, fxr + 1, 62 + o.body, 4, lowR - 62 - o.body - 3, fr) end
  -- body
  N.rect(img, bx, by, bw, bh, c.body)
  N.rect(img, bx + bw - 4, by + 2, 4, bh - 2, c.bshade)
  N.rect(img, bx, by, bw, 2, c.bhi)
  if view == "front" then N.rect(img, cx - 6, by + 8, 12, 14, c.belly) end
  -- arms (x offset)
  local ay = by + 6
  local lx, rx = bx - 3 + (side and 0 or o.armL), bx + bw - 1 + (side and 0 or o.armR)
  if side then lx = bx + 6 + o.armL; rx = bx + bw - 12 + o.armR end
  N.rect(img, lx, ay, 4, 12, c.arm)
  if not side then N.rect(img, rx, ay, 4, 12, c.arm) end
  -- head
  local hxx = side and hx + 4 or hx
  N.rect(img, hxx, hy + 4, 16, 18, c.head)
  N.rect(img, hxx, hy, 16, 5, c.hat)           -- hat/spine top
  N.rect(img, hxx - 3, hy + 3, 22, 2, c.hat)   -- brim
  if view == "front" then
    N.rect(img, hxx + 3, hy + 10, 2, 3, c.ink); N.rect(img, hxx + 11, hy + 10, 2, 3, c.ink)
    N.px(img, hxx + 7, hy + 15, c.ink); N.px(img, hxx + 8, hy + 15, c.ink)
  elseif side then
    N.rect(img, hxx + 16, hy + 12, 4, 4, c.head); N.px(img, hxx + 19, hy + 13, c.ink)
    N.rect(img, hxx + 11, hy + 10, 2, 3, c.ink)
  end
  -- quirk block follows body y
  local q = sp.quirk
  local qx = q.x[view] or q.x.front
  local sway = (f == 5 or f == 8) and 1 or 0
  N.rect(img, qx + sway + (o.armL > 0 and 1 or 0), q.y + o.body, q.w, q.h, c.q)
  N.px(img, qx + sway, q.y + o.body, c.qhi)
  N.outline(img)
end

-- ===== Body-plan drafts (stage 2). All blocky; replace per species in stage 3. =====
-- Rules shared by every drafter below: offsets come from N.offsets(sp, f); head top row = sp.T + o.head;
-- lowest opaque row is 71 (shadow, or the dangling foot for flyers); nothing above the head top.
local function ctx(sp, f)
  local o = N.offsets(sp, f)
  return o, sp.c, 32, sp.T + 1 + o.head
end
local function shadow()
  return function(img)
    N.ellipse(img, 19, 65, 27, 6, N.hex("#74758c"))
    N.ellipse(img, 19, 65, 24, 4, N.hex("#aaa9b8"))
  end
end
local drawShadow = shadow()
-- quirk block follows body y, sways on x on frames 5 and 8
local function quirk(img, sp, view, f, anchor, bx, by, bw, top, cx)
  local q, c = sp.quirk, sp.c
  local x, y
  if anchor == "crown" then x, y = cx - q.w // 2 + (view == "side" and 3 or 0), top + 1
  elseif anchor == "neck" then x, y = cx - q.w // 2, top + 11
  elseif anchor == "chest" then x, y = cx - q.w // 2 + (view == "side" and 2 or 0), by + 8
  elseif anchor == "hand" then
    y = by + 10
    if view == "back" then x = bx - q.w - 1 else x = bx + bw + 1 end
  elseif anchor == "back" then
    if view == "front" then x, y = bx + bw - q.w - 1, by + 1
    elseif view == "back" then x, y = cx - q.w // 2, by + 4
    else x, y = bx + 2, by + 3 end
  else x, y = cx - q.w // 2, by + 8 end
  x = x + ((f == 5 or f == 8) and 1 or 0)
  N.rect(img, x, y, q.w, q.h, c.q)
  if q.h > 1 then N.rect(img, x, y + q.h - 1, q.w, 1, c.qshade) end
  N.px(img, x, y, c.qhi)
end

-- hopper: frog-like, eye bumps on the head top, hind legs, shadow keeps row 71 on airborne frames
function M.hopper(img, view, f, sp)
  local o, c, cx, top = ctx(sp, f)
  local side = view == "side"
  drawShadow(img)
  local bw, bh = sp.bw, 30
  local bx = cx - bw // 2 - (side and 2 or 0)
  local by = sp.T + 10 + o.body
  local function leg(x, foot, col, sh)
    local sole = 70 + foot
    local y0 = by + bh - 10
    N.rect(img, x, y0, 7, sole - 2 - y0, col)
    N.rect(img, x + 5, y0, 2, sole - 2 - y0, sh)
    N.rect(img, x - 1, sole - 2, 11, 3, col)
    N.rect(img, x + 8, sole - 2, 2, 3, sh)
  end
  if side then
    leg(bx + 9, o.footR, c.bshade, c.deep)
    leg(bx + 2, o.footL, c.body, c.bshade)
  else
    leg(bx - 2, o.footL, c.body, c.bshade)
    leg(bx + bw - 5, o.footR, c.body, c.bshade)
  end
  N.rect(img, bx, by, bw, bh, c.body)
  N.rect(img, bx + bw - 4, by + 2, 4, bh - 2, c.bshade)
  N.rect(img, bx, by, bw, 2, c.bhi)
  if view == "front" then
    N.rect(img, cx - 6, by + 6, 12, 10, c.belly)
    N.rect(img, cx - 7, by + 16, 14, 10, c.acc)
  elseif view == "back" then
    N.rect(img, bx + 3, by, 3, 12, c.acc); N.rect(img, bx + bw - 6, by, 3, 12, c.acc)
    N.rect(img, bx + 3, by + 12, bw - 6, 12, c.accs)
  else
    N.rect(img, bx + 3, by + 14, bw - 6, 10, c.acc)
  end
  -- arms (armL/armR raise the arm)
  if side then
    N.rect(img, bx + bw - 6 + (o.armL > 0 and 1 or 0), by + 8 - o.armL, 4, 10, c.bshade)
  else
    N.rect(img, bx - 4 - (o.armL > 0 and 1 or 0), by + 6 - o.armL, 4, 12, c.body)
    N.rect(img, bx + bw + (o.armR > 0 and 1 or 0), by + 6 - o.armR, 4, 12, c.body)
  end
  -- head with eye bumps
  local hx = cx - 9 + (side and 3 or 0)
  local hy = top + 3
  N.rect(img, hx, hy, 18, 12, c.head)
  N.rect(img, hx, hy + 9, 18, 3, c.bshade)
  if side then
    N.rect(img, hx + 10, top, 6, 4, c.head)
    N.rect(img, hx + 17, hy + 4, 4, 7, c.head)
    N.rect(img, hx + 11, top + 1, 3, 2, c.eye); N.px(img, hx + 13, top + 2, c.ink)
    N.rect(img, hx + 9, hy + 9, 7, 3, c.belly)
    N.rect(img, hx + 15, hy + 8, 6, 1, c.ink)
  else
    N.rect(img, hx + 1, top, 5, 4, c.head); N.rect(img, hx + 12, top, 5, 4, c.head)
    if view == "front" then
      N.rect(img, hx + 2, top + 1, 3, 2, c.eye); N.px(img, hx + 3, top + 2, c.ink)
      N.rect(img, hx + 13, top + 1, 3, 2, c.eye); N.px(img, hx + 14, top + 2, c.ink)
      N.rect(img, hx + 3, hy + 8, 12, 1, c.ink)
    end
  end
  quirk(img, sp, view, f, sp.quirk.anchor, bx, by, bw, top, cx)
  N.outline(img)
end

-- six-legged: domed shell, small head with antennae, three leg pairs in a tripod gait
-- (footL = tripod A: L front, R mid, L back; footR = tripod B; armL/armR shift the front legs)
function M.sixleg(img, view, f, sp)
  local o, c, cx, top = ctx(sp, f)
  local side = view == "side"
  drawShadow(img)
  local bh = 26
  local by = sp.T + 9 + o.body
  local function leg(x, y0, sole, col)
    N.rect(img, x, y0, 3, sole - y0 + 1, col)
  end
  if side then
    local sw = math.min(26, sp.W - 12)
    local bx = cx - sw // 2 - 3
    local step = (sw - 8) // 2
    for i = 0, 2 do   -- far legs first (shade), group opposite to the near leg
      local grpA = (i % 2 == 1)
      leg(bx + 5 + i * step, by + bh - 6, 70 + (grpA and o.footL or o.footR), c.bshade)
    end
    for i = 0, 2 do
      local grpA = (i % 2 == 0)
      leg(bx + 2 + i * step + (i == 0 and o.armL or 0), by + bh - 6, 70 + (grpA and o.footL or o.footR), c.acc)
    end
    N.rect(img, bx + 2, by, sw - 4, bh, c.body); N.rect(img, bx, by + 3, sw, bh - 6, c.body)
    N.rect(img, bx, by + bh - 8, sw, 5, c.bshade)
    N.rect(img, bx + 2, by, sw - 4, 2, c.bhi)
    N.rect(img, bx + 4, by + 8, 2, 2, c.deep)
    local hx, hy = bx + sw - 1, top + 3
    N.rect(img, hx, hy, 9, 10, c.head)
    N.rect(img, hx + 6, hy + 3, 2, 2, c.eye); N.px(img, hx + 7, hy + 4, c.ink)
    N.rect(img, hx + 4, top, 1, 4, c.deep); N.rect(img, hx + 3, top, 3, 1, c.acc)
    N.rect(img, hx - 3, hy + 8, 6, 3, c.acc)
    quirk(img, sp, view, f, sp.quirk.anchor, bx, by, sw, top, cx)
  else
    local bw = sp.bw
    local bx = cx - bw // 2
    for i = 0, 2 do
      local ytop = by + bh - 8 + i * 2
      local lA, rA = (i % 2 == 0), (i % 2 == 1)
      leg(bx - 3 - i + (i == 0 and o.armL or 0), ytop, 70 + (lA and o.footL or o.footR), c.acc)
      leg(bx + bw + i + (i == 0 and o.armR or 0), ytop, 70 + (rA and o.footL or o.footR), c.acc)
    end
    N.rect(img, bx + 2, by, bw - 4, bh, c.body); N.rect(img, bx, by + 3, bw, bh - 6, c.body)
    N.rect(img, bx + bw - 5, by + 3, 5, bh - 6, c.bshade)
    N.rect(img, bx + 2, by, bw - 4, 2, c.bhi)
    local hx, hy = cx - 6, top + 3
    N.rect(img, hx, hy, 12, 10, c.head)
    N.rect(img, hx + 2, top, 1, 4, c.deep); N.rect(img, hx + 9, top, 1, 4, c.deep)
    N.rect(img, hx + 1, top, 3, 1, c.acc); N.rect(img, hx + 8, top, 3, 1, c.acc)
    if view == "front" then
      N.rect(img, hx + 2, hy + 3, 3, 3, c.eye); N.px(img, hx + 3, hy + 4, c.ink)
      N.rect(img, hx + 7, hy + 3, 3, 3, c.eye); N.px(img, hx + 8, hy + 4, c.ink)
      N.rect(img, cx - 7, hy + 9, 14, 3, c.acc)
      N.rect(img, cx - 5, by + 14, 10, 8, c.belly)
    else
      N.rect(img, cx, by + 2, 1, bh - 4, c.deep)
      N.rect(img, bx + 4, by + 8, 3, 3, c.deep); N.rect(img, bx + bw - 8, by + 14, 3, 3, c.deep)
    end
    quirk(img, sp, view, f, sp.quirk.anchor, bx, by, bw, top, cx)
  end
  N.outline(img)
end

-- crawler: snail. Foot halves rise with footL/footR, eyestalks lean with armL/armR, shell bobs with the body
function M.crawler(img, view, f, sp)
  local o, c, cx, top = ctx(sp, f)
  local side = view == "side"
  drawShadow(img)
  local sy = 22 + o.body
  local function stalks(x1, x2)
    N.rect(img, x1 + o.armL, top, 2, 12, c.body); N.rect(img, x2 + o.armR, top, 2, 12, c.body)
    N.rect(img, x1 - 1 + o.armL, top, 4, 2, c.deep); N.rect(img, x2 - 1 + o.armR, top, 4, 2, c.deep)
    N.px(img, x1 + o.armL, top, c.eye); N.px(img, x2 + o.armR, top, c.eye)
  end
  local function shell(x, w)
    N.ellipse(img, x, sy, w, 30, c.acc)
    N.ellipse(img, x + 4, sy + 6, w - 8, 18, c.accs)
    N.ellipse(img, x + 8, sy + 10, w - 16, 10, c.acc)
    N.ellipse(img, x + w - 7, sy + 8, 5, 20, c.accs)
    N.rect(img, x + w // 2 - 1, sy + 14, 3, 3, c.deep)
  end
  if side then
    N.rect(img, 11, 56, 20, 70 + o.footL - 56 + 1, c.body)
    N.rect(img, 31, 56, 19, 70 + o.footR - 56 + 1, c.body)
    N.rect(img, 11, 66, 39, 4, c.bshade)
    N.rect(img, 40, top + 10, 10, 50 - (top + 10), c.head)
    N.rect(img, 38, top + 8, 12, 10, c.head)
    N.rect(img, 41, top + 12, 2, 2, c.eye)
    stalks(41, 46)
    shell(13, 26)
    quirk(img, sp, view, f, "x", 0, sy + 8, 0, top, 26 - sp.quirk.w // 2 + 6)
  else
    if view == "back" then stalks(cx - 6, cx + 4) end
    N.rect(img, cx - 11, 52, 11, 70 + o.footL - 52 + 1, c.body)
    N.rect(img, cx, 52, 11, 70 + o.footR - 52 + 1, c.body)
    N.rect(img, cx - 11, 64, 22, 6, c.bshade)
    shell(cx - 13, 26)
    if view == "front" then
      N.rect(img, cx - 7, top + 9, 14, 12, c.head)
      N.rect(img, cx - 5, top + 13, 3, 3, c.eye); N.rect(img, cx + 2, top + 13, 3, 3, c.eye)
      N.px(img, cx - 4, top + 14, c.ink); N.px(img, cx + 3, top + 14, c.ink)
      N.rect(img, cx - 8, top + 21, 16, 3, c.acc)
      stalks(cx - 6, cx + 4)
    end
    quirk(img, sp, view, f, "x", 0, sy + 8, 0, top, cx - sp.quirk.w // 2 + 4)
  end
  N.outline(img)
end

-- flyer: hover with wing flap (armL/armR = wing spread, + wider), no shadow;
-- the dangling left foot (footL = 0) holds row 71, the right foot sways
function M.flyer(img, view, f, sp)
  local o, c, cx, top = ctx(sp, f)
  local side = view == "side"
  local bw, bh = sp.bw, 28
  local bx = cx - bw // 2 - (side and 2 or 0)
  local by = sp.T + 11 + o.body
  local y0 = by + bh - 3
  local soleL, soleR = 70 + o.footL, 70 + o.footR
  if side then
    N.rect(img, bx + 9, y0, 3, soleR - y0 + 1, c.bshade)
    N.rect(img, bx + 3, y0, 3, soleL - y0 + 1, c.acc)
  else
    N.rect(img, cx - 5, y0, 3, soleL - y0 + 1, c.acc)
    N.rect(img, cx + 2, y0, 3, soleR - y0 + 1, c.bshade)
  end
  local wl, wr = 7 + o.armL, 7 + o.armR
  local wh = 14 + 2 * math.max(o.armL, 0) + (o.armL < 0 and 0 or 0)
  local wy = by + 3 - math.max(o.armL, 0)
  if side then
    N.rect(img, bx - wl + 1, wy + 2, wl + 1, wh, c.wing)
    N.rect(img, bx - wl + 1, wy + wh - 1, wl + 1, 3, c.bshade)
  else
    N.rect(img, bx - wl, wy, wl, wh, c.wing); N.rect(img, bx - wl, wy + wh - 3, wl, 3, c.bshade)
    N.rect(img, bx + bw, wy, wr, wh, c.wing); N.rect(img, bx + bw, wy + wh - 3, wr, 3, c.bshade)
  end
  N.rect(img, bx, by, bw, bh, c.body)
  N.rect(img, bx + bw - 4, by + 2, 4, bh - 2, c.bshade)
  N.rect(img, bx, by, bw, 2, c.bhi)
  if view == "front" then
    N.rect(img, cx - 4, by + 8, 8, 14, c.belly)
  elseif view == "back" then
    N.rect(img, cx, by + 2, 1, bh - 4, c.deep)
  else
    N.rect(img, bx + 3, by + 14, bw - 6, 8, c.belly)
  end
  local hx, hy = cx - 7 + (side and 3 or 0), top + 3
  N.rect(img, hx, hy, 14, 12, c.head)
  N.rect(img, hx, hy + 9, 14, 3, c.bshade)
  if side then
    N.rect(img, hx + 6, top, 2, 4, c.head)
    N.rect(img, hx + 14, hy + 5, 3, 3, c.head)
    N.rect(img, hx + 9, hy + 4, 3, 3, c.eye); N.px(img, hx + 11, hy + 5, c.ink)
  else
    N.rect(img, hx + 2, top, 2, 4, c.head); N.rect(img, hx + 10, top, 2, 4, c.head)
    if view == "front" then
      N.rect(img, hx + 2, hy + 4, 3, 3, c.eye); N.px(img, hx + 3, hy + 5, c.ink)
      N.rect(img, hx + 9, hy + 4, 3, 3, c.eye); N.px(img, hx + 10, hy + 5, c.ink)
    end
  end
  quirk(img, sp, view, f, sp.quirk.anchor, bx, by, bw, top, cx)
  N.outline(img)
end
return M
