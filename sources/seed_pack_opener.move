module grow_a_garden::seed_pack_opener {
    use sui::clock;
    use sui::event;
    use grow_a_garden::seed_pack;

    /// Constantes para tipos de pacotes
    const PACK_TYPE_BASIC: u8 = 0;
    const PACK_TYPE_MAGIC: u8 = 1;

    /// Tipos de frutas
    const FRUIT_TYPE_CARROT: u8 = 0;
    const FRUIT_TYPE_APPLE: u8 = 1;
    const FRUIT_TYPE_ORANGE: u8 = 2;
    const FRUIT_TYPE_GRAPE: u8 = 3;
    const FRUIT_TYPE_STRAWBERRY: u8 = 4;
    const FRUIT_TYPE_DRAGONFRUIT: u8 = 5;

    /// Raridades
    const RARITY_COMMON: u8 = 0;
    const RARITY_UNCOMMON: u8 = 1;
    const RARITY_RARE: u8 = 2;
    const RARITY_EPIC: u8 = 3;
    const RARITY_LEGENDARY: u8 = 4;
    const RARITY_MYTHIC: u8 = 5;

    /// Evento emitido quando um pacote de sementes é aberto
    /// As informações da fruta serão processadas pelo frontend/backend
    public struct SeedPackOpened has copy, drop {
        seed_pack_id: sui::object::ID,
        owner: address,
        fruit_type: u8,
        rarity: u8,
    }

    /// Abre um pacote de sementes e determina a fruta aleatória
    /// A fruta será adicionada ao inventário do usuário no banco de dados
    public fun open_seed_pack(
        seed_pack: seed_pack::SeedPack,
        clock: &clock::Clock,
        ctx: &mut sui::tx_context::TxContext
    ) {
        // Obtém o ID do pacote de sementes antes de queimá-lo
        let seed_pack_id = sui::object::id(&seed_pack);
        
        // Obtém o tipo do pacote antes de queimá-lo
        let pack_type = seed_pack::pack_type(&seed_pack);
        
        // Queima o pacote de sementes (remove da wallet)
        seed_pack::burn(seed_pack);
        
        // Gera um número aleatório para determinar o tipo de fruta e raridade
        let current_time = clock::timestamp_ms(clock);
        let random_value = (current_time % 1000);
        
        // Determina o tipo de fruta e raridade com base nas probabilidades e tipo do pacote
        let (fruit_type, rarity) = determine_fruit_type_and_rarity_by_pack(random_value, pack_type);
        
        // Emite evento com as informações da fruta
        // O frontend/backend processará este evento para adicionar a fruta ao inventário
        event::emit(SeedPackOpened {
            seed_pack_id,
            owner: sui::tx_context::sender(ctx),
            fruit_type,
            rarity,
        });
    }

    /// Determina o tipo de fruta e raridade com base em um valor aleatório e tipo de pacote
    fun determine_fruit_type_and_rarity_by_pack(random_value: u64, pack_type: u8): (u8, u8) {
        if (pack_type == PACK_TYPE_BASIC) {
            // Basic Pack: apenas Carrot, Apple, Orange
            determine_fruit_type_basic_pack(random_value)
        } else if (pack_type == PACK_TYPE_MAGIC) {
            // Magic Pack: Carrot, Apple, Orange, Grape, Strawberry
            determine_fruit_type_magic_pack(random_value)
        } else {
            // Genesis Pack: todas as frutas incluindo Dragonfruit
            determine_fruit_type_and_rarity(random_value)
        }
    }

    /// Determina fruta para Basic Pack (apenas Carrot, Apple, Orange)
    fun determine_fruit_type_basic_pack(random_value: u64): (u8, u8) {
        let scaled_random = random_value % 1000;
        let mut cumulative = 0;
        
        // Redistribuir probabilidades apenas para Carrot, Apple, Orange
        // Carrot: 58.8%, Apple: 29.4%, Orange: 11.8%
        
        cumulative = cumulative + 588;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_CARROT, RARITY_COMMON)
        };
        
        cumulative = cumulative + 294;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_APPLE, RARITY_UNCOMMON)
        };
        
        (FRUIT_TYPE_ORANGE, RARITY_RARE)
    }

    /// Determina fruta para Magic Pack (Carrot, Apple, Orange, Grape, Strawberry)
    fun determine_fruit_type_magic_pack(random_value: u64): (u8, u8) {
        let scaled_random = random_value % 1000;
        let mut cumulative = 0;
        
        // Carrot: 54.9%, Apple: 27.5%, Orange: 11%, Grape: 5.5%, Strawberry: 1.1%
        
        cumulative = cumulative + 549;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_CARROT, RARITY_COMMON)
        };
        
        cumulative = cumulative + 275;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_APPLE, RARITY_UNCOMMON)
        };
        
        cumulative = cumulative + 110;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_ORANGE, RARITY_RARE)
        };
        
        cumulative = cumulative + 55;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_GRAPE, RARITY_EPIC)
        };
        
        (FRUIT_TYPE_STRAWBERRY, RARITY_LEGENDARY)
    }

    /// Determina o tipo de fruta e raridade para Genesis Pack (todas as frutas)
    fun determine_fruit_type_and_rarity(random_value: u64): (u8, u8) {
        let scaled_random = random_value % 1000;
        let mut cumulative = 0;
        
        // Carrot: 50%, Apple: 25%, Orange: 10%, Grape: 5%, Strawberry: 1%, Dragonfruit: 0.5%
        
        cumulative = cumulative + 500;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_CARROT, RARITY_COMMON)
        };
        
        cumulative = cumulative + 250;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_APPLE, RARITY_UNCOMMON)
        };
        
        cumulative = cumulative + 100;
        if (scaled_random < cumulative) {
            return (FRUIT_TYPE_ORANGE, RARITY_RARE)
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
        
        // Fallback para Carrot
        (FRUIT_TYPE_CARROT, RARITY_COMMON)
    }
}