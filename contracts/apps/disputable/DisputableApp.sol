/*
 * SPDX-License-Identitifer:    GPL-3.0-or-later
 */

pragma solidity 0.4.24;

import "./IAgreement.sol";
import "./IDisputable.sol";
import "../AragonApp.sol";
import "../../lib/token/ERC20.sol";
import "../../lib/math/SafeMath64.sol";


contract DisputableApp is IDisputable, AragonApp {
    /* Validation errors */
    string internal constant ERROR_AGREEMENT_NOT_SET = "DISPUTABLE_AGREEMENT_NOT_SET";
    string internal constant ERROR_AGREEMENT_ALREADY_SET = "DISPUTABLE_AGREEMENT_ALREADY_SET";
    string internal constant ERROR_SENDER_NOT_AGREEMENT = "DISPUTABLE_SENDER_NOT_AGREEMENT";

    // This role is not required to be validated in the Disputable app, the Agreement app is already doing the check
    // bytes32 public constant CHALLENGE_ROLE = keccak256("CHALLENGE_ROLE");
    bytes32 public constant CHALLENGE_ROLE = 0xef025787d7cd1a96d9014b8dc7b44899b8c1350859fb9e1e05f5a546dd65158d;

    // bytes32 public constant SET_AGREEMENT_ROLE = keccak256("SET_AGREEMENT_ROLE");
    bytes32 public constant SET_AGREEMENT_ROLE = 0x8dad640ab1b088990c972676ada708447affc660890ec9fc9a5483241c49f036;

    // bytes32 internal constant AGREEMENT_POSITION = keccak256("aragonOS.appStorage.agreement");
    bytes32 internal constant AGREEMENT_POSITION = 0x6dbe80ccdeafbf5f3fff5738b224414f85e9370da36f61bf21c65159df7409e9;

    event AgreementSet(IAgreement indexed agreement);

    modifier onlyAgreement() {
        require(address(_getAgreement()) == msg.sender, ERROR_SENDER_NOT_AGREEMENT);
        _;
    }

    /**
    * @notice Set disputable agreements to `_agreement`
    * @param _agreement Agreement instance to be linked
    */
    function setAgreement(IAgreement _agreement) external auth(SET_AGREEMENT_ROLE) {
        IAgreement agreement = _getAgreement();
        require(agreement == IAgreement(0) || _agreement == IAgreement(0), ERROR_AGREEMENT_ALREADY_SET);

        AGREEMENT_POSITION.setStorageAddress(address(_agreement));
        emit AgreementSet(_agreement);
    }

    /**
    * @notice Challenge disputable action #`_disputableActionId`
    * @param _disputableActionId Identification number of the disputable action to be challenged
    * @param _challengeId Identification number of the challenge in the context of the Agreement
    * @param _challenger Address challenging the disputable
    */
    function onDisputableActionChallenged(uint256 _disputableActionId, uint256 _challengeId, address _challenger) external onlyAgreement {
        _onDisputableActionChallenged(_disputableActionId, _challengeId, _challenger);
    }

    /**
    * @notice Allow disputable action #`_disputableActionId`
    * @param _disputableActionId Identification number of the disputable action to be allowed
    */
    function onDisputableActionAllowed(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionAllowed(_disputableActionId);
    }

    /**
    * @notice Reject disputable action #`_disputableActionId`
    * @param _disputableActionId Identification number of the disputable action to be rejected
    */
    function onDisputableActionRejected(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionRejected(_disputableActionId);
    }

    /**
    * @notice Void disputable action #`_disputableActionId`
    * @param _disputableActionId Identification number of the disputable action to be voided
    */
    function onDisputableActionVoided(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionVoided(_disputableActionId);
    }

    /**
    * @notice Tells whether the Agreement app is a forwarder or not
    * @dev IForwarder interface conformance
    * @return Always true
    */
    function isForwarder() external pure returns (bool) {
        return true;
    }

    /**
    * @dev Tell the agreement linked to the disputable instance
    * @return Agreement linked to the disputable instance
    */
    function getAgreement() external view returns (IAgreement) {
        return _getAgreement();
    }

    /**
    * @dev Create a new action in the agreement without lifetime set
    * @param _disputableActionId Identification number of the disputable action in the context of the disputable
    * @param _submitter Address of the user that has submitted the action
    * @param _context Link to a human-readable text giving context for the given action
    * @return Unique identification number for the created action in the context of the agreement
    */
    function _newAgreementAction(uint256 _disputableActionId, address _submitter, bytes _context) internal returns (uint256) {
        return _newAgreementAction(_disputableActionId, 0, _submitter, _context);
    }

    /**
    * @dev Create a new action in the agreement
    * @param _disputableActionId Identification number of the disputable action in the context of the disputable
    * @param _lifetime Lifetime duration in seconds of the disputable action, it can be set to zero to specify infinite
    * @param _submitter Address of the user that has submitted the action
    * @param _context Link to a human-readable text giving context for the given action
    * @return Unique identification number for the created action in the context of the agreement
    */
    function _newAgreementAction(uint256 _disputableActionId, uint64 _lifetime, address _submitter, bytes _context) internal returns (uint256) {
        IAgreement agreement = _ensureAgreement();
        return agreement.newAction(_disputableActionId, _lifetime, _submitter, _context);
    }

    /**
    * @dev Close action in the agreement
    * @param _actionId Identification number of the disputable action in the context of the agreement
    */
    function _closeAgreementAction(uint256 _actionId) internal {
        IAgreement agreement = _ensureAgreement();
        agreement.closeAction(_actionId);
    }

    /**
    * @dev Reject disputable action
    * @param _disputableActionId Identification number of the disputable action to be rejected
    */
    function _onDisputableActionRejected(uint256 _disputableActionId) internal;

    /**
    * @dev Challenge disputable action
    * @param _disputableActionId Identification number of the disputable action to be challenged
    * @param _challengeId Identification number of the challenge in the context of the Agreement
    * @param _challenger Address challenging the disputable
    */
    function _onDisputableActionChallenged(uint256 _disputableActionId, uint256 _challengeId, address _challenger) internal;

    /**
    * @dev Allow disputable action
    * @param _disputableActionId Identification number of the disputable action to be allowed
    */
    function _onDisputableActionAllowed(uint256 _disputableActionId) internal;

    /**
    * @dev Void disputable action
    * @param _disputableActionId Identification number of the disputable action to be voided
    */
    function _onDisputableActionVoided(uint256 _disputableActionId) internal;

    /**
    * @dev Tell whether an action can proceed or not, i.e. if its not being challenged or disputed
    * @param _actionId Identification number of the action being queried in the context of the Agreement app
    * @return True if the action can proceed, false otherwise
    */
    function _canProceedAgreementAction(uint256 _actionId) internal view returns (bool) {
        IAgreement agreement = _ensureAgreement();
        return agreement.canProceed(_actionId);
    }

    /**
    * @dev Tell the agreement linked to the disputable instance
    * @return Agreement linked to the disputable instance
    */
    function _getAgreement() internal view returns (IAgreement) {
        return IAgreement(AGREEMENT_POSITION.getStorageAddress());
    }

    /**
    * @dev Tell the agreement linked to the disputable instance
    * @return Agreement linked to the disputable instance
    */
    function _ensureAgreement() internal view returns (IAgreement) {
        IAgreement agreement = _getAgreement();
        require(agreement != IAgreement(0), ERROR_AGREEMENT_NOT_SET);
        return agreement;
    }
}
