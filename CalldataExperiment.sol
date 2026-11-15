// Name: Mihyeon Seo
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CalldataExperiment {
    function testCalldata(uint256[] calldata numbers)
        external pure returns (uint256)
    {
        uint256[] memory copiedNumbers = numbers;
        copiedNumbers[0] = 100;
        return copiedNumbers[0];
    }
}
