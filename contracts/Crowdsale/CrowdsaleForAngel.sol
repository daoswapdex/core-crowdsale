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

    // token address
    IERC20 private _token;
    address private _tokenWallet;

    // joined amount
    mapping(address => uint256) public joined;

    // report parames
    struct ReportInfo {
        address token;
        uint256 amount;
    }

    // TokenVesting Info
    struct TokenVestingInfo {
        address tokenVesting;
        uint256 tokenAmount;
    }

    // Get TokenVesting info by Beneficiary token
    mapping(address => TokenVestingInfo) public TokenVestingInfoByBeneficiaryToken;

    constructor(IERC20 token, address tokenWallet) Ownable() public {
        require(address(token) != address(0), "CrowdsaleForAngel: token is the zero address");
        require(tokenWallet != address(0), "CrowdsaleForAngel: token wallet is the zero address");
        
        _token = token;
        _tokenWallet = tokenWallet;
    }

    // upload report
    function updateList(ReportInfo[] memory list) public onlyOwner {
        require(list.length > 0, "CrowdsaleForAngel： list array is null");
        for (uint i = 0; i < list.length; i++) {
            ReportInfo memory reportInfo = list[i];
            if (reportInfo.amount > 0) {
                _deliverTokens(reportInfo.token, reportInfo.amount);
            }
        }
    }

    // exec submit
    function _deliverTokens(address beneficiary, uint256 amount) internal {
        uint256 tokenAmount = amount * (10**uint256(18));
        // recode joined amount
        joined[beneficiary] = joined[beneficiary].add(tokenAmount);

        TokenVestingInfo storage info = TokenVestingInfoByBeneficiaryToken[beneficiary];
        require(info.tokenVesting == address(0), 'CrowdsaleForAngel::deploy: The address has participated in crowdfunding');

        info.tokenVesting = address(new TokenVestingAngel(
            beneficiary,
            block.timestamp
        ));
        info.tokenAmount = tokenAmount;
        // transfer token to tokenVestion contract
        _token.safeTransferFrom(_tokenWallet, info.tokenVesting, tokenAmount);
    }
}
