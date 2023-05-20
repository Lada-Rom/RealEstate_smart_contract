function deploy(abi, bytecode) {    
    const url_get = "http://localhost:3000/get_status.php";
    const url_post = "http://localhost:3000/contract_status.php";
    $.get(url_get).then(function(is_deployed){
        console.log(is_deployed);
        console.log("TEXT!!!!!!!!!!!");

        if (is_deployed != "aaa") {
            $.post(url_post, {status: "aaa"}).then(function(data){
                console.log("GET DATA");
                console.log(data);
            });
            // web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    
            // // https://www.geeksforgeeks.org/how-to-deploy-contract-from-nodejs-using-web3/
            // var contract = new web3.eth.Contract(abi);
            // web3.eth.getAccounts().then((accounts) => {
            //     // Display all Ganache Accounts
            //     console.log("Accounts:", accounts);
            
            //     mainAccount = accounts[0];
            
            //     // address that will deploy smart contract
            //     console.log("Default Account:", mainAccount);
            //     contract
            //         .deploy({ data: bytecode })
            //         .send({ from: mainAccount, gas: 3000000 })
            //         .on("receipt", (receipt) => {
            
            //             // Contract Address will be returned here
            //             console.log("Contract Address:", receipt.contractAddress);
            //         })
            //         .then(function() {
            //             console.log('success!');
            //         });
            // });
        }
    });
}
