
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

contract MultiplyDivideFacet {
    /// @notice Multiplies X to the current number in the Diamond storage
    function multiplyNumber(uint256 x) external returns (uint256) {
        uint256 num;
        assembly {
            num := sload(0)
        }
        num *= x;
        assembly {
            sstore(0, num)
        }
        return num;
    }

    /// @notice Divides X to the current number in the Diamond storage
    function divideNumber(uint256 x) external returns (uint256) {
        uint256 num;
        assembly {
            num := sload(0)
        }
        num /= x;
        assembly {
            sstore(0, num)
        }
        return num;
    }
}