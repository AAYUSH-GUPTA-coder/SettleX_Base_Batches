// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CheckUsdtBalance is Script {
    function run() external view {
        address baseUsdtToken = vm.envAddress("BASE_USDT_ADDR");
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        console.log(
            "USDT balance of Receiver on Base:",
            IERC20(baseUsdtToken).balanceOf(0xFDD5D943101CDc7758085D48E608a0e5B8e3BE31)
        );
    }
}

// forge script script/Spoke/Base/Getter/CheckUsdtBalance.s.sol:CheckUsdtBalance --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL -vvv
