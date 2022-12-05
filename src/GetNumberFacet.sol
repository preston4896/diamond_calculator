// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

contract GetNumberFacet {
    /// @notice Reads the current number from the Diamond storage
    function getNumber() external view returns (uint256 num) {
        assembly {
            num := sload(0)
        }
    }
}
