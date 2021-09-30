const CrowdsaleForRetail = artifacts.require("CrowdsaleForRetail");

module.exports = function (deployer, network, accounts) {
  const purchaseToken = '0x738B815eaDD06E0041b52B0C9d4F0d0D277B24bA'; // 用于众筹的代币地址，DAT
  const rate = 1; // 兑换比例，即 1DAT 换多少代币
  const beneficiaryToken = accounts[0]; // 收 DAT 的钱包地址
  const token = '0xc096332CAacF00319703558988aD03eC6586e704'; // 代币地址
  const deliverToken = accounts[0]; // 发送代币的钱包地址
  const openingTime = 1633015800; // 众筹开始时间
  const closingTime = 1640878200; // 众筹结束时间
  const cap = 5000000; // 众筹目标封顶数额，DAT
  // 部署合约
  deployer.deploy(CrowdsaleForRetail,
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
