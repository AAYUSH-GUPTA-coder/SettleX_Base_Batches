// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Hub} from "../../../../src/Hub.sol";

contract GetterHub is Script {
    function run() external view {
        address hubAddress = vm.envAddress("HUB_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        uint24 opChainSelector = uint24(vm.envUint("OP_CHAIN_SELECTOR"));
        uint24 baseChainSelector = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));
        uint24 zksyncChainSelector = uint24(vm.envUint("ZKSYNC_CHAIN_SELECTOR"));
        uint24 fujiChainSelector = uint24(vm.envUint("FUJI_CHAIN_SELECTOR"));
        uint24 monadChainSelector = uint24(vm.envUint("MONAD_CHAIN_SELECTOR"));

        address baseSpokeAddress = vm.envAddress("BASE_SPOKE_ADDRESS");
        address opSpokeAddress = vm.envAddress("OP_SPOKE_ADDRESS");
        address zksyncSpokeAddress = vm.envAddress("ZKSYNC_SPOKE_ADDRESS");
        address fujiSpokeAddress = vm.envAddress("FUJI_SPOKE_ADDRESS");
        address monadSpokeAddress = vm.envAddress("MONAD_SPOKE_ADDRESS");

        // Instantiate the Hub contract
        Hub hub = Hub(payable(hubAddress));

        // Check Owner
        console.log("Owner:", hub.getOwner());
        assert(hub.getOwner() == owner);

        // Check Whitelist Status
        console.log("Whitelist Status:", hub.checkWhitelistAddr(owner));
        assert(hub.checkWhitelistAddr(owner) == true);

        // Check Spoke Address
        console.log("Spoke Address on Base:", hub.getSpokeAddr(baseChainSelector));
        assert(hub.getSpokeAddr(baseChainSelector) == baseSpokeAddress);

        console.log("Spoke Address on Op:", hub.getSpokeAddr(opChainSelector));
        assert(hub.getSpokeAddr(opChainSelector) == opSpokeAddress);

        console.log("Spoke Address on ZkSync:", hub.getSpokeAddr(zksyncChainSelector));
        assert(hub.getSpokeAddr(zksyncChainSelector) == zksyncSpokeAddress);

        console.log("Spoke Address on Fuji:", hub.getSpokeAddr(fujiChainSelector));
        assert(hub.getSpokeAddr(fujiChainSelector) == fujiSpokeAddress);

        console.log("Spoke Address on Monad:", hub.getSpokeAddr(monadChainSelector));
        assert(hub.getSpokeAddr(monadChainSelector) == monadSpokeAddress);

        uint256 length = hub.getTransactionsLength();
        console.log("Transactions Length:", length);
    }
}

// forge script script/Hub/Arbitrum/Getter/GetterHub.s.sol:GetterHub --account defaultKey --sender $WALLET_ADDRESS --rpc-url $ARB_SEPOLIA_RPC_URL -vvv
