// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../src/Spoke.sol";

contract CheckWhitelistAddr is Script {
    function run() external view {
        address baseSpoke = vm.envAddress("BASE_SPOKE_ADDRESS");
        address addrToCheck = vm.envAddress("OWNER_ADDRESS");
        Spoke spoke = Spoke(payable(baseSpoke));

        bool isWhitelisted = spoke.checkWhitelistAddr(addrToCheck);
        console.log("BaseSpoke whitelist status of Address:", isWhitelisted);
        assert(isWhitelisted == true);
    }
}

// forge script script/Spoke/Base/Getter/CheckWhitelistAddr.s.sol:CheckWhitelistAddr --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL -vvv
