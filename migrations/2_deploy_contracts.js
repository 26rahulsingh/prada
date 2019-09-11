const owner = artifacts.require("owner");
const prada = artifacts.require("prada");

module.exports = function (deployer) {
    deployer.deploy(owner);
    deployer.deploy(prada);
};