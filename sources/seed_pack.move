module grow_a_garden::seed_pack {
    use std::string;
    use grow_a_garden::events;

    public struct SeedPack has key, store {
        id: sui::object::UID,
        name: string::String,
        description: string::String,
        image_url: string::String,
        pack_type: u8, // 0 = basic, 1 = magic, 2 = genesis
    }

    public struct SEED_PACK has drop {}

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
            string::utf8(b"https://garden.sazuto.com/"),
            string::utf8(b"Grow A Garden"),
        ];

        let mut display = sui::display::new_with_fields<SeedPack>(
            &publisher, keys, values, ctx
        );

        sui::display::update_version(&mut display);

        sui::transfer::public_transfer(publisher, sui::tx_context::sender(ctx));
        sui::transfer::public_transfer(display, sui::tx_context::sender(ctx));
    }

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

    public fun id(self: &SeedPack): &sui::object::UID {
        &self.id
    }

    public fun name(self: &SeedPack): &string::String {
        &self.name
    }

    public fun description(self: &SeedPack): &string::String {
        &self.description
    }

    public fun image_url(self: &SeedPack): &string::String {
        &self.image_url
    }

    public fun pack_type(self: &SeedPack): u8 {
        self.pack_type
    }
    
    public fun burn(seed_pack: SeedPack) {
        let SeedPack { id, name: _, description: _, image_url: _, pack_type: _ } = seed_pack;
        sui::object::delete(id);
    }
}