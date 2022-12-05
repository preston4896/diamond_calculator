// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./diamond/Diamond.sol";

contract DiamondCalculator is Diamond {
    uint256 private _currentNumber;

    constructor(IDiamondCut.FacetCut[] memory _diamondCut, DiamondArgs memory _args)
        payable
        Diamond(_diamondCut, _args)
    {}
}
