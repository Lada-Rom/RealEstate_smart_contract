const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("RealEstate", function () {
    let smart_contract_god
    let owner
    let not_owner
    let addr3

    let RealEstate_instance

    beforeEach(async function() {
        [smart_contract_god, owner, not_owner, addr3] = await ethers.getSigners()
        const RealEstate = await ethers.getContractFactory("RealEstate", smart_contract_god)
        RealEstate_instance = await RealEstate.deploy()
        await RealEstate_instance.deployed()
    })

    it("Token Constructor", async function () {
        // создаём токен
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end", 1, "login", "password")
        expect(await RealEstate_instance.totalSupply()).to.equal(1)
        let [, , , isSelling] = await RealEstate_instance.propertyOf(1)
        await expect(isSelling).to.equal(true)
    })

    it("Change Token Selling Status", async function () {
        let Prop
        // создаём токен
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end", 1, "login", "password")
        Prop = await RealEstate_instance.propertyOf(1)
        // после создания токена автоматически ставится флаг продажи
        await expect(Prop.isSelling).to.equal(true)

        // снимаем флаг за НЕвладельца -> ошибка
        await expect(RealEstate_instance.connect(not_owner).stopSelling(1)).to.be.revertedWith("Operator not approved and sender is not an owner!")

        // снимаем флаг продажи
        await RealEstate_instance.connect(owner).stopSelling(1)
        Prop = await RealEstate_instance.propertyOf(1)
        await expect(Prop.isSelling).to.equal(false)

        // устанавливаем снова
        await RealEstate_instance.connect(owner).startSelling(1)
        Prop = await RealEstate_instance.propertyOf(1)
        await expect(Prop.isSelling).to.equal(true)
    })

    it("Change Token Cost", async function () {
        let Prop 
        // создаём токен
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end", 1, "login", "password")

        await RealEstate_instance.connect(owner).setPropertyCost(1, 1000)
        Prop = await RealEstate_instance.propertyOf(1)
        await expect(Prop.cost).to.equal(1000)
    })

    it("All User Tokens", async function () {
        let Prop 
        let count
        // создаём токены (5 шт)
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end_1", 1, "login", "password")
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end_2", 2, "login", "password")
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end_3", 3, "login", "password")
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end_4", 4, "login", "password")
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end_5", 5, "login", "password")

        count = (await RealEstate_instance.connect(owner).getAllTokens(owner.address)).length
        expect(count).to.equal(5)
    })

    it("Token Transfer (safe)", async function () {
        let Prop 

        // создаём токен
        await RealEstate_instance.connect(owner).constructToken("ipfs://dead_end", 100, "login", "password")


        // покупка без верификации -> ошибка 
        await expect(RealEstate_instance.safeTransferFrom(owner.address, not_owner.address, 1, {value: 10} ))
            .to.be.revertedWith("Please, pass verification by calling verifyMe()!")


        // покупка непродаваемого токена -> ошибка 
        await RealEstate_instance.connect(not_owner).verifyMe("log_in", "pass_word")
        // снимаем флаг продажи
        await RealEstate_instance.connect(owner).stopSelling(1)
        await expect(RealEstate_instance.connect(not_owner).safeTransferFrom(owner.address, not_owner.address, 1, {value: 10} ))
            .to.be.revertedWith("Property is not selling now!")


        // ставим флаг продажи
        await RealEstate_instance.connect(owner).startSelling(1)
        // покупка с меньшим кол-во крипты чем необходимо -> ошибка 
        await expect(RealEstate_instance.connect(not_owner).safeTransferFrom(owner.address, not_owner.address, 1, {value: 10} ))
            .to.be.revertedWith("Not enough money to buy token!")


        // покупка от имени оператора, не получившего разрешения владельца -> ошибка
        await expect(RealEstate_instance.connect(not_owner).safeTransferFrom(owner.address, not_owner.address, 1, {value: 100} ))
            .to.be.revertedWith("Not approved and sender is not an owner!")
        await RealEstate_instance.connect(owner).approve(not_owner.address, 1)


        // проверка владельца токена
        expect(await RealEstate_instance.connect(not_owner).ownerOf(1)).to.equal(owner.address)
        await RealEstate_instance.connect(not_owner).safeTransferFrom(owner.address, not_owner.address, 1, {value: 100} )
        expect(await RealEstate_instance.connect(not_owner).ownerOf(1)).to.equal(not_owner.address)
 
    })

    it("Fallback check", async function () {
        const nonExistentFuncSignature = 'nonExistentFunc(uint256,uint256)';
        const fakeDemoContract = new ethers.Contract(
        RealEstate_instance.address,
        [
            ...RealEstate_instance.interface.fragments,
            `function ${nonExistentFuncSignature}`,
        ],
        smart_contract_god,
        );
        const tx = fakeDemoContract[nonExistentFuncSignature](8, 9);
        await expect(tx)
            .to.be.revertedWith('Operation does not allowed!');
    });
})
