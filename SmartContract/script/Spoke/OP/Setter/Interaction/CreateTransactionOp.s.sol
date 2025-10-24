// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CreateTransactionOp is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("OP_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint24 opSourceChain = uint24(vm.envUint("OP_CHAIN_SELECTOR"));
        uint24 baseDestinationChain = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        // Prepare the CrossChainTransfer data.
        Spoke.CrossChainTransfer memory transferData = Spoke.CrossChainTransfer({
            sourceChainSelector: opSourceChain,
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

// forge script script/Spoke/OP/Setter/Interaction/CreateTransactionOp.s.sol:CreateTransactionOp --account defaultKey --sender $WALLET_ADDRESS --rpc-url $OP_SEPOLIA_RPC_URL --broadcast -vvv
