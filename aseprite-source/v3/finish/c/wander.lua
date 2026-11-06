-- wander-step.lua: 5 frames 96x64: a tiny bushy-bearded gnome steps off a stone path edge into tall grass.
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local S0 = dofile(SRC .. "/v3/tree-yard/common.lua")
local INK = "#2b1c26"
local floor, max, min, sin = math.floor, math.max, math.min, math.sin
local main = HP.canvas{ w = 480, h = 64, scale = 1, name = "wander-step" }
local S = S0.setup(main)
local hash = S.hash
local STONE, GREEN, LEAF, BARN, SBLUE, CREAM, TIMB, GOLD, ROSE = S.STONE, S.GREEN, S.LEAF, S.BARN, S.SBLUE, S.CREAM, S.TIMB, S.GOLD, S.ROSE
local PATHTOP, PATHEND, GRASSY = 59, 54, 62

local function newc() return HP.canvas{ w = 96, h = 64, scale = 1 } end
local function put(g, x, y, col) x, y = floor(x + .5), floor(y + .5) if x >= 0 and x < 96 and y >= 0 and y < 64 then g.pix[y * 96 + x] = col end end
local function R(g, x0, y0, x1, y1, col) x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5) for y = y0, y1 do for x = x0, x1 do put(g, x, y, col) end end end

