module grow_a_garden::seed_pack {
    use std::string;
    use grow_a_garden::events;

    /// Tipo para o NFT de Pacote de Sementes
    public struct SeedPack has key, store {
        id: sui::object::UID,
        name: string::String,
        description: string::String,
        image_url: string::String,
        pack_type: u8, // 0 = basic, 1 = magic, 2 = genesis
    }

    /// Witness para o tipo SeedPack
    public struct SEED_PACK has drop {}

    /// Inicializa o módulo e cria o objeto Display
    fun init(otw: SEED_PACK, ctx: &mut sui::tx_context::TxContext) {
        let publisher = sui::package::claim(otw, ctx);
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
            string::utf8(b"project_url"),
            string::utf8(b"creator"),
        ];

        let values = vector[
            string::utf8(b"{name}"),
            string::utf8(b"{description}"),
            string::utf8(b"{image_url}"),
            string::utf8(b"https://grow-a-garden.example.com"),
            string::utf8(b"Grow A Garden"),
        ];

        let mut display = sui::display::new_with_fields<SeedPack>(
            &publisher, keys, values, ctx
        );

        sui::display::update_version(&mut display);

        sui::transfer::public_transfer(publisher, sui::tx_context::sender(ctx));
        sui::transfer::public_transfer(display, sui::tx_context::sender(ctx));
    }

    /// Cria um novo NFT de Pacote de Sementes
    public fun mint(
        name: string::String,
        description: string::String,
        image_url: string::String,
        pack_type: u8,
        ctx: &mut sui::tx_context::TxContext
    ): SeedPack {
        let id = sui::object::new(ctx);
        let seed_pack = SeedPack {
            id,
            name,
            description,
            image_url,
            pack_type,
        };

        events::emit_seed_pack_minted(sui::object::uid_to_inner(&seed_pack.id), sui::tx_context::sender(ctx), pack_type);
        seed_pack
    }

    /// Transfere o NFT de Pacote de Sementes para o remetente
    #[allow(lint(self_transfer))]
    public fun mint_to_sender(
        name: string::String,
        description: string::String,
        image_url: string::String,
        pack_type: u8,
        ctx: &mut sui::tx_context::TxContext
    ) {
        let seed_pack = mint(name, description, image_url, pack_type, ctx);
        sui::transfer::public_transfer(seed_pack, sui::tx_context::sender(ctx));
    }

    /// Obtém o ID do Pacote de Sementes
    public fun id(self: &SeedPack): &sui::object::UID {
        &self.id
    }

    /// Obtém o nome do Pacote de Sementes
    public fun name(self: &SeedPack): &string::String {
        &self.name
    }

    /// Obtém a descrição do Pacote de Sementes
    public fun description(self: &SeedPack): &string::String {
        &self.description
    }

    /// Obtém a URL da imagem do Pacote de Sementes
    public fun image_url(self: &SeedPack): &string::String {
        &self.image_url
    }

    /// Obtém o tipo do Pacote de Sementes
    public fun pack_type(self: &SeedPack): u8 {
        self.pack_type
    }
    
    /// Queima (destrói) um pacote de sementes
    public fun burn(seed_pack: SeedPack) {
        let SeedPack { id, name: _, description: _, image_url: _, pack_type: _ } = seed_pack;
        sui::object::delete(id);
    }
}