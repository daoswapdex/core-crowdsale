pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./CrowdsaleByERC20/emission/TokenVestingAngel.sol";

contract CrowdsaleForAngel is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // 兑换代币地址
    IERC20 private _token;
    address private _tokenWallet;

    // 每个地址已众筹的额度
    mapping(address => uint256) public joined;

    // 上传报表格式参数
    struct ReportInfo {
        address token;
        uint256 amount;
    }

    // 分期释放信息结构
    struct TokenVestingInfo {
        address tokenVesting;
        uint256 tokenAmount;
    }

    // 通过受益人Token查分期释放信息
    mapping(address => TokenVestingInfo) public TokenVestingInfoByBeneficiaryToken;

    constructor(IERC20 token, address tokenWallet) Ownable() public {
        require(address(token) != address(0), "CrowdsaleForAngel: token is the zero address");
        require(tokenWallet != address(0), "CrowdsaleForAngel: token wallet is the zero address");
        
        _token = token;
        _tokenWallet = tokenWallet;
    }

    // 上传报表数据
    function updateList(ReportInfo[] memory list) public onlyOwner {
        require(list.length > 0, "CrowdsaleForAngel： list array is null");
        for (uint i = 0; i < list.length; i++) {
            ReportInfo memory reportInfo = list[i];
            if (reportInfo.amount > 0) {
                _deliverTokens(reportInfo.token, reportInfo.amount);
            }
        }
    }

    // 执行提交
    function _deliverTokens(address beneficiary, uint256 amount) internal {
        uint256 tokenAmount = amount * (10**uint256(18));
        // 记录参与人代币数量
        joined[beneficiary] = joined[beneficiary].add(tokenAmount);

        TokenVestingInfo storage info = TokenVestingInfoByBeneficiaryToken[beneficiary];
        require(info.tokenVesting == address(0), 'CrowdsaleForAngel::deploy: The address has participated in crowdfunding');

        info.tokenVesting = address(new TokenVestingAngel(
            beneficiary, // 受益人地址
            block.timestamp // 当前众筹时间
        ));
        info.tokenAmount = tokenAmount;
        // 代币转入分期释放合约地址
        _token.safeTransferFrom(_tokenWallet, info.tokenVesting, tokenAmount);
    }
}
