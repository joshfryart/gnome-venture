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
local FUR = R("#d9a066","#a8683a","#6f4258","#43283a")
local QUILL = R("#c89a62","#7a4a34","#4d3040","#33212f")
local MUZ = R("#fff0d0","#f0cf9c","#b88a86","#7a5566")
local TUN = R("#9fc46a","#6a9e4e","#46705a","#2f4a48")
local BOOT = R("#a8683a","#7a4a34","#4d3040","#33212f")
local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = "hedgehog" }
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  local function boot(x, dy)
    local m = c:ellipse(x, 68 + dy, 3.5, 2)
    form(c, m, BOOT, { frac = 0.35, off = 1 }) under(c, m, BOOT.deep)
  end
  boot(27, p.ly or 0) boot(38, p.ry or 0)
  -- back quills peeking behind body
  local back = c:poly{ {X(21),47+b},{X(17),52+b},{X(21),56+b},{X(19),61+b},{X(24),60+b},{X(44),60+b},{X(47),61+b},{X(45),56+b},{X(49),52+b},{X(45),47+b} }
  form(c, back, QUILL, { frac = 0.4, off = 2 })
  local tun = c:poly{ {X(24),46+b},{X(42),46+b},{X(46),61+b},{X(20),61+b} }
  tun:add(c:ellipse(X(33)+(p.hem or 0), 62+b, 12.5, 4))
  form(c, tun, TUN, { frac = 0.3, off = 2 }) under(c, tun, TUN.deep)
  -- belly patch
  form(c, c:ellipse(X(33), 55+b, 4, 4), MUZ, { frac = 0.3, off = 1, inner = false })
  -- arms
  local la, ra = (p.arm or 0) * 2, -(p.arm or 0) * 2
  for _, a in ipairs({ {18,la,0.35},{46,ra,0.6} }) do
    local arm = c:rrect(X(a[1]), 47+b, X(a[1])+3, 55+b+a[2], 1)
    form(c, arm, TUN, { frac = a[3], off = 1 })
    form(c, c:ellipse(X(a[1])+1.5, 57.5+b+a[2], 2, 1.7), MUZ, { frac = 0.35, off = 1, inner = false })
  end
  -- ears
  form(c, c:ellipse(X(21), 34+b, 2.5, 3), FUR, { frac = 0.3, off = 1 })
  form(c, c:ellipse(X(45), 34+b, 2.5, 3), FUR, { frac = 0.5, off = 1 })
  c:put(X(21), 34+b, "#d99a8a") c:put(X(45), 34+b, "#d99a8a")
  -- head
  local head = c:ellipse(X(33), 38+b, 13, 9.5)
  form(c, head, FUR, { frac = 0.25, off = 1 })
  -- spiky crown
  local crown = HP.mask()
  local tips = {}
  for i, x in ipairs({19,23,27,31,35,39,43,47}) do
    local tipy = 21 + math.floor(math.abs(x-33)*0.45) + ((i%2==0) and -1 or 1)
    crown:add(c:poly{ {X(x-3),33+b},{X(x),tipy+b},{X(x+3),33+b} })
    tips[#tips+1] = {X(x), tipy+b}
  end
  crown:add(c:ellipse(X(33), 31+b, 13, 4))
  form(c, crown, QUILL, { frac = 0.35, off = 2 })
  for _, t in ipairs(tips) do c:put(t[1], t[2]+1, QUILL.hi) end
  -- fur fringe line under crown
  for x = 22, 44 do c:put(X(x), 33+b + ((x%3==0) and 1 or 0), FUR.shade) end
  -- muzzle, nose
  form(c, c:ellipse(X(33), 42+b, 7, 4.5), MUZ, { frac = 0.3, off = 1, inner = false })
  form(c, c:ellipse(X(33.5), 40+b, 2, 1.5), R("#6a4a5a","#43283a","#2f1c2c","#2b1c26"), { off = 1, frac = 0.4, inner = false })
  c:put(X(32), 39+b, "#fff0d0")
  c:eyeSmall(X(27), 37+b) c:eyeSmall(X(38), 37+b)
  c:cheek(X(24), 41+b) c:cheek(X(42), 41+b)
  c:put(X(31), 44+b, MUZ.deep) c:put(X(32), 45+b, MUZ.deep) c:put(X(34), 45+b, MUZ.deep) c:put(X(35), 44+b, MUZ.deep)
  -- quirk: red berry skewered on a quill
  form(c, c:ellipse(X(26), 23+b, 2, 2), R("#ffb0a0","#e0483c","#a02e4e","#6a1e3e"), { frac = 0.4, off = 1, inner = false })
  c:put(X(25), 22+b, "#fff0d0")
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
run("npc-hedgehog", frame)
