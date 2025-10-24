// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CallTransferDetailsFuji is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("FUJI_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint256 gasLimit = 100_000;

        vm.startBroadcast();

        // Call the callTransferDetails function
        spoke.callTransferDetails{value: 0.001 ether}(gasLimit);

        vm.stopBroadcast();

        console.log("CallTransferDetails function called successfully on Fuji");
    }
}

// forge script script/Spoke/Fuji/Setter/Interaction/CallTransferDetailsFuji.s.sol:CallTransferDetailsFuji --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FUJI_RPC_URL --broadcast -vvv
