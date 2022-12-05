// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

// interfaces
import "../src/diamond/interfaces/IDiamondCut.sol";
import "../src/diamond/Diamond.sol";

// Contracts to deploy
import "../src/diamond/facets/DiamondCutFacet.sol";
import "../src/diamond/facets/OwnershipFacet.sol";
import "../src/diamond/facets/DiamondLoupeFacet.sol";
import "../src/AddSubtractFacet.sol";
import "../src/MultiplyDivideFacet.sol";
import "../src/GetNumberFacet.sol";
import "../src/DiamondCalculator.sol";

contract CalculatorDiamondTest is Test {
    DiamondCutFacet public diamondCutFacet;
    DiamondCalculator public calculator;
    OwnershipFacet public ownershipFacet;
    AddSubtractFacet public addSubtractFacet;
    MultiplyDivideFacet public multiplyDivideFacet;
    GetNumberFacet public getNumberFacet;
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerKey);

    function setUp() public {
        vm.startPrank(deployer);
        diamondCutFacet = new DiamondCutFacet();
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = IDiamondCut.diamondCut.selector;
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = IDiamondCut.FacetCut(
            address(diamondCutFacet),
            IDiamondCut.FacetCutAction.Add,
            selectors
        );
        Diamond.DiamondArgs memory args =  Diamond.DiamondArgs(deployer);
        calculator = new DiamondCalculator(cuts, args);

        // deploy remaining facets
        ownershipFacet = new OwnershipFacet();
        addSubtractFacet = new AddSubtractFacet();
        multiplyDivideFacet = new MultiplyDivideFacet();
        getNumberFacet = new GetNumberFacet();

        vm.stopPrank();
    }

    function testOwnerFacet(address input) public {
        vm.assume(input != address(0));

        // add OwnershipFacet cut to the diamond
        DiamondCutFacet configureCutCalculator = DiamondCutFacet(address(calculator));
        OwnershipFacet configureOwnershipCalculator = OwnershipFacet(address(calculator));
        bytes4[] memory ownerSelectors = new bytes4[](2);
        ownerSelectors[0] = ownershipFacet.transferOwnership.selector;
        ownerSelectors[1] = ownershipFacet.owner.selector;
        IDiamondCut.FacetCut[] memory ownerCut = new IDiamondCut.FacetCut[](1);
        ownerCut[0] = IDiamondCut.FacetCut(
            address(ownershipFacet),
            IDiamondCut.FacetCutAction.Add,
            ownerSelectors
        );
        vm.startPrank(deployer);
        configureCutCalculator.diamondCut(ownerCut, address(0), "");

        // Transfer to new owner
        configureOwnershipCalculator.transferOwnership(input);
        vm.stopPrank();
        assertEq(configureOwnershipCalculator.owner(), input);
    }

    function testAddSubFacet(uint256 x, uint256 y) public {
        vm.assume(x > 0);
        vm.assume(y <= x);

        // add AddSubtractFacet cut to the diamond
        DiamondCutFacet configureCutCalculator = DiamondCutFacet(address(calculator));
        AddSubtractFacet addSubCalculator = AddSubtractFacet(address(calculator));
        bytes4[] memory addSubSelectors = new bytes4[](2);
        addSubSelectors[0] = addSubtractFacet.addNumber.selector;
        addSubSelectors[1] = addSubtractFacet.subtractNumber.selector;
        IDiamondCut.FacetCut[] memory addSubCut = new IDiamondCut.FacetCut[](1);
        addSubCut[0] = IDiamondCut.FacetCut(
            address(addSubtractFacet),
            IDiamondCut.FacetCutAction.Add,
            addSubSelectors
        );
        vm.startPrank(deployer);
        configureCutCalculator.diamondCut(addSubCut, address(0), "");

        // test calculations
        uint256 addNum = addSubCalculator.addNumber(x);
        assertEq(addNum, x);
        uint256 subNum = addSubCalculator.subtractNumber(y);
        assertEq(subNum, x - y);
        vm.stopPrank();

        // verify storage
        _isNumberMatchedWithStorage(subNum);
    }

    // TODO: Implement DimaondInit to get non-zero values
    function testMultDivideFacet(uint256 x, uint256 y) public {
        vm.assume(x > 0 && y > 0);

        // add MultiplyDivideFacet cut to the diamond
        DiamondCutFacet configureCutCalculator = DiamondCutFacet(address(calculator));
        MultiplyDivideFacet multiplyDivideCalculator = MultiplyDivideFacet(address(calculator));
        bytes4[] memory multDivSelectors = new bytes4[](2);
        multDivSelectors[0] = multiplyDivideFacet.multiplyNumber.selector;
        multDivSelectors[1] = multiplyDivideFacet.divideNumber.selector;
        IDiamondCut.FacetCut[] memory multDivCut = new IDiamondCut.FacetCut[](1);
        multDivCut[0] = IDiamondCut.FacetCut(
            address(multiplyDivideFacet),
            IDiamondCut.FacetCutAction.Add,
            multDivSelectors
        );
        vm.startPrank(deployer);
        configureCutCalculator.diamondCut(multDivCut, address(0), "");

        // test calculations
        uint256 multiplyNum = multiplyDivideCalculator.multiplyNumber(x);
        assertEq(multiplyNum, 0);
        uint256 divNum = multiplyDivideCalculator.divideNumber(y);
        assertEq(divNum, 0);
        vm.stopPrank();

        // verify storage
        _isNumberMatchedWithStorage(divNum);
    }

    function _isNumberMatchedWithStorage(uint256 res) private returns (bool) {
        // add GetNumberFacet cut to the diamond
        DiamondCutFacet configureCutCalculator = DiamondCutFacet(address(calculator));
        GetNumberFacet getCalculator = GetNumberFacet(address(calculator));
        bytes4[] memory selector = new bytes4[](1);
        selector[0] = getNumberFacet.getNumber.selector;
        IDiamondCut.FacetCut[] memory getNumCut = new IDiamondCut.FacetCut[](1);
        getNumCut[0] = IDiamondCut.FacetCut(
            address(getNumberFacet),
            IDiamondCut.FacetCutAction.Add,
            selector
        );
        vm.startPrank(deployer);
        configureCutCalculator.diamondCut(getNumCut, address(0), "");
        vm.stopPrank();
        return getCalculator.getNumber() == res;
    }
}
