// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract MintAndApprove is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address opUsdtToken = vm.envAddress("OP_USDT_ADDR");
        Stablecoin usdtOp = Stablecoin(opUsdtToken);
        address poolAddr = vm.envAddress("OP_TOKENPOOL");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address spokeOp = vm.envAddress("OP_SPOKE_ADDRESS");
        uint256 amount = 1e6;

        vm.startBroadcast();
        usdtOp.mint(poolAddr, 10_000_000 * amount);
        usdtOp.mint(owner, 1_000_000 * amount);

        usdtOp.approve(spokeOp, 10_000_000 * amount); // remember this approval is only valid for owner address
        vm.stopBroadcast();
    }
}

// forge script script/Spoke/OP/Setter/Setup/MintAndApprove.s.sol:MintAndApprove --account defaultKey --sender $WALLET_ADDRESS --rpc-url $OP_SEPOLIA_RPC_URL --broadcast -vvv
