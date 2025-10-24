// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract MintAndApprove is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address zksyncUsdtToken = vm.envAddress("ZKSYNC_USDT_ADDR");
        Stablecoin usdtZksync = Stablecoin(zksyncUsdtToken);
        address poolAddr = vm.envAddress("ZKSYNC_TOKENPOOL");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address spokeZksync = vm.envAddress("ZKSYNC_SPOKE_ADDRESS");
        uint256 amount = 1e6;

        vm.startBroadcast();
        usdtZksync.mint(poolAddr, 10_000_000 * amount);
        usdtZksync.mint(owner, 1_000_000 * amount);

        usdtZksync.approve(spokeZksync, 10_000_000 * amount); // remember this approval is only valid for owner address
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Zksync/Setter/Setup/MintAndApprove.s.sol:MintAndApprove --account defaultKey --sender $WALLET_ADDRESS --rpc-url $ZKSYNC_SEPOLIA_RPC_URL --broadcast -vvv