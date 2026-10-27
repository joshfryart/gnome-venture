-- Mockup B: "embroidery hoop progress". One hoop holds the current leg: a stitched S-path from the
-- From button (lower left) to the To button (upper right) with a French knot per space. Sewn = gold.
-- Params: steps (default 5), step (default 3). Prints knot centres so the page can seat the gnome token.
-- Also: b-minihoop-done / -here / -todo for the legs row (one small hoop per stop on the route).
local L = dofile(app.fs.joinPath(app.fs.filePath(debug.getinfo(1, "S").source:sub(2)), "route-lib.lua"))
local px = L.px
local STEPS = tonumber(app.params["steps"] or "5")
local STEP = tonumber(app.params["step"] or "3")

local W = 76
local cx, cy = 38, 40
local RO, RI = 33, 26

local function ring(img, cx, cy, ro, ri, clasp)
  for y = 0, W - 1 do for x = 0, W - 1 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local d = math.sqrt(dx * dx + dy * dy)
    if d <= ro and d > ri then
      local t = (d - ri) / (ro - ri)                 -- 0 inner lip .. 1 outer edge
      local s = (dx + dy) / (d * 1.4142)             -- +1 lower right, -1 upper left
      local col = "#b07a45"
      if s > 0.25 and t > 0.45 then col = "#8a4f2a" end
      if s > 0.55 and t > 0.7 then col = "#5e2f1e" end
      if s < -0.35 and t > 0.55 then col = "#d9a660" end
      if s < -0.25 and t < 0.22 then col = "#8a4f2a" end   -- inner lip faces away from the light
      if s > 0.2 and t < 0.22 then col = "#d9a660" end     -- lit inner lip opposite
      if math.abs(t - 0.5) < 0.09 then col = (s > 0.25) and "#5e2f1e" or "#8a4f2a" end   -- seam between the two rings
      if s < -0.85 and math.abs(t - 0.75) < 0.12 then col = "#ecc58a" end                 -- gloss arc
      px(img, x, y, col)
    elseif d <= ri then
      -- stretched felt: one crescent to the lower right
      local ddx, ddy = dx + 4, dy + 4
      local col = (ddx * ddx + ddy * ddy <= ri * ri) and "#4a2c1a" or "#3d2a1c"
      px(img, x, y, col)
    end
  end end
end

do
  local spr, img = L.new(W, W)
  ring(img, cx, cy, RO, RI)
  -- edge stitch just inside the hoop, every third pixel
  local n = 0
  for a = 0, 359, 2 do
    local r = RI - 2.5
    local x = math.floor(cx + math.cos(math.rad(a)) * r)
    local y = math.floor(cy + math.sin(math.rad(a)) * r)
    n = n + 1
    if n % 3 == 0 then px(img, x, y, "#7a4a1f") end
  end
  -- clasp at the top (gold screw block)
  L.rows(img, cx - 6, 2, {
    "..gggggggg..",
    ".gwggggggss.",
    "ggggHggHgsss",
    "gsssssssssss",
    ".ssssssssss.",
    "..ss....ss..",
    "..ss....ss..",
  }, { g = "#f5cf6a", w = "#fff1c8", s = "#e8a317", H = "#8a4a1c" })
  L.rect(img, cx - 9, 6, 3, 2, "#c9c5bc"); L.rect(img, cx + 6, 6, 3, 2, "#8b8f96")   -- screw ends
  -- the path
  local function P(t)
    return cx - 17 + 34 * t, cy + 15 - 30 * t + 6 * math.sin(2 * math.pi * t)
  end
  local knotT = {}
  for k = 1, STEPS do knotT[k] = k / (STEPS + 1) end
  local here = STEP / (STEPS + 1)
  local last, pts = nil, {}
  for i = 0, 2000 do
    local t = i / 2000
    local x, y = P(t)
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    local key = x .. "," .. y
    if key ~= last then pts[#pts + 1] = { x, y, t }; last = key end
  end
  local idx = 0
  for _, p in ipairs(pts) do
    idx = idx + 1
    if p[3] <= here then
      if idx % 3 ~= 0 then px(img, p[1], p[2], "#f5cf6a"); px(img, p[1] + 1, p[2] + 1, "#b07a10") end
    else
      if idx % 3 == 0 then px(img, p[1], p[2], "#2a1a10") end
    end
  end
  -- knots
  local out = {}
  for k = 1, STEPS do
    local x, y = P(knotT[k]); x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    if k <= STEP then
      L.rows(img, x - 2, y - 2, { ".gg.", "gwgs", "ggss", ".ss." }, { g = "#f5cf6a", w = "#fff1c8", s = "#e8a317" })
    else
      L.rows(img, x - 2, y - 2, { ".cc.", "c..b", "c..b", ".bb." }, { c = "#c9a96e", b = "#9a6b3f" })
    end
    out[#out + 1] = string.format("{\"k\":%d,\"x\":%d,\"y\":%d}", k, x, y)
  end
  -- From and To buttons (red felt buttons with two thread holes)
  for _, t in ipairs({ 0, 1 }) do
    local x, y = P(t); x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    L.rows(img, x - 3, y - 3, {
      ".rrrr.",
      "rhrrrs",
      "rrHrrs",
      "rrrHrs",
      "rrrrss",
      ".ssss.",
    }, { r = "#dd3a2a", h = "#ff9158", s = "#ae2a2a", H = "#f5cf6a" })
  end
  L.outline(img, 1, false)
  L.border(img)
  L.save(spr, "b-hoop")
  print("[" .. table.concat(out, ",") .. "]")
end

-- small hoops for the legs row, 18 x 18
local function mini(name, inside)
  local spr, img = L.new(18, 18)
  for y = 0, 17 do for x = 0, 17 do
    local dx, dy = x + 0.5 - 9, y + 0.5 - 9
    local d = math.sqrt(dx * dx + dy * dy)
    local s = (dx + dy)
    if d <= 7.5 and d > 5.2 then
      px(img, x, y, s > 3 and "#8a4f2a" or (s < -4 and "#d9a660" or "#b07a45"))
    elseif d <= 5.2 then
      px(img, x, y, (s > 3) and "#3d2a1c" or "#4a2c1a")
    end
  end end
  if inside == "done" then
    for _, p in ipairs({ {7,7},{10,7},{8,8},{9,9},{7,10},{10,10},{8,9},{9,8} }) do px(img, p[1], p[2], "#f5cf6a") end
    px(img, 9, 9, "#e8a317"); px(img, 10, 10, "#e8a317")
  elseif inside == "here" then
    L.rows(img, 7, 7, { ".rr.", "rhrs", "rrss", ".ss." }, { r = "#dd3a2a", h = "#ff9158", s = "#ae2a2a" })
  elseif inside == "goal" then
    L.rows(img, 6, 5, { "p.....", "pccrr.", "prrcc.", "pccrr.", "p.....", "p....." }, { p = "#d9a660", c = "#f2e4c0", r = "#dd3a2a" })
  end
  L.outline(img, 1, false)
  L.border(img)
  L.save(spr, name)
end
mini("b-minihoop-done", "done")
mini("b-minihoop-here", "here")
mini("b-minihoop-todo", nil)
mini("b-minihoop-goal", "goal")
print("B sprites ok")
