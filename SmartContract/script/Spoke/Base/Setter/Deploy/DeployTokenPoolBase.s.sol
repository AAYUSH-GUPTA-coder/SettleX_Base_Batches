// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {TokenPool} from "../../../../../src/TokenPool.sol";

contract DeployTokenPoolBase is Script {
    function run() external returns (address) {
        // Retrieve deployment parameters from environment variables
        address owner = vm.envAddress("OWNER_ADDRESS");
        address conceroRouter = vm.envAddress("CONCERO_ROUTER_BASE_SEPOLIA");

        vm.startBroadcast();
        TokenPool tokenPool = new TokenPool(owner, conceroRouter);
        vm.stopBroadcast();

        console.log("TokenPool deployed on Base at:", address(tokenPool));
        return address(tokenPool);
    }
}

// forge script script/Spoke/Base/Setter/Deploy/DeployTokenPoolBase.s.sol:DeployTokenPoolBase --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
