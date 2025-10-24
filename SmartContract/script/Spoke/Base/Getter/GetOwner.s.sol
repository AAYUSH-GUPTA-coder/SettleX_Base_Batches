// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../src/Spoke.sol";

contract GetOwner is Script {
    function run() external view {
        address baseSpoke = vm.envAddress("BASE_SPOKE_ADDRESS");
        address ownerAddr = vm.envAddress("OWNER_ADDRESS");
        Spoke spoke = Spoke(payable(baseSpoke));

        address owner = spoke.getOwner();
        console.log("BaseSpoke owner address:", owner);
        assert(owner == ownerAddr);
    }
}

// forge script script/Spoke/Base/Getter/GetOwner.s.sol:GetOwner --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL -vvv
