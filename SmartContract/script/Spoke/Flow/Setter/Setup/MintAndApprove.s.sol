// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract MintAndApprove is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address flowUsdtToken = vm.envAddress("FLOW_USDT_ADDR");
        Stablecoin usdtFlow = Stablecoin(flowUsdtToken);
        address poolAddr = vm.envAddress("FLOW_TOKENPOOL");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address spokeFlow = vm.envAddress("FLOW_SPOKE_ADDRESS");
        uint256 amount = 1e6;

        vm.startBroadcast();
        usdtFlow.mint(poolAddr, 10_000_000 * amount);
        usdtFlow.mint(owner, 1_000_000 * amount);

        usdtFlow.approve(spokeFlow, 10_000_000 * amount); // remember this approval is only valid for owner address
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Flow/Setter/Setup/MintAndApprove.s.sol:MintAndApprove --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FLOW_TESTNET_RPC_URL --broadcast -vvv
