// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CreateTransactionFlow is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("FLOW_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint24 flowSourceChain = uint24(vm.envUint("FLOW_CHAIN_SELECTOR"));
        uint24 baseDestinationChain = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        // Prepare the CrossChainTransfer data.
        Spoke.CrossChainTransfer memory transferData = Spoke.CrossChainTransfer({
            sourceChainSelector: flowSourceChain,
            destinationChainSelector: baseDestinationChain,
            protocolTokenId: 1,
            receiver: receiver,
            amount: 9_500 * 1e6
        });

        vm.startBroadcast();

        // Call the createTransaction function with the constructed struct
        spoke.createTransaction(transferData);

        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Flow/Setter/Interaction/CreateTransactionFlow.s.sol:CreateTransactionFlow --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FLOW_TESTNET_RPC_URL --broadcast -vvv
