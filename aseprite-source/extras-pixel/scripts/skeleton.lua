-- puzzles/skeleton : 320x288 animated scene (22 frames x 60 ms = 1.32 s, loops, opaque background).
-- A toy skeleton in black clogs and white gloves does a crouched side-to-side sway dance on a porch floor,
-- bystanders' jeans at both edges. Drawn on a 160x144 grid, written 2x nearest. Stitched Toy (Part D + addenda).
-- Families: bone = gold/cream (pale-ish #e9dc96), gloves = cream, clogs = dusk, jeans = water deep,
-- porch wood = soil, floor = stone (warm concrete #a8a499), sneaker = stone.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/"
local W, H, N, DUR = 160, 144, 22, 0.06
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local function R(v) return floor(v + 0.5) end
local function canvas() return GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1 } end

local BONE  = GV.ramp("#e9dc96")
local GLOVE = GV.ramp("cream")
local CLOG  = GV.ramp("dusk")
local JEAN  = GV.ramp("#2a3c6c")
local WOOD  = GV.ramp("#b4a48a")
local FL    = GV.ramp("#a8a499")
local SNEAK = GV.ramp("#8b8f96")
local SOCK  = "#3e2f66"

---------------------------------------------------------------- static background (drawn once)
local B = canvas()
-- floor: warm concrete with specks
B:fill(B:rect(0, 60, W - 1, H - 1), FL.base)
B:fill(B:rect(0, 60, W - 1, 62), FL.deep)          -- shadow under the bottom step
B:fill(B:rect(0, 63, W - 1, 64), FL.shade)
for _, p in ipairs({ { 12, 96 }, { 26, 120 }, { 70, 106 }, { 98, 138 }, { 140, 100 }, { 150, 126 }, { 58, 134 }, { 120, 112 }, { 8, 136 }, { 84, 96 } }) do
  B:px(p[1], p[2], FL.shade); B:px(p[1] + 1, p[2], FL.shade); B:px(p[1] + 1, p[2] - 1, FL.rim)
end
-- crack in the slab
B:paint({ "ss.....", "..ss...", "....sss" }, 136, 88, { s = FL.shade })
-- porch steps: planks, each 7 px with a lit top, a shaded underside and a dark gap
local steps = B:rect(-2, -2, W + 1, 59)
B:part(steps, WOOD, { gloss = false, cres = 8, deep = 3, outline = false, rim = false, bounce = false })
for y = 4, 58, 7 do
  B:fill(B:rect(0, y, W - 1, y), WOOD.deep)
  B:fill(B:rect(0, y - 1, W - 1, y - 1), WOOD.shade)
  B:fill(B:rect(0, y + 1, W - 1, y + 1), WOOD.rim)
end
for _, p in ipairs({ { 44, 7 }, { 100, 7 }, { 60, 21 }, { 116, 21 }, { 40, 35 }, { 92, 35 }, { 68, 49 }, { 120, 49 }, { 52, 14 }, { 108, 28 }, { 80, 42 } }) do
  B:px(p[1], p[2], WOOD.shade)
end
B:outline(B:rect(-4, -4, W + 3, 58), { ol = 1, olx = 0 })   -- step nose line
-- left bystander: dark jeans with a gold outer seam, black shoe
local jl = B:poly({ { -3, -3 }, { 31, -3 }, { 28, 76 }, { -3, 78 } })
B:part(jl, JEAN, { gloss = false, cres = 6, deep = 2 })
B:seam({ { 25, 0 }, { 23, 72 } })
B:part(B:rrect(-6, 70, 25, 86, 5), CLOG, { cres = 3, deep = 1 })
B:seam({ { 0, 82 }, { 21, 82 } })
-- right bystander: jeans and a grey sneaker with a cream sole
local jr = B:poly({ { 130, -3 }, { 163, -3 }, { 163, 70 }, { 133, 70 } })
B:part(jr, JEAN, { gloss = false, cres = 6, deep = 2 })
B:seam({ { 135, 0 }, { 137, 66 } })
B:part(B:rrect(128, 62, 165, 80, 6), SNEAK, { cres = 3, deep = 1 })
B:part(B:rect(129, 77, 165, 81), GLOVE, { flat = true })
B:seam({ { 132, 75 }, { 160, 75 } })
B:paint({ "c.c.c", ".c.c." }, 142, 66, { c = "#c9c5bc" })   -- laces

---------------------------------------------------------------- one frame of the dance
local function frame(i)
  local c = canvas()
  for k, v in pairs(B.pix) do c.pix[k] = v end
  for k, v in pairs(B.own) do c.own[k] = v end
  local t = i / N
  local sw = sin(2 * pi * t)                -- side-to-side sway
  local bob = (1 - cos(4 * pi * t)) / 2     -- two knee bobs per sway
  local a = cos(2 * pi * t)                 -- arm pump
  local sx = 16 * sw
  local P  = { 80 + 0.55 * sx, 80 + 3 * bob }          -- pelvis
  local Rc = { P[1] + 0.25 * sx, P[2] - 13 }           -- ribcage
  local Hc = { R(80 + sx), R(41 + 2.5 * bob) }         -- skull
  local f = R(0.28 * sx)                                -- face turns toward the sway
  local Al, Ar = { 40 - 0.15 * sx, 121 }, { 120 - 0.15 * sx, 121 }  -- feet stay planted (tiny slide)

  -- floor shadow under the dancer
  c:fill(c:ellipse(80 + 0.4 * sx, 130, 50, 5), FL.shade)
  c:fill(c:ellipse(80 + 0.4 * sx, 130, 40, 3), FL.deep)

  local function bone(p, q, w)
    return c:line({ p, q }, w or 3):add(c:ellipse(R(p[1]), R(p[2]), 2)):add(c:ellipse(R(q[1]), R(q[2]), 2))
  end
  -- legs: bowed knees, deeper on the bob
  local Hl, Hr = { P[1] - 7, P[2] + 4 }, { P[1] + 7, P[2] + 4 }
  local Kl = { (Hl[1] + Al[1]) / 2 - 7 - 3 * bob, (Hl[2] + Al[2]) / 2 - 3 }
  local Kr = { (Hr[1] + Ar[1]) / 2 + 7 + 3 * bob, (Hr[2] + Ar[2]) / 2 - 3 }
  c:part(bone(Hl, Kl), BONE, { flat = true })
  c:part(bone(Kl, Al), BONE, { flat = true })
  c:part(bone(Hr, Kr), BONE, { flat = true })
  c:part(bone(Kr, Ar), BONE, { flat = true })
  -- clogs, toes out, with a gold sole seam and two vent holes
  local function clog(A, dir)
    local x, y = R(A[1]), R(A[2])
    local m = c:rrect(x - 6, y + 1, x + 6, y + 9, 4):add(c:ellipse(x + 6 * dir, y + 6, 6, 3.5))
    c:part(m, CLOG, { cres = 3, deep = 1 })
    c:seam({ { x - 6, y + 8 }, { x + 11 * dir, y + 8 } })
    c:px(x - 1, y + 4, CLOG.deep); c:px(x + 2, y + 4, CLOG.deep)
  end
  clog(Al, -1); clog(Ar, 1)
  -- pelvis and ribcage
  c:part(c:ellipse(R(P[1]), R(P[2]) + 2, 9, 5), BONE, { cres = 3, deep = 1, gloss = false })
  local rx, ry = R(Rc[1]), R(Rc[2])
  local rib = c:part(c:ellipse(rx, ry, 11, 9), BONE, { cres = 4, deep = 2, gloss = false })
  for _, dy in ipairs({ -2, 2, 6 }) do
    c:fill(c:line({ { rx - 9, ry + dy + 1 }, { rx - 6, ry + dy }, { rx - 2, ry + dy } }, 1), "#4a2c1a")
    c:fill(c:line({ { rx + 2, ry + dy }, { rx + 6, ry + dy }, { rx + 9, ry + dy + 1 } }, 1), "#4a2c1a")
  end
  c:seam({ { rx, ry - 4 }, { rx, ry + 8 } })      -- sternum seam
  -- upper arms (behind the skull at the shoulder)
  local Sl, Sr = { Rc[1] - 12, Rc[2] - 6 }, { Rc[1] + 12, Rc[2] - 6 }
  local El = { Sl[1] - 8, Sl[2] + 16 + 2 * a }
  local Er = { Sr[1] + 8, Sr[2] + 16 - 2 * a }
  local Wl = { Sl[1] + 2 + 4 * a, Sl[2] + 31 - 4 * a }
  local Wr = { Sr[1] - 2 + 4 * a, Sr[2] + 31 + 4 * a }
  c:part(bone(Sl, El), BONE, { flat = true })
  c:part(bone(Sr, Er), BONE, { flat = true })
  -- skull, jaw, face
  local hx, hy = Hc[1], Hc[2]
  c:part(c:ellipse(hx, hy, 19, 16), BONE, { cres = 5, deep = 2 })
  c:seam({ { hx - 15, hy - 8 }, { hx - 7, hy - 13 }, { hx + 3, hy - 14 }, { hx + 13, hy - 9 } })   -- cranial suture
  c:part(c:rrect(hx - 10 + f, hy + 9, hx + 10 + f, hy + 21, 5), BONE, { cres = 3, deep = 1, gloss = false })
  -- collar button at the head of the sternum seam, just under the jaw
  c:button(rx - 2 + R(0.5 * f), hy + 23)
  for _, ex in ipairs({ -8, 8 }) do
    local cx, cy = hx + ex + f, hy + 1
    c:fill(c:ellipse(cx, cy, 4.5, 4), SOCK)
    c:fill(c:ellipse(cx, cy, 4.5, 4):cut(c:ellipse(cx + 1, cy + 1, 4.5, 4)), "#291d4a")
    c:eye(cx - 2, cy - 2)
  end
  c:paint({ "uu.uu", "uuuuu", ".uuu.", "..u.." }, hx - 2 + f, hy + 7, { u = SOCK })   -- nose hole
  c:fill(c:rect(hx - 7 + f, hy + 16, hx + 7 + f, hy + 16), "#4a2c1a")              -- mouth line
  for _, tx in ipairs({ -6, -3, 0, 3, 6 }) do
    c:px(hx + tx + f, hy + 14, "#4a2c1a"); c:px(hx + tx + f, hy + 15, "#4a2c1a")
    c:px(hx + tx + f, hy + 17, "#4a2c1a")
  end
  -- forearms and gloves in front of the knees
  c:part(bone(El, Wl), BONE, { flat = true })
  c:part(bone(Er, Wr), BONE, { flat = true })
  local function glove(Wp, dir)
    local x, y = R(Wp[1]), R(Wp[2])
    local m = c:ellipse(x, y + 5, 5, 4.5):add(c:ellipse(x - 5 * dir, y + 3, 2, 2))   -- palm + thumb
    m:add(c:rrect(x - 4, y - 1, x + 4, y + 2, 1))                                    -- cuff
    c:part(m, GLOVE, { cres = 3, deep = 1, gloss = { x - 2, y + 3 } })
    c:seam({ { x - 4, y + 2 }, { x + 4, y + 2 } })
  end
  glove(Wl, 1); glove(Wr, -1)
  return c:image()
end

---------------------------------------------------------------- assemble the animation
local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
for i = 0, N - 1 do
  if i > 0 then spr:newEmptyFrame() end
  spr:newCel(spr.layers[1], i + 1, frame(i), Point(0, 0))
  spr.frames[i + 1].duration = DUR
end
for _, d in ipairs({ "png", "aseprite" }) do pcall(function() app.fs.makeAllDirectories(OUT .. d) end) end
spr:saveAs(OUT .. "aseprite/skeleton.aseprite")
spr:saveCopyAs(OUT .. "png/skeleton.gif")
local t = GV.check(spr.cels[1].image)
print("frame1 " .. GV.report(t))
spr:close()
