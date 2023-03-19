// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @dev API сервиса Госуслуг
 */
contract GosuslugiApi {
    
    /**
    * @dev Возвращает кадастровый номер из документа о владении имуществом
    * 
    * @param document Ссылка на документ о владении
    * @return Кадастровый номер
    */
    function getCadastralNumberFromDoc(string memory document) internal pure returns(string memory) {
        return "34:24:2342452:23";
    }

    /**
    * @dev Верифицирует пользователя
    * 
    * @param login Логин верифицируемого пользователя на сайте Госуслуг
    * @param password Пароль верифицируемого пользователя на сайте Госуслуг
    * @return Статус верификации
    */
    function verifyUser(string memory login, string memory password) internal pure returns(bool) {
        return true;
    }

    /**
    * @dev Возвращает паспортные данные (серия и номер)
    * 
    * @param login Логин верифицируемого пользователя на сайте Госуслуг
    * @param password Пароль верифицируемого пользователя на сайте Госуслуг
    * @return Серия и номер паспорта
    */
    function getPassportData(string memory login, string memory password) internal pure returns(uint256) {
        return 1111222333;
    }

    /**
    * @dev Обновляет данные владельца в договоре о владении
    * 
    * @param document Ссылка на документ о владении
    */
    function updateOwnerInfo(string memory document) internal {}
}


/**
 * @dev API сервиса Росреестра
 */
contract RosregApi {

    /**
    * @dev Валидирование кадастрового номера
    * 
    * @param cadastral Кадастровый номер
    * @return Статус валидации
    */
    function validateCadastrialNumber(string memory cadastral) internal pure returns(bool) {
        return true;
    }

    /**
    * @dev Проверяет информацию о владельце по кадастровому номера
    * 
    * @param cadastral Кадастровый номер
    * @param passport Паспортные данные (серия и номер)
    * @return Статус проверки
    */
    function checkOwneship(string memory cadastral, uint256 passport) internal pure returns(bool) {
        return true;
    }
}


/**
 * @dev Совокупное API сервисов Госуслуг и Росреестра
 */
contract API is GosuslugiApi, RosregApi {}
