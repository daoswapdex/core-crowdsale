pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);

    // 受益人地址
    address private _beneficiary;

    // UNIX time，UTC时间戳，单位秒，类型uint，与 block.timestamp 一致
    // 合约开始时间，即锁定开始时间
    uint256 private _start;
    // 锁定周期，例如：4年
    uint256 private _duration;
    // 总释放比例
    uint256 private _totalShares;

    // 记录每个币种的已释放量
    mapping (address => uint256) private _released;

    // 释放规则参数
    // 释放时间
    uint256[] private _vestTime;
    // 释放比例
    uint256[] private _vestRate;

    constructor (address beneficiary, uint256 start, uint256[] memory vestTime, uint256[] memory vestRate) public {
        require(beneficiary != address(0), "TokenVesting: beneficiary is the zero address");
        // solhint-disable-next-line max-line-length
        require(vestTime.length == vestRate.length, "TokenVesting: vestTime and vestRate length mismatch");
        require(vestTime.length > 0, "TokenVesting: no set vestTime");

        _beneficiary = beneficiary;
        _start = start;
        _vestTime = vestTime;
        _vestRate = vestRate;

        for (uint256 i = 0; i < _vestTime.length; i++) {
            _duration = _duration.add(_vestTime[i]);
            _totalShares = _totalShares.add(_vestRate[i]);
        }

        // solhint-disable-next-line max-line-length
        require(start.add(_duration) > block.timestamp, "TokenVesting: final time is before current time");
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the start time of the token vesting.
     */
    function start() public view returns (uint256) {
        return _start;
    }

    /**
     * @return the duration of the token vesting.
     */
    function duration() public view returns (uint256) {
        return _duration;
    }

    /**
     * @return the amount of the token released.
     */
    function released(address token) public view returns (uint256) {
        return _released[token];
    }

    // 提取代币
    function release(IERC20 token) public {
        uint256 unreleased = releasableAmount(token);

        require(unreleased > 0, "TokenVesting: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    // 计算可提取代币数量
    function releasableAmount(IERC20 token) public view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }

    // 计算已释放代币数量
    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp >= _start.add(_duration)) {
            return totalBalance;
        } else {
            uint256 vestedAmount = 0;
            uint256 cumulativeTime = _start;
            for (uint256 i = 0; i < _vestTime.length; i++) {
                cumulativeTime = cumulativeTime.add(_vestTime[i]);
                if (cumulativeTime > block.timestamp) {
                    break;
                }
                vestedAmount = vestedAmount.add(totalBalance.mul(_vestRate[i]).div(_totalShares));
            }
            return vestedAmount;
        }
    }
}
