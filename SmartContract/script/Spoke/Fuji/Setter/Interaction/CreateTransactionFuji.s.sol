// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

contract CreateTransactionFuji is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("FUJI_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        uint24 fujiSourceChain = uint24(vm.envUint("FUJI_CHAIN_SELECTOR"));
        uint24 baseDestinationChain = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));
        // address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        // Prepare the CrossChainTransfer data.
        Spoke.CrossChainTransfer memory transferData = Spoke.CrossChainTransfer({
            sourceChainSelector: fujiSourceChain,
            destinationChainSelector: baseDestinationChain,
            protocolTokenId: 1,
            receiver: 0xD1856e4149c0E72Da0D9258E2945550C535E3bf6,
            amount: 20_000 * 1e6
        });

        vm.startBroadcast();

        // Call the createTransaction function with the constructed struct
        spoke.createTransaction(transferData);

        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Fuji/Setter/Interaction/CreateTransactionFuji.s.sol:CreateTransactionFuji --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FUJI_RPC_URL --broadcast -vvv
