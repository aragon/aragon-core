pragma solidity ^0.4.11;

import "../../apps/IApplication.sol";
import "./IOrgan.sol";

contract ApplicationOrgan is IOrgan {
  // AppOrgan intercepts all the calls
  function canHandlePayload(bytes payload) public returns (bool) {
    return true;
  }

  function organWasInstalled() {}

  function installApp(uint i, address application) {
    require(i > 0);
    storageSet(getApplicationStorageKey(i), uint256(application));
    InstalledApplication(application);
  }

  function () public {
    address responsiveApplication = getResponsiveApplication(msg.data);
    assert(responsiveApplication > 0);

    IApplication app = IApplication(responsiveApplication);
    DAOMessage memory daomsg = dao_msg();
    app.setDAOMsg(daomsg.sender, daomsg.token, daomsg.value); // TODO: check reentrancy risks
    uint32 len = getReturnSize();

    assembly {
      calldatacopy(0x0, 0x0, calldatasize)
      let result := call(sub(gas, 10000), responsiveApplication, 0, 0x0, calldatasize, 0, len)
      jumpi(invalidJumpLabel, iszero(result))
      return(0, len)
    }
  }

  function getApp(uint i) constant public returns (address) {
    return address(storageGet(getApplicationStorageKey(i)));
  }

  function getResponsiveApplicationForSignature(bytes4 sig) constant returns (address) {
    bytes memory p = new bytes(4);
    p[0] = sig[0]; p[1] = sig[1]; p[2] = sig[2]; p[3] = sig[3];

    return getResponsiveApplication(p);
  }

  function getResponsiveApplication(bytes payload) returns (address) {
    uint i = 1;
    while (true) {
      address applicationAddress = getApp(i);
      if (applicationAddress == 0) return 0;  // if a 0 address is returned it means, there is no more apps.
      if (IApplication(applicationAddress).canHandlePayload(payload)) return applicationAddress;
      i++;
    }
  }

  function getApplicationStorageKey(uint _appId) internal constant returns (bytes32) {
    return sha3(0x04, 0x00, _appId);
  }

  event InstalledApplication(address applicationAddress);
}
