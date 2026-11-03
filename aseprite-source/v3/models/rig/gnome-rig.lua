-- gnome-rig.lua : splits gnome-player (../gnome-player.lua, run unchanged) into stackable rig layers.
-- Every pixel goes to the layer of the drawing step that painted it LAST, so the layers are disjoint
-- and stacking them reproduces gnome-player.png exactly. Tintable layers are written in 4 marker greys.
-- Run: AppRun -b --script-param out=<rig dir>/ --script gnome-rig.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local SRC = DIR .. "/../gnome-player.lua"
local out = app.params.out or (DIR .. "/")

-- layer order (bottom -> top) and roles; must match rig.json
local LAYERS = { "shadow", "outline", "boots", "tunic", "scarf", "skin", "beard", "face", "hat", "trim" }
local MARK = { hi = "#f0f0f0", base = "#b4b4b4", shade = "#787878", deep = "#3c3c3c" }

-- section anchors in gnome-player.lua: a put belongs to the section whose anchor line is the last one
-- at or above the innermost calling line inside frame(). Robust to edits that keep these comments/calls.
local ANCHORS = {
  { "c:groundShadow", "shadow" }, { "-- boots with", "boots" }, { "-- tunic:", "tunic" },
  { "-- sleeves", "tunic" }, { "form(c, c:ellipse(X(x0 + 2)", "skin" }, { "sleeve(17, la", "tunic" },
  { "-- scarf ring", "scarf" }, { "-- head + ears", "skin" }, { "-- beard:", "beard" },
  { "-- nose", "skin" }, { "c:put(X(32), 41 + b, P.cream)", "face" }, { "-- eyes, cheeks", "face" },
  { "-- hat: tall", "hat" }, { "local bell =", "trim" }, { "c:finish", "outline" },
}

local lines = {}
for l in io.lines(SRC) do lines[#lines + 1] = l end
local F0, F1
for i, l in ipairs(lines) do
  if l:find("local function frame(", 1, true) then F0 = i end
  if F0 and not F1 and i > F0 and l:find("^  return c") then F1 = i end
end
assert(F0 and F1, "rig: frame() not found in gnome-player.lua")
local secAt = {}
local marks = {}
for _, a in ipairs(ANCHORS) do
  local hit
  for i = F0, F1 do if lines[i]:find(a[1], 1, true) then hit = i break end end
  assert(hit, "rig: anchor not found: " .. a[1])
  marks[#marks + 1] = { hit, a[2] }
end
table.sort(marks, function(p, q) return p[1] < q[1] end)
for i = F0, F1 do
  local s
  for _, m in ipairs(marks) do if m[1] <= i then s = m[2] end end
  secAt[i] = s
end

local function caller()
  for lv = 3, 40 do
    local inf = debug.getinfo(lv, "Sl")
    if not inf then break end
    if inf.source == "@" .. SRC and inf.currentline >= F0 and inf.currentline <= F1 then
      return secAt[inf.currentline] or error("rig: put at line " .. inf.currentline .. " has no section")
    end
  end
  error("rig: put from outside frame()")
end

-- run gnome-player.lua with an instrumented HP (canvas tracks layer per pixel, sheet only captures)
local captured, HPref
local env = setmetatable({}, { __index = _G })
env.dofile = function(p)
  local H = dofile(p)
  HPref = H
  local mk = H.canvas
  H.canvas = function(o)
    local c = mk(o)
    c.lay = {}
    local put = getmetatable(c).put
    c.put = function(self, x, y, hex, owner)
      if x >= 0 and y >= 0 and x < self.w and y < self.h then self.lay[y * self.w + x] = caller() end
      return put(self, x, y, hex, owner)
    end
    return c
  end
  H.sheet = function(o)
    captured = captured or o -- first sheet() call = the colour gnome
    return { save = function() end }
  end
  return H
end
local chunk = assert(load(io.open(SRC):read("a"), "@" .. SRC, "t", env))
chunk()
local HP, P = HPref, HPref.P

-- as-drawn ramps of tintable layers (colour -> marker). Extra keys = colours folded in by remap().
local function R(r, extra)
  local t = { [r.hi:lower()] = "hi", [r.base:lower()] = "base", [r.shade:lower()] = "shade", [r.deep:lower()] = "deep" }
  for k, v in pairs(extra or {}) do t[k:lower()] = v end
  return t
end
local TINT = {
  boots = R(P.wood),
  tunic = R(P.sea),
  scarf = R(P.gold, { [P.wood.deep] = "deep" }),          -- gold.deep remapped to wood.deep
  skin  = R(P.skinA, { [P.wood.deep] = "deep" }),         -- skinA.deep remapped to wood.deep
  beard = R({ hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }),
  hat   = R(P.ember),
  trim  = R(P.gold, { [P.wood.deep] = "deep" }),
}

local W, H, N = 64, 80, #captured.frames
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs, stats = {}, {}
for _, ln in ipairs(LAYERS) do
  imgs[ln] = {}
  stats[ln] = { px = 0, cols = {} }
  for f = 1, N do local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0)) imgs[ln][f] = im end
end
for f, c in ipairs(captured.frames) do
  for i, hex in pairs(c.pix) do
    local ln = c.lay[i] or error("rig: pixel without layer")
    local t = TINT[ln]
    local o = hex
    if t then
      local m = t[hex] or error(string.format("rig: %s colour %s not in its ramp (frame %d px %d)", ln, hex, f, i))
      o = MARK[m]
    end
    imgs[ln][f]:putPixel(i % W, i // W, rgba(o))
    local s = stats[ln] s.px = s.px + 1 s.cols[hex] = (s.cols[hex] or 0) + 1
  end
end

-- per-layer strips (384x80) + one layered .aseprite (frames, tags)
for _, ln in ipairs(LAYERS) do
  local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
  for f = 1, N do strip:drawImage(imgs[ln][f], Point((f - 1) * W, 0)) end
  local spr = Sprite(W * N, H, ColorMode.RGB) spr.cels[1].image = strip
  spr:saveCopyAs(out .. "gnome-" .. ln .. ".png") spr:close()
  local cl = {} for k, v in pairs(stats[ln].cols) do cl[#cl + 1] = k .. "x" .. v end table.sort(cl)
  print(string.format("%-8s %5d px  %s", ln, stats[ln].px, table.concat(cl, " ")))
end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
local base = spr.layers[1]
for li, ln in ipairs(LAYERS) do
  local L = li == 1 and base or spr:newLayer()
  L.name = ln
  for f = 1, N do spr:newCel(L, spr.frames[f], imgs[ln][f], Point(0, 0)) end
end
for _, t in ipairs(captured.tags) do local tg = spr:newTag(t.from, t.to) tg.name = t.name end
spr:saveAs(out .. "gnome-rig.aseprite") spr:close()
print("rig: " .. N .. " frames, " .. #LAYERS .. " layers -> " .. out)
