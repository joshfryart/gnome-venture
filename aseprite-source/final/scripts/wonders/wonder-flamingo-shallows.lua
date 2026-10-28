-- wonder-flamingo-shallows.lua : unique-location scene. A pink lake, pink birds, feather crafters at tiny stalls. Bright day.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local PINK = { "#f9d0de", "#f4bccf", "#efa8c0", "#e994b2", "#df80a4", "#d26e96" }
local PK = GV.ramp("#f29ab8", { shade = "#d4709a", deep = "#a8467a", bounce = "#e08aaa" })
local PKL = GV.ramp("#f8bcd0", { shade = "#e69ab8", deep = "#c0709a" })
local LEG = GV.ramp("#d9628c", { shade = "#b84a78", deep = "#8a3460" })

-- sky and far shore
L.sky(c, "day", 48)
L.cloud(c, 40, 20, 16, "#fbf3ea", "#f4cfdc"); L.cloud(c, 150, 14, 18, "#fbf3ea", "#f4cfdc"); L.cloud(c, 214, 30, 12, "#fbf3ea", "#f4cfdc")
c:part(c:poly({ {0,50},{0,42},{20,36},{44,40},{70,34},{100,41},{130,37},{160,42},{190,35},{214,40},{240,37},{240,50} }), GV.ramp("#9aa9c8"), { gloss = false, rim = false, bounce = false, outline = false, cres = 3 })
c:part(c:poly({ {0,50},{0,45},{30,43},{60,46},{96,43},{140,46},{180,44},{240,46},{240,50} }), GV.ramp("#7ab55c"), { gloss = false, rim = false, bounce = false, outline = false, cres = 2 })
local function acacia(x, y, s)
  c:fill(c:rect(x, y - 3 * s, x + (s > 1 and 1 or 0), y), "#5e2f1e")
  c:part(c:ellipse(x, y - 4 * s, 4 * s, 1.6 * s), GV.ramp("#4a8a3e"), { flat = true, outline = false, gloss = false })
end
for _, a in ipairs({ {18,46,1},{52,46,2},{88,46,1},{170,46,1},{204,46,2},{232,46,1} }) do acacia(a[1], a[2], a[3]) end

-- lake
c:bands(c:rect(0, 47, W - 1, H - 1), PINK, { dir = "v" })
for i = 0, 18 do
  local x = (i * 41 + 9) % (W - 16); local y = 52 + (i * 13) % 44
  c:fill(c:rect(x, y, x + 5 + (i % 3) * 3, y), (i % 2 == 0) and "#fbe0ea" or "#f6b8cf")
end
for i = 0, 9 do
  local x = (i * 53 + 20) % (W - 16); local y = 56 + (i * 17) % 40
  c:fill(c:rect(x, y, x + 4 + (i % 3) * 2, y), "#c8628a")
end

-- flamingo: feet at (x,y); sz 1 small (background, no outline), 2 big. dir = 1 faces right
local function flamingo(x, y, sz, dir, opt)
  opt = opt or {}
  local ol = sz > 1
  local o = { outline = ol, gloss = false, cres = 2 * sz, deep = 3 * sz }
  local legL = (opt.leg or (sz > 1 and 13 or 6))
  local bw, bh = 4 * sz + 1, 2 * sz + 1
  local by = y - legL - bh + 1
  -- legs
  c:part(c:line({ {x, by + bh}, {x + dir, y} }, 2), LEG, { flat = true, outline = false, gloss = false })
  if sz > 1 then c:part(c:line({ {x - dir * 3, by + bh}, {x - dir * 2, y - 1} }, 2), LEG, { flat = true, outline = false, gloss = false }) end
  -- neck
  local nx = x + dir * (bw - 1)
  c:part(c:line({ {nx, by}, {nx + dir * 2 * sz, by - 3 * sz}, {nx - dir * 1 * sz, by - 6 * sz}, {nx + dir * 1 * sz, by - 9 * sz} }, 2 + (sz > 1 and 2 or 0)), PK, { flat = true, outline = ol, gloss = false })
  -- body and tail
  local body = c:ellipse(x, by, bw, bh)
  c:part(body, PK, { cres = o.cres, deep = o.deep, outline = ol, gloss = false })
  c:part(c:poly({ {x - dir * (bw + 3), by - 1}, {x - dir * (bw - 2), by - bh}, {x - dir * (bw - 2), by + bh - 1} }), PKL, { flat = true, outline = false, gloss = false })
  -- wing hint
  c:fill(c:rect(x - 2, by, x + 2, by), "#c4527e")
  -- head
  local hx, hy = nx + dir * 1 * sz, by - 9 * sz - 1
  local hr = (sz > 1) and 4.5 or 2.5
  c:part(c:ellipse(hx, hy, hr, hr), PK, { cres = o.cres, deep = o.deep, outline = ol, gloss = false })
  -- beak: pale with dark tip
  local bx = hx + dir * (hr - 0.5)
  c:part(c:rect(math.min(bx, bx + dir * 3 * sz), hy, math.max(bx, bx + dir * 3 * sz), hy + sz), GV.ramp("#f6d9b0"), { flat = true, outline = false, gloss = false })
  c:fill(c:rect(math.min(bx + dir * 2 * sz, bx + dir * 3 * sz), hy, math.max(bx + dir * 2 * sz, bx + dir * 3 * sz), hy + sz), "#2a1a10")
  if sz > 1 then c:eye(hx - 2 - (dir > 0 and 0 or 1) + dir, hy - 3, false)
  else c:fill(c:rect(hx - 1, hy - 1, hx, hy), "#fff1c8"); c:px(hx + dir - (dir > 0 and 1 or 0), hy - 1, "#2a1a10") end
  c:fill(c:ellipse(x, y + 1, sz > 1 and 6 or 3, 1), "#c8628a")
