// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

contract AddSubtractFacet {
    /// @notice Adds X to the current number in the Diamond storage
    function addNumber(uint256 x) external returns (uint256) {
        uint256 num;
        assembly {
            num := sload(0)
        }
        num += x;
        assembly {
            sstore(0, num)
        }
        return num;
    }

    /// @notice Subtracts X to the current number in the Diamond storage
    function subtractNumber(uint256 x) external returns (uint256) {
        uint256 num;
        assembly {
            num := sload(0)
        }
        num -= x;
        assembly {
            sstore(0, num)
        }
        return num;
    }
}
