// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


contract GosuslugiApi {
    
    function getCadastralNumberFromDoc(string memory document) internal returns(string memory) {
        return "324:2424453:234245245435:232";
    }

    function verifyUser(string memory login, string memory password) internal returns(bool) {
        return true;
    }

    function getPassportData(string memory login, string memory password) internal returns(uint256) {
        return 123356497;
    }

    function updateOwnerInfo(string memory document) internal {}
}


contract RosregApi {

    function validateCadastrialNumber(string memory cadastral) internal returns(bool) {
        return true;
    }

    function checkOwneship(string memory cadastral, uint256 passport) internal returns(bool) {
        return true;
    }
}


contract API is GosuslugiApi, RosregApi {}
