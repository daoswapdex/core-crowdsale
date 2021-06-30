const CrowdsaleForAngel = artifacts.require("CrowdsaleForAngel");

module.exports = function (deployer, network, accounts) {
  const token = '0xc096332CAacF00319703558988aD03eC6586e704'; // 代币地址
  const deliverToken = accounts[0]; // 发送代币的钱包地址
  // 部署合约
  deployer.deploy(CrowdsaleForAngel,
    token,
    deliverToken
  );
};