end
-- the far shallows: little wading flocks (no outline, they are far)
for _, f in ipairs({ {20,66,1,1},{34,70,1,-1},{54,64,1,1},{98,62,1,-1},{108,67,1,1},{150,63,1,1},{166,68,1,-1},{186,64,1,-1},{212,70,1,1},{230,62,1,-1},{72,72,1,1},{130,70,1,-1} }) do
  flamingo(f[1], f[2], f[3], f[4])
end
-- a bigger pair mid-lake
flamingo(64, 88, 2, 1, { leg = 9 }); flamingo(190, 90, 2, -1, { leg = 9 })

-- sand bank (foreground)
local bank = L.below(c, function(x) return 96 + 4 * math.sin(x / 22) + (x > 120 and 3 or 0) end)
c:part(bank, GV.ramp("#e2c487"), { cres = 6, deep = 9, gloss = false })
for _, p in ipairs({ {10,126,3,1},{70,124,2,1},{128,127,3,1},{200,125,2,1},{232,128,3,1},{40,129,2,1} }) do
  c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#c9b8a0"), { flat = true, gloss = false, outline = false })
end
for _, x in ipairs({ 6, 90, 160, 236 }) do c:px(x, 104 + (x % 5), "#7ab55c"); c:px(x + 1, 103 + (x % 5), "#a4b86a"); c:px(x + 2, 104 + (x % 5), "#7ab55c") end

-- stalls ---------------------------------------------------------------------------------------------
local function feathers(x, y, n)  -- a bundle of feathers on the counter
  for i = 1, n do
    local fx = x + (i - 1) * 4
    c:fill(c:rect(fx, y - 2 - (i % 2) * 2, fx + 1, y), (i % 2 == 0) and "#f6a2c0" or "#f08aae")
    c:px(fx, y - 3 - (i % 2) * 2, "#fbe0ea")
  end
