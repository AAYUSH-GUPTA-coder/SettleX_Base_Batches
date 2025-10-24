// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract DeploySpokeOp is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        uint24 hubChainSelector = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));
        uint24 sourceChainSelector = uint24(vm.envUint("OP_CHAIN_SELECTOR"));
        address hubAddress = vm.envAddress("HUB_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouterOp = vm.envAddress("CONCERO_ROUTER_OP_SEPOLIA");

        vm.startBroadcast();
        Spoke spoke = new Spoke(hubChainSelector, sourceChainSelector, hubAddress, owner, conceroRouterOp);
        vm.stopBroadcast();

        console.log("Spoke deployed on OP Sepolia at:", address(spoke));

        return address(spoke);
    }
}

// forge script script/Spoke/OP/Setter/Deploy/DeploySpokeOp.s.sol:DeploySpokeOp --account defaultKey --sender $WALLET_ADDRESS --rpc-url $OP_SEPOLIA_RPC_URL --broadcast -vvv