local function ground(g)
  -- stone path: slab with lit top, shaded front, cobble seams, ends in a rounded edge at PATHEND
  for x = 0, PATHEND do
    local edge = (x > PATHEND - 2) and 1 or 0
    for y = PATHTOP, 63 do
      local col = STONE[5]
      if y == PATHTOP then col = STONE[6] elseif y >= PATHTOP + 3 then col = STONE[3] elseif y >= PATHTOP + 2 then col = STONE[4] end
      if (x + (y // 3) * 4) % 9 == 0 and y > PATHTOP then col = STONE[2] end
      if x >= PATHEND - 1 then col = STONE[3] end
      put(g, x, y, col)
    end
  end
  -- ink around the slab
  for x = 0, PATHEND + 1 do put(g, x, PATHTOP - 1, INK) end
  for y = PATHTOP - 1, 63 do put(g, PATHEND + 1, y, INK) end
  -- grass floor
  for x = PATHEND + 2, 95 do for y = GRASSY, 63 do put(g, x, y, (y == GRASSY) and GREEN[5] or GREEN[3]) end end
  for x = PATHEND + 2, 95 do if hash(x, 1, 4) > .6 then put(g, x, 63, GREEN[2]) end end
  for y = GRASSY, 63 do put(g, PATHEND + 1, y, INK) end
end
local function blade(g, x, by, h, lean, ramp, seed)
  for k = 0, h - 1 do
    local lx = x + floor(lean * (k / h) ^ 1.5 + .5)
    local w = (k < h - 3) and 2 or 1
    put(g, lx - 1, by - k, INK) ; put(g, lx + w, by - k, INK)
    put(g, lx, by - k, ramp[k > h * .6 and 5 or 4]); if w == 2 then put(g, lx + 1, by - k, ramp[3]) end
  end
  put(g, x + floor(lean + .5), by - h, INK); put(g, x + floor(lean + .5) - 1, by - h + 1, INK)
end
local function tallGrass(g, fr, front)
  for i = 0, 17 do
    local x = PATHEND + 5 + i * 2 + floor(hash(i, 3, 6) * 2)
    if x < 95 and (i % 2 == (front and 1 or 0)) then
      local h = 11 + floor(hash(i, 5, 7) * 8)
      if front then h = 5 + floor(hash(i, 5, 7) * 6) end
      local lean = 2.2 * sin(fr * 1.3 + i * .9) + 1
      blade(g, x, GRASSY + 1, h, lean, (i % 3 == 0) and LEAF or GREEN, i)
      if not front and i % 4 == 0 then put(g, x + lean, GRASSY - h - 1, "#fac4d4"); put(g, x + lean + 1, GRASSY - h - 1, "#f4a8b8") end
    end
  end
end

-- the gnome, drawn on a scratch canvas then ink-rimmed as a whole
local function gnome(g, cx, foot, a)   -- a: {sw = leg swing -1..1, lift = swinging foot rise, bob, wave}
  local bob = a.bob or 0
  local fy = foot
  local function boot(x, y) R(g, x, y - 2, x + 4, y, TIMB[3]); R(g, x, y - 2, x + 4, y - 2, TIMB[4]); put(g, x + 4, y - 1, TIMB[2]); put(g, x + 4, y, TIMB[2]) end
  local fx, bx = cx + 2 + a.sw * 3, cx - 5 - a.sw * 3   -- front foot, back foot (x of boot left)
  local fyF, fyB = a.fy or fy, a.by or fy
  -- legs
  R(g, bx + 1, fyB - 7, bx + 2, fyB - 3, SBLUE[2]); boot(bx, fyB)
  R(g, fx + 1, fyF - 7 - (fy - fyF) * 0, fx + 2, fyF - 3, SBLUE[3]); boot(fx, fyF)
  -- tunic
  local ty = fy - 19 + bob
  R(g, cx - 5, ty, cx + 5, ty + 11, SBLUE[4]); R(g, cx - 5, ty, cx - 4, ty + 11, SBLUE[5]); R(g, cx + 4, ty, cx + 5, ty + 11, SBLUE[3])
  R(g, cx - 5, ty + 11, cx + 5, ty + 11, SBLUE[3])
  R(g, cx - 5, ty + 8, cx + 5, ty + 8, GOLD[4]); put(g, cx, ty + 8, GOLD[6]); put(g, cx + 1, ty + 8, GOLD[6])   -- belt + buckle
  -- arms
  local ax = cx - 7 - a.sw * 2
  R(g, ax, ty + 1, ax + 2, ty + 6, SBLUE[4]); R(g, ax, ty + 7, ax + 2, ty + 8, ROSE[5])
  local bx2 = cx + 6 + a.sw * 2
  R(g, bx2, ty + 1, bx2 + 2, ty + 6, SBLUE[3]); R(g, bx2, ty + 7, bx2 + 2, ty + 8, ROSE[4])
  -- beard: big bushy, rough edge, covers the chest
  local hy = ty - 7      -- head centre y
  for y = hy + 1, hy + 10 do
    local t = (y - hy - 1) / 9
    local hw = floor(8 - t * t * 4 + (hash(y, cx, 8) * 1.6))
    for x = cx - hw, cx + hw + 1 do
      local lit = x < cx - 2 and y < hy + 7
      local col = (hash(x, y, 9) > .8) and CREAM[4] or (lit and CREAM[6] or (x > cx + 2 and CREAM[4] or CREAM[5]))
      if y > hy + 8 then col = CREAM[4] end
      put(g, x, y, col)
    end
  end
  -- face
  R(g, cx - 3, hy - 2, cx + 4, hy + 3, ROSE[6]); R(g, cx - 3, hy + 2, cx + 4, hy + 3, ROSE[5])
  put(g, cx - 1, hy, INK); put(g, cx + 2, hy, INK)
  R(g, cx + 4, hy + 1, cx + 6, hy + 3, ROSE[3]); put(g, cx + 5, hy + 1, ROSE[4])   -- nose (facing right)
  -- moustache hint
  R(g, cx - 3, hy + 4, cx + 5, hy + 5, CREAM[5])
  -- hat: red cone with a bent tip leaning right, brim and band
  local hh = 15
  for k = 0, hh - 1 do
    local y = hy - 3 - k
    local half = floor((hh - k) * 7 / hh + .5)
    local shift = floor((k / hh) ^ 2 * 7)
    for x = cx - half + shift, cx + half + shift do
      local col = BARN[4]
      if x < cx - half + shift + 2 then col = BARN[5] elseif x > cx + half + shift - 3 then col = BARN[3] end
      if hash(x, y, 3) > .93 then col = BARN[3] end
      put(g, x, y, col)
    end
  end
  R(g, cx - 8, hy - 3, cx + 8, hy - 2, BARN[3]); R(g, cx - 8, hy - 3, cx - 4, hy - 3, BARN[5])
  R(g, cx - 6, hy - 5, cx + 6, hy - 4, GOLD[4]); R(g, cx - 6, hy - 5, cx - 3, hy - 5, GOLD[5])
  R(g, cx + 4 + 7, hy - 3 - hh + 1, cx + 5 + 7, hy - 3 - hh + 2, BARN[3])   -- bent tip
  R(g, cx + 12, hy - 3 - hh + 3, cx + 12, hy - 3 - hh + 4, BARN[3])
end
local function rimAll(g)
  local m = HP.mask()
  for k in pairs(g.pix) do m:set(k % 96, k // 96) end
  local r = m:grow(1):cut(m)
  r:each(function(x, y) if g.pix[y * 96 + x] == nil then put(g, x, y, INK) end end)
end

local frames = {
  { cx = 38, a = { sw = 1,  bob = 0 } },
  { cx = 44, a = { sw = -.3, bob = -1, by = 58 } },
  { cx = 51, a = { sw = 1,  bob = 0, fy = 61 } },                    -- front foot stepping down onto grass
  { cx = 58, a = { sw = -.2, bob = 0, fy = 61, by = 61 } },         -- both feet in the grass
  { cx = 65, a = { sw = 1,  bob = -1, fy = 61, by = 61 } },
}
local fyPath = 58
for i, f in ipairs(frames) do
  local back = newc(); ground(back); tallGrass(back, i, false)
  local gn = newc()
  local foot = fyPath
  if f.cx >= 56 then foot = 61 end
  gnome(gn, f.cx, foot, f.a)
  rimAll(gn)
  -- composite: ground, gnome, front blades
  local fr = newc()
  for k, v in pairs(back.pix) do fr.pix[k] = v end
  for k, v in pairs(gn.pix) do fr.pix[k] = v end
  tallGrass(fr, i, true)
  for y = 0, 63 do for x = 0, 95 do local v = fr.pix[y * 96 + x]; if v then main.pix[y * 480 + (i - 1) * 96 + x] = v end end end
end
main:save{ aseprite = d .. "/out/wander-step.aseprite", png = d .. "/out/wander-step.png", scale = 1 }
main:save{ png = "/tmp/claude-0/-home-user-gnome-venture/06fd8064-60b9-5d47-ba02-41f9cb9f6245/scratchpad/wander_x3.png", scale = 3 }
