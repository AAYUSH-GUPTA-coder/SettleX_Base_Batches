// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Hub} from "../../../../../src/Hub.sol";

contract Setup is Script {
    function run() external {
        // Retrieve the deployed Hub contract address from environment variables
        address hubAddress = vm.envAddress("HUB_ADDRESS");

        // Instantiate the Hub contract
        Hub hub = Hub(payable(hubAddress));

        // Retrieve the spoke chain and whitelist status from environment variables
        
        uint24 baseSpokeChain = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));
        uint24 opSpokeChain = uint24(vm.envUint("OP_CHAIN_SELECTOR"));
        uint24 monadSpokeChain = uint24(vm.envUint("MONAD_CHAIN_SELECTOR"));
        uint24 zkSyncSpokeChain = uint24(vm.envUint("ZKSYNC_CHAIN_SELECTOR"));
        uint24 fujiSpokeChain = uint24(vm.envUint("FUJI_CHAIN_SELECTOR"));
        uint24 flowSpokeChain = uint24(vm.envUint("FLOW_CHAIN_SELECTOR"));

        address baseSpokeContract = vm.envAddress("BASE_SPOKE_ADDRESS");
        address opSpokeContract = vm.envAddress("OP_SPOKE_ADDRESS");
        address monadSpokeContract = vm.envAddress("MONAD_SPOKE_ADDRESS");
        address zkSyncSpokeContract = vm.envAddress("ZKSYNC_SPOKE_ADDRESS");
        address fujiSpokeContract = vm.envAddress("FUJI_SPOKE_ADDRESS");
        address flowSpokeContract = vm.envAddress("FLOW_SPOKE_ADDRESS");

        vm.startBroadcast();
        // 1. UPDATED SPOKE CHAINS AND CONTRACTS
        hub.updateSpokeContract(baseSpokeChain, baseSpokeContract);
        hub.updateSpokeContract(opSpokeChain, opSpokeContract);
        hub.updateSpokeContract(monadSpokeChain, monadSpokeContract);
        hub.updateSpokeContract(zkSyncSpokeChain, zkSyncSpokeContract);
        hub.updateSpokeContract(fujiSpokeChain, fujiSpokeContract);
        hub.updateSpokeContract(flowSpokeChain, flowSpokeContract);
        vm.stopBroadcast();

        console.log("Called updateSpokeContract on Hub at:", hubAddress);
    }
}

// forge script script/Hub/Arbitrum/Setter/Setup/Setup.s.sol:Setup --account defaultKey --sender $WALLET_ADDRESS --rpc-url $ARB_SEPOLIA_RPC_URL --broadcast -vvv
