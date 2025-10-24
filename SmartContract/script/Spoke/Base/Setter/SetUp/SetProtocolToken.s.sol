// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

/// @notice Script to set the protocol token on Spoke contracts
contract SetProtocolToken is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("BASE_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        address baseUsdtToken = vm.envAddress("BASE_USDT_ADDR");

        vm.startBroadcast();
        spoke.setProtocolToken(baseUsdtToken, 1);
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Base/Setter/SetUp/SetProtocolToken.s.sol:SetProtocolToken --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
