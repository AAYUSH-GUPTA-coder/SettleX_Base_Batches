// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Hub} from "../../../../../src/Hub.sol";

contract CallExecuteNetting is Script {
    function run() external {
        // Retrieve the deployed Netting contract address from environment variables
        address hubAddress = vm.envAddress("HUB_ADDRESS");
        uint256 gasLimit = 100_000;

        // Instantiate the Netting contract
        Hub hub = Hub(payable(hubAddress));

        vm.startBroadcast();
        hub.executeNetting{value: 0.0002 ether}(gasLimit);
        vm.stopBroadcast();

        console.log("Called executeNetting on Hub at:", hubAddress);
    }
}

// forge script script/Hub/Arbitrum/Setter/Interaction/CallExecuteNetting.s.sol:CallExecuteNetting --account defaultKey --sender $WALLET_ADDRESS --rpc-url $ARB_SEPOLIA_RPC_URL --broadcast -vvv
