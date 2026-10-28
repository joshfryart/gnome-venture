-- puzzles/skeleton : 320x288 animated scene (24 frames x 50 ms = 1.2 s, loops, opaque background).
-- A felt toy skeleton in dusk clogs and cream cartoon gloves does a crouched side-to-side sway dance on a
-- porch floor, jazz hands pumping in a W, bystanders' jeans at both edges. Drawn on a 160x144 grid, written
-- 2x nearest. Stitched Toy (Part D + addenda).
-- Families: bone = cream (pale ivory #efe2b4, cream-safe gloss), gloves = cream, clogs = dusk, jeans = water
-- deep, porch wood = soil, floor = stone (warm concrete #a8a499), sneaker = stone, boot = wood.
-- v2: separate ribs + spine + pelvis (readable torso), W arms with 3-finger gloves clear of the legs,
-- clean slot-and-teeth grin (no zipper), dark thread (#e8a317) on bone so seams/edge stitch show,
-- eased sway that holds on each side with the knee dip on the hold, head follow-through, no big ground ellipse.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/"
local W, H, N, DUR = 160, 144, 24, 0.05
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local function R(v) return floor(v + 0.5) end
local function canvas() return GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1 } end
local function ease(v, p) return (v < 0 and -1 or 1) * abs(v) ^ p end   -- >0 linger at the ends

local BONE  = GV.ramp("#efe2b4")
local GLOVE = GV.ramp("cream")
local CLOG  = GV.ramp("dusk")
local JEAN  = GV.ramp("#2a3c6c")
local WOOD  = GV.ramp("#b4a48a")
local FL    = GV.ramp("#a8a499")
local SNEAK = GV.ramp("#8b8f96")
local BOOT  = GV.ramp("wood")
local SOCK, SOCKD, UMB = "#3e2f66", "#291d4a", "#4a2c1a"
local THREAD = GV.C.goldS          -- the darker thread step, so stitches read on pale bone

-- 2 on / 1 off thread on bone (gv seam colour #f5cf6a vanishes on ivory)
local function bseam(c, pts)
  local n, seen = 0, {}
  local function visit(x, y)
    local k = c:key(x, y)
    if seen[k] or not c:inside(x, y) or not c.own[k] then return end
    seen[k] = true
    if n % 3 < 2 and not c.gl.s[k] then c.pix[k] = THREAD end
    n = n + 1
  end
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local s = math.max(1, math.ceil(math.max(abs(x1 - x0), abs(y1 - y0))))
    for t = 0, s do visit(R(x0 + (x1 - x0) * t / s), R(y0 + (y1 - y0) * t / s)) end
  end
end
-- lit-side edge stitch on bone, 2 px in, every third diagonal, skips the gloss
local function bstitch(c, m)
  local x0, y0, x1, y1 = m:bbox()
  local mcx, mcy = (x0 + x1) / 2, (y0 + y1) / 2
  local s1 = m:shrink(1); local s2 = s1:shrink(1)
  s1:each(function(x, y)
    local k = c:key(x, y)
    if not s2.s[k] and (x + y) % 3 == 0 and (x - mcx) + (y - mcy) <= -4 and not c.gl.s[k] then c.pix[k] = THREAD end
  end)
end

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
-- left bystander: dark jeans with a gold outer seam, brown boot (not a clog, so the dancer's shoes stay unique)
local jl = B:poly({ { -3, -3 }, { 31, -3 }, { 28, 76 }, { -3, 78 } })
B:part(jl, JEAN, { gloss = false, cres = 6, deep = 2 })
B:seam({ { 25, 0 }, { 23, 72 } })
B:fill(B:ellipse(10, 87, 17, 2), FL.shade)                    -- boot contact shadow
B:part(B:rrect(-6, 70, 25, 86, 5), BOOT, { cres = 3, deep = 1 })
B:seam({ { 0, 82 }, { 21, 82 } })
-- right bystander: jeans and a grey sneaker with a cream sole
local jr = B:poly({ { 130, -3 }, { 163, -3 }, { 163, 70 }, { 133, 70 } })
B:part(jr, JEAN, { gloss = false, cres = 6, deep = 2 })
B:seam({ { 135, 0 }, { 137, 66 } })
B:fill(B:ellipse(148, 82, 19, 2), FL.shade)                   -- sneaker contact shadow
B:part(B:rrect(128, 62, 165, 80, 6), SNEAK, { cres = 3, deep = 1 })
B:part(B:rect(129, 77, 165, 81), GLOVE, { flat = true })
B:seam({ { 132, 75 }, { 160, 75 } })
B:paint({ "c.c.c", ".c.c." }, 142, 66, { c = "#c9c5bc" })   -- laces

---------------------------------------------------------------- one frame of the dance
local function frame(i)
  local c = canvas()
  for k, v in pairs(B.pix) do c.pix[k] = v end
  for k, v in pairs(B.own) do c.own[k] = v end
  local ph = 2 * pi * i / N
  local sw  = ease(sin(ph), 0.7)              -- side-to-side sway, holds on each side
  local hsw = ease(sin(ph - 0.35), 0.7)       -- skull follows a beat late (follow-through)
  local bob = sw * sw                         -- knee dip lands on each hold (two per loop)
  local pump = cos(ph)                        -- elbows flap through the crossing
  local sx = 15 * sw
  local P  = { 80 + 0.5 * sx, 85 + 3 * bob }            -- pelvis
  local Rc = { 80 + 0.8 * sx, P[2] - 19 }               -- ribcage centre
  local Hc = { R(80 + 14 * hsw), R(41 + 3 * bob) }      -- skull
  local f = R(2.5 * sw)                                 -- face turns toward the sway
  local Al, Ar = { 40 - 0.2 * sx, 122 }, { 120 - 0.2 * sx, 122 }  -- feet stay planted (tiny slide)

  -- small contact shadows under the clogs only
  for _, A in ipairs({ Al, Ar }) do c:fill(c:ellipse(R(A[1]), A[2] + 10, 10, 1.5), FL.shade) end

  local function bone(p, q, w)
    return c:line({ p, q }, w or 3):add(c:ellipse(R(p[1]), R(p[2]), 2)):add(c:ellipse(R(q[1]), R(q[2]), 2))
  end
  -- legs: bowed knees, deeper on the dip
  local Hl, Hr = { P[1] - 7, P[2] + 3 }, { P[1] + 7, P[2] + 3 }
  local Kl = { (Hl[1] + Al[1]) / 2 - 6 - 3 * bob, (Hl[2] + Al[2]) / 2 - 2 }
  local Kr = { (Hr[1] + Ar[1]) / 2 + 6 + 3 * bob, (Hr[2] + Ar[2]) / 2 - 2 }
  c:part(bone(Hl, Kl), BONE, { flat = true })
  c:part(bone(Kl, Al), BONE, { flat = true })
  c:part(bone(Hr, Kr), BONE, { flat = true })
  c:part(bone(Kr, Ar), BONE, { flat = true })
  for _, K in ipairs({ Kl, Kr }) do c:part(c:ellipse(R(K[1]), R(K[2]), 2.5), BONE, { flat = true }) end  -- kneecaps
  -- clogs, toes out, with a gold sole seam and two vent holes
  local function clog(A, dir)
    local x, y = R(A[1]), R(A[2])
    local m = c:rrect(x - 6, y + 1, x + 6, y + 9, 4):add(c:ellipse(x + 6 * dir, y + 6, 6, 3.5))
    c:part(m, CLOG, { cres = 3, deep = 1 })
    c:seam({ { x - 6, y + 8 }, { x + 11 * dir, y + 8 } })
    c:px(x - 1, y + 4, CLOG.deep); c:px(x + 2, y + 4, CLOG.deep)
  end
  clog(Al, -1); clog(Ar, 1)
  -- spine: a column of vertebrae from the pelvis up to the neck
  local px, py, rx, ry = R(P[1]), R(P[2]), R(Rc[1]), R(Rc[2])
  local nv = 7
  for v = 0, nv - 1 do                          -- bottom up, 4 px apart: the outline makes the disc gaps
    local t = v / (nv - 1)
    local vx, vy = R(px + (rx - px) * t), R(py - 1 + (ry - 8 - (py - 1)) * t)
    c:part(c:rrect(vx - 2, vy - 1, vx + 2, vy + 1, 1), BONE, { flat = true })
  end
  -- pelvis: two hip wings with a notch at the top, over a small bowl
  c:part(c:ellipse(px - 5, py + 2, 5.5, 4):add(c:ellipse(px + 5, py + 2, 5.5, 4)):add(c:rrect(px - 4, py + 2, px + 4, py + 7, 2)), BONE, { cres = 3, deep = 1, gloss = false })
  c:fill(c:rect(px, py - 2, px, py + 1), UMB)
  -- ribs: three curved pairs, each its own outlined bone so the gaps read
  for j = 0, 2 do
    local y0 = ry - 6 + 5 * j
    local span = ({ 9, 10, 8 })[j + 1]
    c:part(c:line({ { rx - 1, y0 }, { rx - span + 3, y0 - 1 }, { rx - span, y0 + 2 }, { rx - span + 1, y0 + 4 } }, 3), BONE, { flat = true })
    c:part(c:line({ { rx + 1, y0 }, { rx + span - 3, y0 - 1 }, { rx + span, y0 + 2 }, { rx + span - 1, y0 + 4 } }, 3), BONE, { flat = true })
  end
  -- sternum plate with the felt seam down it
  local st = c:part(c:rrect(rx - 2, ry - 8, rx + 2, ry + 4, 2), BONE, { flat = true })
  bseam(c, { { rx, ry + 1 }, { rx, ry + 4 } })
  c:button(rx - 2, ry - 4)                       -- collar button at the head of the sternum seam
  -- upper arms out to the elbows (W pose), elbows flap a little
  local Sl, Sr = { rx - 9, ry - 6 }, { rx + 9, ry - 6 }
  local El = { Sl[1] - 15 - 2 * pump, Sl[2] + 8 + 2 * bob }
  local Er = { Sr[1] + 15 - 2 * pump, Sr[2] + 8 + 2 * bob }
  local Wl = { El[1] - 3, El[2] - 13 + 6 * sw }       -- left hand up when swaying left
  local Wr = { Er[1] + 3, Er[2] - 13 - 6 * sw }
  c:part(bone(Sl, El), BONE, { flat = true })
  c:part(bone(Sr, Er), BONE, { flat = true })
  -- skull, jaw, face
  local hx, hy = Hc[1], Hc[2]
  local skull = c:ellipse(hx, hy, 18, 15)
  c:part(skull, BONE, { cres = 5, deep = 2 })
  bstitch(c, skull)
  local jx = hx + f
  c:part(c:rrect(jx - 10, hy + 8, jx + 10, hy + 20, 5), BONE, { cres = 3, deep = 1, gloss = false })
  -- grin: one dark slot with five square teeth hanging from the top
  c:fill(c:rrect(jx - 7, hy + 12, jx + 7, hy + 16, 1), SOCKD)
  for _, tx in ipairs({ -6, -3, 0, 3, 6 }) do
    c:fill(c:rect(jx + tx - 1, hy + 12, jx + tx, hy + 14), BONE.base)
    c:px(jx + tx, hy + 14, BONE.shade)
  end
  for _, ex in ipairs({ -8, 8 }) do
    local cx, cy = hx + ex + f, hy
    c:fill(c:ellipse(cx, cy, 4.5, 4), SOCK)
    c:fill(c:ellipse(cx, cy, 4.5, 4):cut(c:ellipse(cx + 1, cy + 1, 4.5, 4)), SOCKD)
    c:eye(cx - 2, cy - 2)
  end
  c:paint({ "uu.uu", "uuuuu", ".uuu.", "..u.." }, hx - 2 + f, hy + 5, { u = SOCK })   -- nose hole
  -- forearms and jazz-hand gloves, beside the head, clear of the legs
  c:part(bone(El, Wl), BONE, { flat = true })
  c:part(bone(Er, Wr), BONE, { flat = true })
  local function glove(Wp, dir)
    local x, y = R(Wp[1]), R(Wp[2])
    local m = c:rrect(x - 3, y - 1, x + 3, y + 2, 1)                       -- cuff
    m:add(c:ellipse(x, y - 5, 4.5, 4))                                    -- palm
    for _, fx in ipairs({ -3, 0, 3 }) do m:add(c:rrect(x + fx - 1, y - 12 + abs(fx) // 3, x + fx, y - 6, 1)) end  -- fingers
    local tx0 = dir < 0 and x - 7 or x + 4
    m:add(c:rrect(tx0, y - 6, tx0 + 3, y - 4, 1))                          -- thumb out
    c:part(m, GLOVE, { cres = 3, deep = 1, gloss = { x - 2, y - 7 } })
    c:seam({ { x - 3, y + 1 }, { x + 3, y + 1 } })
  end
  glove(Wl, -1); glove(Wr, 1)
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
