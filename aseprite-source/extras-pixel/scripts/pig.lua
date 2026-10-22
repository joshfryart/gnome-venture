-- puzzles/pig.gif: pig bouncing in a mud puddle on a sunny meadow (Stitched Toy scene)
-- 480x320, 20 frames x 70 ms, loops forever, solid background. Drawn on a 240x160 grid, written at 2x.
-- Families: sky/haze = water, hills/grass = moss, pig = petal (pale treatment), mud = soil, fence = soil cream, sun = gold.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/"
local N, DUR = 20, 70
local pi, sin, cos, floor = math.pi, math.sin, math.cos, math.floor
local function rnd(v) return floor(v + 0.5) end

local BOB  = { 0, -4, -8, -11, -13, -14, -13, -11, -8, -4 }      -- pig height (two hops per loop)
local EAR  = { 0, -2, -4, -3, -2, 0, 0, -1, -1, 0 }              -- ear tip lag
local WING = { "c","m","o","c","m","o","m","c","o","m","c","m","o","c","m","o","m","c","o","m" }

local PINK  = GV.ramp("#f6b8cf", { shade = "#e48aaa", deep = "#c06a8e", bounce = "#ec9cb4" })                                 -- petal light (pale)
local BELLY = GV.ramp("#fbd3e0", { pale = true, shade = "#f6b8cf", deep = "#eaa3bd", bounce = "#f2b0c6" })
local SNOUT = GV.ramp("#ef9dbb", { shade = "#d77a9c", deep = "#a8587a", bounce = "#e08aa8" })
local FAR   = GV.ramp("#e48aaa", { shade = "#c97393", deep = "#9a5274", bounce = "#d58099" })
local FLOWERS = {  -- x, y (head centre), colour, sway phase
  { 14, 118, "#e46a9b", 0.0 }, { 60, 122, "#f1ece0", 1.3 }, { 34, 131, "#f5cf6a", 2.1 },
  { 80, 138, "#dd3a2a", 0.7 }, { 100, 133, "#dd3a2a", 2.9 }, { 140, 130, "#7b66b4", 1.8 },
  { 172, 121, "#e46a9b", 0.4 }, { 197, 133, "#f5cf6a", 2.5 }, { 222, 122, "#f1ece0", 1.1 },
  { 214, 143, "#7b66b4", 3.4 }, { 120, 150, "#f5cf6a", 0.9 }, { 50, 150, "#e46a9b", 2.2 },
}

