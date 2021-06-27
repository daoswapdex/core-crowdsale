pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TokenVestingAngel is Ownable {
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
    // 每阶段释放时间
    uint256[] private _stageTime = [10 minutes, 20 minutes, 20 minutes, 15 minutes];
    // 每阶段截断时间单位
    uint256[] private _stageCliffUnit = [5 minutes, 5 minutes, 10 minutes, 5 minutes];
    // 每阶段释放比例
    uint256[] private _stageRate = [20, 20, 30, 30];

    constructor (address beneficiary, uint256 start) public {
        require(beneficiary != address(0), "TokenVestingAngel: beneficiary is the zero address");

        _beneficiary = beneficiary;
        _start = start;

        for (uint256 i = 0; i < _stageTime.length; i++) {
            _duration = _duration.add(_stageTime[i]);
            _totalShares = _totalShares.add(_stageRate[i]);
        }

        // solhint-disable-next-line max-line-length
        require(start.add(_duration) > block.timestamp, "TokenVestingAngel: final time is before current time");
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

        require(unreleased > 0, "TokenVestingAngel: no tokens are due");

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

        // 按条件计算已释放代币数量
        if (block.timestamp >= _start.add(_duration)) {
            return totalBalance;
        } else {
            // 确认是否跳出循环
            bool isJumpFor = false;
            // 记录已释放代币数量
            uint256 vestedAmount = 0;
            // 累计释放时间
            uint256 cumulativeTime = _start;
            for (uint256 i = 0; i < _stageTime.length; i++) {
                // 计算每阶段释放次数
                uint256 vestCount = _stageTime[i].div(_stageCliffUnit[i]);
                // 计算每阶段每次的释放比例
                uint256 vestRate = _stageRate[i].div(vestCount);
                for (uint256 j = 0; j < vestCount; j++) {
                    cumulativeTime = cumulativeTime.add(_stageCliffUnit[i]);
                    if (cumulativeTime > block.timestamp) {
                        isJumpFor = true;
                        break;
                    }
                    vestedAmount = vestedAmount.add(totalBalance.mul(vestRate).div(_totalShares));
                }
                if (isJumpFor) {
                    break;
                }
            }
            return vestedAmount;
        }
    }
}
