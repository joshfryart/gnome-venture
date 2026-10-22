local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
-- drawn at half size (120x80), written at 2x (240x160)
local c = GV.canvas{ w = 120, h = 80, mode = "scene", out = 2 }

-- 1. dusk sky: hard bands, lighter toward the horizon
c:bands(c:rect(0, 0, 119, 79), { "#221f44", "#2a2750", "#33305c", "#3d396a", "#48437a", "#544d86" })

-- 2. stars (1 px here = 2 px out), plus a few tiny twinkle crosses
local star = "#f5cf6a"
for _, s in ipairs({ { 15, 12 }, { 35, 20 }, { 60, 10 }, { 80, 23 }, { 107, 35 }, { 48, 30 }, { 86, 6 } }) do
  c:px(s[1], s[2], star)
end
for _, s in ipairs({ { 25, 6 }, { 72, 16 } }) do
  c:px(s[1], s[2], star); c:px(s[1] - 1, s[2], "#e8a317"); c:px(s[1] + 1, s[2], "#e8a317")
  c:px(s[1], s[2] - 1, "#e8a317"); c:px(s[1], s[2] + 1, "#e8a317")
end

-- 3. crescent moon, top right
local moon = c:ellipse(99, 14, 7, 7):cut(c:ellipse(102.5, 11.5, 6, 6))
c:part(moon, GV.ramp("#f4f0e0"), { outline = false, gloss = false, cres = 2, deep = 0, bounce = false })
c:outline(moon, { ol = 1, olx = 0 })

-- 4. ground: rolling hill, higher in the middle where the houses stand
local ground = c:poly({ { 0, 56 }, { 12, 54 }, { 26, 51 }, { 40, 50 }, { 56, 49 }, { 70, 47 }, { 84, 48 },
  { 96, 51 }, { 108, 52 }, { 120, 50 }, { 120, 80 }, { 0, 80 } })
c:part(ground, GV.ramp("#44281c", { rim = "#6e4430" }), { outline = false, gloss = false, cres = 8, deep = 0, bounce = false })
-- a few darker tufts on the ground
for _, t in ipairs({ { 8, 66 }, { 30, 74 }, { 52, 70 }, { 88, 64 }, { 104, 72 }, { 76, 76 }, { 112, 60 } }) do
  c:px(t[1], t[2], "#2e1a12"); c:px(t[1] + 1, t[2] - 1, "#2e1a12"); c:px(t[1] + 2, t[2], "#2e1a12")
end

