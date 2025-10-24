// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CreateTransactionBase is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("BASE_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint24 baseSourceChain = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));
        uint24 flowDestinationChain = uint24(vm.envUint("FLOW_CHAIN_SELECTOR"));
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        // Prepare the CrossChainTransfer data.
        Spoke.CrossChainTransfer memory transferData = Spoke.CrossChainTransfer({
            sourceChainSelector: baseSourceChain,
            destinationChainSelector: flowDestinationChain,
            protocolTokenId: 1,
            receiver: receiver,
            amount: 10_000 * 1e6
        });

        vm.startBroadcast();

        // Call the createTransaction function with the constructed struct
        spoke.createTransaction(transferData);

        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Base/Setter/Interaction/CreateTransactionBase.s.sol:CreateTransactionBase --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
