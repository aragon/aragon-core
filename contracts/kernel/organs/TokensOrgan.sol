pragma solidity ^0.4.11;

import "./IOrgan.sol";

contract ITokensOrgan is IOrgan {
  event NewToken(address tokenAddress, uint tokenId);
  event TokenRemoved(address tokenAddress, uint tokenId); // beware that ids change on remove

  function addToken(address token) returns (uint256);
  function removeToken(uint tokenId);
  function getTokenCount() constant returns (uint);
  function getToken(uint i) constant returns (address);
}

contract TokensOrgan is ITokensOrgan {
  function addToken(address token) returns (uint256) {
    uint tokenId = getTokenCount();
    storageSet(getStorageKeyForToken(tokenId), uint256(token));
    setTokenCount(tokenId + 1);

    NewToken(token, tokenId);
    return tokenId;
  }

  function removeToken(uint tokenId) {
    address removedAddress = getToken(tokenId);
    if (getTokenCount() > 1) {
      // Move last element to the place of the removing item
      storageSet(getStorageKeyForToken(tokenId), uint256(getToken(getTokenCount() - 1)));
    }
    // Remove last item
    setTokenCount(getTokenCount() - 1);
    TokenRemoved(removedAddress, tokenId);
  }

  function getToken(uint i) constant returns (address) {
    return address(storageGet(getStorageKeyForToken(i)));
  }

  function getStorageKeyForToken(uint tokenId) constant internal returns (bytes32) {
    return sha3(0x03, 0x00, tokenId);
  }

  function getTokenCount() constant returns (uint) {
    return storageGet(sha3(0x03, 0x01));
  }

  function setTokenCount(uint _count) internal {
    storageSet(sha3(0x03, 0x01), _count);
  }

  function canHandlePayload(bytes payload) returns (bool) {
    bytes4 sig = getFunctionSignature(payload);
    return
      sig == 0xd48bfca7 ||   // addToken(address)
      sig == 0x36c5d724 ||   // removeToken(uint256)
      sig == 0xe4b50cb8 ||   // getToken(uint256)
      sig == 0x78a89567;     // getTokenCount()
  }

  function organWasInstalled() {}
}
