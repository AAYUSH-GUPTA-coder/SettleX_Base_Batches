// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CallBridgeSettlementBase is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("BASE_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint256 gasLimit = 100_000;

        uint256 ethValue = spoke.getStoredTransactionsSettlementLength() * 0.0001 ether;
        uint256 gasLimitValue = spoke.getStoredTransactionsSettlementLength() * gasLimit;

        vm.startBroadcast();

        // Call the bridgeSettlement function
        spoke.bridgeSettlement{value: ethValue}(gasLimitValue);

        vm.stopBroadcast();

        console.log("bridgeSettlement function called successfully on Base sepolia");
    }
}

// forge script script/Spoke/Base/Setter/Interaction/CallBridgeSettlementBase.s.sol:CallBridgeSettlementBase --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
