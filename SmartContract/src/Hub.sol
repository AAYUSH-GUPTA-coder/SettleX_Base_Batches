// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import {ConceroClient} from "@concero/contracts/ConceroClient/ConceroClient.sol";
import {IConceroRouter} from "@concero/contracts/interfaces/IConceroRouter.sol";
import {ConceroTypes} from "@concero/contracts/ConceroClient/ConceroTypes.sol";

/**
 * @title Hub
 * @author Aayush Gupta
 * @notice Handles the operations related to a hub in SettleX.
 * Manages token transfers, whitelisting of addresses, and interaction with the spoke.
 * Ensures secure and efficient cross-chain transactions by verifying addresses and handling messages from the spoke.
 */
contract Hub is ConceroClient {
    /*//////////////////////////////////////////////////////////////
                                 ERROR
    //////////////////////////////////////////////////////////////*/
    error Hub__NotWhitelisted();
    error Hub__NotOwner();
    error Hub__NoTransactions();
    error Hub__AddressIsZero();
    error Hub__NotWhitelistedChainAndContract();
    error Hub__CallExecuteFailed();
    error Hub__InsufficientBalance();
    error Hub__EthTransferFailed();

    /*//////////////////////////////////////////////////////////////
                               STRUCTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Represents a transaction involving a specific token.
    struct MultiTokenTransaction {
        uint24 protocolTokenId; // protocol token ID
        uint24 from; // Sender
        uint24 to; // Receiver
        uint256 amount; // Token amount
    }

    /// @notice Represents a settlement result where a debtor pays a creditor in a specific token.
    struct Settlement {
        uint24 protocolTokenId; // protocol token ID
        uint24 from; // Debtor
        uint24 to; // Creditor
        uint256 amount; // amount of token
    }

    /// @notice Used to track a participant’s net position.
    struct Participant {
        uint24 chainSelector; // Chain Selector
        int256 net; // Net position
    }

    /*//////////////////////////////////////////////////////////////
                               ARRAY
    //////////////////////////////////////////////////////////////*/
    /// @notice Array that stores all submitted transactions.
    MultiTokenTransaction[] private _storedTransactions;

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Concero Router
    IConceroRouter public immutable CONCERO_ROUTER;

    /// @notice Owner of the contract.
    address private _owner;

    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/

    event UpdateWhitelist(address indexed addr, bool indexed status);
    event TransactionAdded(uint24 indexed protocolTokenId, uint24 indexed from, uint24 indexed to, uint256 amount);
    event SettlementExecuted(
        uint24 indexed protocolTokenId, uint24 indexed fromChain, uint24 indexed toChain, uint256 amount
    );
    event OwnerAddressUpdated(address indexed newOwnerAddress);
    event CallBridgeExtraTokens(uint24 indexed spokeChainSelector, address indexed spokeAddress, bytes message);
    event UpdateSpokeContract(uint24 indexed chainSelector, address indexed spokeContract);

    /*//////////////////////////////////////////////////////////////
                                MAPPING
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping of whitelisted addresses allowed to call executeNetting.
    mapping(address user => bool value) private _whitelist;

    /// @notice Mapping of chain selectors to their corresponding spoke contracts.
    mapping(uint24 chainSelector => address spokeContract) private _chainSelectorToSpokeContract;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Restricts function calls to whitelisted addresses.
    modifier onlyWhitelisted() {
        if (!_whitelist[msg.sender]) revert Hub__NotWhitelisted();
        _;
    }

    /// @notice Restricts function calls to the contract owner.
    modifier onlyOwner() {
        if (msg.sender != _owner) revert Hub__NotOwner();
        _;
    }

    /// @notice Restricts function calls to non-zero addresses
    modifier checkZero(address addressToCheck_) {
        if (addressToCheck_ == address(0)) revert Hub__AddressIsZero();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address owner_, address conceroRouter_) ConceroClient(conceroRouter_) checkZero(owner_) {
        _owner = owner_;
        _whitelist[_owner] = true;
        CONCERO_ROUTER = IConceroRouter(conceroRouter_);
    }

    /*//////////////////////////////////////////////////////////////
                                FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Fallback function must be declared as external.
    fallback() external payable {}

    // Receive is a variant of fallback that is triggered when msg.data is empty
    receive() external payable {}

    /**
     * @notice Send a specific amount of ETH from this contract to `receiver` address
     * @param receiver_ address to send the ETH to
     * @param amount_ amount of ETH to send
     */
    function transferEth(address payable receiver_, uint256 amount_) external onlyOwner {
        if (address(this).balance < amount_) revert Hub__InsufficientBalance();
        (bool success,) = receiver_.call{value: amount_}("");
        if (!success) revert Hub__EthTransferFailed();
    }

    /**
     * @notice Updates the owner address.
     * @param newOwner_ new owner address
     */
    function updateOwner(address newOwner_) external onlyOwner checkZero(newOwner_) {
        emit OwnerAddressUpdated(newOwner_);
        _owner = newOwner_;
    }

    /**
     * @notice Updates the whitelist status of an address.
     * @param addr_ address to whitelist
     * @param status_ new status
     */
    function updateWhitelist(address addr_, bool status_) external onlyOwner checkZero(addr_) {
        emit UpdateWhitelist(addr_, status_);
        _whitelist[addr_] = status_;
    }

    /**
     * @notice Updates the spoke contract address for a given chain ID.
     * @param chainSelector_ chain selector of the spoke contract
     * @param spokeContract_ new spoke contract address
     */
    function updateSpokeContract(uint24 chainSelector_, address spokeContract_) external onlyOwner {
        emit UpdateSpokeContract(chainSelector_, spokeContract_);
        _chainSelectorToSpokeContract[chainSelector_] = spokeContract_;
    }

    /**
     * @notice This function is called by the spoke contract from spoke chain.
     * @param messageId_ The unique identifier of the cross-chain message being executed
     * @param srcChainSelector_ The chain selector of the source chain from which the message originated
     * @param sender_ The address on the source chain that sent the message
     * @param message_ message payload
     */
    function _conceroReceive(
        bytes32 messageId_,
        uint24 srcChainSelector_,
        bytes calldata sender_,
        bytes calldata message_
    ) internal override {
        // 1. Decode the sender bytes into an address (for EVM chains)
        address senderAddress = abi.decode(sender_, (address));

        // 2. Check if the sender (spoke contract) is approved
        if (_chainSelectorToSpokeContract[srcChainSelector_] != senderAddress) {
            revert Hub__NotWhitelistedChainAndContract();
        }

        // 3. Call the target function
        (bool success,) = address(this).call(message_);
        if (!success) revert Hub__CallExecuteFailed();
    }

    /**
     * @notice Adds multiple transactions to the _storedTransactions array.
     * @param transactions_ the transactions to add
     */
    function addTransactions(MultiTokenTransaction[] calldata transactions_) external {
        uint256 len = transactions_.length;
        for (uint256 i = 0; i < len;) {
            _storedTransactions.push(transactions_[i]);
            emit TransactionAdded(
                transactions_[i].protocolTokenId, transactions_[i].from, transactions_[i].to, transactions_[i].amount
            );
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Executes netting over all stored transactions.
     * @param gasLimit_ the gas limit for each transaction
     * @dev this will actually transfer the message cross-chain to spoke contracts.
     * Only callable by a whitelisted address.
     * After execution, stored transactions are cleared.
     * @return settlements An array of Settlement results.
     */
    function executeNetting(uint256 gasLimit_) external payable onlyWhitelisted returns (Settlement[] memory) {
        uint256 txCount = getStoredTransactionsLength();
        if (txCount == 0) revert Hub__NoTransactions();

        // Copy stored transactions from storage to memory.
        MultiTokenTransaction[] memory transactions = new MultiTokenTransaction[](txCount);
        for (uint256 i = 0; i < txCount;) {
            transactions[i] = _storedTransactions[i];
            unchecked {
                ++i;
            }
        }

        // Transfer debt message to spoke contracts.
        uint256 settlementLen = allSettlements.length;
        for (uint256 i = 0; i < settlementLen;) {
            // Emit events for each settlement
            emit SettlementExecuted(
                allSettlements[i].protocolTokenId,
                allSettlements[i].from,
                allSettlements[i].to,
                allSettlements[i].amount
            );
            if (allSettlements[i].amount > 0) {
                // get spokecontract address
                bytes memory message = abi.encodeWithSignature(
                    "bridgeExtraTokens(uint24,uint24,address,uint256,uint256)",
                    allSettlements[i].protocolTokenId,
                    allSettlements[i].to,
                    toSpokeContractAddr,
                    allSettlements[i].amount,
                    gasLimit_
                );

                // Emit event for settlement info
                emit CallBridgeExtraTokens(allSettlements[i].from, fromSpokeContract, message);

                // Send the message to the right spoke contract
                // Pay for gas using native currency for a contract call on a destination chain.

                // 1. Prepare destination chain data
                ConceroTypes.EvmDstChainData memory dstData = ConceroTypes.EvmDstChainData({
                    receiver: fromSpokeContract, // Contract address that will receive the message
                    gasLimit: gasLimit_ // Gas limit for your contract on destination chain
                });

                // 2. Calculate message fee
                uint256 messageFeeNative = CONCERO_ROUTER.getMessageFee(
                    allSettlements[i].from, // Destination chain selector
                    false, // IsSrcFinalityRequired: Not yet supported, leave as false
                    address(0), // FeeToken: Use native value
                    dstData // Destination chain data
                );

                // 3. Send the cross-chain message
                bytes32 messageId = CONCERO_ROUTER.conceroSend{value: messageFeeNative}(
                    allSettlements[i].from, //destination chain selector
                    false, // bool shouldFinaliseSrc: not yet supported
                    address(0), // address feeToken: use native token
                    dstData, // ConceroTypes.EvmDstChainData
                    message // The bytes data to send to your contract
                );
            }
            unchecked {
                ++i;
            }
        }
        return allSettlements;
    }

    /*//////////////////////////////////////////////////////////////
                         INTENTIONALLY REMOVED NETTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                         VIEW & PURE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the owner of the contract.
    function getOwner() external view returns (address) {
        return _owner;
    }

    /// @notice Returns the whitelist status of an address.
    function checkWhitelistAddr(address addr_) external view returns (bool) {
        return _whitelist[addr_];
    }

    /// @notice Returns the length of the stored transactions array.
    function getTransactionsLength() external view returns (uint256) {
        return _storedTransactions.length;
    }

    /// @notice Returns the spoke contract address for a given chain ID.
    function getSpokeAddr(uint24 chainSelector_) external view returns (address) {
        return _chainSelectorToSpokeContract[chainSelector_];
    }

    /// @notice Returns the entire array of stored transactions.
    function getStoredTransactions() external view returns (MultiTokenTransaction[] memory) {
        return _storedTransactions;
    }

    /**
     * @notice Returns a single transaction by its index.
     * @param index_ The index in the _storedTransactions array.
     */
    function getStoredTransactionsId(uint256 index_) external view returns (MultiTokenTransaction memory) {
        return _storedTransactions[index_];
    }

    /// @notice Returns the length of the stored transactions array.
    function getStoredTransactionsLength() public view returns (uint256) {
        return _storedTransactions.length;
    }
}
