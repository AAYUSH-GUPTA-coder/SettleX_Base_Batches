// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract DeployStablecoinFuji is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        Stablecoin stablecoin = new Stablecoin("USDT", "USDT");
        vm.stopBroadcast();

        console.log("Stablecoin USDT deployed on Avalanche Fuji at:", address(stablecoin));
        return address(stablecoin);
    }
}

// forge script script/Spoke/Fuji/Setter/Deploy/DeployStablecoinFuji.s.sol:DeployStablecoinFuji --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FUJI_RPC_URL --broadcast -vvv
