// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../../src/Spoke.sol";
import {TokenPool} from "../../../../../src/TokenPool.sol";

/// @notice Script to set the protocol token on Spoke and TokenPool contracts
contract SpokeBaseSetup is Script {
    function run() external {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("BASE_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        address poolAddr = vm.envAddress("BASE_TOKENPOOL");
        TokenPool pool = TokenPool(poolAddr);
        address baseUsdtToken = vm.envAddress("BASE_USDT_ADDR");

        uint24 opDestinationChain = uint24(vm.envUint("OP_CHAIN_SELECTOR"));
        uint24 monadDestinationChain = uint24(vm.envUint("MONAD_CHAIN_SELECTOR"));
        uint24 zksyncDestinationChain = uint24(vm.envUint("ZKSYNC_CHAIN_SELECTOR"));
        uint24 fujiDestinationChain = uint24(vm.envUint("FUJI_CHAIN_SELECTOR"));

        address opPoolContract = vm.envAddress("OP_TOKENPOOL");
        address monadPoolContract = vm.envAddress("MONAD_TOKENPOOL");
        address fujiPoolContract = vm.envAddress("FUJI_TOKENPOOL");
        address zksyncPoolContract = vm.envAddress("ZKSYNC_TOKENPOOL");

        address opSpokeContract = vm.envAddress("OP_SPOKE_ADDRESS");
        address monadSpokeContract = vm.envAddress("MONAD_SPOKE_ADDRESS");
        address fujiSpokeContract = vm.envAddress("FUJI_SPOKE_ADDRESS");
        address zksyncSpokeContract = vm.envAddress("ZKSYNC_SPOKE_ADDRESS");

        address baseTokenPoolAddr = vm.envAddress("BASE_TOKENPOOL");

        vm.startBroadcast();
        // 1. Set the protocol token on Spoke contract
        spoke.setProtocolToken(baseUsdtToken, 1);

        // 2. Set the protocol token on TokenPool contract
        pool.setProtocolToken(baseUsdtToken, 1);

        // 3. Update the destination pool contract
        spoke.updateDestinationPoolContract(opDestinationChain, opPoolContract);
        spoke.updateDestinationPoolContract(monadDestinationChain, monadPoolContract);
        spoke.updateDestinationPoolContract(fujiDestinationChain, fujiPoolContract);
        spoke.updateDestinationPoolContract(zksyncDestinationChain, zksyncPoolContract);

        // 4. Update the destination spoke contract
        spoke.updateDestinationSpokeContracts(opDestinationChain, opSpokeContract, true, true);
        spoke.updateDestinationSpokeContracts(monadDestinationChain, monadSpokeContract, true, true);
        spoke.updateDestinationSpokeContracts(fujiDestinationChain, fujiSpokeContract, true, true);
        spoke.updateDestinationSpokeContracts(zksyncDestinationChain, zksyncSpokeContract, true, true);

        // 5. Update the pool address
        spoke.updatePoolAddr(baseTokenPoolAddr);

        // 6. Update the trusted spoke contracts
        pool.setWhitelistedSpokeContracts(opDestinationChain, opSpokeContract, true);
        pool.setWhitelistedSpokeContracts(monadDestinationChain, monadSpokeContract, true);
        pool.setWhitelistedSpokeContracts(fujiDestinationChain, fujiSpokeContract, true);
        pool.setWhitelistedSpokeContracts(zksyncDestinationChain, zksyncSpokeContract, true);

        vm.stopBroadcast();
    }
}

// forge script script/Spoke/Base/Setter/SetUp/SpokeBaseSetup.s.sol:SpokeBaseSetup --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
