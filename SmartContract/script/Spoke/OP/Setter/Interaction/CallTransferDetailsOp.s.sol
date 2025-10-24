// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CallTransferDetailsOp is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("OP_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint256 gasLimit = 100_000;

        vm.startBroadcast();

        // Call the callTransferDetails function
        spoke.callTransferDetails{value: 0.0001 ether}(gasLimit);

        vm.stopBroadcast();

        console.log("CallTransferDetails function called successfully on OP sepolia");
    }
}

// forge script script/Spoke/OP/Setter/Interaction/CallTransferDetailsOp.s.sol:CallTransferDetailsOp --account defaultKey --sender $WALLET_ADDRESS --rpc-url $OP_SEPOLIA_RPC_URL --broadcast -vvv
