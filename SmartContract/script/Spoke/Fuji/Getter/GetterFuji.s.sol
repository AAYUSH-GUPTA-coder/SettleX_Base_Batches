// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import {Spoke} from "../../../../src/Spoke.sol";
import {TokenPool} from "../../../../src/TokenPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GetterFuji is Script {
    function run() external view {
        // Retrieve the deployed Spoke contract address from environment variables
        address spokeAddress = vm.envAddress("FUJI_SPOKE_ADDRESS");
        Spoke spoke = Spoke(payable(spokeAddress));
        address poolAddr = vm.envAddress("FUJI_TOKENPOOL");
        TokenPool pool = TokenPool(poolAddr);
        address fujiUsdtToken = vm.envAddress("FUJI_USDT_ADDR");
        address receiver = vm.envAddress("RECIPIENT_ADDRESS");

        uint24 opDestinationChain = uint24(vm.envUint("OP_CHAIN_SELECTOR"));
        uint24 monadDestinationChain = uint24(vm.envUint("MONAD_CHAIN_SELECTOR"));
        uint24 zksyncDestinationChain = uint24(vm.envUint("ZKSYNC_CHAIN_SELECTOR"));
        uint24 baseDestinationChain = uint24(vm.envUint("BASE_CHAIN_SELECTOR"));

        address opPoolContract = vm.envAddress("OP_TOKENPOOL");
        address monadPoolContract = vm.envAddress("MONAD_TOKENPOOL");
        address zksyncPoolContract = vm.envAddress("ZKSYNC_TOKENPOOL");
        address basePoolContract = vm.envAddress("BASE_TOKENPOOL");

        address opSpokeContract = vm.envAddress("OP_SPOKE_ADDRESS");
        address monadSpokeContract = vm.envAddress("MONAD_SPOKE_ADDRESS");
        address zksyncSpokeContract = vm.envAddress("ZKSYNC_SPOKE_ADDRESS");
        address baseSpokeContract = vm.envAddress("BASE_SPOKE_ADDRESS");

        address hubAddress = vm.envAddress("HUB_ADDRESS");

        uint24 hubChain = uint24(vm.envUint("HUB_CHAIN_SELECTOR"));

        // Check the protocol token on Spoke and Pool contracts
        console.log("Protocol Token on Fuji Spoke at:", spoke.checkProtocolToOriginal(1));
        assert(spoke.checkProtocolToOriginal(1) == fujiUsdtToken);
        console.log("Protocol Token on Fuji Pool at:", pool.checkProtocolToOriginal(1));
        assert(pool.checkProtocolToOriginal(1) == fujiUsdtToken);

        // Check the destination pool contract on Spoke contracts
        console.log("Destination Pool Contract on OP Spoke at:", spoke.getDestinationPoolContract(opDestinationChain));
        assert(spoke.getDestinationPoolContract(opDestinationChain) == opPoolContract);

        console.log(
            "Destination Pool Contract on Monad Spoke at:", spoke.getDestinationPoolContract(monadDestinationChain)
        );
        assert(spoke.getDestinationPoolContract(monadDestinationChain) == monadPoolContract);

        console.log(
            "Destination Pool Contract on ZKSync Spoke at:", spoke.getDestinationPoolContract(zksyncDestinationChain)
        );
        assert(spoke.getDestinationPoolContract(zksyncDestinationChain) == zksyncPoolContract);

        console.log(
            "Destination Pool Contract on Base Spoke at:", spoke.getDestinationPoolContract(baseDestinationChain)
        );
        assert(spoke.getDestinationPoolContract(baseDestinationChain) == basePoolContract);

        // Check the destination spoke contract on Spoke contracts
        console.log("Destination Spoke Contracts on OP Chain", spoke.getDestinationSpokeContracts(opDestinationChain));
        assert(spoke.getDestinationSpokeContracts(opDestinationChain) == opSpokeContract);

        console.log(
            "Destination Spoke Contracts on Monad Chain", spoke.getDestinationSpokeContracts(monadDestinationChain)
        );
        assert(spoke.getDestinationSpokeContracts(monadDestinationChain) == monadSpokeContract);

        console.log(
            "Destination Spoke Contracts on ZKSync Chain", spoke.getDestinationSpokeContracts(zksyncDestinationChain)
        );
        assert(spoke.getDestinationSpokeContracts(zksyncDestinationChain) == zksyncSpokeContract);

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
            "Whitelisted Spoke Contracts on TokenPool contract for OP Chain and spoke contract: ",
            pool.getWhitelistedSpokeContracts(opDestinationChain, opSpokeContract)
        );
        assert(pool.getWhitelistedSpokeContracts(opDestinationChain, opSpokeContract));

        console.log(
            "Whitelisted Spoke Contracts on TokenPool contract for Monad Chain and spoke contract: ",
            pool.getWhitelistedSpokeContracts(monadDestinationChain, monadSpokeContract)
        );
        assert(pool.getWhitelistedSpokeContracts(monadDestinationChain, monadSpokeContract));

        console.log(
            "Whitelisted Spoke Contracts on TokenPool contract for ZKSync Chain and spoke contract: ",
            pool.getWhitelistedSpokeContracts(zksyncDestinationChain, zksyncSpokeContract)
        );
        assert(pool.getWhitelistedSpokeContracts(zksyncDestinationChain, zksyncSpokeContract));

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

        // Balance of USDT in TokenPool
        console.log("USDT balance in the TokenPool:", IERC20(fujiUsdtToken).balanceOf(poolAddr));

        // Balance of Base TokenPool in Spoke
        console.log("USDT balance of Spoke on Base:", IERC20(fujiUsdtToken).balanceOf(spokeAddress));

        console.log("USDT balance of Receiver on Base:", IERC20(fujiUsdtToken).balanceOf(receiver));
    }
}

// forge script script/Spoke/Fuji/Getter/GetterFuji.s.sol:GetterFuji --account defaultKey --sender $WALLET_ADDRESS --rpc-url $FUJI_RPC_URL -vvv