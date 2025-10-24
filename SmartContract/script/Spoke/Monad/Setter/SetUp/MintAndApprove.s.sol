// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract MintAndApprove is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address monadUsdtToken = vm.envAddress("MONAD_USDT_ADDR");
        Stablecoin usdtMonad = Stablecoin(monadUsdtToken);
        address poolAddr = vm.envAddress("MONAD_TOKENPOOL");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address spokeMonad = vm.envAddress("MONAD_SPOKE_ADDRESS");
        uint256 amount = 1e6;

        vm.startBroadcast();
        usdtMonad.mint(poolAddr, 10_000_000 * amount);
        usdtMonad.mint(owner, 1_000_000 * amount);

        usdtMonad.approve(spokeMonad, 10_000_000 * amount); // remember this approval is only valid for owner address
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Monad/Setter/SetUp/MintAndApprove.s.sol:MintAndApprove --account defaultKey --sender $WALLET_ADDRESS --rpc-url $MONAD_SEPOLIA_RPC_URL --broadcast -vvv