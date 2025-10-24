// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract DeploySpokeFlow is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        uint24 hubChainSelector = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));
        uint24 sourceChainSelector = uint24(vm.envUint("FLOW_CHAIN_SELECTOR"));
        address hubAddress = vm.envAddress("HUB_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouter = vm.envAddress("CONCERO_ROUTER_FLOW_TESTNET");

        vm.startBroadcast();
        Spoke spoke = new Spoke(hubChainSelector, sourceChainSelector, hubAddress, owner, conceroRouter);
        vm.stopBroadcast();

        console.log("Spoke deployed on Flow testnet at:", address(spoke));

        return address(spoke);
    }
}

// forge script script/Spoke/Flow/Setter/Deploy/DeploySpokeFlow.s.sol:DeploySpokeFlow --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FLOW_TESTNET_RPC_URL --broadcast -vvv

// cast balance --ether --rpc-url https://testnet.evm.nodes.onflow.org $WALLET_ADDRESS