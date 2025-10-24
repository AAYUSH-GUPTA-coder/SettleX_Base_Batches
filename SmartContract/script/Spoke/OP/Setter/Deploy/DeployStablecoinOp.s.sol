// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract DeployStablecoinOp is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        Stablecoin stablecoin = new Stablecoin("USDT", "USDT");
        vm.stopBroadcast();

        console.log("Stablecoin USDT deployed on OP Sepolia at:", address(stablecoin));
        return address(stablecoin);
    }
}

// forge script script/Spoke/OP/Setter/Deploy/DeployStablecoinOp.s.sol:DeployStablecoinOp --account defaultKey --sender $WALLET_ADDRESS --rpc-url $OP_SEPOLIA_RPC_URL --broadcast -vvv
