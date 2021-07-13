pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TokenVestingAngel is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);

    address private _beneficiary;

    // UNIX time，UTC timestamp，unit second，type uint，same as block.timestamp
    // start timestamp
    uint256 private _start;
    // lock duration
    uint256 private _duration;
    // release rate
    uint256 private _totalShares;

    // recode token released amount
    mapping (address => uint256) private _released;

    // per stage release time
    uint256[] private _stageTime = [80 weeks, 80 weeks];
    // per stage cliff time
    uint256[] private _stageCliffUnit = [4 weeks, 4 weeks];
    // per stage release rate
    uint256[] private _stageRate = [40, 60];

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

    // claim token
    function release(IERC20 token) public {
        uint256 unreleased = releasableAmount(token);

        require(unreleased > 0, "TokenVestingAngel: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    // calc releaseable token amount
    function releasableAmount(IERC20 token) public view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }

    // calc released token amount
    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp >= _start.add(_duration)) {
            return totalBalance;
        } else {
            bool isJumpFor = false;
            uint256 vestedAmount = 0;
            uint256 cumulativeTime = _start;
            for (uint256 i = 0; i < _stageTime.length; i++) {
                uint256 vestCount = _stageTime[i].div(_stageCliffUnit[i]);
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
