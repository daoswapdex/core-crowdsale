pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./CrowdsaleByERC20/Crowdsale.sol";
import "./CrowdsaleByERC20/emission/AllowanceCrowdsale.sol";
import "./CrowdsaleByERC20/validation/TimedCrowdsale.sol";
import "./CrowdsaleByERC20/validation/CappedCrowdsale.sol";
import "./CrowdsaleByERC20/emission/TokenVesting.sol";

contract CrowdsaleByUSDT is Crowdsale, AllowanceCrowdsale, TimedCrowdsale, CappedCrowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // 用于众筹的代币地址
    IERC20 private _usdtToken;
    // 每个地址已众筹的额度
    mapping(address => uint256) public joined;

    // 释放规则参数
    // 释放时间
    uint256[] private _vestTime = [10 minutes, 10 minutes, 10 minutes];
    // 释放比例
    uint256[] private _vestRate = [20, 50, 30];

    // 分期释放信息结构
    struct TokenVestingInfo {
        address tokenVesting;
        uint256 tokenAmount;
    }

    // 通过受益人Token查分期释放信息
    mapping(address => TokenVestingInfo) public TokenVestingInfoByBeneficiaryToken;

    constructor(
        IERC20 usdtToken,   // 用于众筹的代币地址
        uint256 rate,           // 兑换比例
        address payable wallet, // 接收ETH受益人地址
        IERC20 token,           // 代币地址
        address tokenWallet,     // 代币从这个地址发送
        uint256 openingTime,    // 众筹开始时间
        uint256 closingTime,     // 众筹结束时间
        uint256 cap             // 封顶数量,单位是wei
    )
        AllowanceCrowdsale(tokenWallet) 
        TimedCrowdsale(openingTime, closingTime) 
        CappedCrowdsale(cap * (10**uint256(18))) 
        Crowdsale(rate, wallet, token) 
        public {
        require(address(usdtToken) != address(0), "Crowdsale: purchase token is the zero address");

        _usdtToken = usdtToken;
    }

    /**
     * @return the usdtToken being buy.
     */
    function usdtToken() public view returns (IERC20) {
        return _usdtToken;
    }

    // 重写预先验证方法
    // 校验金额
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        super._preValidatePurchase(beneficiary, weiAmount);
        // 同一个地址只能参与一次众筹
        require(joined[beneficiary] == 0, 'CrowdsaleByUSDT: The address has participated in crowdfunding');
        // 金额只能为 5000 或 10000 USDT
        require(weiAmount == (5 ether) || weiAmount == (10 ether), 'CrowdsaleByUSDT: the amount can only be 5000 to 10000 usdt');
    }

    // 修改变量状态
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        super._updatePurchasingState(beneficiary, weiAmount);
        // 接收众筹USDT
        _usdtToken.safeTransferFrom(beneficiary, wallet(), weiAmount);
        // 记录参与人已购买金额
        joined[beneficiary] = joined[beneficiary].add(weiAmount);
    }

    // 执行众筹
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        TokenVestingInfo storage info = TokenVestingInfoByBeneficiaryToken[beneficiary];
        require(info.tokenVesting == address(0), 'CrowdsaleByUSDT::deploy: The address has participated in crowdfunding');

        info.tokenVesting = address(new TokenVesting(
            beneficiary, // 受益人地址
            block.timestamp, // 当前众筹时间
            _vestTime, // 释放时间节点
            _vestRate // 对应释放时间的释放比例
        ));
        info.tokenAmount = tokenAmount;
        // 代币转入分期释放合约地址
        token().safeTransferFrom(tokenWallet(), info.tokenVesting, tokenAmount);
    }
}
