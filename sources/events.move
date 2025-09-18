module grow_a_garden::events {
    use sui::event;

    /// Evento emitido quando um seed pack é mintado
    public struct SeedPackMinted has copy, drop {
        seed_pack_id: sui::object::ID,
        owner: address,
        pack_type: u8,
    }

    /// Função para emitir evento de seed pack mintado
    public fun emit_seed_pack_minted(seed_pack_id: sui::object::ID, owner: address, pack_type: u8) {
        event::emit(SeedPackMinted {
            seed_pack_id,
            owner,
            pack_type,
        });
    }
}