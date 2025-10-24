// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ConceroClient} from "@concero/contracts/ConceroClient/ConceroClient.sol";
import {IConceroRouter} from "@concero/contracts/interfaces/IConceroRouter.sol";
import {ConceroTypes} from "@concero/contracts/ConceroClient/ConceroTypes.sol";

/**
 * @title Spoke
 * @author Aayush Gupta
 * @notice Handles the operations related to a spoke contracts in SettleX.
 * Manages token transfers, whitelisting of addresses, and interaction with the hub and destination spoke contracts.
 * Ensures secure and efficient cross-chain transactions by verifying addresses and handling messages from the hub and spoke contracts.
 */
contract Spoke is ConceroClient {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error Spoke__OnlyOwner();
    error Spoke__InsufficientBalance();
    error Spoke__TransferEthBalanceFailed();
    error Spoke__NotWhitelisted();
    error Spoke__AddressIsZero();
    error Spoke__StoredTransactionDetailsLengthIsZero();
    error Spoke__InvalidStatus(uint256 status);
    error Spoke__NotWhitelistedChainAndContract();
    error Spoke__StoredTransactionSettlementLengthIsZero();
    error Spoke__CallExecuteFailed(bytes message);

    /*//////////////////////////////////////////////////////////////
                             STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @notice Concero Router
    IConceroRouter public immutable CONCERO_ROUTER;

    uint24 private _hubChainSelector; // Chain Selector for hub chain
    uint24 private _sourceChainSelector; // Chain Selector for source chain
    address private _owner; // address of the owner
    address private _hubAddress; // address of the hub contract deployed on Hub chain
    address private _poolAddr; // Token Pool Addr

    /*//////////////////////////////////////////////////////////////
                             STRUCT
    //////////////////////////////////////////////////////////////*/

    /// @notice Struct to store the cross chain transfer details
    struct CrossChainTransfer {
        uint24 sourceChainSelector; // Chain Selector for source chain
        uint24 destinationChainSelector; // Chain Selector for destination chain
        uint24 protocolTokenId; // Protocol ID of fungible token
        address receiver; // Address of the receiver on destination chain
        uint256 amount; // Amount of fungible token
    }

    /// @notice Struct to store the cross chain transfer details for each token
    struct TransferDetail {
        uint24 protocolTokenId; // Protocol ID of fungible token
        uint24 sourceChainSelector; // Chain Selector for source chain
        uint24 destinationChainSelector; // Chain Selector for destination chain
        uint256 amount; // Amount of fungible token
    }

    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a cross-chain transfer is added
    event TransactionAdded(
        uint24 indexed sourceChainSelector,
        uint24 indexed destinationChainSelector,
        uint24 indexed protocolTokenId,
        address receiver,
        uint256 amount
    );

    /// @notice Emitted when a cross-chain transfer messages bridged to Hub chain
    event CallTransferDetails(uint24 indexed hubChainSelector, address indexed hubAddress, bytes message);

    /// @notice Emitted when a cross-chain transfer messages bridged to destination Spoke chain
    event CallBridgeExtraTokens(uint24 indexed destinationSpokeId, address indexed destinationPoolAddr, bytes message);

    /// @notice Emitted when a cross-chain transfer messages bridged to destination Spoke chain
    event CallSettlement(uint24 indexed destinationChainSelector, address indexed destinationSpokeAddr, bytes message);

    /// @notice Emitted when pool address on the same chain is updated
    event UpdatePoolAddr(address indexed poolAddr);

    /// @notice Emitted when a address is whitelisted
    event UpdateWhitelist(address indexed whitelistAddr, bool indexed status);

    /// @notice Emitted when new protocol token is set
    event ProtocolToOriginalSet(uint24 indexed protocolTokenId, address indexed originalToken);

    /// @notice Emitted when hub chain ID is updated
    event UpdateHubChainSelector(uint24 indexed hubChainSelector);

    /// @notice Emitted when hub contract is updated
    event UpdateHubContract(address indexed hubContract);

    /// @notice Emitted when owner address is updated
    event OwnerAddressUpdated(address indexed newOwnerAddress);

    /// @notice Emitted when source chain ID is updated
    event UpdateSourceChainSelector(uint24 indexed sourceChainSelector);

    /// @notice Emitted when destination pool contract is updated
    event UpdateDestinationPoolContract(
        uint24 indexed destinationchainSelector, address indexed destinationPoolContract
    );

    /// @notice Emitted when destination spoke contract is updated
    event UpdateDestinationSpokeContracts(
        uint24 indexed destinationchainSelector, address indexed destinationSpokeContract
    );

    /*//////////////////////////////////////////////////////////////
                                 ARRAY
    //////////////////////////////////////////////////////////////*/

    /// @notice Array that stores all submitted transactions, valid for message Transfer to hub
    TransferDetail[] private _storedTransactionDetails;

    /// @notice Array that stores all submitted transactions
    /// @dev it will act as a helper for _storedTransactionsSettlement array
    CrossChainTransfer[] private _storedTransactionsData;

    /// @notice Array that stores all submitted transactions, valid for message Settlement to destination spoke chain
    CrossChainTransfer[] private _storedTransactionsSettlement;

    /*//////////////////////////////////////////////////////////////
                                MAPPING
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping to store the protocol token ID for each original token
    mapping(address originalTokenAddr => uint24 protocolTokenId) private _originalToProtocol;

    /// @notice Mapping to store the original token address for each protocol token
    mapping(uint24 protocolTokenId => address originalTokenAddr) private _protocolToOriginal;

    /// @notice Mapping of whitelisted addresses allowed to call callTransferDetails
    mapping(address whitelistAddress => bool whitelistStatus) private _whitelist;

    /// @notice Mapping to store the destination pool contract for each chain
    mapping(uint24 dstChainSelector => address dstPoolContract) private _destinationPoolContracts;

    /// @notice Mapping to store the destination spoke contract for each chain
    mapping(uint24 dstChainSelector => address dstSpokeContract) private _destinationSpokeContracts;

    /// @notice Mapping to store the approved spoke contracts
    mapping(address => bool) private _isApprovedSpokeContract;

    /// @notice Mapping to store the approved chain selectors
    mapping(uint24 => bool) private _isApprovedChainSelector;

    /*//////////////////////////////////////////////////////////////
                                MODIFIER
    //////////////////////////////////////////////////////////////*/

    /// @notice Modifier to check if the caller is the owner
    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert Spoke__OnlyOwner();
        }
        _;
    }

    /// @notice Restricts function calls to whitelisted addresses.
    modifier onlyWhitelisted() {
        if (!_whitelist[msg.sender]) revert Spoke__NotWhitelisted();
        _;
    }

    /// @notice checks if the address is zero
    modifier checkZero(address addressToCheck_) {
        if (addressToCheck_ == address(0)) revert Spoke__AddressIsZero();
        _;
    }

    /// @notice checks if the _storedTransactionDetails array is empty
    modifier checkStoredTransactionDetailsLength() {
        if (_storedTransactionDetails.length == 0) revert Spoke__StoredTransactionDetailsLengthIsZero();
        _;
    }

    /// @notice checks if the _storedTransactionsSettlement array is empty
    modifier checkStoredTransactionSettlementLength() {
        if (_storedTransactionsSettlement.length == 0) revert Spoke__StoredTransactionSettlementLengthIsZero();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        uint24 hubChainSelector_,
        uint24 sourceChainSelector_,
        address hubAddress_,
        address owner_,
        address conceroRouter_
    ) ConceroClient(conceroRouter_) checkZero(hubAddress_) checkZero(owner_) {
        _hubChainSelector = hubChainSelector_;
        _sourceChainSelector = sourceChainSelector_;
        _hubAddress = hubAddress_;
        _owner = owner_;
        _whitelist[owner_] = true;
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
        if (address(this).balance < amount_) revert Spoke__InsufficientBalance();
        (bool success,) = receiver_.call{value: amount_}("");
        if (!success) revert Spoke__TransferEthBalanceFailed();
    }

    /**
     * @notice Updates the owner address
     * @param owner_ new owner address
     */
    function updateOwner(address owner_) external onlyOwner checkZero(owner_) {
        emit OwnerAddressUpdated(owner_);
        _owner = owner_;
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
     * @notice Updates the pool address
     * @param poolAddr_ new pool address
     */
    function updatePoolAddr(address poolAddr_) external onlyOwner checkZero(poolAddr_) {
        emit UpdatePoolAddr(poolAddr_);
        _poolAddr = poolAddr_;
    }

    /**
     * @notice Updates the trusted status of a hub contract for a given chain Selector.
     * @param hubChainSelector_ chain Selector of the hub contract
     * @param hubContract_ hub contract address
     */
    function updateTrustedHubContracts(uint24 hubChainSelector_, address hubContract_)
        external
        onlyWhitelisted
        checkZero(hubContract_)
    {
        emit UpdateHubChainSelector(hubChainSelector_);
        _hubChainSelector = hubChainSelector_;
        emit UpdateHubContract(hubContract_);
        _hubAddress = hubContract_;
    }

    /**
     * @notice Updates the source chain ID
     * @param sourceChainSelector_ new source chain ID
     */
    function updateSourceChainSelector(uint24 sourceChainSelector_) external onlyWhitelisted {
        emit UpdateSourceChainSelector(sourceChainSelector_);
        _sourceChainSelector = sourceChainSelector_;
    }

    /**
     * @notice Updates the destination pool contract address
     * @param dstChainSelector_ Chain Selector of the destination chain
     * @param dstPoolContract_ new destination pool contract address
     */
    function updateDestinationPoolContract(uint24 dstChainSelector_, address dstPoolContract_)
        external
        onlyWhitelisted
        checkZero(dstPoolContract_)
    {
        emit UpdateDestinationPoolContract(dstChainSelector_, dstPoolContract_);
        _destinationPoolContracts[dstChainSelector_] = dstPoolContract_;
    }

    /**
     * @notice Updates the destination spoke contract address
     * @param dstChainSelector_ Chain Selector of the destination chain
     * @param dstSpokeContract_ new destination spoke contract address
     */
    function updateDestinationSpokeContracts(
        uint24 dstChainSelector_,
        address dstSpokeContract_,
        bool contractValue_,
        bool chainSelectorValue_
    ) external onlyWhitelisted checkZero(dstSpokeContract_) {
        emit UpdateDestinationSpokeContracts(dstChainSelector_, dstSpokeContract_);
        _destinationSpokeContracts[dstChainSelector_] = dstSpokeContract_;
        _isApprovedSpokeContract[dstSpokeContract_] = contractValue_;
        _isApprovedChainSelector[dstChainSelector_] = chainSelectorValue_;
    }

    /**
     * @notice Sets the original token for a protocol token and protocol token for an original token
     * @param originalToken_ The original token address
     * @param protocolTokenId_ The protocol token ID
     */
    function setProtocolToken(address originalToken_, uint24 protocolTokenId_)
        external
        onlyWhitelisted
        checkZero(originalToken_)
    {
        emit ProtocolToOriginalSet(protocolTokenId_, originalToken_);
        _protocolToOriginal[protocolTokenId_] = originalToken_;
        _originalToProtocol[originalToken_] = protocolTokenId_;
    }

    /**
     * @notice Creates a new cross-chain transfer
     * @param transaction_ the cross-chain transfer to create
     */
    function createTransaction(CrossChainTransfer calldata transaction_) external {
        // transfer the token to the spoke contract
        IERC20(_protocolToOriginal[transaction_.protocolTokenId])
            .safeTransferFrom(msg.sender, address(this), transaction_.amount);

        // Create a new TransferDetail using relevant fields from the CrossChainTransfer
        _storedTransactionDetails.push(
            TransferDetail({
                protocolTokenId: transaction_.protocolTokenId,
                sourceChainSelector: transaction_.sourceChainSelector,
                destinationChainSelector: transaction_.destinationChainSelector,
                amount: transaction_.amount
            })
        );

        // push the transaction to the _storedTransactionsData array
        _storedTransactionsData.push(transaction_);

        // emit the event
        emit TransactionAdded(
            transaction_.sourceChainSelector,
            transaction_.destinationChainSelector,
            transaction_.protocolTokenId,
            transaction_.receiver,
            transaction_.amount
        );
    }

    /**
     * @notice Sends the stored transaction details to the hub contract
     * @dev This function is called by the owner and whitelisted addresses to send the stored transaction details to the hub contract
     */
    function callTransferDetails(uint256 gasLimit_)
        external
        payable
        onlyWhitelisted
        checkStoredTransactionDetailsLength
    {
        // 1. Prepare destination chain data
        ConceroTypes.EvmDstChainData memory dstData = ConceroTypes.EvmDstChainData({
            receiver: _hubAddress, // Contract address of the hub contract
            gasLimit: gasLimit_ // Gas limit for your contract on destination chain
        });

        // 2. Calculate message fee
        uint256 messageFeeNative = CONCERO_ROUTER.getMessageFee(
            _hubChainSelector, // Hub chain selector
            false, // IsSrcFinalityRequired: Not yet supported, leave as false
            address(0), // FeeToken: Use native value
            dstData // Destination chain data
        );

        // 3. encode the function call with the stored transaction details
        bytes memory message =
            abi.encodeWithSignature("addTransactions((uint24,uint24,uint24,uint256)[])", _storedTransactionDetails);

        emit CallTransferDetails(_hubChainSelector, _hubAddress, message);

        // 4. iterate and copy each transaction
        uint256 len = _storedTransactionsData.length;
        for (uint256 i = 0; i < len;) {
            _storedTransactionsSettlement.push(_storedTransactionsData[i]);

            unchecked {
                ++i;
            }
        }

        // 5. Clear out the storage array
        delete _storedTransactionDetails;
        delete _storedTransactionsData;

        // 6. Send the cross-chain message to hub contract on hub chain
        bytes32 messageId = CONCERO_ROUTER.conceroSend{
            value: messageFeeNative
        }(
            _hubChainSelector, // uint24 dstChainSelector: hub chain selector
            false, // bool shouldFinaliseSrc: not yet supported
            address(0), // address feeToken: use native token
            dstData, // ConceroTypes.EvmDstChainData
            message // The bytes data to send to hub contract
        );
    }

    /**
     * @notice Concero receive function
     * @param messageId_ message id
     * @param srcChainSelector_ source chain selector
     * @param sender_ sender address
     * @param message_ message data
     */
    function _conceroReceive(
        bytes32 messageId_,
        uint24 srcChainSelector_,
        bytes calldata sender_,
        bytes calldata message_
    ) internal override {
        // 1. Decode the sender bytes into an address (for EVM chains)
        address senderAddress = abi.decode(sender_, (address));

        // 2. Check if the sender (hub contract) is approved
        if (_hubAddress != senderAddress && !_isApprovedSpokeContract[senderAddress]) {
            revert Spoke__NotWhitelistedChainAndContract();
        }

        // 3. Check if the hub chain selector is approved
        if (_hubChainSelector != srcChainSelector_ && !_isApprovedChainSelector[srcChainSelector_]) {
            revert Spoke__NotWhitelistedChainAndContract();
        }

        // 4. Call the target function
        (bool success,) = address(this).call(message_);
        if (!success) revert Spoke__CallExecuteFailed(message_);
    }

    /**
     * @notice Function to bridge the message to POOL contract on destination spoke chain
     * @dev Only valid for TESTNET / MVP
     * @param token_ the protocol ID of the token
     * @param dstSpokeChainSelector_ the destination spoke chain selector
     * @param to_ address of the spoke contract on destination chain
     * @param amount_ the amount of token to transfer
     */
    function bridgeExtraTokens(
        uint24 token_,
        uint24 dstSpokeChainSelector_,
        address to_,
        uint256 amount_,
        uint256 gasLimit_
    ) external returns (bytes memory) {
        // encode the function call with the transferToken details
        bytes memory message = abi.encodeWithSignature("transferToken(uint24,address,uint256)", token_, to_, amount_);

        // transfer the extra token to the pool contract
        IERC20(_protocolToOriginal[token_]).safeTransfer(_poolAddr, amount_);

        emit CallBridgeExtraTokens(dstSpokeChainSelector_, _destinationPoolContracts[dstSpokeChainSelector_], message);

        // Prepare destination chain data
        ConceroTypes.EvmDstChainData memory dstData = ConceroTypes.EvmDstChainData({
            receiver: _destinationPoolContracts[dstSpokeChainSelector_], // Contract address of the destination Pool contract
            gasLimit: gasLimit_ // Gas limit for your contract on destination chain
        });

        // Calculate message fee
        uint256 messageFeeNative = CONCERO_ROUTER.getMessageFee(
            dstSpokeChainSelector_, // Destination chain selector
            false, // IsSrcFinalityRequired: Not yet supported, leave as false
            address(0), // FeeToken: Use native value
            dstData // Destination chain data
        );

        return message;
    }

    /**
     * @notice Function to bridge the settlement to destination spoke contract on destination spoke chain
     * @dev Only valid for TESTNET / MVP
     * TODO  NEED TO TEST IT
     */
    function bridgeSettlement(uint256 gasLimit_)
        external
        payable
        onlyWhitelisted
        checkStoredTransactionSettlementLength
    {
        uint256 len = _storedTransactionsSettlement.length;
        for (uint256 i = 0; i < len;) {
            uint24 destinationSpokeChainSelector = _storedTransactionsSettlement[i].destinationChainSelector;
            address destinationSpokeAddress = _destinationSpokeContracts[destinationSpokeChainSelector];

            uint256 destinationCount;

            // allocate memory array of the exact size
            CrossChainTransfer[] memory settlementData = new CrossChainTransfer[](destinationCount);
            destinationCount = 0;
            uint256 settlementIndex;
            settlementIndex = 0;

            // encode the function call with the stored transaction details
            bytes memory message =
                abi.encodeWithSignature("settlement((uint24,uint24,uint24,address,uint256)[])", settlementData);

            emit CallSettlement(destinationSpokeChainSelector, destinationSpokeAddress, message);

            // Prepare destination chain data
            ConceroTypes.EvmDstChainData memory dstData = ConceroTypes.EvmDstChainData({
                receiver: destinationSpokeAddress, // Contract address of the destination spoke Address
                gasLimit: gasLimit_ // Gas limit for your contract on destination chain
            });

            // Calculate message fee
            uint256 messageFeeNative = CONCERO_ROUTER.getMessageFee(
                destinationSpokeChainSelector, // Destination chain selector
                false, // IsSrcFinalityRequired: Not yet supported, leave as false
                address(0), // FeeToken: Use native value
                dstData // Destination chain data
            );

            // Send the cross-chain message to destination spoke contract on destination spoke chain
            bytes32 messageId = CONCERO_ROUTER.conceroSend{
                value: messageFeeNative
            }(
                destinationSpokeChainSelector, // uint24 dstChainSelector: destination spoke chain selector
                false, // bool shouldFinaliseSrc: not yet supported
                address(0), // address feeToken: use native token
                dstData, // ConceroTypes.EvmDstChainData
                message // The bytes data to send to destination spoke contract
            );

            unchecked {
                ++i;
            }
        }

        // Clear out the storage array
        delete _storedTransactionsSettlement;
    }

    /**
     * @notice function to transfer the token to the receiver
     * @param settlement_ the settlement data
     * TODO: make this function private
     */
    function settlement(CrossChainTransfer[] calldata settlement_) external {
        uint256 len = settlement_.length;
        for (uint256 i = 0; i < len;) {
            IERC20(_protocolToOriginal[settlement_[i].protocolTokenId])
                .safeTransfer(settlement_[i].receiver, settlement_[i].amount);
            unchecked {
                ++i;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                           VIEW AND PURE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the hub domain.
    function getHubChainSelector() external view returns (uint24) {
        return _hubChainSelector;
    }

    /// @notice Returns the hub address in bytes32
    function getHubAddress() external view returns (address) {
        return _hubAddress;
    }

    /// @notice Returns the owner of the contract
    function getOwner() external view returns (address) {
        return _owner;
    }

    /// @notice Returns the pool address on the same chain
    function getPoolAddr() external view returns (address) {
        return _poolAddr;
    }

    /**
     * @notice Returns the whitelist status of an address
     * @param addr_ The address to check
     */
    function checkWhitelistAddr(address addr_) external view returns (bool) {
        return _whitelist[addr_];
    }

    /**
     * @notice Returns the protocol token ID for a original token
     * @param originalToken_ The original token address
     */
    function checkOriginalToProtocol(address originalToken_) external view returns (uint24) {
        return _originalToProtocol[originalToken_];
    }

    /**
     * @notice Returns the original token for a protocol token
     * @param protocolTokenId_ The protocol token ID
     */
    function checkProtocolToOriginal(uint24 protocolTokenId_) external view returns (address) {
        return _protocolToOriginal[protocolTokenId_];
    }

    /// @notice Returns the source chain selector
    function getSourceChainSelector() external view returns (uint24) {
        return _sourceChainSelector;
    }

    /// @notice Returns the stored transaction details
    function getStoredTransactionDetails() external view returns (TransferDetail[] memory) {
        return _storedTransactionDetails;
    }

    /// @notice Returns the stored transaction details by id
    function getStoredTransactionDetailsId(uint256 id_) external view returns (TransferDetail memory) {
        return _storedTransactionDetails[id_];
    }

    /// @notice Returns the length of the stored transaction details array
    function getStoredTransactionDetailsLength() external view returns (uint256) {
        return _storedTransactionDetails.length;
    }

    /**
     * @notice Returns the destination pool contract for a chain
     * @param chainSelector_ The chain selector of the destination pool contract
     */
    function getDestinationPoolContract(uint24 chainSelector_) external view returns (address) {
        return _destinationPoolContracts[chainSelector_];
    }

    /// @notice Returns the stored transactions data
    function getStoredTransactionsData() external view returns (CrossChainTransfer[] memory) {
        return _storedTransactionsData;
    }

    /**
     * @notice Returns the stored transactions data by id
     * @param id_ The id of the _storedTransactionsData item
     */
    function getStoredTransactionsDataId(uint256 id_) external view returns (CrossChainTransfer memory) {
        return _storedTransactionsData[id_];
    }

    /// @notice Returns the length of the stored transactions data array
    function getStoredTransactionsDataLength() external view returns (uint256) {
        return _storedTransactionsData.length;
    }

    /// @notice Returns the stored transactions settlement
    function getStoredTransactionsSettlement() external view returns (CrossChainTransfer[] memory) {
        return _storedTransactionsSettlement;
    }

    /// @notice Returns the length of the stored transactions settlement array
    function getStoredTransactionsSettlementLength() external view returns (uint256) {
        return _storedTransactionsSettlement.length;
    }

    /**
     * @notice Returns the stored transactions settlement by id
     * @param id_ The id of the _storedTransactionsSettlement item
     */
    function getStoredTransactionsSettlementId(uint256 id_) external view returns (CrossChainTransfer memory) {
        return _storedTransactionsSettlement[id_];
    }

    /**
     * @notice Returns the destination spoke contract address for the chain selector
     * @param chainSelector_ The chain selector of the destination spoke contract
     */
    function getDestinationSpokeContracts(uint24 chainSelector_) external view returns (address) {
        return _destinationSpokeContracts[chainSelector_];
    }

    /**
     * @notice Returns the approval status of a spoke contract
     * @param spokeContract_ The spoke contract address
     */
    function getIsApprovedSpokeContract(address spokeContract_) external view returns (bool) {
        return _isApprovedSpokeContract[spokeContract_];
    }

    /**
     * @notice Returns the approval status of a chain selector
     * @param chainSelector_ The chain selector
     */
    function getIsApprovedChainSelector(uint24 chainSelector_) external view returns (bool) {
        return _isApprovedChainSelector[chainSelector_];
    }
}
