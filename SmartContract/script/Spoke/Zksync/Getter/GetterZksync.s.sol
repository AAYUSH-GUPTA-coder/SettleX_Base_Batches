// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../src/Spoke.sol";
import {TokenPool} from "../../../../src/TokenPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GetterZksync is Script {
    function run() external view {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("ZKSYNC_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        address poolAddr = vm.envAddress("ZKSYNC_TOKENPOOL");
        TokenPool pool = TokenPool(poolAddr);
        address zksyncUsdtToken = vm.envAddress("ZKSYNC_USDT_ADDR");
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        uint24 monadDestinationChain = uint24(vm.envUint("MONAD_CHAIN_SELECTOR"));
        uint24 fujiDestinationChain = uint24(vm.envUint("FUJI_CHAIN_SELECTOR"));
        uint24 opDestinationChain = uint24(vm.envUint("OP_CHAIN_SELECTOR"));
        uint24 baseDestinationChain = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));

        address monadPoolContract = vm.envAddress("MONAD_TOKENPOOL");
        address fujiPoolContract = vm.envAddress("FUJI_TOKENPOOL");
        address opPoolContract = vm.envAddress("OP_TOKENPOOL");
        address basePoolContract = vm.envAddress("BASE_TOKENPOOL");

        address monadSpokeContract = vm.envAddress("MONAD_SPOKE_ADDRESS");
        address fujiSpokeContract = vm.envAddress("FUJI_SPOKE_ADDRESS");
        address opSpokeContract = vm.envAddress("OP_SPOKE_ADDRESS");
        address baseSpokeContract = vm.envAddress("BASE_SPOKE_ADDRESS");

        address hubAddress = vm.envAddress("HUB_ADDRESS");

        uint24 hubChain = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));

        // Check the protocol token on Spoke and Pool contracts
        console.log("Protocol Token on ZKSync Spoke at:", spoke.checkProtocolToOriginal(1));
        assert(spoke.checkProtocolToOriginal(1) == zksyncUsdtToken);
        console.log("Protocol Token on ZKSync Pool at:", pool.checkProtocolToOriginal(1));
        assert(pool.checkProtocolToOriginal(1) == zksyncUsdtToken);

        // Check the destination pool contract on Spoke contracts
        console.log(
            "Destination Pool Contract on Monad Spoke at:", spoke.getDestinationPoolContract(monadDestinationChain)
        );
        assert(spoke.getDestinationPoolContract(monadDestinationChain) == monadPoolContract);

        console.log(
            "Destination Pool Contract on Fuji Spoke at:", spoke.getDestinationPoolContract(fujiDestinationChain)
        );
        assert(spoke.getDestinationPoolContract(fujiDestinationChain) == fujiPoolContract);

        console.log("Destination Pool Contract on OP Spoke at:", spoke.getDestinationPoolContract(opDestinationChain));
        assert(spoke.getDestinationPoolContract(opDestinationChain) == opPoolContract);

        console.log(
            "Destination Pool Contract on Base Spoke at:", spoke.getDestinationPoolContract(baseDestinationChain)
        );
        assert(spoke.getDestinationPoolContract(baseDestinationChain) == basePoolContract);

        // Check the destination spoke contract on Spoke contracts
        console.log(
            "Destination Spoke Contracts on Monad Chain", spoke.getDestinationSpokeContracts(monadDestinationChain)
        );
        assert(spoke.getDestinationSpokeContracts(monadDestinationChain) == monadSpokeContract);

        console.log(
            "Destination Spoke Contracts on Fuji Chain", spoke.getDestinationSpokeContracts(fujiDestinationChain)
        );
        assert(spoke.getDestinationSpokeContracts(fujiDestinationChain) == fujiSpokeContract);

        console.log("Destination Spoke Contracts on OP Chain", spoke.getDestinationSpokeContracts(opDestinationChain));
        assert(spoke.getDestinationSpokeContracts(opDestinationChain) == opSpokeContract);

        console.log(
            "Destination Spoke Contracts on Base Chain", spoke.getDestinationSpokeContracts(baseDestinationChain)
        );
        assert(spoke.getDestinationSpokeContracts(baseDestinationChain) == baseSpokeContract);

        // Check Hub Contract
        console.log("Hub Contract of Base Spoke contract on Arbitrum Chain :", spoke.getHubAddress());
        assert(spoke.getHubAddress() == hubAddress);

        // Check Pool Addr
        console.log("Pool Address on Base Spoke chain", spoke.getPoolAddr());
        assert(spoke.getPoolAddr() == poolAddr);

        // Check Whitelisted Spoke Contracts on TokenPool contract
        console.log(
            "Whitelisted Spoke Contracts on TokenPool contract for Monad Chain and spoke contract: ",
            pool.getWhitelistedSpokeContracts(monadDestinationChain, monadSpokeContract)
        );
        assert(pool.getWhitelistedSpokeContracts(monadDestinationChain, monadSpokeContract));

        console.log(
            "Whitelisted Spoke Contracts on TokenPool contract for Fuji Chain and spoke contract: ",
            pool.getWhitelistedSpokeContracts(fujiDestinationChain, fujiSpokeContract)
        );
        assert(pool.getWhitelistedSpokeContracts(fujiDestinationChain, fujiSpokeContract));

        console.log(
            "Whitelisted Spoke Contracts on TokenPool contract for OP Chain and spoke contract: ",
            pool.getWhitelistedSpokeContracts(opDestinationChain, opSpokeContract)
        );
        assert(pool.getWhitelistedSpokeContracts(opDestinationChain, opSpokeContract));

        console.log(
            "Whitelisted Spoke Contracts on TokenPool contract for Base Chain and spoke contract: ",
            pool.getWhitelistedSpokeContracts(baseDestinationChain, baseSpokeContract)
        );
        assert(pool.getWhitelistedSpokeContracts(baseDestinationChain, baseSpokeContract));

        // check hub chain selector
        console.log("Hub Chain Selector on Base Spoke contract for Arbitrum Chain :", spoke.getHubChainSelector());
        assert(spoke.getHubChainSelector() == hubChain);

        // Check Stored Transactions Settlement Length
        console.log("Stored Transactions Settlement Length:", spoke.getStoredTransactionsSettlementLength());

        // Check Stored Transactions Data Length
        console.log("Stored Transactions Data Length:", spoke.getStoredTransactionsDataLength());

        // USDT Balance of TokenPool on zksync
        console.log("USDT balance on Zksync in the TokenPool:", IERC20(zksyncUsdtToken).balanceOf(poolAddr));

        // USDT Balance of spoke contract on zksync
        console.log("USDT balance of Spoke on Zksync:", IERC20(zksyncUsdtToken).balanceOf(spokeAddress));

        // USDT Balance of Receiver on zksync
        console.log("USDT balance of Receiver on Zksync:", IERC20(zksyncUsdtToken).balanceOf(receiver));
    }
}

// forge script script/Spoke/Zksync/Getter/GetterZksync.s.sol:GetterZksync --account defaultKey --sender $WALLET_ADDRESS --rpc-url $ZKSYNC_SEPOLIA_RPC_URL -vvv
