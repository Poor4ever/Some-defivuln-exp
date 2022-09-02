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

[shadowfi-exp.sol](https://github.com/Poor4ever/Some-Defivlun-Exp/blob/main/src/shadowfi-exp.sol) 

```
forge test --contracts "./src/shadowfi.sol" -vvv
```

Attack_tx:https://bscscan.com/tx/0xe30dc75253eecec3377e03c532aa41bae1c26909bc8618f21fb83d4330a01018 获利~ 1078 WBNB
