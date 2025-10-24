// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ConceroClient} from "@concero/contracts/ConceroClient/ConceroClient.sol";

/**
 * @title TokenPool
 * @author Aayush Gupta
 * @notice Manages operations for the token pool.
 * Handles token transfers, address whitelisting, and communication between the spoke, and pool contracts.
 * Ensures secure and efficient cross-chain transactions through address verification and controlled message handling.
 */
contract TokenPool is ConceroClient {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error TokenPool__OnlyOwner();
    error TokenPool__AddressIsZero();
    error TokenPool__NotWhitelistedSpokeChainAndContract();
    error TokenPool__NotWhitelisted();
    error TokenPool__CallExecuteFailed(bytes _message);
    error TokenPool__InsufficientBalance();
    error TokenPool__TransferEthBalanceFailed();

    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/
    address private _owner; // address of the owner

    /*//////////////////////////////////////////////////////////////
                                MAPPING
    //////////////////////////////////////////////////////////////*/
    /// @notice Mapping to store the protocol token ID for each original token address
    mapping(address originalTokenAddr => uint24 protocolTokenId) private _originalToProtocol;

    /// @notice Mapping to store the original token address for each protocol token
    mapping(uint24 protocolTokenId => address originalTokenAddr) private _protocolToOriginal;

    /// @notice Mapping of whitelisted addresses allowed to call callTransferDetails.
    mapping(address whitelistAddress => bool whitelistStatus) private _whitelist;

    mapping(uint24 spokeChainSelector => mapping(address spokeContractAddr => bool spokeStatus)) private
        _whitelistedSpokeContracts;

    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a token is transferred
    event Transfer(address token, address receiver, uint256 amount);

    /// @notice Emitted when a token is withdrawn
    event Withdraw(address token, address receiver, uint256 amount);

    /// @notice Emitted when new protocol token is set
    event ProtocolToOriginalSet(uint24 indexed protocolTokenId, address indexed originalToken);

    /// @notice Emitted when a address is whitelisted
    event UpdateWhitelist(address indexed whitelistAddr, bool indexed status);

    /// @notice Emitted when the owner address is updated
    event OwnerAddressUpdated(address indexed newOwnerAddress);

    /// @notice Emitted when the owner address is updated
    event UpdateOwner(address indexed newOwnerAddress);

    /// @notice Emitted when the whitelisted spoke contracts are updated
    event UpdateWhitelistedSpokeContracts(
        uint24 indexed spokeChainSelector, address indexed spokeContractAddr, bool indexed status
    );

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Restricts function calls to the contract owner
    modifier onlyOwner() {
        if (msg.sender != _owner) revert TokenPool__OnlyOwner();
        _;
    }

    /**
     * @notice Restricts function calls to non-zero addresses
     * @param addr_ The address to check
     */
    modifier checkZero(address addr_) {
        if (addr_ == address(0)) revert TokenPool__AddressIsZero();
        _;
    }

    /// @notice Restricts function calls to whitelisted addresses.
    modifier onlyWhitelisted() {
        if (!_whitelist[msg.sender]) revert TokenPool__NotWhitelisted();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               Constructor
    //////////////////////////////////////////////////////////////*/

    constructor(address owner_, address conceroRouter_) ConceroClient(conceroRouter_) {
        _owner = owner_;
        _whitelist[owner_] = true;
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
        if (address(this).balance < amount_) revert TokenPool__InsufficientBalance();
        (bool success,) = receiver_.call{value: amount_}("");
        if (!success) revert TokenPool__TransferEthBalanceFailed();
    }

    /**
     * @notice Updates the owner address
     * @param owner_ The new owner address
     */
    function updateOwner(address owner_) external onlyOwner checkZero(owner_) {
        emit UpdateOwner(owner_);
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

    function _conceroReceive(
        bytes32 messageId_,
        uint24 srcChainSelector_,
        bytes calldata sender_,
        bytes calldata message_
    ) internal override {
        // 1. Decode the sender bytes into an address (for EVM chains)
        address senderAddress = abi.decode(sender_, (address));

        // 2. Check if the sender (spoke contract and spoke chain selector) is approved
        if (!_whitelistedSpokeContracts[srcChainSelector_][senderAddress]) {
            revert TokenPool__NotWhitelistedSpokeChainAndContract();
        }

        // 3. Call the target function
        (bool success,) = address(this).call(message_);
        if (!success) revert TokenPool__CallExecuteFailed(message_);
    }

    /**
     * @notice Transfering tokens
     * @param token_ address of the token
     * @param to_ address of the spoke contract
     * @param amount_ the number of tokens to send
     */
    function transferToken(uint24 token_, address to_, uint256 amount_) external checkZero(to_) {
        address token = _protocolToOriginal[token_];
        emit Transfer(token, to_, amount_);
        IERC20(token).safeTransfer(to_, amount_);
    }

    /**
     * @notice Withdraws tokens from the contract
     * @param token_ address of the token
     * @param to_ address of the reciever
     * @param amount_ the number of tokens to send
     */
    function withdraw(uint24 token_, address to_, uint256 amount_) external onlyOwner checkZero(to_) {
        address token = _protocolToOriginal[token_];
        emit Withdraw(token, to_, amount_);
        IERC20(token).safeTransfer(to_, amount_);
    }

    /*//////////////////////////////////////////////////////////////
                           VIEW & PURE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the owner of the contract
    function getOwner() external view returns (address) {
        return _owner;
    }

    /// @notice Returns the whitelist status of an address
    function getWhitelist(address _addr) external view returns (bool) {
        return _whitelist[_addr];
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

    function getWhitelistedSpokeContracts(uint24 spokeChainSelector_, address spokeContractAddr_)
        external
        view
        returns (bool)
    {
        return _whitelistedSpokeContracts[spokeChainSelector_][spokeContractAddr_];
    }
}
