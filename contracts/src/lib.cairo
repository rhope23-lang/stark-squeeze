use starknet::ContractAddress;

#[starknet::interface]
trait IDataStorage<TContractState> {
    fn add_data(ref self: TContractState, name: ByteArray, cid: ByteArray, file_format: ByteArray);
    fn get_data(
        self: @TContractState, address: ContractAddress
    ) -> (ByteArray, ByteArray, ContractAddress, u64, ByteArray);
}

#[starknet::contract]
mod DataStorage {
    use super::ContractAddress;
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        DataAdded: DataAdded,
    }

    #[derive(Drop, starknet::Event)]
    struct DataAdded {
        name: ByteArray,
        cid: ByteArray,
        address: ContractAddress,
        timestamp: u64,
        file_format: ByteArray,
    }

    #[storage]
    struct Storage {
        name: ByteArray,
        cid: ByteArray,
        address: ContractAddress,
        timestamp: u64,
        file_format: ByteArray,
    }

    #[abi(embed_v0)]
    impl DataStorage of super::IDataStorage<ContractState> {
        fn add_data(ref self: ContractState, name: ByteArray, cid: ByteArray, file_format: ByteArray) {
            let caller = get_caller_address();
            let timestamp = get_block_timestamp();

            self.name.write(name.clone());
            self.cid.write(cid.clone());
            self.address.write(caller);
            self.timestamp.write(timestamp);
            self.file_format.write(file_format.clone());

            self.emit(DataAdded { name, cid, address: caller, timestamp, file_format });
        }

        fn get_data(
            self: @ContractState, address: ContractAddress
        ) -> (ByteArray, ByteArray, ContractAddress, u64, ByteArray) {
            assert(self.address.read() == address, 'Address not found');
            (
                self.name.read(),
                self.cid.read(),
                self.address.read(),
                self.timestamp.read(),
                self.file_format.read()
            )
        }
    }
}