end
local function stall(x0, y0, w, h, c1, c2, crafter)
  -- posts and back cloth
  c:part(c:rect(x0, y0 - h, x0 + w, y0), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, gloss = false, pale = true })
  c:part(c:rect(x0 - 1, y0 - h, x0 + 1, y0 + 1), GV.ramp("#b07a45"), { gloss = false, cres = 2 })
  c:part(c:rect(x0 + w - 1, y0 - h, x0 + w + 1, y0 + 1), GV.ramp("#b07a45"), { gloss = false, cres = 2 })
  -- hanging feather garland on the back
  for i = 0, 3 do
    local fx = x0 + 4 + i * math.floor((w - 8) / 3)
    c:fill(c:rect(fx, y0 - h + 6, fx, y0 - h + 8), "#8a4f2a")
    c:fill(c:rect(fx - 1, y0 - h + 9, fx + 1, y0 - h + 13), (i % 2 == 0) and "#f08aae" or "#f6b0c8")
  end
  -- crafter (a flamingo folk), head above the counter
  local mx = x0 + math.floor(w / 2)
  if crafter then
    c:part(c:ellipse(mx, y0 - 6, 7, 6), PK, { cres = 4, deep = 6, gloss = false })
    c:part(c:line({ {mx + 3, y0 - 10}, {mx + 6, y0 - 14}, {mx + 3, y0 - 18} }, 4), PK, { flat = true, outline = true, gloss = false })
    c:part(c:ellipse(mx + 4, y0 - 20, 5, 4.5), PK, { cres = 3, deep = 5, gloss = false })
    c:part(c:poly({ {mx + 8, y0 - 21}, {mx + 14, y0 - 19}, {mx + 8, y0 - 17} }), GV.ramp("#f6d9b0"), { flat = true, outline = false, gloss = false })
    c:fill(c:rect(mx + 12, y0 - 20, mx + 13, y0 - 19), "#2a1a10")
    c:eye(mx + 1, y0 - 24)
    -- a feather in the hat band
    c:part(c:rect(mx - 1, y0 - 25, mx + 8, y0 - 25), GV.ramp("#e8a317"), { flat = true, outline = false, gloss = false })
    c:fill(c:rect(mx + 5, y0 - 30, mx + 6, y0 - 26), "#fbe0ea"); c:fill(c:rect(mx + 7, y0 - 30, mx + 7, y0 - 27), "#f6a2c0")
  end
  -- counter
  c:part(c:rrect(x0 - 3, y0 - 7, x0 + w + 3, y0 + 2, 1), GV.ramp("#d9a660"), { cres = 3, gloss = false })
  c:seam({ {x0 - 1, y0 - 3}, {x0 + w + 1, y0 - 3} }, { on = 2, off = 1 })
  -- awning (scalloped stripes)
  local n = math.floor((w + 8) / 6)
  for i = 0, n - 1 do
    local ax = x0 - 4 + i * 6
    c:part(c:rect(ax, y0 - h - 6, ax + 5, y0 - h + 1), GV.ramp((i % 2 == 0) and c1 or c2), { cres = 2, deep = 3, gloss = false, outline = true })
    c:part(c:ellipse(ax + 2.5, y0 - h + 1, 3, 2), GV.ramp((i % 2 == 0) and c1 or c2), { flat = true, outline = false, gloss = false })
  end
end
stall(18, 112, 34, 30, "#f08aae", "#f9e6c0")
stall(184, 112, 34, 30, "#4aa0a8", "#f9e6c0")
-- goods on the small stalls' counters
feathers(24, 105, 6); feathers(192, 105, 5)
-- hats/fans on the right stall
c:part(c:ellipse(212, 103, 4, 3), GV.ramp("#f08aae"), { flat = true, gloss = false, outline = false })
-- right-hand crafter
do
  local mx = 201
  c:part(c:ellipse(mx, 104, 5, 4), PK, { cres = 3, deep = 5, gloss = false })
  c:part(c:ellipse(mx + 1, 92, 4, 3.5), PK, { cres = 2, deep = 4, gloss = false })
  c:part(c:poly({ {mx + 5, 91}, {mx + 10, 93}, {mx + 5, 94} }), GV.ramp("#f6d9b0"), { flat = true, outline = false, gloss = false })
  c:eye(mx - 4, 88, true)
end
-- the big central stall (focal): bigger, with a flamingo-feather fan sign and a bright awning
-- feather fan above the central stall
do
  local fx, fy = 115, 80
  for i = -4, 4 do
    local tipx = fx + i * 5; local tipy = fy - 22 + math.abs(i) * 3
    c:part(c:line({ {fx, fy}, {tipx, tipy} }, 2), GV.ramp((i % 2 == 0) and "#f08aae" or "#f6b0c8"), { flat = true, outline = false, gloss = false })
  end
  c:part(c:ellipse(fx, fy + 1, 3, 3), GV.ramp("#e8a317"), { flat = true, outline = false })
end
stall(88, 116, 54, 38, "#d6322b", "#f9e6c0", true)
-- goods on the central counter: feather bundles and a plumed hat
feathers(94, 109, 5); feathers(120, 109, 4)
c:part(c:ellipse(106, 107, 5, 2), GV.ramp("#4aa0a8"), { flat = true, gloss = false, outline = false })
c:fill(c:rect(106, 100, 106, 105), "#f08aae"); c:fill(c:rect(107, 98, 107, 103), "#fbe0ea")

-- customers: a gnome-scale flamingo trader in the foreground, with a bag, and one with a basket
flamingo(66, 128, 2, 1, { leg = 10 })
flamingo(168, 128, 2, -1, { leg = 10 })
-- drifting feathers on the lake / in the air
for _, f in ipairs({ {30,56},{150,58},{100,86},{220,80},{170,52},{12,92} }) do
  c:fill(c:rect(f[1], f[2], f[1] + 3, f[2]), "#fbe0ea"); c:px(f[1] + 4, f[2] + 1, "#f6a2c0")
end
-- sky birds
for _, g in ipairs({ {70,26},{80,22},{176,24} }) do c:px(g[1], g[2], "#d9628c"); c:px(g[1] + 1, g[2] + 1, "#d9628c"); c:px(g[1] + 2, g[2], "#d9628c") end
L.finish(c, "wonder-flamingo-shallows")
