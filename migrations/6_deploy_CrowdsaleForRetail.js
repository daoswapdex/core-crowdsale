const CrowdsaleForRetail = artifacts.require("CrowdsaleForRetail");

module.exports = function (deployer, network, accounts) {
  const purchaseToken = '0x36653A4089DEB09A4782bf9EaEE5C8f4381ad010'; // 用于众筹的代币地址，DAT
  const rate = 1; // 兑换比例，即 1DAT 换多少代币
  const beneficiaryToken = accounts[0]; // 收 DAT 的钱包地址
  const token = '0xd2f169c79553654452a3889b210AEeF494eB2374'; // 代币地址
  const deliverToken = accounts[0]; // 发送代币的钱包地址
  const openingTime = 1624672200; // 众筹开始时间
  const closingTime = 1624931400; // 众筹结束时间
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
