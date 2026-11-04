local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local function R(h,b,s,d) return {hi=h,base=b,shade=s,deep=d} end
local function form(c, m, r, o)
  o = o or {}
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
  if not o.noshade then
    local rows = {}
    m:each(function(x, y) local t = rows[y]
      if not t then rows[y] = { x, x } else t[1] = math.min(t[1], x) t[2] = math.max(t[2], x) end end)
    local frac, off = o.frac or 0.3, o.off or 2
    local list = {}
    m:each(function(x, y)
      if c:get(x, y) ~= r.base:lower() then return end
      local t = rows[y]
      local s = (x - t[1] + 0.5) / (t[2] - t[1] + 1) > 1 - frac
      if not m:has(x + off, y + off) then s = true end
      if s then list[#list + 1] = { x, y } end
    end)
    for _, p in ipairs(list) do c:put(p[1], p[2], r.shade, r) end
  end
  if o.pop then c:put(o.pop[1], o.pop[2], r.hi, r) c:put(o.pop[1] + 1, o.pop[2], r.hi, r) end
  return m
end
local function under(c, m, hex)
  m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end)
end
local idle = { { bob = 0 }, { bob = 1 } }
local walk = {
  { bob = 0, ly = 2, ry = -2, arm = -1, hem = 1 },
  { bob = 1, ly = 0, ry = -3, arm = 0, sx = -1 },
  { bob = 0, ly = -2, ry = 2, arm = 1, hem = -1 },
  { bob = 1, ly = -3, ry = 0, arm = 0, sx = 1 },
}
local function run(name, frame)
  local fr = {}
  for _, p in ipairs(idle) do fr[#fr + 1] = frame(p) end
  for _, p in ipairs(walk) do fr[#fr + 1] = frame(p) end
  local s = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
  s:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local GR = R("#b6e07a","#6cbc4e","#3f8a5a","#2a5a4e")
local EYE = R("#fff6d8","#f4e8b8","#c4b0a0","#8a7080")
local VEST = R("#e8a860","#c47a3e","#8a4e4a","#5a3244")
local BEL = R("#f2f0b0","#d8dc8a","#9aa87a","#5e7a6a")
local PAD = R("#8ad06a","#4a9a48","#2e6a52","#1e4440")
local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = "frog" }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  c:groundShadow(31.5, 68.5, 14.5, 3.5)
  -- big flat webbed feet
  local function foot(x, dy, dir)
    local m = c:ellipse(x, 68 + dy, 5, 2.2)
    m:add(c:rect(x+dir*5, 68+dy, x+dir*5, 69+dy))
    form(c, m, GR, { frac = 0.35, off = 1 }) under(c, m, GR.deep)
    c:put(x+dir*2, 68+dy, GR.shade) c:put(x+dir*4, 68+dy, GR.shade)
  end
  foot(26, p.ly or 0, -1) foot(39, p.ry or 0, 1)
  -- round tunic body
  local tun = c:ellipse(X(33)+0, 54+b, 12, 8.5)
  tun:add(c:ellipse(X(33)+(p.hem or 0), 61+b, 11, 4.5))
  form(c, tun, VEST, { frac = 0.3, off = 2 }) under(c, tun, VEST.deep)
  form(c, c:ellipse(X(33), 56+b, 5, 5), BEL, { frac = 0.3, off = 1, inner = false })
  for y = 52, 59, 3 do for x = 30, 36, 2 do c:put(X(x), y+b, BEL.shade) end end
  -- arms with webbed hands
  local la, ra = (p.arm or 0) * 2, -(p.arm or 0) * 2
  for _, a in ipairs({ {19,la,0.35,-1},{45,ra,0.6,1} }) do
    local arm = c:rrect(X(a[1]), 48+b, X(a[1])+3, 55+b+a[2], 1)
    form(c, arm, GR, { frac = a[3], off = 1 })
    local h = c:ellipse(X(a[1])+1.5, 57.5+b+a[2], 2.8, 1.8)
    form(c, h, GR, { frac = 0.35, off = 1, inner = false }) under(c, h, GR.deep)
  end
  -- wide chunky head
  local head = c:ellipse(X(33), 39+b, 15, 10)
  form(c, head, GR, { frac = 0.25, off = 1 })
  -- throat pouch
  form(c, c:ellipse(X(33), 47+b, 6, 2.5), BEL, { frac = 0.3, off = 1, inner = false })
  -- bulging eyes on top
  for _, e in ipairs({ {25,0.2},{41,0.55} }) do
    local bump = c:ellipse(X(e[1]), 30+b, 5, 4.5)
    form(c, bump, GR, { frac = 0.3, off = 1 })
    local ey = c:ellipse(X(e[1]), 31+b, 3.6, 3.4)
    form(c, ey, EYE, { frac = 0.3, off = 1, inner = false })
    c:rect(X(e[1])-1, 30+b, X(e[1])+0, 32+b)
    c:put(X(e[1])-1, 31+b, "#2b1c26") c:put(X(e[1]), 31+b, "#2b1c26") c:put(X(e[1])-1, 32+b, "#2b1c26") c:put(X(e[1]), 32+b, "#2b1c26")
    c:put(X(e[1])-1, 30+b, EYE.hi)
  end
  -- wide smile, nostrils, cheeks, spots
  for x = 24, 42 do
    local y = 44
    if x < 27 or x > 39 then y = 43 end
    c:put(X(x), y+b, GR.deep)
  end
  c:put(X(31), 38+b, GR.deep) c:put(X(35), 38+b, GR.deep)
  c:cheek(X(22), 41+b) c:cheek(X(44), 41+b)
  for _, q in ipairs({ {28,36},{38,35},{33,35},{40,41} }) do c:put(X(q[1]), q[2]+b, GR.shade) end
  -- quirk: tiny lily pad with pink bud on head
  local pad = c:ellipse(X(33), 34+b, 4, 1.8)
  form(c, pad, PAD, { frac = 0.3, off = 1, inner = false })
  c:put(X(35), 34+b, GR.hi)
  c:put(X(33), 32+b, "#ffb8d0") c:put(X(32), 32+b, "#e8789c") c:put(X(34), 32+b, "#e8789c") c:put(X(33), 31+b, "#fff0f4")
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
run("folk-frog", frame)
