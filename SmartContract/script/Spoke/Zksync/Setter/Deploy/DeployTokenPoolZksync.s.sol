// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {TokenPool} from "../../../../../src/TokenPool.sol";

contract DeployTokenPoolZksync is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouter = vm.envAddress("CONCERO_ROUTER_ZKSYNC_SEPOLIA");

        vm.startBroadcast();
        TokenPool tokenPool = new TokenPool(owner, conceroRouter);
        vm.stopBroadcast();

        console.log("TokenPool deployed on Zksync at:", address(tokenPool));
        return address(tokenPool);
    }
}

// forge script script/Spoke/Zksync/Setter/Deploy/DeployTokenPoolZksync.s.sol:DeployTokenPoolZksync --account defaultKey --sender $WALLET_ADDRESS --rpc-url $ZKSYNC_SEPOLIA_RPC_URL --broadcast -vvv
