// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CreateTransactionMonad is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("MONAD_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint24 monadSourceChain = uint24(vm.envUint("MONAD_CHAIN_SELECTOR"));
        uint24 fujiDestinationChain = uint24(vm.envUint("FUJI_CHAIN_SELECTOR"));
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        // Prepare the CrossChainTransfer data.
        Spoke.CrossChainTransfer memory transferData = Spoke.CrossChainTransfer({
            sourceChainSelector: monadSourceChain,
            destinationChainSelector: fujiDestinationChain,
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

// forge script script/Spoke/Monad/Setter/Interaction/CreateTransactionMonad.s.sol:CreateTransactionMonad --account defaultKey --sender $WALLET_ADDRESS --rpc-url $MONAD_SEPOLIA_RPC_URL --broadcast -vvv
