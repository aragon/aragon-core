pragma solidity ^0.4.18;

import "./EtherTokenConstant.sol";
import "./IsContract.sol";
import "./IVaultRecoverable.sol";
import "../lib/zeppelin/token/ERC20.sol";


contract VaultRecoverable is IVaultRecoverable, EtherTokenConstant, IsContract {
    /**
     * @notice Send funds to recovery Vault. This contract should never receive funds,
     *         but in case it does, this function allows one to recover them.
     * @param _token Token balance to be sent to recovery vault.
     */
    function transferToVault(address _token) external {
        address vault = getRecoveryVault();
        require(isContract(vault));

        if (_token == ETH) {
            // solium-disable-next-line security/no-call-value
            require(vault.call.value(address(this).balance)());
        } else {
            uint256 amount = ERC20(_token).balanceOf(this);
            ERC20(_token).transfer(vault, amount);
        }
    }
}
