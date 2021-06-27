const ERC20DAO = artifacts.require("ERC20DAO");

module.exports = function (deployer) {
  deployer.deploy(ERC20DAO,
    // 构造函数的参数
    "DaoSwap", "DAO", 18, 1000000000);
};
