// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract MintAndApprove is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address fujiUsdtToken = vm.envAddress("FUJI_USDT_ADDR");
        Stablecoin usdtFuji = Stablecoin(fujiUsdtToken);
        address poolAddr = vm.envAddress("FUJI_TOKENPOOL");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address spokeFuji = vm.envAddress("FUJI_SPOKE_ADDRESS");
        uint256 amount = 1e6;

        vm.startBroadcast();
        usdtFuji.mint(poolAddr, 10_000_000 * amount);
        usdtFuji.mint(owner, 1_000_000 * amount);

        usdtFuji.approve(spokeFuji, 10_000_000 * amount); // remember this approval is only valid for owner address
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Fuji/Setter/Setup/MintAndApprove.s.sol:MintAndApprove --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FUJI_RPC_URL --broadcast -vvv
