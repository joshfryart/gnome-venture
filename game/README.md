# Gnome Venture — v0.7.36 (gnomeventure.ca)

A Neopets-style garden game in plain PHP + MySQL. Runs on almost any cheap shared web host.

## What's in this build
- **Secure accounts:** sign-up, log-in, log-out. Passwords hashed, brute-force lockout (5 tries / 15 min),
  forms protected against forgery (CSRF), output escaped against script injection (XSS),
  strict browser security headers, bot trap on sign-up.
- **Admin panel** (`/admin/`): dashboard, game settings, players (ban, roles, stats, currency),
  give/take items, items, plants, recipes, locations, NPCs, NPC schedules, shops, shop stock,
  Almanac entries, news, pages, and a log of every admin change.
- **Shop staffing check:** each shop shows a week grid of which NPC covers each hour; red = nobody working.
- **New players get:** a 4×4 plot, starter seeds/tools/compost, and their Almanac (encyclopedia).
- **Starter world:** 2 shops staffed 24/7 by 6 NPCs who wander and go home after work, 1 travelling NPC.
- **World crop catalog (v0.7):** 186 real crops and 14 merged world regions, each with gnomish and real
  names, climate flavour and three crop tiers (staple / uncommon / treasure). 12 flowers per region
  (168 in all). 667 Almanac pages: Plants, Flowers, Regions, Villages, Landmarks, Creatures. 57
  milestones with rewards. The lists live in `includes/data/` (`regions.txt`, `zones.txt`,
  `landmarks.txt`, `flowers.txt`, `region_crops.txt`, `crops.txt`). Edit them and press
  **Import / update catalog** on the admin dashboard to add new ones.
- **Gardening (v0.2):** till, add soil, plant, water, harvest, seed saving, perennials that regrow,
  plant knowledge and mastery, XP and levels, energy that refills over time, plot expansion.

- **Soil health (v0.3):** each square has fertility, soil life and moisture. Till (fast, but harms soil life;
  tilling a no-till bed wipes it out) or no-till (cardboard + mulch, settles, then improves every harvest).
  Hoe, broadfork, soil test kit, compost, worm castings, three mulches, cover crops, Three Sisters and pollinator bonuses.
- **No-till soil grades (v0.3.1):** no-till beds are graded F, F+, D, D+, C, C+, B, B+, A, A+, S.
  Gentle upkeep (v0.3.2): straw mulch lasts 6 days (wood chips 10), weeds and drying take days, and one watering
  lasts 6–24 hours. Well-kept beds gain points (double with living roots, bonus for harvests and cover crops);
  neglected beds slowly lose them. Checkpoints at C and A: a bed can't fall below them unless tilled or
  neglected for 14 days straight.
  Higher grades grow faster, give bigger harvests and more seeds, hold water longer, and A+/S beds find
  worm castings and rich loam. Reaching C, B, A and S unlocks Almanac pages, rewards and titles.
  Rates are adjustable in Game settings.
- **Flowers (v0.7):** 168 ornamental flowers, 12 per world region. Regions need all their flowers for Gold tier.
- **Home region & guides (v0.7):** players pick a home region AND a starter zone at sign-up. They can grow
  everyday crops plus their home region's staples and flowers. Gardening guides (rare market finds) teach
  a whole region at once.
- **Markets & travel (v0.7):** 14 regional seed markets (one per region) with Gnomish names, each staffed
  around the clock, with Neopets-style restocks and rare finds. The Mossbottom hub sells supplies and
  everyday seeds from anywhere. Travel home is free.
- **Zones & landmarks (v0.7):** each region holds four zones (one easy, two medium, one hard) and 5–6
  landmarks: 🏕️ havens (safe rests and buffs), ✨ wonders (puzzles and events), 🕳️ delves (hard side paths)
  and 🐉 lairs (bosses with set levels).
- **Region tiers (v0.7):** every region earns Bronze (grow every staple), Silver (+ every uncommon), and
  Gold (+ every treasure and every flower) tiers, each with its own title and rewards.

- **Gnomes (v0.4):** players are garden gnomes with seven stats: Grit, Nimble, Hardiness, Lore, Sense, Charm
  and Luck, each with a clear gardening effect (adventuring effects come next). Gardener level gives stat
  points; each garden has its own garden level, which sets how big it can grow and unlocks the kitchen.
  Six callings at level 5 (Rootwarden, Bloomcaller, Thornblade, Seedkeeper, Wayfinder, Brewroot), each with
  a hat colour and a gardening perk. Switching costs Petals.
