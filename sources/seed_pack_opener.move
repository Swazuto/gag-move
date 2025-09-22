module grow_a_garden::seed_pack_opener {
    use sui::clock;
    use sui::event;
    use grow_a_garden::seed_pack;

    const PACK_TYPE_BASIC: u8 = 0;
    const PACK_TYPE_MAGIC: u8 = 1;

    const FRUIT_TYPE_APPLE: u8 = 0;
    const FRUIT_TYPE_ORANGE: u8 = 1;
    const FRUIT_TYPE_BANANA: u8 = 2;
    const FRUIT_TYPE_GRAPE: u8 = 3;
    const FRUIT_TYPE_STRAWBERRY: u8 = 4;
    const FRUIT_TYPE_DRAGONFRUIT: u8 = 5;

    const RARITY_COMMON: u8 = 0;
    const RARITY_UNCOMMON: u8 = 1;
    const RARITY_RARE: u8 = 2;
    const RARITY_EPIC: u8 = 3;
    const RARITY_LEGENDARY: u8 = 4;
    const RARITY_MYTHIC: u8 = 5;

    public struct SeedPackOpened has copy, drop {
        seed_pack_id: sui::object::ID,
        owner: address,
        fruit_type: u8,
        rarity: u8,
    }

    public fun open_seed_pack(
        seed_pack: seed_pack::SeedPack,
        clock: &clock::Clock,
        ctx: &mut sui::tx_context::TxContext
    ) {
        let seed_pack_id = sui::object::id(&seed_pack);
        
        let pack_type = seed_pack::pack_type(&seed_pack);
        
        seed_pack::burn(seed_pack);
        
        let current_time = clock::timestamp_ms(clock);
        let random_value = (current_time % 1000);
        
        let (fruit_type, rarity) = determine_fruit_type_and_rarity_by_pack(random_value, pack_type);
        
        event::emit(SeedPackOpened {
            seed_pack_id,
            owner: sui::tx_context::sender(ctx),
            fruit_type,
            rarity,
        });
    }

    fun determine_fruit_type_and_rarity_by_pack(random_value: u64, pack_type: u8): (u8, u8) {
        if (pack_type == PACK_TYPE_BASIC) {
            // Basic Pack: Apple, Orange, Banana
            determine_fruit_type_basic_pack(random_value)
        } else if (pack_type == PACK_TYPE_MAGIC) {
            // Magic Pack: Apple, Orange, Banana, Grape, Strawberry
            determine_fruit_type_magic_pack(random_value)
        } else {
            // Genesis Pack: Apple, Orange, Banana, Grape, Strawberry e Dragonfruit
            determine_fruit_type_and_rarity(random_value)
        }
    }

    /// Determina fruta para Basic Pack (apenas Apple, Orange, Banana)  
    fun determine_fruit_type_basic_pack(random_value: u64): (u8, u8) {
        let scaled_random = random_value % 1000;
        let mut cumulative = 0;
        
        // Redistribuir probabilidades apenas para Apple, Orange, Banana
        // Apple: 58.8%, Orange: 29.4%, Banana: 11.8%
        
        cumulative = cumulative + 588;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_APPLE, RARITY_COMMON)
        };
        
        cumulative = cumulative + 294;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_ORANGE, RARITY_UNCOMMON)
        };
        
        (FRUIT_TYPE_BANANA, RARITY_RARE)
    }

    /// Determina fruta para Magic Pack (Apple, Orange, Banana, Grape, Strawberry)
    fun determine_fruit_type_magic_pack(random_value: u64): (u8, u8) {
        let scaled_random = random_value % 1000;
        let mut cumulative = 0;
        
        // Apple: 54.9%, Orange: 27.5%, Banana: 11%, Grape: 5.5%, Strawberry: 1.1%
        
        cumulative = cumulative + 549;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_APPLE, RARITY_COMMON)
        };
        
        cumulative = cumulative + 275;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_ORANGE, RARITY_UNCOMMON)
        };
        
        cumulative = cumulative + 110;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_BANANA, RARITY_RARE)
        };
        
        cumulative = cumulative + 55;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_GRAPE, RARITY_EPIC)
        };
        
        (FRUIT_TYPE_STRAWBERRY, RARITY_LEGENDARY)
    }

    /// Determina o tipo de fruta e raridade para Genesis Pack (Apple, Orange, Banana, Grape, Strawberry, Dragonfruit)
    fun determine_fruit_type_and_rarity(random_value: u64): (u8, u8) {
        let scaled_random = random_value % 1000;
        let mut cumulative = 0;
        
        // Apple: 50%, Orange: 25%, Banana: 10%, Grape: 5%, Strawberry: 1%, Dragonfruit: 0.5%
        
        cumulative = cumulative + 500;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_APPLE, RARITY_COMMON)
        };
        
        cumulative = cumulative + 250;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_ORANGE, RARITY_UNCOMMON)
        };
        
        cumulative = cumulative + 100;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_BANANA, RARITY_RARE)
        };
        
        cumulative = cumulative + 50;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_GRAPE, RARITY_EPIC)
        };
        
        cumulative = cumulative + 10;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_STRAWBERRY, RARITY_LEGENDARY)
        };
        
        cumulative = cumulative + 5;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_DRAGONFRUIT, RARITY_MYTHIC)
        };
        
        (FRUIT_TYPE_APPLE, RARITY_COMMON)
    }
}