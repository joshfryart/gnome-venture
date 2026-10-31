<?php
declare(strict_types=1);

/**
 * Full database schema. To add a new table later: add it here, then press
 * "Upgrade database" on the admin dashboard. Existing data is never touched.
 * Returns [tableStatements, indexStatements, columnPatches].
 */
function schema_statements(string $driver): array
{
    $sqlite = $driver === 'sqlite';
    $PK  = $sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY';
    $ID  = $sqlite ? 'INTEGER' : 'INT UNSIGNED';
    $END = $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci';

    $t = [];

    // ---------- Accounts & site ----------
    $t[] = "CREATE TABLE IF NOT EXISTS users (
        id $PK,
        username VARCHAR(30) NOT NULL UNIQUE,
        email VARCHAR(190) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(10) NOT NULL DEFAULT 'player',
        coins INT NOT NULL DEFAULT 0,
        level INT NOT NULL DEFAULT 1,
        xp INT NOT NULL DEFAULT 0,
        energy INT NOT NULL DEFAULT 10,
        stat_grit INT NOT NULL DEFAULT 10,
        stat_nimble INT NOT NULL DEFAULT 10,
        stat_hardiness INT NOT NULL DEFAULT 10,
        stat_lore INT NOT NULL DEFAULT 10,
        stat_sense INT NOT NULL DEFAULT 10,
        stat_charm INT NOT NULL DEFAULT 10,
        stat_luck INT NOT NULL DEFAULT 10,
        stat_points INT NOT NULL DEFAULT 4,
        calling VARCHAR(20) NULL,
        buff TEXT NULL,
        buff_until DATETIME NULL,
        location_id $ID NULL,
        home_village_id $ID NULL,
        active_plot_id $ID NULL,
        banned INT NOT NULL DEFAULT 0,
        ban_reason VARCHAR(255) NULL,
        created_at DATETIME NOT NULL,
        last_login DATETIME NULL,
        last_seen DATETIME NULL,
        energy_updated_at DATETIME NULL,
        title VARCHAR(80) NULL,
        region_id $ID NULL,
        location VARCHAR(60) NULL,
        gnome_name VARCHAR(30) NULL,
        hat_color VARCHAR(7) NULL,
        beard_color VARCHAR(7) NULL,
        onboarded INT NOT NULL DEFAULT 1,
        tour_step INT NOT NULL DEFAULT 0
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS login_attempts (
        id $PK,
        ip VARCHAR(45) NOT NULL,
        username VARCHAR(190) NOT NULL,
        attempted_at DATETIME NOT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS settings (
        name VARCHAR(64) NOT NULL PRIMARY KEY,
        value TEXT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS admin_log (
        id $PK,
        user_id $ID NULL,
        action VARCHAR(64) NOT NULL,
        target VARCHAR(190) NULL,
        details TEXT NULL,
        ip VARCHAR(45) NULL,
        created_at DATETIME NOT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS news (
        id $PK,
        title VARCHAR(150) NOT NULL,
        body TEXT NULL,
        published INT NOT NULL DEFAULT 0,
        author_id $ID NULL,
        created_at DATETIME NOT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS pages (
        id $PK,
        slug VARCHAR(80) NOT NULL UNIQUE,
        title VARCHAR(150) NOT NULL,
        body TEXT NULL,
        published INT NOT NULL DEFAULT 0,
        show_in_nav INT NOT NULL DEFAULT 0,
        updated_at DATETIME NULL
    )$END";

    // ---------- Items, plants, cooking ----------
    $t[] = "CREATE TABLE IF NOT EXISTS items (
        id $PK,
        name VARCHAR(80) NOT NULL,
        slug VARCHAR(80) NOT NULL UNIQUE,
        category VARCHAR(20) NOT NULL DEFAULT 'misc',
        description TEXT NULL,
        rarity INT NOT NULL DEFAULT 1,
        base_price INT NOT NULL DEFAULT 10,
        image VARCHAR(255) NULL,
        edible INT NOT NULL DEFAULT 0,
        effects TEXT NULL,
        tradable INT NOT NULL DEFAULT 1,
        max_stack INT NOT NULL DEFAULT 999
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS plants (
        id $PK,
        name VARCHAR(80) NOT NULL,
        slug VARCHAR(80) NULL,
        kind VARCHAR(20) NOT NULL DEFAULT 'vegetable',
        perennial INT NOT NULL DEFAULT 0,
        regrow_minutes INT NOT NULL DEFAULT 0,
        knowledge_per_harvest INT NOT NULL DEFAULT 10,
        common INT NOT NULL DEFAULT 0,
        region_code VARCHAR(10) NULL,
        pollinator VARCHAR(20) NULL,
        soil_effect INT NOT NULL DEFAULT -8,
        seed_item_id $ID NOT NULL,
        produce_item_id $ID NULL,
        sapling_item_id $ID NULL,
        grow_minutes INT NOT NULL DEFAULT 60,
        water_interval_minutes INT NOT NULL DEFAULT 120,
        stages INT NOT NULL DEFAULT 4,
        yield_min INT NOT NULL DEFAULT 1,
        yield_max INT NOT NULL DEFAULT 3,
        xp_per_harvest INT NOT NULL DEFAULT 5,
        knowledge_max INT NOT NULL DEFAULT 100,
        min_soil INT NOT NULL DEFAULT 0,
        seasons VARCHAR(40) NULL,
        description TEXT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS recipes (
        id $PK,
        name VARCHAR(80) NOT NULL,
        output_item_id $ID NOT NULL,
        output_qty INT NOT NULL DEFAULT 1,
        ingredients TEXT NOT NULL,
        cook_minutes INT NOT NULL DEFAULT 0,
        skill_required INT NOT NULL DEFAULT 0,
        slug VARCHAR(80) NULL,
        category VARCHAR(20) NOT NULL DEFAULT 'cooking',
        energy INT NOT NULL DEFAULT 2
    )$END";

    // Recipes a player has discovered (kept even after the ingredients are used up)
    $t[] = "CREATE TABLE IF NOT EXISTS user_recipes (
        id $PK,
        user_id $ID NOT NULL,
        recipe_id $ID NOT NULL,
        learned_at DATETIME NOT NULL,
        made INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, recipe_id)
    )$END";

    // ---------- World, NPCs, shops ----------
    $t[] = "CREATE TABLE IF NOT EXISTS locations (
        id $PK,
        name VARCHAR(80) NOT NULL,
        slug VARCHAR(80) NOT NULL UNIQUE,
        region VARCHAR(60) NULL,
        description TEXT NULL,
        is_public INT NOT NULL DEFAULT 1,
        kind VARCHAR(16) NOT NULL DEFAULT 'place',
        region_id $ID NULL,
        zone_id $ID NULL,
        landscape VARCHAR(20) NULL,
        sort_order INT NOT NULL DEFAULT 0
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS npcs (
        id $PK,
        name VARCHAR(80) NOT NULL,
        slug VARCHAR(80) NOT NULL UNIQUE,
        species VARCHAR(60) NULL,
        personality VARCHAR(60) NULL,
        bio TEXT NULL,
        home_location_id $ID NULL,
        mood INT NOT NULL DEFAULT 50,
        active INT NOT NULL DEFAULT 1
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS shops (
        id $PK,
        name VARCHAR(80) NOT NULL,
        slug VARCHAR(80) NOT NULL UNIQUE,
        location_id $ID NULL,
        shop_type VARCHAR(30) NULL,
        description TEXT NULL,
        restock_minutes INT NOT NULL DEFAULT 30,
        markup_percent INT NOT NULL DEFAULT 0,
        open INT NOT NULL DEFAULT 1,
        last_restock DATETIME NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS npc_schedules (
        id $PK,
        npc_id $ID NOT NULL,
        location_id $ID NULL,
        shop_id $ID NULL,
        activity VARCHAR(30) NOT NULL DEFAULT 'wandering',
        days VARCHAR(20) NOT NULL DEFAULT 'all',
        start_hour INT NOT NULL DEFAULT 0,
        end_hour INT NOT NULL DEFAULT 0
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS shop_stock (
        id $PK,
        shop_id $ID NOT NULL,
        item_id $ID NOT NULL,
        price_min INT NOT NULL DEFAULT 10,
        price_max INT NOT NULL DEFAULT 20,
        max_stock INT NOT NULL DEFAULT 10,
        restock_chance INT NOT NULL DEFAULT 50,
        current_stock INT NOT NULL DEFAULT 0,
        current_price INT NOT NULL DEFAULT 0
    )$END";

    // ---------- Player state ----------
    $t[] = "CREATE TABLE IF NOT EXISTS user_items (
        id $PK,
        user_id $ID NOT NULL,
        item_id $ID NOT NULL,
        qty INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, item_id)
    )$END";

    // A gnome can own several gardens ("plots"), each in a different region.
    $t[] = "CREATE TABLE IF NOT EXISTS plots (
        id $PK,
        user_id $ID NOT NULL,
        region_id $ID NULL,
        village_id $ID NULL,
        width INT NOT NULL DEFAULT 4,
        height INT NOT NULL DEFAULT 4,
        garden_name VARCHAR(60) NULL,
        garden_xp INT NOT NULL DEFAULT 0,
        garden_level INT NOT NULL DEFAULT 1,
        created_at DATETIME NOT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS plot_tiles (
        id $PK,
        plot_id $ID NOT NULL,
        user_id $ID NOT NULL,
        x INT NOT NULL,
        y INT NOT NULL,
        tilled INT NOT NULL DEFAULT 0,
        soil_quality INT NOT NULL DEFAULT 0,
        plant_id $ID NULL,
        planted_at DATETIME NULL,
        last_watered DATETIME NULL,
        growth_seconds INT NOT NULL DEFAULT 0,
        growth_updated_at DATETIME NULL,
        method VARCHAR(10) NULL,
        fertility INT NOT NULL DEFAULT 30,
        soil_life INT NOT NULL DEFAULT 20,
        moisture INT NOT NULL DEFAULT 20,
        settle_until DATETIME NULL,
        mulch INT NOT NULL DEFAULT 0,
        weeds INT NOT NULL DEFAULT 0,
        bed_score INT NOT NULL DEFAULT 0,
        maint_at DATETIME NULL,
        checkpoint INT NOT NULL DEFAULT 0,
        neglect_hours INT NOT NULL DEFAULT 0,
        feed_fert INT NOT NULL DEFAULT 0,
        feed_life INT NOT NULL DEFAULT 0,
        feed_hours INT NOT NULL DEFAULT 0,
        feed_at DATETIME NULL,
        fork_at DATETIME NULL,
        UNIQUE (plot_id, x, y)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS user_plant_knowledge (
        user_id $ID NOT NULL,
        plant_id $ID NOT NULL,
        knowledge INT NOT NULL DEFAULT 0,
        PRIMARY KEY (user_id, plant_id)
    )$END";

    // ---------- Encyclopedia (the player's book) ----------
    $t[] = "CREATE TABLE IF NOT EXISTS encyclopedia_entries (
        id $PK,
        chapter VARCHAR(30) NOT NULL DEFAULT 'General',
        category VARCHAR(30) NOT NULL DEFAULT 'general',
        title VARCHAR(120) NOT NULL,
        body TEXT NULL,
        unlock_key VARCHAR(100) NOT NULL DEFAULT 'start',
        hint VARCHAR(190) NULL,
        sort_order INT NOT NULL DEFAULT 0
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS user_encyclopedia (
        user_id $ID NOT NULL,
        entry_id $ID NOT NULL,
        unlocked_at DATETIME NOT NULL,
        read_at DATETIME NULL,
        PRIMARY KEY (user_id, entry_id)
    )$END";

    // ---------- World catalog ----------
    // 14 merged world regions. "real_name" is flavour text (e.g. "North America"),
    // "gnomish_name" is the in-world name players see (e.g. "The Maplewold").
    $t[] = "CREATE TABLE IF NOT EXISTS regions (
        id $PK,
        code VARCHAR(6) NOT NULL UNIQUE,
        gnomish_name VARCHAR(80) NOT NULL,
        real_name VARCHAR(80) NOT NULL,
        climate_trait VARCHAR(255) NULL,
        soil_type VARCHAR(255) NULL,
        base_danger INT NOT NULL DEFAULT 4,
        min_level INT NOT NULL DEFAULT 1,
        description TEXT NULL,
        sort_order INT NOT NULL DEFAULT 0
    )$END";

    // Each region has 4 zones with a landscape and difficulty.
    $t[] = "CREATE TABLE IF NOT EXISTS zones (
        id $PK,
        region_id $ID NOT NULL,
        zone_num INT NOT NULL,
        landscape VARCHAR(20) NOT NULL,
        name VARCHAR(80) NOT NULL,
        difficulty VARCHAR(10) NOT NULL DEFAULT 'easy',
        villages INT NOT NULL DEFAULT 3,
        UNIQUE (region_id, zone_num)
    )$END";

    // Landmarks live inside a zone. Kinds: haven (safe, small shop), wonder (puzzle/event),
    // delve (hard side path), lair (boss).
    $t[] = "CREATE TABLE IF NOT EXISTS landmarks (
        id $PK,
        region_id $ID NOT NULL,
        zone_id $ID NULL,
        location_id $ID NULL,
        kind VARCHAR(10) NOT NULL,
        name VARCHAR(80) NOT NULL,
        description TEXT NULL,
        sort_order INT NOT NULL DEFAULT 0
    )$END";

    // A plant grows in a region at one of three tiers:
    //   staple    = known from the start when it's your home region
    //   uncommon  = sold at that region's seed market
    //   treasure  = rare find, boosts a stat permanently when first eaten
    $t[] = "CREATE TABLE IF NOT EXISTS plant_regions (
        id $PK,
        plant_id $ID NOT NULL,
        region_id $ID NOT NULL,
        tier VARCHAR(10) NOT NULL DEFAULT 'uncommon',
        UNIQUE (plant_id, region_id)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS almanac_milestones (
        id $PK,
        name VARCHAR(100) NOT NULL,
        kind VARCHAR(10) NOT NULL DEFAULT 'pages',
        threshold INT NOT NULL DEFAULT 0,
        unlock_key VARCHAR(100) NULL,
        reward_coins INT NOT NULL DEFAULT 0,
        reward_item_id $ID NULL,
        reward_qty INT NOT NULL DEFAULT 1,
        reward_title VARCHAR(80) NULL,
        active INT NOT NULL DEFAULT 1
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS user_milestones (
        user_id $ID NOT NULL,
        milestone_id $ID NOT NULL,
        achieved_at DATETIME NOT NULL,
        PRIMARY KEY (user_id, milestone_id)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS user_guides (
        id $PK,
        user_id $ID NOT NULL,
        guide_key VARCHAR(100) NOT NULL,
        read_at DATETIME NOT NULL,
        UNIQUE (user_id, guide_key)
    )$END";

    // ---------- v0.9.1: where gnome XP comes from ----------
    $t[] = "CREATE TABLE IF NOT EXISTS xp_log (
        day VARCHAR(10) NOT NULL,
        user_id INT NOT NULL,
        source VARCHAR(40) NOT NULL,
        xp INT NOT NULL DEFAULT 0,
        PRIMARY KEY (day, user_id, source)
    )$END";

    // ---------- Eating ----------
    $t[] = "CREATE TABLE IF NOT EXISTS user_tasted (
        id $PK,
        user_id $ID NOT NULL,
        item_id $ID NOT NULL,
        tasted_at DATETIME NOT NULL,
        UNIQUE (user_id, item_id)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS user_food_bonus (
        id $PK,
        user_id $ID NOT NULL,
        stat VARCHAR(20) NOT NULL,
        amount INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, stat)
    )$END";

    // Job Board (v0.7.8)
    $t[] = "CREATE TABLE IF NOT EXISTS job_templates (
        id $PK,
        period VARCHAR(10) NOT NULL,
        kind VARCHAR(20) NOT NULL,
        title VARCHAR(80) NOT NULL,
        text TEXT NOT NULL,
        qty_min INT NOT NULL DEFAULT 1,
        qty_max INT NOT NULL DEFAULT 1,
        stages INT NOT NULL DEFAULT 1,
        reward_coins INT NOT NULL DEFAULT 0,
        reward_xp INT NOT NULL DEFAULT 0,
        reward_item VARCHAR(60) NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS user_jobs (
        id $PK,
        user_id $ID NOT NULL,
        period VARCHAR(10) NOT NULL,
        period_key VARCHAR(10) NOT NULL,
        template_id $ID NULL,
        kind VARCHAR(20) NOT NULL,
        title VARCHAR(80) NOT NULL,
        text TEXT NOT NULL,
        npc VARCHAR(80) NULL,
        target VARCHAR(80) NULL,
        target_item_id $ID NULL,
        target_name VARCHAR(80) NULL,
        qty INT NOT NULL DEFAULT 1,
        progress INT NOT NULL DEFAULT 0,
        stages INT NOT NULL DEFAULT 1,
        stages_paid INT NOT NULL DEFAULT 0,
        reward_coins INT NOT NULL DEFAULT 0,
        reward_xp INT NOT NULL DEFAULT 0,
        reward_item_id $ID NULL,
        reward_qty INT NOT NULL DEFAULT 0,
        status VARCHAR(10) NOT NULL DEFAULT 'active',
        taken_at DATETIME NOT NULL,
        done_at DATETIME NULL
    )$END";
    // Random events (v0.7.19)
    $t[] = "CREATE TABLE IF NOT EXISTS random_events (
        id $PK,
        slug VARCHAR(40) NOT NULL UNIQUE,
        weight INT NOT NULL DEFAULT 10,
        kind VARCHAR(10) NOT NULL DEFAULT 'instant',
        effect VARCHAR(190) NOT NULL,
        icon VARCHAR(16) NULL,
        title VARCHAR(120) NOT NULL,
        text TEXT NOT NULL,
        button VARCHAR(60) NULL,
        active INT NOT NULL DEFAULT 1
    )$END";

    // Town squares (v0.7.20): places to go in every town, each with a few things to do
    $t[] = "CREATE TABLE IF NOT EXISTS town_spots (
        id $PK,
        slug VARCHAR(60) NOT NULL UNIQUE,
        region VARCHAR(60) NOT NULL,
        kind VARCHAR(12) NOT NULL DEFAULT 'special',
        icon VARCHAR(16) NULL,
        name VARCHAR(80) NOT NULL,
        description TEXT NULL,
        hours VARCHAR(10) NOT NULL DEFAULT '',
        months VARCHAR(40) NOT NULL DEFAULT '',
        sort_order INT NOT NULL DEFAULT 0,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS town_actions (
        id $PK,
        spot_id $ID NOT NULL,
        slug VARCHAR(60) NOT NULL UNIQUE,
        label VARCHAR(80) NOT NULL,
        kind VARCHAR(10) NOT NULL DEFAULT 'effect',
        effect VARCHAR(190) NOT NULL DEFAULT '',
        link VARCHAR(80) NULL,
        cost_coins INT NOT NULL DEFAULT 0,
        cost_item VARCHAR(60) NOT NULL DEFAULT '',
        energy INT NOT NULL DEFAULT 0,
        chance INT NOT NULL DEFAULT 100,
        stat VARCHAR(12) NOT NULL DEFAULT '',
        daily INT NOT NULL DEFAULT 1,
        success_text TEXT NULL,
        fail_text TEXT NULL,
        sort_order INT NOT NULL DEFAULT 0,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS town_uses (
        id $PK,
        user_id $ID NOT NULL,
        action_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        uses INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, action_id, day)
    )$END";
    // v0.7.65: Wren's Journey, a questline per region
    $t[] = "CREATE TABLE IF NOT EXISTS quest_chapters (
        id $PK,
        slug VARCHAR(80) NOT NULL UNIQUE,
        region_id $ID NOT NULL,
        sort_order INT NOT NULL DEFAULT 0,
        title VARCHAR(120) NOT NULL,
        npc_slug VARCHAR(80) NULL,
        intro TEXT NULL,
        outro TEXT NULL,
        project_name VARCHAR(80) NULL,
        project_icon VARCHAR(16) NULL,
        benefit VARCHAR(40) NULL,
        benefit_text VARCHAR(255) NULL,
        reward_coins INT NOT NULL DEFAULT 0,
        reward_xp INT NOT NULL DEFAULT 0,
        reward_item_slug VARCHAR(80) NULL,
        reward_qty INT NOT NULL DEFAULT 1,
        reward_title VARCHAR(60) NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS quest_tasks (
        id $PK,
        chapter_id $ID NOT NULL,
        sort_order INT NOT NULL DEFAULT 0,
        kind VARCHAR(12) NOT NULL,
        spec VARCHAR(255) NULL,
        qty INT NOT NULL DEFAULT 1,
        label VARCHAR(255) NOT NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS user_quests (
        id $PK,
        user_id $ID NOT NULL,
        chapter_id $ID NOT NULL,
        stage INT NOT NULL DEFAULT 0,
        started_at DATETIME NULL,
        done_at DATETIME NULL,
        crate_at DATETIME NULL,
        UNIQUE (user_id, chapter_id)
    )$END";
    // v0.9.4: calling questlines (a Journeyman and a Master chapter per calling)
    $t[] = "CREATE TABLE IF NOT EXISTS calling_chapters (
        id $PK,
        slug VARCHAR(80) NOT NULL UNIQUE,
        calling VARCHAR(20) NOT NULL,
        tier INT NOT NULL DEFAULT 2,
        title VARCHAR(120) NOT NULL,
        mentor_slug VARCHAR(80) NULL,
        intro TEXT NULL,
        outro TEXT NULL,
        reward_coins INT NOT NULL DEFAULT 0,
        reward_xp INT NOT NULL DEFAULT 0,
        reward_item_slug VARCHAR(80) NULL,
        reward_qty INT NOT NULL DEFAULT 1,
        reward_title VARCHAR(60) NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS calling_tasks (
        id $PK,
        chapter_id $ID NOT NULL,
        sort_order INT NOT NULL DEFAULT 0,
        mode VARCHAR(8) NOT NULL DEFAULT 'event',
        kind VARCHAR(20) NOT NULL,
        spec VARCHAR(255) NULL,
        qty INT NOT NULL DEFAULT 1,
        label VARCHAR(255) NOT NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS user_calling_chapters (
        id $PK,
        user_id $ID NOT NULL,
        chapter_id $ID NOT NULL,
        started_at DATETIME NOT NULL,
        done_at DATETIME NULL,
        UNIQUE (user_id, chapter_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS user_calling_tasks (
        id $PK,
        user_id $ID NOT NULL,
        task_id $ID NOT NULL,
        progress INT NOT NULL DEFAULT 0,
        seen TEXT NULL,
        done_at DATETIME NULL,
        UNIQUE (user_id, task_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS user_npc_met (
        id $PK,
        user_id $ID NOT NULL,
        npc_id $ID NOT NULL,
        first_at DATETIME NULL,
        UNIQUE (user_id, npc_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS town_lore (
        id $PK,
        region VARCHAR(60) NOT NULL,
        text TEXT NOT NULL
    )$END";

    // Guess the Giant Marrow (v0.7.31): one guess a gnome a day
    $t[] = "CREATE TABLE IF NOT EXISTS marrow_guesses (
        id $PK,
        day VARCHAR(10) NOT NULL,
        user_id $ID NOT NULL,
        grams INT NOT NULL,
        placed INT NULL,
        at DATETIME NOT NULL,
        UNIQUE (day, user_id)
    )$END";

    // Rebuilt landmarks (v0.7.29): who finished a rebuild job for which landmark
    $t[] = "CREATE TABLE IF NOT EXISTS landmark_rebuilds (
        id $PK,
        landmark_id $ID NOT NULL,
        user_id $ID NOT NULL,
        done_at DATETIME NOT NULL,
        UNIQUE (landmark_id, user_id)
    )$END";

    // Moderation (v0.7.28): player reports for the mod queue
    $t[] = "CREATE TABLE IF NOT EXISTS reports (
        id $PK,
        reporter_id $ID NOT NULL,
        target_id $ID NOT NULL,
        kind VARCHAR(16) NOT NULL,
        ref_id $ID NULL,
        snapshot TEXT NULL,
        reason VARCHAR(20) NOT NULL,
        details VARCHAR(255) NULL,
        status VARCHAR(10) NOT NULL DEFAULT 'open',
        action VARCHAR(20) NULL,
        handled_by $ID NULL,
        handled_at DATETIME NULL,
        created_at DATETIME NOT NULL
    )$END";

    // Landmarks (v0.7.26): once-a-day things at each landmark, and delve/lair clears
    $t[] = "CREATE TABLE IF NOT EXISTS landmark_uses (
        id $PK,
        user_id $ID NOT NULL,
        landmark_id $ID NOT NULL,
        action VARCHAR(16) NOT NULL,
        day VARCHAR(10) NOT NULL,
        at DATETIME NOT NULL,
        UNIQUE (user_id, landmark_id, action, day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS landmark_clears (
        id $PK,
        user_id $ID NOT NULL,
        landmark_id $ID NOT NULL,
        clears INT NOT NULL DEFAULT 0,
        first_at DATETIME NOT NULL,
        last_at DATETIME NOT NULL,
        UNIQUE (user_id, landmark_id)
    )$END";

    // Landmark repairs (v0.7.77): a gnome's own repair project at a ruined haven, wonder or delve, four stages
    $t[] = "CREATE TABLE IF NOT EXISTS landmark_repairs (
        id $PK,
        user_id $ID NOT NULL,
        landmark_id $ID NOT NULL,
        stage INT NOT NULL DEFAULT 0,
        started_at DATETIME NOT NULL,
        done_at DATETIME NULL,
        UNIQUE (user_id, landmark_id)
    )$END";

    // Road Journal (v2.0.79): the sights a gnome has sketched on the roads, per region; '_done' = the full-page prize was paid
    $t[] = "CREATE TABLE IF NOT EXISTS road_journal (
        user_id $ID NOT NULL,
        region VARCHAR(8) NOT NULL,
        entry VARCHAR(40) NOT NULL,
        at DATETIME NOT NULL,
        PRIMARY KEY (user_id, region, entry)
    )$END";

    // Roads between towns (v0.7.24): town → 3 villages → town; stops kept in order as a JSON list of location ids
    $t[] = "CREATE TABLE IF NOT EXISTS roads (
        id $PK,
        name VARCHAR(120) NOT NULL,
        a_town $ID NOT NULL,
        b_town $ID NOT NULL,
        nodes TEXT NOT NULL
    )$END";

    // Travelling NPCs (v0.7.21): one deal per gnome per stop
    $t[] = "CREATE TABLE IF NOT EXISTS traveller_deals (
        id $PK,
        user_id $ID NOT NULL,
        npc_id $ID NOT NULL,
        stop VARCHAR(20) NOT NULL,
        at DATETIME NOT NULL,
        UNIQUE (user_id, npc_id, stop)
    )$END";

    // Gnomes meeting in town (v0.7.22): waves, benches and snacks (once a day per pair), friendly rock-paper-trowel
    $t[] = "CREATE TABLE IF NOT EXISTS town_meets (
        id $PK,
        a_id $ID NOT NULL,
        b_id $ID NOT NULL,
        kind VARCHAR(10) NOT NULL,
        day VARCHAR(10) NOT NULL,
        at DATETIME NOT NULL,
        UNIQUE (a_id, b_id, kind, day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS town_rps (
        id $PK,
        from_id $ID NOT NULL,
        to_id $ID NOT NULL,
        spot_id $ID NOT NULL,
        move_a VARCHAR(8) NOT NULL,
        move_b VARCHAR(8) NULL,
        status VARCHAR(8) NOT NULL DEFAULT 'open',
        created_at DATETIME NOT NULL,
        done_at DATETIME NULL
    )$END";
    // NPC favours on the notice board (v0.7.22): one per NPC friend per week
    $t[] = "CREATE TABLE IF NOT EXISTS npc_favours (
        id $PK,
        user_id $ID NOT NULL,
        npc_id $ID NOT NULL,
        week VARCHAR(10) NOT NULL,
        done_at DATETIME NOT NULL,
        UNIQUE (user_id, npc_id, week)
    )$END";

    // Accounts (v0.7.16)
    $t[] = "CREATE TABLE IF NOT EXISTS password_resets (
        id $PK,
        user_id $ID NOT NULL,
        token_hash VARCHAR(64) NOT NULL UNIQUE,
        expires_at DATETIME NOT NULL,
        used INT NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL
    )$END";

    // Shows and carving (v0.7.15)
    $t[] = "CREATE TABLE IF NOT EXISTS show_entries (
        id $PK,
        week VARCHAR(10) NOT NULL,
        user_id $ID NOT NULL,
        crop VARCHAR(40) NOT NULL,
        size DECIMAL(10,2) NOT NULL DEFAULT 0,
        placed INT NULL,
        entered_at DATETIME NOT NULL,
        UNIQUE (week, user_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS carvings (
        id $PK,
        user_id $ID NOT NULL,
        year INT NOT NULL,
        title VARCHAR(60) NOT NULL,
        pattern VARCHAR(100) NOT NULL,
        votes INT NOT NULL DEFAULT 0,
        placed INT NULL,
        carved_at DATETIME NOT NULL,
        UNIQUE (user_id, year)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS carving_votes (
        id $PK,
        user_id $ID NOT NULL,
        carving_id $ID NOT NULL,
        voted_at DATETIME NOT NULL,
        UNIQUE (user_id, carving_id)
    )$END";

    // Community garden (v0.7.14)
    $t[] = "CREATE TABLE IF NOT EXISTS community_beds (
        id $PK,
        x INT NOT NULL,
        y INT NOT NULL,
        plant_id $ID NULL,
        planted_by $ID NULL,
        grown INT NOT NULL DEFAULT 0,
        grow_at DATETIME NULL,
        water_until DATETIME NULL,
        weeds INT NOT NULL DEFAULT 0,
        weeds_at DATETIME NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS community_store (
        id $PK,
        item_id $ID NOT NULL UNIQUE,
        qty INT NOT NULL DEFAULT 0
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS community_log (
        id $PK,
        user_id $ID NOT NULL,
        action VARCHAR(10) NOT NULL,
        week VARCHAR(10) NOT NULL,
        at DATETIME NOT NULL
    )$END";

    // NPC friendships (v0.7.13)
    $t[] = "CREATE TABLE IF NOT EXISTS npc_friends (
        id $PK,
        user_id $ID NOT NULL,
        npc_id $ID NOT NULL,
        points INT NOT NULL DEFAULT 0,
        talks INT NOT NULL DEFAULT 0,
        gifts INT NOT NULL DEFAULT 0,
        last_talk VARCHAR(10) NULL,
        last_gift VARCHAR(10) NULL,
        known TEXT NULL,
        UNIQUE (user_id, npc_id)
    )$END";

    // Mini-games (v0.7.11)
    $t[] = "CREATE TABLE IF NOT EXISTS game_state (
        id $PK,
        user_id $ID NOT NULL,
        game VARCHAR(20) NOT NULL,
        state TEXT NOT NULL,
        updated_at DATETIME NOT NULL,
        UNIQUE (user_id, game)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS game_scores (
        id $PK,
        user_id $ID NOT NULL,
        game VARCHAR(20) NOT NULL,
        score INT NOT NULL DEFAULT 0,
        day VARCHAR(10) NOT NULL,
        week VARCHAR(10) NOT NULL,
        played_at DATETIME NOT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS snail_bets (
        id $PK,
        user_id $ID NOT NULL,
        race VARCHAR(10) NOT NULL,
        snail INT NOT NULL,
        amount INT NOT NULL,
        paid INT NOT NULL DEFAULT 0,
        winnings INT NOT NULL DEFAULT 0,
        day VARCHAR(10) NOT NULL,
        placed_at DATETIME NOT NULL,
        UNIQUE (user_id, race)
    )$END";

    // Trading (v0.7.10)
    $t[] = "CREATE TABLE IF NOT EXISTS notices (
        id $PK,
        user_id $ID NOT NULL,
        text VARCHAR(300) NOT NULL,
        created_at DATETIME NOT NULL,
        seen INT NOT NULL DEFAULT 0
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS gifts (
        id $PK,
        from_id $ID NOT NULL,
        to_id $ID NOT NULL,
        item_id $ID NULL,
        qty INT NOT NULL DEFAULT 0,
        coins INT NOT NULL DEFAULT 0,
        note VARCHAR(160) NULL,
        sent_at DATETIME NOT NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS trade_offers (
        id $PK,
        from_id $ID NOT NULL,
        to_id $ID NOT NULL,
        give_items TEXT NOT NULL,
        give_coins INT NOT NULL DEFAULT 0,
        want_items TEXT NOT NULL,
        want_coins INT NOT NULL DEFAULT 0,
        note VARCHAR(160) NULL,
        status VARCHAR(10) NOT NULL DEFAULT 'open',
        created_at DATETIME NOT NULL,
        closed_at DATETIME NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stall_listings (
        id $PK,
        seller_id $ID NOT NULL,
        item_id $ID NOT NULL,
        qty INT NOT NULL DEFAULT 0,
        sold INT NOT NULL DEFAULT 0,
        price INT NOT NULL,
        listed_at DATETIME NOT NULL
    )$END";

    // Player-posted jobs (v0.7.9)
    $t[] = "CREATE TABLE IF NOT EXISTS player_jobs (
        id $PK,
        poster_id $ID NOT NULL,
        kind VARCHAR(10) NOT NULL,
        plot_id $ID NULL,
        item_id $ID NULL,
        qty INT NOT NULL DEFAULT 1,
        days INT NOT NULL DEFAULT 1,
        wage INT NOT NULL DEFAULT 0,
        escrow INT NOT NULL DEFAULT 0,
        paid INT NOT NULL DEFAULT 0,
        progress INT NOT NULL DEFAULT 0,
        note VARCHAR(160) NULL,
        status VARCHAR(10) NOT NULL DEFAULT 'open',
        taker_id $ID NULL,
        user_job_id $ID NULL,
        posted_at DATETIME NOT NULL,
        expires_at DATETIME NOT NULL,
        taken_at DATETIME NULL,
        ends_at DATETIME NULL,
        closed_at DATETIME NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS job_rerolls (
        id $PK,
        user_id $ID NOT NULL,
        period VARCHAR(10) NOT NULL,
        period_key VARCHAR(10) NOT NULL,
        UNIQUE (user_id, period, period_key)
    )$END";

    // Hired help (v0.7.7)
    $t[] = "CREATE TABLE IF NOT EXISTS helpers (
        id $PK,
        name VARCHAR(80) NOT NULL,
        species VARCHAR(40) NULL,
        icon VARCHAR(16) NULL,
        skills VARCHAR(60) NOT NULL DEFAULT 'water',
        wage INT NOT NULL DEFAULT 50,
        bio TEXT NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS garden_hires (
        id $PK,
        plot_id $ID NOT NULL,
        user_id $ID NOT NULL,
        helper_id $ID NOT NULL,
        started_at DATETIME NOT NULL,
        ends_at DATETIME NOT NULL,
        last_visit DATETIME NOT NULL,
        paid INT NOT NULL DEFAULT 0,
        visits INT NOT NULL DEFAULT 0,
        waterings INT NOT NULL DEFAULT 0,
        weedings INT NOT NULL DEFAULT 0,
        harvests INT NOT NULL DEFAULT 0,
        active INT NOT NULL DEFAULT 1
    )$END";

    // Root cellar (v0.7.56): perennials dug up to keep, with how grown they were
    $t[] = "CREATE TABLE IF NOT EXISTS cellar_plants (
        id $PK,
        plot_id $ID NOT NULL,
        user_id $ID NOT NULL,
        plant_id $ID NOT NULL,
        growth_seconds INT NOT NULL DEFAULT 0,
        stored_at DATETIME NOT NULL
    )$END";

    // v0.8.1 Grand Harvest Fair
    $t[] = "CREATE TABLE IF NOT EXISTS fair_best (
        id $PK,
        user_id $ID NOT NULL,
        month VARCHAR(10) NOT NULL,
        cat VARCHAR(10) NOT NULL,
        plant_id $ID NOT NULL,
        score INT NOT NULL DEFAULT 0,
        at DATETIME NOT NULL,
        UNIQUE (user_id, month, cat)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS fair_entries (
        id $PK,
        user_id $ID NOT NULL,
        month VARCHAR(10) NOT NULL,
        cat VARCHAR(10) NOT NULL,
        plant_id $ID NOT NULL,
        score INT NOT NULL DEFAULT 0,
        placed INT NULL,
        at DATETIME NOT NULL,
        UNIQUE (user_id, month, cat)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS fair_ribbons (
        id $PK,
        user_id $ID NOT NULL,
        month VARCHAR(10) NOT NULL,
        cat VARCHAR(10) NOT NULL,
        place INT NOT NULL,
        UNIQUE (user_id, month, cat)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS compost_turns (
        id $PK,
        user_id $ID NOT NULL,
        plot_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        at DATETIME NOT NULL,
        UNIQUE (user_id, plot_id, day)
    )$END";   // v0.7.99: turning a neighbour's compost, once a day per garden

    $t[] = "CREATE TABLE IF NOT EXISTS feedback (
        id $PK,
        user_id $ID NOT NULL,
        page VARCHAR(120) NOT NULL DEFAULT '',
        body VARCHAR(1000) NOT NULL,
        status VARCHAR(10) NOT NULL DEFAULT 'new',
        created_at DATETIME NOT NULL
    )$END";   // v0.8.6: notes players send from the menu (Admin → Feedback)

    $t[] = "CREATE TABLE IF NOT EXISTS site_texts (
        skey VARCHAR(60) NOT NULL PRIMARY KEY,
        body TEXT NOT NULL,
        updated_at DATETIME NULL
    )$END";   // v0.8.9: words on public pages changed in Admin → Page text (only changed ones are stored)

    $t[] = "CREATE TABLE IF NOT EXISTS garden_buildings (
        id $PK,
        plot_id $ID NOT NULL,
        building VARCHAR(20) NOT NULL,
        built_at DATETIME NOT NULL,
        last_collect DATETIME NULL,
        UNIQUE (plot_id, building)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS cook_pots (
        id $PK,
        user_id $ID NOT NULL,
        recipe_id $ID NOT NULL,
        makes INT NOT NULL DEFAULT 1,
        dishes INT NOT NULL DEFAULT 1,
        started_at DATETIME NOT NULL,
        ready_at DATETIME NOT NULL,
        collected_at DATETIME NULL
    )$END";   // v0.9.4: a pot on the stove: what is cooking, how many dishes it will give (extra-dish roll stored at start), when it is ready

    $t[] = "CREATE TABLE IF NOT EXISTS pantry_jars (
        id $PK,
        user_id $ID NOT NULL,
        recipe_id $ID NOT NULL,
        makes INT NOT NULL DEFAULT 1,
        qty INT NOT NULL DEFAULT 1,
        score INT NOT NULL DEFAULT 0,
        started_at DATETIME NOT NULL,
        ready_at DATETIME NOT NULL,
        collected_at DATETIME NULL
    )$END";   // v0.9.8: a Pantry jar: one batch of a preserve (qty items when collected), its Harvest Fair score (rolled at start), real-day timer

    // v0.9.9 part A: flowers. A drying rack bundle (real-time timer, lazy), an arrangement on show for the weekly contest, a volunteer shift at a florist, and small per-day counters
    $t[] = "CREATE TABLE IF NOT EXISTS dry_racks (
        id $PK,
        user_id $ID NOT NULL,
        item_id $ID NOT NULL,
        qty INT NOT NULL DEFAULT 1,
        started_at DATETIME NOT NULL,
        ready_at DATETIME NOT NULL,
        collected_at DATETIME NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS arrangement_entries (
        id $PK,
        week VARCHAR(10) NOT NULL,
        user_id $ID NOT NULL,
        item_id $ID NOT NULL DEFAULT 0,
        title VARCHAR(80) NOT NULL,
        score INT NOT NULL DEFAULT 0,
        comp TEXT NULL,
        entered_at DATETIME NOT NULL,
        placed INT NULL,
        UNIQUE (week, user_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS florist_shifts (
        id $PK,
        user_id $ID NOT NULL,
        shop_id $ID NOT NULL,
        npc_id $ID NOT NULL DEFAULT 0,
        started_at DATETIME NOT NULL,
        ready_at DATETIME NOT NULL,
        collected_at DATETIME NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS flower_daily (
        id $PK,
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        kind VARCHAR(10) NOT NULL,
        n INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, day, kind)
    )$END";

    // v0.9.7 Petal sinks: one-off purchases (building looks, dyes, garden signs) and weekly curio buys
    $t[] = "CREATE TABLE IF NOT EXISTS sink_owned (
        id $PK,
        user_id $ID NOT NULL,
        plot_id $ID NOT NULL DEFAULT 0,
        kind VARCHAR(8) NOT NULL,
        ref VARCHAR(40) NOT NULL,
        at DATETIME NOT NULL,
        UNIQUE (user_id, plot_id, kind, ref)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS curio_buys (
        id $PK,
        user_id $ID NOT NULL,
        week VARCHAR(10) NOT NULL,
        slug VARCHAR(60) NOT NULL,
        qty INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, week, slug)
    )$END";

    // ---------- The yard (v0.7.32) ----------
    $t[] = "CREATE TABLE IF NOT EXISTS garden_objects (
        id $PK,
        plot_id $ID NOT NULL,
        kind VARCHAR(10) NOT NULL,
        ref VARCHAR(20) NULL,
        item_id $ID NULL,
        x INT NOT NULL DEFAULT -1,
        y INT NOT NULL DEFAULT -1,
        w INT NOT NULL DEFAULT 1,
        h INT NOT NULL DEFAULT 1,
        rot INT NOT NULL DEFAULT 0,
        placed_at DATETIME NOT NULL
    )$END";

    // v0.9.5: yard undo history (a snapshot of the layout from before each save; the newest few are kept)
    $t[] = "CREATE TABLE IF NOT EXISTS yard_history (
        id $PK,
        plot_id $ID NOT NULL,
        snap TEXT NOT NULL,
        created_at DATETIME NOT NULL
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS garden_admires (
        id $PK,
        plot_id $ID NOT NULL,
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        admired_at DATETIME NOT NULL,
        UNIQUE (plot_id, user_id, day)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS gotm_entries (
        id $PK,
        month VARCHAR(7) NOT NULL,
        plot_id $ID NOT NULL,
        user_id $ID NOT NULL,
        votes INT NOT NULL DEFAULT 0,
        appeal INT NOT NULL DEFAULT 0,
        placed INT NULL,
        entered_at DATETIME NOT NULL,
        UNIQUE (month, plot_id)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS gotm_votes (
        id $PK,
        month VARCHAR(7) NOT NULL,
        entry_id $ID NOT NULL,
        user_id $ID NOT NULL,
        voted_at DATETIME NOT NULL,
        UNIQUE (entry_id, user_id)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS local_deals (
        id $PK,
        user_id $ID NOT NULL,
        location_id $ID NOT NULL,
        visit_key VARCHAR(25) NOT NULL,
        day VARCHAR(10) NOT NULL,
        kind VARCHAR(20) NOT NULL,
        at DATETIME NOT NULL,
        UNIQUE (user_id, location_id, visit_key)
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS region_visits (
        id $PK,
        user_id $ID NOT NULL,
        region_id $ID NOT NULL,
        first_at DATETIME NOT NULL,
        UNIQUE (user_id, region_id)
    )$END";

    // ---------- Adventuring ----------
    $t[] = "CREATE TABLE IF NOT EXISTS routes (
        id $PK,
        a_id $ID NOT NULL,
        b_id $ID NOT NULL,
        steps INT NOT NULL DEFAULT 3,
        minutes INT NOT NULL DEFAULT 9,
        level INT NOT NULL DEFAULT 1,
        min_level INT NOT NULL DEFAULT 1,
        max_level INT NOT NULL DEFAULT 1,
        fixed INT NOT NULL DEFAULT 0
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS creatures (
        id $PK,
        slug VARCHAR(80) NOT NULL UNIQUE,
        name VARCHAR(80) NOT NULL,
        size VARCHAR(10) NOT NULL DEFAULT 'small',
        landscapes VARCHAR(190) NOT NULL DEFAULT 'any',
        level INT NOT NULL DEFAULT 1,
        hp INT NOT NULL DEFAULT 10,
        attack INT NOT NULL DEFAULT 1,
        defense INT NOT NULL DEFAULT 10,
        dmg_die INT NOT NULL DEFAULT 4,
        dmg_bonus INT NOT NULL DEFAULT 0,
        xp INT NOT NULL DEFAULT 5,
        description TEXT NULL,
        active INT NOT NULL DEFAULT 1
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS creature_drops (
        id $PK,
        creature_id $ID NOT NULL,
        item_id $ID NULL,
        special VARCHAR(20) NULL,
        chance INT NOT NULL DEFAULT 50
    )$END";

    // Things gathered automatically on adventures, by landscape and gathering tool.
    $t[] = "CREATE TABLE IF NOT EXISTS gatherables (
        id $PK,
        item_id $ID NOT NULL UNIQUE,
        landscapes VARCHAR(190) NOT NULL DEFAULT 'any',
        tool VARCHAR(20) NOT NULL DEFAULT 'forage',
        rarity VARCHAR(10) NOT NULL DEFAULT 'common',
        active INT NOT NULL DEFAULT 1
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS problems (
        id $PK,
        slug VARCHAR(80) NOT NULL UNIQUE,
        text VARCHAR(255) NOT NULL,
        landscapes VARCHAR(190) NOT NULL DEFAULT 'any',
        options TEXT NOT NULL,
        active INT NOT NULL DEFAULT 1
    )$END";

    $t[] = "CREATE TABLE IF NOT EXISTS expeditions (
        id $PK,
        user_id $ID NOT NULL,
        from_id $ID NOT NULL,
        to_id $ID NOT NULL,
        route_id $ID NOT NULL,
        steps_total INT NOT NULL,
        step INT NOT NULL DEFAULT 0,
        hp INT NOT NULL,
        max_hp INT NOT NULL,
        encounter TEXT NULL,
        log TEXT NULL,
        status VARCHAR(10) NOT NULL DEFAULT 'active',
        level INT NOT NULL DEFAULT 1,
        scaled INT NOT NULL DEFAULT 0,
        started_at DATETIME NOT NULL,
        arrive_at DATETIME NOT NULL
    )$END";

    $i = [
        'CREATE INDEX idx_routes_a ON routes (a_id)',
        'CREATE INDEX idx_routes_b ON routes (b_id)',
        'CREATE INDEX idx_drops_creature ON creature_drops (creature_id)',
        'CREATE INDEX idx_exped_user ON expeditions (user_id, status)',
        'CREATE INDEX idx_loc_region ON locations (region_id)',
        'CREATE INDEX idx_loc_zone ON locations (zone_id)',
        'CREATE INDEX idx_plants_region ON plants (region_code)',
        'CREATE UNIQUE INDEX idx_plants_slug ON plants (slug)',
        'CREATE INDEX idx_pr_region ON plant_regions (region_id)',
        'CREATE INDEX idx_pr_tier ON plant_regions (region_id, tier)',
        'CREATE INDEX idx_zones_region ON zones (region_id)',
        'CREATE INDEX idx_landmarks_region ON landmarks (region_id)',
        'CREATE INDEX idx_landmarks_zone ON landmarks (zone_id)',
        'CREATE INDEX idx_ency_chapter ON encyclopedia_entries (chapter, category)',
        'CREATE INDEX idx_login_attempts ON login_attempts (ip, attempted_at)',
        'CREATE INDEX idx_admin_log_time ON admin_log (created_at)',
        'CREATE INDEX idx_news_pub ON news (published, created_at)',
        'CREATE INDEX idx_sched_npc ON npc_schedules (npc_id)',
        'CREATE INDEX idx_sched_shop ON npc_schedules (shop_id)',
        'CREATE INDEX idx_stock_shop ON shop_stock (shop_id)',
        'CREATE INDEX idx_stock_item ON shop_stock (item_id)',   // v1.0.0: sell_price looks up the shop price per item
        'CREATE INDEX idx_tiles_user ON plot_tiles (user_id)',
        'CREATE INDEX idx_tiles_plot ON plot_tiles (plot_id)',
        'CREATE INDEX idx_plots_user ON plots (user_id)',
        'CREATE INDEX idx_ency_key ON encyclopedia_entries (unlock_key)',
        'CREATE INDEX idx_users_seen ON users (last_seen)',
        'CREATE INDEX idx_users_guest ON users (guest, last_seen)',
        'CREATE INDEX idx_users_verify ON users (verify_hash)',
        'CREATE INDEX idx_hires_plot ON garden_hires (plot_id, active)',
        'CREATE INDEX idx_user_jobs ON user_jobs (user_id, status)',
        'CREATE INDEX idx_player_jobs ON player_jobs (status, expires_at)',
        'CREATE INDEX idx_notices_user ON notices (user_id, seen)',
        'CREATE INDEX idx_scores_user ON game_scores (user_id, game, day)',
        'CREATE INDEX idx_scores_week ON game_scores (game, week)',
        'CREATE INDEX idx_bets_open ON snail_bets (paid, race)',
        'CREATE INDEX idx_commlog_week ON community_log (week, user_id)',
        'CREATE INDEX idx_gifts_from ON gifts (from_id, sent_at)',
        'CREATE INDEX idx_offers_to ON trade_offers (to_id, status)',
        'CREATE INDEX idx_offers_from ON trade_offers (from_id, status)',
        'CREATE INDEX idx_stall_item ON stall_listings (item_id, qty)',
        'CREATE INDEX idx_stall_seller ON stall_listings (seller_id, qty)',
        'CREATE INDEX idx_gobj_plot ON garden_objects (plot_id)',
        'CREATE INDEX idx_yhist_plot ON yard_history (plot_id, id)',
        'CREATE INDEX idx_cookpots_user ON cook_pots (user_id, collected_at)',
        'CREATE INDEX idx_pantryjars_user ON pantry_jars (user_id, collected_at)',
        'CREATE INDEX idx_dryracks_user ON dry_racks (user_id, collected_at)',
        'CREATE INDEX idx_floristshifts_user ON florist_shifts (user_id, collected_at)',
        'CREATE INDEX idx_arrentries_week ON arrangement_entries (week, score)',
        'CREATE INDEX idx_gotm_month ON gotm_entries (month, votes)',
        'CREATE INDEX idx_gotmv_user ON gotm_votes (user_id, month)',
    ];
    // Columns added after v0.7.0 (fresh install). Older installs get them via "Upgrade database".
    $c = [
        ['users', 'gnome_name', 'VARCHAR(30) NULL'],
        ['users', 'theme', "VARCHAR(8) NOT NULL DEFAULT 'dark'"],      // v1.6.5: dark / light / auto
        ['users', 'hp', 'INT NULL'],                                   // v2.3.5: the gnome's health (NULL = full), see includes/health.php
        ['users', 'hp_at', 'DATETIME NULL'],                           // v2.3.5: when the town health clock last ran (NULL = stopped)
        ['users', 'sess_ver', 'INT NOT NULL DEFAULT 0'],              // v1.2.2: bumped on password change/reset; older sessions are signed out
        ['users', 'hat_color', 'VARCHAR(7) NULL'],
        ['users', 'beard_color', 'VARCHAR(7) NULL'],
        ['users', 'onboarded', 'INT NOT NULL DEFAULT 1'],      // existing players skip the welcome flow
        ['users', 'tour_step', 'INT NOT NULL DEFAULT 0'],
        ['plot_tiles', 'feed_fert', 'INT NOT NULL DEFAULT 0'],
        ['plot_tiles', 'feed_life', 'INT NOT NULL DEFAULT 0'],
        ['plot_tiles', 'feed_hours', 'INT NOT NULL DEFAULT 0'],
        ['plot_tiles', 'feed_at', 'DATETIME NULL'],
        ['plot_tiles', 'fork_at', 'DATETIME NULL'],
        ['plot_tiles', 'care', 'INT NOT NULL DEFAULT 0'],             // v0.8.7 Soil care points (tilled squares)
        ['plot_tiles', 'care_day', 'VARCHAR(10) NULL'],                 // the game day the last point was earned (1 a day)
        ['plot_tiles', 'care_at', 'DATETIME NULL'],                     // last harvest (wild ground loses stars from here)
        ['plot_tiles', 'care_fed', 'INT NOT NULL DEFAULT 0'],           // a soil improver went in since the last harvest
        ['plants', 'climate', 'VARCHAR(10) NULL'],                      // v0.8.9: cool, tropical or '' (for region climates)
        ['regions', 'climate', 'VARCHAR(255) NULL'],                    // v0.8.9: climate effects, e.g. "cool:10, tropical:-10" (includes/climate.php)
        ['recipes', 'slug', 'VARCHAR(80) NULL'],                       // v0.7.5 crafting
        ['recipes', 'category', "VARCHAR(20) NOT NULL DEFAULT 'cooking'"],
        ['recipes', 'energy', 'INT NOT NULL DEFAULT 2'],
        ['recipes', 'tier', "VARCHAR(8) NOT NULL DEFAULT 'meal'"],       // v0.9.4 snack, meal or feast
        ['recipes', 'batch_max', 'INT NOT NULL DEFAULT 1'],            // v0.9.4 most makes per pot (snacks 5)
        ['plot_tiles', 'n', 'INT NOT NULL DEFAULT 50'],               // v0.7.6 NPK soil
        ['plot_tiles', 'p', 'INT NOT NULL DEFAULT 50'],
        ['plot_tiles', 'k', 'INT NOT NULL DEFAULT 50'],
        ['plot_tiles', 'feed_n', 'INT NOT NULL DEFAULT 0'],
        ['plot_tiles', 'feed_p', 'INT NOT NULL DEFAULT 0'],
        ['plot_tiles', 'feed_k', 'INT NOT NULL DEFAULT 0'],
        ['plants', 'nutrient', 'VARCHAR(1) NULL'],
        ['users', 'job_dailies', 'INT NOT NULL DEFAULT 0'],
        ['user_jobs', 'player_job_id', 'INT NULL'],
        ['users', 'sapling_day', 'VARCHAR(10) NULL'],                    // v0.7.10 saplings raised today
        ['users', 'sapling_count', 'INT NOT NULL DEFAULT 0'],
        ['users', 'community_day', 'VARCHAR(10) NULL'],                  // v0.7.14 community garden
        ['users', 'community_shift_until', 'DATETIME NULL'],
        ['users', 'shift_actions', 'INT NOT NULL DEFAULT 0'],
        ['users', 'community_rep', 'INT NOT NULL DEFAULT 0'],
        ['users', 'ribbons', 'INT NOT NULL DEFAULT 0'],
        ['users', 'agreed_at', 'DATETIME NULL'],                         // v0.7.16 rules/privacy/13+ agreed at sign-up
        ['users', 'deleted_at', 'DATETIME NULL'],
        ['users', 'guest', 'INT NOT NULL DEFAULT 0'],                     // v2.0.75: 1 = a guest garden (no email, purged when idle)
        ['users', 'guest_ip', 'VARCHAR(45) NULL'],
        ['users', 'email_verified_at', 'DATETIME NULL'],                 // v1.7: email verification (NULL = unverified)
        ['users', 'verify_hash', 'VARCHAR(64) NULL'],
        ['users', 'verify_expires', 'DATETIME NULL'],
        ['users', 'email_nudges', 'INT NOT NULL DEFAULT 0'],             // v1.7: opt-in reminder emails (CASL: default off)
        ['users', 'last_nudge_at', 'DATETIME NULL'],
        ['users', 'nudge_away_seen', 'DATETIME NULL'],                   // the last_seen value an away nudge was already sent for
        ['users', 'event_at', 'DATETIME NULL'],                          // v0.7.19 random events
        ['users', 'event_day', 'VARCHAR(10) NULL'],
        ['users', 'event_count', 'INT NOT NULL DEFAULT 0'],
        ['users', 'ev_stat', 'VARCHAR(10) NULL'],
        ['garden_buildings', 'level', 'INT NOT NULL DEFAULT 1'],     // v0.7.95 building upgrades
        ['garden_buildings', 'scraps', 'INT NOT NULL DEFAULT 0'],    // v0.7.95 compost heap
        ['garden_buildings', 'heap_made', 'INT NOT NULL DEFAULT 0'],
        ['garden_buildings', 'free_day', 'VARCHAR(10) NULL'],          // v0.7.96 rain barrel's free Water all
        ['garden_buildings', 'heap_out', "VARCHAR(40) NOT NULL DEFAULT 'plain-compost'"],   // v0.9.4 what the compost heap makes
        ['users', 'free_mend_n', 'INT NOT NULL DEFAULT 0'],
        ['users', 'dest_id', "$ID NULL"],
        ['users', 'dest_auto', 'TINYINT(1) NOT NULL DEFAULT 1'],          // v0.9.3 keep walking to the next stop of the route
        ['users', 'dest_pause_towns', 'TINYINT(1) NOT NULL DEFAULT 0'],
        ['users', 'dest_chain', 'SMALLINT NOT NULL DEFAULT 0'],           // legs auto-started on this journey
        ['users', 'dest_legs', 'SMALLINT NOT NULL DEFAULT 0'],            // legs in the route when set off
        ['users', 'dest_trail', 'TEXT NULL'],                              // v0.9.5 stops already passed on this journey (location ids, comma separated)
        ['users', 'last_cooked_id', "$ID NULL"],                       // v0.7.99 the last dish cooked (a visitor can smell it)                              // v0.7.98 where the gnome is heading           // v0.7.96 free mends used on free_mend_day
        ['users', 'ev_amt', 'INT NOT NULL DEFAULT 0'],
        ['users', 'ev_until', 'DATETIME NULL'],
        ['users', 'town_stat', 'VARCHAR(12) NULL'],              // v0.7.20 a town drink's little boost
        ['users', 'town_amt', 'INT NOT NULL DEFAULT 0'],
        ['users', 'town_until', 'DATETIME NULL'],
        ['users', 'lore_read', 'INT NOT NULL DEFAULT 0'],
        ['npc_schedules', 'spot_id', 'INT NULL'],                // v0.7.21 NPCs spend their free hours at town places
        ['npcs', 'fav_spot_id', 'INT NULL'],
        ['npcs', 'traveller', 'VARCHAR(12) NULL'],               // merchant / minstrel / naturalist: on a circuit of the towns
        ['npcs', 'circuit_offset', 'INT NOT NULL DEFAULT 0'],
        ['routes', 'kind', "VARCHAR(8) NOT NULL DEFAULT 'road'"],  // v0.7.24 road or side path
        ['routes', 'road_id', 'INT NULL'],
        ['plants', 'timing_v', 'INT NOT NULL DEFAULT 0'],
        ['users', 'ev_harvest_bonus', 'INT NOT NULL DEFAULT 0'],    // v0.7.31 random-event boons
        ['users', 'ev_quickwalk', 'INT NOT NULL DEFAULT 0'],
        ['users', 'ev_gather_until', 'DATETIME NULL'],
        ['users', 'ev_sale_until', 'DATETIME NULL'],
        ['plot_tiles', 'bonus_yield', 'INT NOT NULL DEFAULT 0'],
        ['landmarks', 'restored_at', 'DATETIME NULL'],               // v0.7.29 rebuilt landmarks
        ['landmark_repairs', 'dropped_at', 'DATETIME NULL'],          // v0.7.85 a given-up repair is kept (no re-paying stage 1); taking it on again resumes
        ['landmark_repairs', 'plan', 'VARCHAR(8) NULL'],              // v2.0.76 'v1' = began on the place's own build plan (empty = the old four stages)
        ['landmark_repairs', 'prog', 'INT NOT NULL DEFAULT 0'],      // v2.0.76 days worked on a clear stage
        ['landmark_repairs', 'prog_day', 'VARCHAR(10) NULL'],        // v2.0.76 last Hollow day that counted
        ['npcs', 'loved_item_id', 'INT NULL'],                       // v0.7.85 an NPC's favourite gift, fixed once chosen
        ['user_items', 'wear', 'INT NOT NULL DEFAULT 0'],              // v0.7.86 tool wear: uses (gathering) or days (garden) on the working copy
        ['user_items', 'wear_day', 'VARCHAR(10) NULL'],
        ['users', 'free_mend_day', 'VARCHAR(10) NULL'],                  // v0.7.86 the Tool Shed's free mend, once a Hollow day
        ['landmarks', 'ruined', 'INT NOT NULL DEFAULT 0'],                // v0.7.87 1 = this haven, wonder or delve started in ruins (closed until repaired)
        ['landmarks', 'restored_by', 'INT NULL'],
        ['users', 'muted_until', 'DATETIME NULL'],                   // v0.7.28 moderation
        ['users', 'banned_until', 'DATETIME NULL'],            // v0.7.27 grow times rescaled (1 = done)
        ['expeditions', 'kind', "VARCHAR(8) NOT NULL DEFAULT 'walk'"],   // v0.7.25 walk or explore
        ['expeditions', 'depth', 'INT NOT NULL DEFAULT 0'],
        ['expeditions', 'chain', 'VARCHAR(40) NULL'],   // v2.0.79: the road card that follows on the next space (a chain)
        ['expeditions', 'trail', 'TEXT NULL'],   // v2.0.45: the depths walked in order on a wander (the hoop map's thread)
        ['users', 'town_spot_id', 'INT NULL'],                   // v0.7.22 where in town a gnome is (for "gnomes here")
        ['users', 'town_seen', 'DATETIME NULL'],
        ['users', 'town_hidden', 'INT NOT NULL DEFAULT 0'],
        ['users', 'rps_wins', 'INT NOT NULL DEFAULT 0'],
        ['plot_tiles', 'yx', 'INT NULL'],                        // v0.7.32 the yard: where each bed square sits
        ['plot_tiles', 'yy', 'INT NULL'],
        ['garden_objects', 'shape', 'VARCHAR(8) NULL'],           // v0.9.5: a fence/wall/hedge piece's chosen shape (NULL = joins its neighbours by itself)
        ['garden_buildings', 'skin', 'VARCHAR(12) NULL'],         // v0.9.7: the look a building wears (Mossy, Painted, Lantern-lit)
        ['garden_buildings', 'pantry', 'INT NOT NULL DEFAULT 0'],          // v0.9.8: the Pantry add-on on a Kitchen's row
        ['fair_best', 'label', 'VARCHAR(60) NULL'],                  // v0.9.8: the Preserves class has no plant: the preserve's name
        ['fair_entries', 'label', 'VARCHAR(60) NULL'],
        ['plots', 'sign_style', 'VARCHAR(12) NULL'],              // v0.9.7: the garden's signpost
        ['users', 'hat_dye', 'VARCHAR(7) NULL'],                  // v0.9.7: a hat dye worn over the calling colour
        ['plots', 'bed_adds', 'INT NULL'],                       // v0.9.5: "Add 4 beds" purchases (NULL = not counted yet; upgrade_095_beds fills it)
        ['plots', 'yard_xw', 'INT NOT NULL DEFAULT 0'],          // yard columns/rows bought
        ['plots', 'yard_xh', 'INT NOT NULL DEFAULT 0'],
        ['plots', 'appeal', 'INT NOT NULL DEFAULT 0'],           // curb appeal when last saved
        ['plots', 'admired', 'INT NOT NULL DEFAULT 0'],
        ['users', 'garden_public', 'INT NOT NULL DEFAULT 1'],
        ['users', 'calling_free_change', 'INT NOT NULL DEFAULT 1'],   // v0.9.1: one free change of calling before tier II
        ['users', 'calling_tier_seen', 'INT NOT NULL DEFAULT 0'],     // v0.9.1: highest calling tier already announced
        ['users', 'calling_changes', 'INT NOT NULL DEFAULT 0'],       // v0.9.1a: paid changes of calling so far (cost doubles)
        ['users', 'calling_qt', 'INT NOT NULL DEFAULT 0'],            // v0.9.4: calling chapters finished for the current calling (0-2); tier = min(level tier, 1 + this)
        ['users', 'easy_roads', 'INT NOT NULL DEFAULT 1'],            // v0.9.7: easy roads (near-home encounters stay a few levels below you, no bosses); upgrade_097_roads turns it off for gnomes already past easy_roads_below
        ['users', 'calling_chapter', 'INT NULL'],                     // v0.9.4: the calling chapter in progress (NULL = none; calling_event exits at once)
        ['users', 'buff2', 'TEXT NULL'],                              // v0.9.1: second meal buff (Brewroot master)
        ['users', 'buff2_until', 'DATETIME NULL'],
        ['users', 'game_energy_day', 'TEXT NULL'],                    // v0.9.1a: energy won from games today, 'YYYY-MM-DD:n'
        ['plots', 'free_water_day', 'VARCHAR(10) NULL'],              // v0.9.1: Bloomcaller master free Water all
        ['plots', 'free_water_n', 'INT NOT NULL DEFAULT 0'],
        ['regions', 'min_level', 'INT NOT NULL DEFAULT 1'],
        ['user_encyclopedia', 'read_at', 'DATETIME NULL'],
        ['user_items', 'got_at', 'DATETIME NULL'],
        ['npcs', 'image', 'VARCHAR(255) NULL'],
        ['plot_tiles', 'harvests', 'INT NOT NULL DEFAULT 0'],
        ['quest_chapters', 'locks', 'VARCHAR(255) NULL'],                // v0.7.66 places closed until the chapter is finished          // v0.7.64 how many times this perennial has been harvested
        ['cellar_plants', 'harvests', 'INT NOT NULL DEFAULT 0'],                   // v0.7.61 a portrait (until then a red placeholder)
        ['cellar_plants', 'age_seconds', 'INT NOT NULL DEFAULT 0'],      // v0.7.61 a perennial's age pauses in the cellar                 // v0.7.61 satchel sort: last time you gained some
        ['users', 'arrived_at', 'DATETIME NULL'],                  // v0.7.48 a "visit" to a village starts when you arrive         // v0.7.48 so Wren can suggest a page you haven't read      // v0.7.43 recommended level: the way out from the Maplewold    // v0.7.35 others may visit my gardens                  // v0.7.15 show and carving placings                     // v0.7.9 player-posted jobs              // v0.7.8 daily jobs finished (streak bonus)
        ['users', 'road_recent', 'TEXT NULL'],                        // v1.9.3: the last picks on the road (tiny JSON), so the road does not repeat itself
        ['problems', 'cond', 'VARCHAR(190) NULL'],                    // v1.9.3: optional time/season/weather tag (rest-stop syntax; "!" = must hold)
        ['creatures', 'cond', 'VARCHAR(190) NULL'],
        ['gatherables', 'cond', 'VARCHAR(190) NULL'],
    ];
    require_once __DIR__ . '/social.php';   // v1.0.0 wave 3: friends, goals, festivals, first week
    [$st, $si, $sc] = social100_schema($PK, $ID, $END);
    require_once __DIR__ . '/market100.php';   // v1.0.0 wave 2b: orders, quality, market day, price pressure
    [$mt, $mi, $mc] = market100_schema($PK, $ID, $END);
    require_once __DIR__ . '/garden_world.php';   // v1.0.0 wave 2a: pests, companions, garden animals
    [$gt, $gi, $gc] = garden100_schema($PK, $ID, $END);
    require_once __DIR__ . '/stops.php';   // v1.0.0 wave 1: rest stops (types, activities, villagers, passport, adoption)
    [$pt, $pi, $pc] = stops100_schema($PK, $ID, $END);
    require_once __DIR__ . '/breeding110.php';   // v1.1.0: crop breeding (hybrids, discoveries)
    [$bt, $bi, $bc] = breeding110_schema($PK, $ID, $END);
    require_once __DIR__ . '/mentors120.php';   // v1.2.0: player mentors
    [$ment, $mei, $mec] = mentors120_schema($PK, $ID, $END);
    require_once __DIR__ . '/social169.php';   // v1.6.9: friend watering + garden reactions
    [$s169t, $s169i, $s169c] = social169_schema($PK, $ID, $END);
    require_once __DIR__ . '/trek_data.php';   // v1.8.0: Treks (runs, party, pack, flags, story text)
    [$trt, $tri, $trc] = trek_schema($PK, $ID, $END);
    require_once __DIR__ . '/road_text.php';   // v2.0.4: owner overrides of the road wording (road_texts)
    [$rtt, $rti, $rtc] = road_text_schema($PK, $ID, $END);
    require_once __DIR__ . '/delve_map.php';   // v2.0.6: the delve / lair map view (walk_scene)
    [$wst, $wsi, $wsc] = walk_scene_schema($PK, $ID, $END);
    require_once __DIR__ . '/puzzles.php';   // v2.0.68: puzzle pictures, tournaments, attempts
    [$pzt, $pzi, $pzc] = puzzles_schema($PK, $ID, $END);
    require_once __DIR__ . '/puzzle_pals.php';   // v2.0.88: Puzzle Pals (releases, finds, trophies, users.ppal_*)
    [$ppt, $ppi, $ppc] = ppal_schema($PK, $ID, $END);
    require_once __DIR__ . '/gourmand.php';   // next version: the Gourmand's ledger and cook_pots.score
    [$gmt, $gmi, $gmc] = gourmand_schema($PK, $ID, $END);
    return [array_merge($t, $st, $mt, $gt, $pt, $bt, $ment, $s169t, $trt, $rtt, $wst, $pzt, $ppt, $gmt), array_merge($i, $si, $mi, $gi, $pi, $bi, $mei, $s169i, $tri, $rti, $wsi, $pzi, $ppi, $gmi), array_merge($c, $sc, $mc, $gc, $pc, $bc, $mec, $s169c, $trc, $rtc, $wsc, $pzc, $ppc, $gmc)];
}
