const CrowdsaleByUSDT = artifacts.require("CrowdsaleByUSDT");

module.exports = function (deployer, network, accounts) {
  const purchaseToken = '0x3aA03210EaA74C7D09163fe3ddF80260Cf42DAa6'; // 用于众筹的代币地址，DOIUSDT
  const rate = 20; // 兑换比例，即 1USDT 换多少代币
  const beneficiaryToken = accounts[0]; // 收 USDT 的钱包地址
  const token = '0xd2f169c79553654452a3889b210AEeF494eB2374'; // 代币地址
  const deliverToken = accounts[0]; // 发送代币的钱包地址
  const openingTime = 1624293000; // 众筹开始时间
  const closingTime = 1624379400; // 众筹结束时间
  const cap = 20; // 众筹目标封顶数额，USDT
  // 部署合约
  deployer.deploy(CrowdsaleByUSDT,
    purchaseToken,
    rate,
    beneficiaryToken,
    token,
    deliverToken,
    openingTime,
    closingTime,
    cap
  );
};