local function frame(i)
  local c = GV.canvas{ w = 240, h = 160, mode = "scene", out = 2, ol = 1, olx = 1, cres = 4, deep = 2 }
  local ph = (i - 1) % 10 + 1
  local dy, edy = BOB[ph], EAR[ph]
  -- sky, haze, hills, meadow
  c:bands(c:rect(0, 0, 239, 77), { "#7fc0de", "#88c6e1", "#92cce4", "#9dd2e7", "#a8d8ea" }, { dir = "v" })
  c:fill(c:rect(0, 78, 239, 110), "#c8ecdc")
  c:fill(c:rect(0, 84, 239, 110), "#b5e2e2")
  c:part(c:ellipse(40, 132, 125, 48):clip(c:rect(0, 0, 239, 159)), GV.ramp("#94c46e"), { gloss = false, outline = false, cres = 6 })
  local mead = c:rect(0, 108, 239, 159)
  for x = 0, 236, 8 do mead:add(c:poly({ { x, 109 }, { x + 4, 103 }, { x + 8, 109 } })) end
  c:part(mead, GV.ramp("#7ab55c"), { flat = true, rim = false, outline = false, contour = false })
  c:bands(c:rect(0, 118, 239, 159), { "#74b057", "#6eab52", "#68a64d" }, { dir = "v" })
  -- sun with turning rays (12-fold, 30 deg per loop so it wraps)
  local a0 = (i - 1) * (pi / 6) / N
  local rays = c:mask()
  for r = 0, 11 do
    local a = a0 + r * pi / 6
    local function p(rad, da) return { 203 + rad * cos(a + da), 31 + rad * sin(a + da) } end
    rays:add(c:poly({ p(15, -0.13), p(24, 0), p(15, 0.13) }))
  end
  c:part(rays, GV.ramp("#f5cf6a"), { flat = true })
  c:part(c:ellipse(203, 31, 12, 12), "gold", { gloss = { 197, 24 } })
  -- clouds (pale felt)
  local function cloud(list)
    local m = c:mask()
    for _, e in ipairs(list) do m:add(c:ellipse(e[1], e[2], e[3], e[4])) end
    c:part(m, GV.ramp("#f1ece0"), { outline = false, cres = 3 })
    c:outline(m, { pale = m:grow(3) })
  end
  cloud{ { 44, 33, 11, 8 }, { 57, 26, 12, 11 }, { 70, 33, 11, 8 }, { 57, 36, 22, 6 } }
  cloud{ { 125, 18, 9, 7 }, { 136, 13, 9, 8 }, { 146, 18, 8, 6 }, { 135, 21, 17, 4 } }
  cloud{ { 166, 48, 8, 6 }, { 175, 42, 8, 7 }, { 184, 48, 7, 5 }, { 175, 51, 15, 4 } }
  -- fence (behind the pig)
  local fence = { GV.ramp("#f1ece0"), { gloss = false, outline = false, cres = 2, deep = 1 } }
  local rails = c:rect(148, 98, 239, 101):add(c:rect(148, 107, 239, 110))
  c:part(rails, fence[1], fence[2]); c:outline(rails, { pale = rails:grow(3) })
  for _, x in ipairs({ 171, 191, 211, 231 }) do
    local post = c:rrect(x, 92, x + 5, 121, 1)
    c:part(post, fence[1], fence[2]); c:outline(post, { pale = post:grow(3) })
  end
  -- flowers back row (behind the puddle)
  local function flower(f)
    local sway = rnd(1.2 * sin(2 * pi * (i - 1) / N + f[4]))
    local x, y = f[1] + sway, f[2]
    c:part(c:line({ { f[1], y + 11 }, { x, y + 2 } }, 2), GV.ramp("#4a8a3e"), { flat = true, outline = false })
    local head = c:ellipse(x, y - 2, 1.5, 1.5):add(c:ellipse(x + 2, y, 1.5, 1.5))
      :add(c:ellipse(x, y + 2, 1.5, 1.5)):add(c:ellipse(x - 2, y, 1.5, 1.5))
    c:part(head, GV.ramp(f[3]), { gloss = false, cres = 2, deep = 0 })
    c:px(x, y, "#e8a317"); c:px(x - 1, y - 1, "#f5cf6a"); c:px(x, y - 1, "#f5cf6a"); c:px(x - 1, y, "#f5cf6a")
  end
  for _, f in ipairs(FLOWERS) do if f[2] < 124 then flower(f) end end
  -- mud puddle
  local mud = c:ellipse(121, 121, 48, 8)
  c:part(mud, GV.ramp("#7a4a1f"), { gloss = false })
  local wet = c:ellipse(121, 121, 40, 5)
  c:fill(wet, "#3d2a1c"); c:fill(c:ellipse(121, 122, 34, 3), "#4a3a22")
  c:fill(c:rect(96, 119, 104, 119):add(c:rect(132, 120, 136, 120)), "#9a6b3f")
  -- pig (felt toy, back to front)
  local sq = (ph == 1) and 1 or 0                       -- landing squash
  local by = 97 + dy
  local brx, bry = 37 + 2 * sq, 24 - sq
  local function pale(m) c:outline(m, { pale = m:grow(3) }) end
  local function piece(m, ramp, o) o = o or {}; o.outline = false; local P = c:part(m, ramp, o); pale(m); return P end
  local legClip = c:rect(0, 0, 239, 118)
  for _, L in ipairs({ { 92, FAR }, { 128, FAR }, { 101, PINK }, { 137, PINK } }) do
    local leg = c:rrect(L[1], by + 14, L[1] + 6, by + 29, 2):clip(legClip)
    if leg:count() > 0 then
      piece(leg, L[2], { gloss = false, cres = 2 })
      c:fill(c:rect(L[1] + 1, by + 27, L[1] + 5, by + 29):clip(leg), "#8a4234")
    end
  end
  piece(c:line({ { 83, by - 4 }, { 78, by - 8 }, { 72, by - 7 }, { 70, by - 2 }, { 74, by + 2 }, { 78, by }, { 77, by - 3 } }, 2), PINK, { flat = true })
  local body = c:ellipse(117, by + sq, brx, bry)
  local P = piece(body, PINK, { stitch = { side = "lit" }, gloss = { 92, by - 14 } })
  local belly = c:ellipse(117, by + 11, 27, 10):clip(body:shrink(2))
  c:part(belly, BELLY, { outline = false, gloss = false, rim = false, contour = false, contact = false, cres = 3 })
  local arc = {}
  for t = 0, 18 do local a = pi + t * pi / 18; arc[#arc + 1] = { rnd(117 + 27 * cos(a)), rnd(by + 11 + 10 * sin(a)) } end
  c:seam(arc)
  -- ears and head
  local hy = by - 11
  piece(c:poly({ { 145, hy - 13 }, { 150, hy - 27 + edy }, { 158, hy - 15 } }), FAR, { gloss = false, cres = 2 })
  local head = c:ellipse(159, hy, 20, 19)
  piece(head, PINK, { gloss = { 149, hy - 12 } })
  local ear = c:poly({ { 151, hy - 15 }, { 162, hy - 31 + edy }, { 168, hy - 14 } })
  piece(ear, PINK, { gloss = false, cres = 3 })
  c:fill(c:poly({ { 157, hy - 16 }, { 162, hy - 26 + edy }, { 165, hy - 16 } }):clip(ear:shrink(1)), "#e46a9b")
  local snout = c:ellipse(178, hy + 9, 10, 8)
  piece(snout, SNOUT, { gloss = { 172, hy + 4 } })
  c:fill(c:rrect(175, hy + 7, 177, hy + 11, 1):add(c:rrect(181, hy + 7, 183, hy + 11, 1)), "#6b1b2c")
  c:paint({ "u.....u", ".uuuuu.", "..tt..." }, 164, hy + 15, { u = "umber", t = "#f1ece0" })
  c:fill(c:rrect(160, hy - 7, 166, hy - 1, 2):cut(c:rrect(161, hy - 6, 165, hy - 2, 1)), "#4a2c1a")
  c:eye(161, hy - 6)
  c:button(136, by - 21)
  -- mud splash on landing
  if ph == 1 or ph == 2 then
    local lift = (ph == 2) and 4 or 0
    for _, s in ipairs({ { 70, 113 }, { 64, 108 }, { 172, 112 }, { 178, 107 } }) do
      local sx = s[1] + ((s[1] < 120) and -lift or lift)
      local m = c:rrect(sx, s[2] - lift, sx + 2, s[2] + 2 - lift, 1)
      c:part(m, GV.ramp("#7a4a1f"), { flat = true })
    end
  end
  -- flowers front row
  for _, f in ipairs(FLOWERS) do if f[2] >= 124 then flower(f) end end
  -- butterfly (figure-eight flight)
  local bx = rnd(54 + 20 * cos(2 * pi * (i - 1) / N))
  local byy = rnd(59 + 8.5 * sin(2 * pi * (i - 1) / 10))
  local W = {
    o = { "aaaa.....aaaa", "aaaaa...aaaaa", ".aaaaa.aaaaa.", "..aaaa.aaaa..", "...aaa.aaa...", "..aaaa.aaaa..", "..aaa...aaa.." },
    m = { "...aaa.aaa...", "...aaaaaaaa..", "....aaa.aaa..", "....aaa.aaa..", "....aa...aa..", "............." },
    c = { "....aaa......", "....aaaa.....", ".....aaa.....", ".....aa......", "......a......" },
  }
  local wm = c:ascii(W[WING[i]], bx - 6, byy - 3)
  c:part(wm, GV.ramp("#f5cf6a"), { flat = true })
  if WING[i] == "o" then c:fill(c:rect(bx - 4, byy, bx - 3, byy):add(c:rect(bx + 3, byy, bx + 4, byy)), "#e8a317") end
  c:fill(c:rect(bx, byy - 3, bx, byy + 3), "#3e2f66")
  c:px(bx - 1, byy - 5, "#3e2f66"); c:px(bx + 1, byy - 5, "#3e2f66"); c:px(bx, byy - 4, "#3e2f66")
  return c:image()
end

local spr = Sprite(480, 320, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "pig"
for i = 1, N do
  if i > 1 then spr:newEmptyFrame(i) end
  spr:newCel(layer, spr.frames[i], frame(i), Point(0, 0))
  spr.frames[i].duration = DUR / 1000
end
app.fs.makeAllDirectories(OUT .. "aseprite"); app.fs.makeAllDirectories(OUT .. "png")
spr:saveAs(OUT .. "aseprite/pig.aseprite")
spr:saveCopyAs(OUT .. "png/pig.gif")
local t = GV.check(spr.cels[1].image)
print(GV.report(t))
spr:close()
