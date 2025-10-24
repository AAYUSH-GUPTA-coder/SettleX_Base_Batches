// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract DeployStablecoinMonad is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        Stablecoin stablecoin = new Stablecoin("USDT", "USDT");
        vm.stopBroadcast();

        console.log("Stablecoin USDT deployed on Monad Sepolia at:", address(stablecoin));
        return address(stablecoin);
    }
}

// forge script script/Spoke/Monad/Setter/Deploy/DeployStablecoinMonad.s.sol:DeployStablecoinMonad --account defaultKey --sender $WALLET_ADDRESS --rpc-url $MONAD_SEPOLIA_RPC_URL --broadcast -vvv
