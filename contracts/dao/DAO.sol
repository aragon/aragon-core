pragma solidity ^0.4.11;

import "./DAOStorage.sol";
import "../kernel/Kernel.sol";

// @dev DAO is the base contract on top of which all DAO lives.
// This is the only element of the DAO that is non-upgradeable
// Given the simplicity of this contract, it could be written in LLL and/or
// be formally proven.

contract DAO is DAOStorage {
  // @dev DAO constructor deploys its DAO kernel and saves its own identity as self
  function DAO() {
    setKernel(new Kernel());
    assert(getKernel().delegatecall(0x743d4c1a)); // setupOrgans()
    setSelf(this);
  }

  // @dev All calls to the DAO are forwarded to the kernel with a delegatecall
  function () payable public {
    uint32 len = getReturnSize();
    address target = getKernel();
    assembly {
      calldatacopy(0x0, 0x0, calldatasize)
      let result := delegatecall(sub(gas, 10000), target, 0x0, calldatasize, 0, len)
      jumpi(invalidJumpLabel, iszero(result))
      return(0, len)
    }
  }
}
