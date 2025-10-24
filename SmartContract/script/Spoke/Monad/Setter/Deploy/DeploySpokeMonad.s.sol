// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract DeploySpokeMonad is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        uint24 hubChainSelector = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));
        uint24 sourceChainSelector = uint24(vm.envUint("MONAD_CHAIN_SELECTOR"));
        address hubAddress = vm.envAddress("HUB_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouterMonad = vm.envAddress("CONCERO_ROUTER_MONAD_SEPOLIA");

        vm.startBroadcast();
        Spoke spoke = new Spoke(hubChainSelector, sourceChainSelector, hubAddress, owner, conceroRouterMonad);
        vm.stopBroadcast();

        console.log("Spoke deployed on Monad Sepolia at:", address(spoke));

        return address(spoke);
    }
}

// forge script script/Spoke/Monad/Setter/Deploy/DeploySpokeMonad.s.sol:DeploySpokeMonad --account defaultKey --sender $WALLET_ADDRESS --rpc-url $MONAD_SEPOLIA_RPC_URL --broadcast -vvv
