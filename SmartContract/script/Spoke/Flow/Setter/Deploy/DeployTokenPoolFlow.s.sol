// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {TokenPool} from "../../../../../src/TokenPool.sol";

contract DeployTokenPoolFlow is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouter = vm.envAddress("CONCERO_ROUTER_FLOW_TESTNET");

        vm.startBroadcast();
        TokenPool tokenPool = new TokenPool(owner, conceroRouter);
        vm.stopBroadcast();

        console.log("TokenPool deployed on Flow testnet at:", address(tokenPool));
        return address(tokenPool);
    }
}

// forge script script/Spoke/Flow/Setter/Deploy/DeployTokenPoolFlow.s.sol:DeployTokenPoolFlow --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FLOW_TESTNET_RPC_URL --broadcast -vvv