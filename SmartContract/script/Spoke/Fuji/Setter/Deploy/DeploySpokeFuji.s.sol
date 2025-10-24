// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract DeploySpokeFuji is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        uint24 hubChainSelector = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));
        uint24 sourceChainSelector = uint24(vm.envUint("FUJI_CHAIN_SELECTOR"));
        address hubAddress = vm.envAddress("HUB_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouterFuji = vm.envAddress("CONCERO_ROUTER_AVALANCHE_FUJI");

        vm.startBroadcast();
        Spoke spoke = new Spoke(hubChainSelector, sourceChainSelector, hubAddress, owner, conceroRouterFuji);
        vm.stopBroadcast();

        console.log("Spoke deployed on Avalanche Fuji at:", address(spoke));

        return address(spoke);
    }
}

// forge script script/Spoke/Fuji/Setter/Deploy/DeploySpokeFuji.s.sol:DeploySpokeFuji --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FUJI_RPC_URL --broadcast -vvv
