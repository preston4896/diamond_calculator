// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Script.sol";

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

contract DeployDiamondScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        
        vm.startBroadcast(deployerKey);

        // Step 1: Deploy DiamondCutFacet
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        console.log("DiamondCutFacet deployed at: %s", address(diamondCutFacet));

        // Step 2: Deploy the diamond and adds DiamondCutFacet

        // constructs the FacetCut value to add DiamondCutFacet to the diamond
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = IDiamondCut.FacetCut(
            address(diamondCutFacet),
            IDiamondCut.FacetCutAction.Add,
            getDynamicAtomicSelector(IDiamondCut.diamondCut.selector)
        );

        // assigns the deployer as the owner of the diamond
        Diamond.DiamondArgs memory args =  Diamond.DiamondArgs(deployer);

        // finally, deploys the Diamond
        DiamondCalculator diamondCalculator = new DiamondCalculator(cuts, args);
        console.log("DiamondCalculator deployed at: %s", address(diamondCalculator));

        // Step 3: Deploy the other facets
        OwnershipFacet ownershipFacet = new OwnershipFacet();
        console.log("OwnershipFacet deployed at: %s", address(ownershipFacet));
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        console.log("DiamondLoupeFacet deployed at: %s", address(diamondLoupeFacet));
        AddSubtractFacet addSubtractFacet = new AddSubtractFacet();
        console.log("AddSubtractFacet deployed at: %s", address(addSubtractFacet));
        MultiplyDivideFacet multiplyDivideFacet = new MultiplyDivideFacet();
        console.log("MultiplyDivideFacet deployed at: %s", address(multiplyDivideFacet));
        GetNumberFacet getNumberFacet = new GetNumberFacet();
        console.log("GetNumberFacet deployed at: %s", address(getNumberFacet));

        // Step 4: Add facets to the Diamond
        DiamondCutFacet configCalculator = DiamondCutFacet(address(diamondCalculator));
        IDiamondCut.FacetCut[] memory newCuts = new IDiamondCut.FacetCut[](3);
        bytes4[] memory addSubSelectors = new bytes4[](2);
        addSubSelectors[0] = addSubtractFacet.addNumber.selector;
        addSubSelectors[1] = addSubtractFacet.subtractNumber.selector;
        newCuts[0] = IDiamondCut.FacetCut(
            address(addSubtractFacet),
            IDiamondCut.FacetCutAction.Add,
            addSubSelectors
        );
        bytes4[] memory multiplyDivideSelectors = new bytes4[](2);
        multiplyDivideSelectors[0] = multiplyDivideFacet.multiplyNumber.selector;
        multiplyDivideSelectors[1] = multiplyDivideFacet.divideNumber.selector;
        newCuts[1] = IDiamondCut.FacetCut(
            address(multiplyDivideFacet),
            IDiamondCut.FacetCutAction.Add,
            multiplyDivideSelectors
        );
        bytes4[] memory getNumberSelectors = new bytes4[](1);
        getNumberSelectors[0] = getNumberFacet.getNumber.selector;
        newCuts[2] = IDiamondCut.FacetCut(
            address(getNumberFacet),
            IDiamondCut.FacetCutAction.Add,
            getNumberSelectors
        );
        configCalculator.diamondCut(newCuts, address(0), "");
    }

    function getDynamicAtomicSelector(bytes4 selector) internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = selector;
        return selectors;
    }
}
