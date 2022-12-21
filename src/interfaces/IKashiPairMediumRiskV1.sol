pragma solidity ^0.8.17;

interface IKashiPairMediumRiskV1 {
    function addCollateral(address to, bool skim, uint256 share) external;
    function addAsset(address to, bool skim, uint256 share) external returns (uint256 fraction);
    function borrow(address to, uint256 amount) external returns (uint256 part, uint256 share);
    function liquidate(address[] calldata users, uint256[] calldata maxBorrowParts, address to, address swapper, bool open) external;
   function removeAsset(address to, uint256 fraction) external returns (uint256 share);
   function exchangeRate() external view returns (uint256 rate);
}