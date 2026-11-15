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
return M
