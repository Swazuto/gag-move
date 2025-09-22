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

    // Função para comprar magic pack com SUI (0.02 SUI)
    #[allow(lint(self_transfer))]
    public fun buy_seed_pack_with_sui(
        payment: sui::coin::Coin<sui::sui::SUI>,
        ctx: &mut sui::tx_context::TxContext
    ) {
        let price = 20_000_000; // 0.02 SUI para magic pack

        // Verificar se o pagamento é suficiente
        assert!(sui::coin::value(&payment) >= price, 0);

        // Se o pagamento é exato, usar tudo
        if (sui::coin::value(&payment) == price) {
            // Transferir pagamento para o treasury
            sui::transfer::public_transfer(payment, @0x47efdbc6f87a800909b03bd1e8be6ea1aca2d50ecb95c00c27e289fbaaa67d91);
        } else {
            // Se há troco, separar o pagamento
            let mut payment_mut = payment;
            let payment_coin = sui::coin::split(&mut payment_mut, price, ctx);
            
            // Transferir pagamento para o treasury
            sui::transfer::public_transfer(payment_coin, @0x47efdbc6f87a800909b03bd1e8be6ea1aca2d50ecb95c00c27e289fbaaa67d91);
            
            // Retornar troco
            sui::transfer::public_transfer(payment_mut, sui::tx_context::sender(ctx));
        };

        // Criar magic pack
        let seed_pack = mint(
            string::utf8(b"Magic Pack"),
            string::utf8(b"A magic seed pack with rare seeds chance"),
            string::utf8(b"https://i.imgur.com/woNLd0p.png"),
            1, // magic pack type
            ctx
        );
        sui::transfer::public_transfer(seed_pack, sui::tx_context::sender(ctx));
    }

    // Função para mint gratuito de basic pack (controlado pelo backend usando moedas DB)
    #[allow(lint(self_transfer))]
    public fun mint_seed_pack_free(
        recipient: address,
        ctx: &mut sui::tx_context::TxContext
    ) {
        // Criar basic pack
        let seed_pack = mint(
            string::utf8(b"Basic Pack"),
            string::utf8(b"A basic seed pack with common seeds"),
            string::utf8(b"https://i.imgur.com/fPtrLI7.png"),
            0, // basic pack type
            ctx
        );
        sui::transfer::public_transfer(seed_pack, recipient);
    }
    
    public fun burn(seed_pack: SeedPack) {
        let SeedPack { id, name: _, description: _, image_url: _, pack_type: _ } = seed_pack;
        sui::object::delete(id);
    }
}