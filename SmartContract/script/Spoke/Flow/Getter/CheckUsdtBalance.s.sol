// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CheckUsdtBalance is Script {
    function run() external view {
        address flowUsdtToken = vm.envAddress("FLOW_USDT_ADDR");
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        console.log("USDT balance of Receiver on Flow:", IERC20(flowUsdtToken).balanceOf(receiver));
    }
}

// forge script script/Spoke/Flow/Getter/CheckUsdtBalance.s.sol:CheckUsdtBalance --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FLOW_TESTNET_RPC_URL -vvv