-- 5. glowing mycelium road: quadratic curves, faint wide glow + dotted gold core
local function quad(p0, p1, p2, n)
  local pts = {}
  for i = 0, n do
    local t = i / n
    local a, b, d = (1 - t) ^ 2, 2 * (1 - t) * t, t * t
    pts[#pts + 1] = { math.floor(a * p0[1] + b * p1[1] + d * p2[1] + 0.5), math.floor(a * p0[2] + b * p1[2] + d * p2[2] + 0.5) }
  end
  return pts
end
local main = quad({ -2, 74 }, { 50, 60 }, { 121, 53 }, 60)
local bA = quad({ 54, 61 }, { 44, 56 }, { 33, 52 }, 14)
local bB = quad({ 54, 61 }, { 64, 56 }, { 70, 49 }, 14)
local glow = c:line(main, 3):add(c:line(bA, 3)):add(c:line(bB, 3))
glow:clip(ground)
c:fill(glow:grow(1):clip(ground), "#5e3a1c")
c:fill(glow, "#8a5a24")
local function dotted(pts)
  local seen, i = {}, 0
  local core = c:line(pts, 1)
  -- walk the polyline in order so the 2-on/1-off rhythm follows the path
  for j = 1, #pts - 1 do
    local seg = c:line({ pts[j], pts[j + 1] }, 1)
    local list = {}
    seg:each(function(x, y) list[#list + 1] = { x, y } end)
    table.sort(list, function(p, q)
      local dp = (p[1] - pts[j][1]) ^ 2 + (p[2] - pts[j][2]) ^ 2
      local dq = (q[1] - pts[j][1]) ^ 2 + (q[2] - pts[j][2]) ^ 2
      return dp < dq
    end)
    for _, p in ipairs(list) do
      local k = p[1] .. "," .. p[2]
      if not seen[k] then
        seen[k] = true
        if i % 3 ~= 2 and ground:has(p[1], p[2]) then c:px(p[1], p[2], "#f5cf6a") end
        i = i + 1
      end
    end
  end
end
dotted(main); dotted(bA); dotted(bB)

-- mushroom house helper: stem, gills band, dome cap; outlined as one silhouette
local function house(cx, capY, rx, ry, stemW, baseY, capCol, gillCol, opts)
  local cap = c:ellipse(cx, capY, rx, ry):cut(c:rect(0, capY + 2, 119, 79))
  cap:add(c:rrect(math.floor(cx - rx), capY, math.ceil(cx + rx), capY + 2, 1))
  local gill = c:rrect(math.floor(cx - rx + 2), capY + 2, math.ceil(cx + rx - 2), capY + 3, 0)
  local stem = c:rrect(math.floor(cx - stemW / 2 + 0.5), capY + 2, math.floor(cx + stemW / 2 - 0.5), baseY, 1)
  local sil = cap:copy():add(gill):add(stem)
  c:part(stem, "cream", { outline = false })
  c:part(gill, gillCol, { outline = false, flat = true, rim = false })
  local p = c:part(cap, capCol, { outline = false })
  c:outline(sil)
  return p, stem
end

-- 6. violet house (small, left)
local vcap = house(33, 41, 7.5, 5.5, 6, 52, GV.ramp("#7a5cc0"), "#4a3488")
c:spot(c:ellipse(30, 39, 1, 1), "#f4f0e0", "#fff3c8")
c:spot(c:ellipse(36, 38, 1, 1), "#f4f0e0", "#fff3c8")
c:px(33, 41, "#f4f0e0"); c:px(34, 41, "#f4f0e0")
c:paint({ "uu", "uu" }, 33, 47, { u = "#4a2c1a" }) -- round door
c:px(33, 46, "#74462a"); c:px(34, 46, "#74462a")

-- 7. pink house (largest, centre) with glowing door
local pcap = house(70, 34, 11.5, 8, 9, 48, "petal", "#a8241f")
c:spot(c:ellipse(64, 30, 1.5, 1), "#f4f0e0", "#fff3c8")
c:spot(c:ellipse(72, 28, 1, 1), "#f4f0e0", "#fff3c8")
c:spot(c:ellipse(77, 33, 1, 1), "#f4f0e0", "#fff3c8")
c:part(c:rrect(68, 41, 72, 48, 2), GV.ramp("#f5cf6a"), { outline = false, gloss = false, cres = 2, deep = 0 })
c:px(71, 45, "#b8661a")
-- small round window
c:paint({ ".u.", "ugu", ".u." }, 72, 37, { u = "#4a2c1a", g = "#f5cf6a" })

-- 8. gold house (medium, right)
house(103, 45, 8, 5.5, 6, 54, "gold", "#b07a10")
c:paint({ "uu", "uu", "uu" }, 103, 51, { u = "#4a2c1a" })
c:px(102, 49, "#f5cf6a")
c:spot(c:ellipse(100, 42, 1, 1), "#f5cf6a", "#fff1c8")

-- 9. little gnome walking along the road (left)
local tunic = c:rrect(13, 63, 23, 70, 2)
local face = c:rrect(13, 57, 23, 62, 2)
local beard = c:ellipse(18, 63, 5, 4):cut(c:rect(0, 0, 119, 60))
local brim = c:rrect(11, 55, 25, 57, 1)
local hat = c:poly({ { 12, 46 }, { 25, 56 }, { 11, 56 } })
local bob = c:ellipse(12.5, 46.5, 1.5, 1.5)
local legs = c:line({ { 15, 71 }, { 14, 73 } }, 2):add(c:line({ { 20, 71 }, { 22, 73 } }, 2))
local gsil = tunic:copy():add(face):add(beard):add(brim):add(hat):add(bob):add(legs)
c:limb({ { 15, 70 }, { 14, 73 } }); c:limb({ { 20, 70 }, { 22, 73 } })
c:part(tunic, GV.ramp("#3f93b2"), { outline = false })
c:part(face, GV.ramp("#f6c9a0"), { outline = false, gloss = false })
c:part(beard, "cream", { outline = false, gloss = false, contour = false })
c:part(brim, "cream", { outline = false, flat = true })
c:part(hat, "#d6322b", { outline = false, gloss = { 15, 51 } })
c:part(bob, "gold", { outline = false, flat = true })
c:outline(gsil, { ol = 1, olx = 1 })
c:eye(14, 58, true); c:eye(19, 58, true)
c:px(17, 62, "#d9885a"); c:px(18, 62, "#d9885a") -- nose tip above the beard

-- hem stitch along top and bottom edges
for x = 1, 118 do
  if x % 3 ~= 0 then c:px(x, 1, "#f5cf6a"); c:px(x, 78, "#e8a317") end
end

local t = c:save(O .. "aseprite/landing/roads.aseprite", O .. "png/landing/roads.png")
print(GV.report(t))
