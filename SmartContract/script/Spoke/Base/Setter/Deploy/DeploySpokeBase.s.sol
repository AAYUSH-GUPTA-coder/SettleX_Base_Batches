// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract DeploySpokeBase is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        uint24 hubChainSelector = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));
        uint24 sourceChainSelector = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));
        address hubAddress = vm.envAddress("HUB_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouterBase = vm.envAddress("CONCERO_ROUTER_BASE_SEPOLIA");

        vm.startBroadcast();
        Spoke spoke = new Spoke(hubChainSelector, sourceChainSelector, hubAddress, owner, conceroRouterBase);
        vm.stopBroadcast();

        console.log("Spoke deployed on Base Sepolia at:", address(spoke));

        return address(spoke);
    }
}

// forge script script/Spoke/Base/Setter/Deploy/DeploySpokeBase.s.sol:DeploySpokeBase --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
