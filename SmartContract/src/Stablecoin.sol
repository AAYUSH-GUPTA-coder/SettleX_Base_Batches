// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Stablecoin
 * @author Aayush Gupta
 * @notice ERC20 token contract for stablecoin
 */
contract Stablecoin is ERC20 {
    /// @param name_ the name of the token
    /// @param symbol_ the symbol of the token
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /**
     * @notice mint new tokens to a given address
     * @param to_ the recipient address
     * @param amount_ the number of tokens to mint (in wei)
     */
    function mint(address to_, uint256 amount_) external {
        _mint(to_, amount_);
    }

    /**
     * @notice returns the number of decimals for the token
     * @return the number of decimals
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
