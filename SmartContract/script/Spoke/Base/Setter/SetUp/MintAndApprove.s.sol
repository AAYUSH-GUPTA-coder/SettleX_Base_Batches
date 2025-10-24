// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract MintAndApprove is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address baseUsdtToken = vm.envAddress("BASE_USDT_ADDR");
        Stablecoin usdtBase = Stablecoin(baseUsdtToken);
        address poolAddr = vm.envAddress("BASE_TOKENPOOL");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address spokeBase = vm.envAddress("BASE_SPOKE_ADDRESS");
        uint256 amount = 1e6;

        vm.startBroadcast();
        usdtBase.mint(poolAddr, 10_000_000 * amount);
        usdtBase.mint(owner, 1_000_000 * amount);

        usdtBase.approve(spokeBase, 10_000_000 * amount); // remember this approval is only valid for owner address
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Base/Setter/Setup/MintAndApprove.s.sol:MintAndApprove --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
