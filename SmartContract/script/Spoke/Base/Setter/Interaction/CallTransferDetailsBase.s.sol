// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CallTransferDetailsBase is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("BASE_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint256 gasLimit = 100_000;
        
        uint256 ethValue = spoke.getStoredTransactionsDataLength() * 0.0001 ether;
        uint256 gasLimitValue = spoke.getStoredTransactionsDataLength() * gasLimit;

        vm.startBroadcast();

        // Call the callTransferDetails function
        spoke.callTransferDetails{value: ethValue}(gasLimitValue);

        vm.stopBroadcast();

        console.log("CallTransferDetails function called successfully on Base sepolia");
    }
}

// forge script script/Spoke/Base/Setter/Interaction/CallTransferDetailsBase.s.sol:CallTransferDetailsBase --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
