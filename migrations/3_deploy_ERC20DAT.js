const ERC20DAT = artifacts.require("ERC20DAT");

module.exports = function (deployer) {
  deployer.deploy(ERC20DAT,
    // 构造函数的参数
    "DAT : DAO Credential Token", "DAT", 18, 5000000);
};
