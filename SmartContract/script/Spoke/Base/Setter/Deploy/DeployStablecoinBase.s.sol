// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Stablecoin} from "../../../../../src/Stablecoin.sol";

contract DeployStablecoinBase is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        Stablecoin stablecoin = new Stablecoin("USDT", "USDT");
        vm.stopBroadcast();

        console.log("Stablecoin USDT deployed on Base at:", address(stablecoin));
        return address(stablecoin);
    }
}

// forge script script/Spoke/Base/Setter/Deploy/DeployStablecoinBase.s.sol:DeployStablecoinBase --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
