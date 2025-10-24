// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";

/// @notice Script to set the protocol token on Spoke contracts
contract UpdateTrustedHubContracts is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        uint24 hubChainSelector = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));
        address hubContract = vm.envAddress("HUB_ADDRESS");
        address spokeAddress = vm.envAddress("MONAD_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));

        vm.startBroadcast();
        spoke.updateTrustedHubContracts(hubChainSelector, hubContract);
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Monad/Setter/SetUp/UpdateTrustedHubContracts.s.sol:UpdateTrustedHubContracts --account defaultKey --sender $WALLET_ADDRESS --rpc-url $MONAD_SEPOLIA_RPC_URL --broadcast -vvv
