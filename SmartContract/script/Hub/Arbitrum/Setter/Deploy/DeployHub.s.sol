// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Hub} from "../../../../../src/Hub.sol";

contract DeployHub is Script {
    function run() external {
        // Retrieve deployment parameters from environment variables
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouterArb = vm.envAddress("CONCERO_ROUTER_ARBITRUM_SEPOLIA");

        vm.startBroadcast();
        Hub hub = new Hub(owner, conceroRouterArb);
        vm.stopBroadcast();

        console.log("Hub deployed on Arbitrum Sepolia at:", address(hub));
    }
}

// forge script script/Hub/Arbitrum/Setter/Deploy/DeployHub.s.sol:DeployHub --account defaultKey --sender $WALLET_ADDRESS --rpc-url $ARB_SEPOLIA_RPC_URL --broadcast -vvv
