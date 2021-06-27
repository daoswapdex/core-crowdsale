const CrowdsaleForAngel = artifacts.require("CrowdsaleForAngel");

module.exports = function (deployer, network, accounts) {
  const token = '0xd2f169c79553654452a3889b210AEeF494eB2374'; // 代币地址
  const deliverToken = accounts[0]; // 发送代币的钱包地址
  // 部署合约
  deployer.deploy(CrowdsaleForAngel,
    token,
    deliverToken
  );
};