- **Eating & cooking (v0.4):** eat from the satchel for a meal buff (one at a time) and energy. Rare crops
  raise a stat permanently the first time each gnome eats them, up to +5 per stat from food. 22 recipes
  in `includes/data/recipes.txt`, discovered by growing every ingredient, cooked in the garden kitchen.

- **Adventuring (v0.7):** 146 gnome villages across the 14 regions and 56 zones, each with a landscape:
  coast, mountain, forest, desert, rainforest, grassland, wetland, tundra or island. Walk paths between
  villages and landmarks: each walk costs energy, has 3–6 steps and takes a few real minutes. Steps bring
  creatures, problems (stat checks) or finds (seeds, Petals, landscape treasures). Zone 1 scales to your
  level, zones 2–3 have medium fixed ranges, zone 4 is hard. 48 creatures at gnome scale (aphids to a Storm
  Eagle) with drop tables, 20 problems, turn-based combat with a special ability per calling, auto-resolve
  only when the result is certain, and knock-outs that cost nothing but a little energy. Creatures,
  Villages and Landmarks Almanac chapters. Data in `includes/data/zones.txt`, `landmarks.txt`,
  `creatures.txt`, `problems.txt`; everything editable in Admin → World and Admin → Adventuring.

- **Multiple gardens (v0.7):** a gnome can tend up to 4 gardens, unlocked at gardener levels 10, 25 and 40.
  Buy a land deed in any village of a new region; the locals teach you that region's crops (all tiers).
  Crops grow 25% faster in a garden in their native region. Each garden has its own level, name and
  buildings: Kitchen, Rain Barrel, Tool Shed, Compost Bin (daily compost), Beehive (daily honey +
  pollinators) and Greenhouse (everything grows at native speed).

- **Danger by distance (v0.6.3):** paths next to a safe place (a market, the hub, or a village where you own a
  garden) always match your gardener level and never have bosses. Paths further out have a set level range
  (editable per path in Admin → Routes, with a "fixed" switch for boss lairs). A sidebar box lets you keep
  adventuring from any page.

## How the Almanac fills up
- A **plant** page unlocks the first time you harvest that crop.
- A **flower** page unlocks the first time you cut that flower.
- A **village** or **landmark** page unlocks on your first visit.
- A **region**'s Bronze tier unlocks when you've grown every one of its staple crops.
- Silver tier unlocks when you've also grown every uncommon crop.
- Gold tier unlocks when you've also grown every treasure crop and cut every one of its flowers.
- Plants you know but haven't grown show as **studied**, with their growing info.
- **Milestones** (page counts, % complete, each region's Bronze/Silver/Gold) pay currency, items and titles.
  Edit or add milestones in Admin → Almanac milestones.

## Install on a web host
1. Buy basic shared hosting with PHP 8.1+ and MySQL (most "starter" plans have both).
2. In the host's control panel, create a **MySQL database** and a **database user**; give the user all
   rights on that database. Write down the database name, user, password and host.
3. Upload every file in this folder to your site's `public_html` (or a sub-folder) using the host's
   File Manager or an FTP program.
4. Visit `https://yoursite/install.php`, fill in the form, press Install.
5. **Delete `install.php`** from the server. The admin dashboard reminds you until you do.
6. Turn on free HTTPS (usually "SSL" / "Let's Encrypt" in the control panel).

## Test on your own computer (optional)
Install PHP, then in this folder run `php -S localhost:8000` and open `http://localhost:8000/install.php`,
choosing **SQLite**. Delete `config.php` and `data/game.sqlite` to start over.

## Updating from an older test version
v0.6 changed how gardens are stored. If you installed anything before v0.6 just to test, delete
`config.php` and the old database tables (or make a fresh database) and run `install.php` again.

## Updating later
Upload the new files (never overwrite `config.php`), then press **Upgrade database** on the admin dashboard.

## Security notes for you
- Use a long, unique admin password. Don't share the admin account; make others "mod" later.
- `config.php` holds your database password — never post it anywhere.
- The `includes/` and `data/` folders are locked from the web by `.htaccess` (Apache hosts).
- Times for NPC schedules are server time (UTC). Halifax is UTC−3 in summer, UTC−4 in winter.
