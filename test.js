const { expect } = require("chai");
const { ethers } = require("hardhat");
//const tokenJSON = require("../contracts/artifacts/RESToken.json")

describe("RealEstate", function () {
    let owner
    let buyer
    let RealEstate_instance

    beforeEach(async function() {
        [owner, buyer] = await ethers.getSigners()
        const RealEstate = await ethers.getContractFactory("RealEstate", owner)
        RealEstate_instance = await RealEstate.deploy(["https://property.pdf", 1, true])
        await RealEstate_instance.deployed()

        //erc20 = new ethers.Contract(await shop.token(), tokenJSON.abi, owner)
    })

    it("1 shop and owner are different entities", async function () {
        expect(await RealEstate_instance.address_shop()).not.eq(owner.address)
    })

    it("2 token belongs to the owner", async function () {
        expect(await RealEstate_instance.balanceOf(RealEstate_instance.address_shop())).to.eq(0)
        expect(await RealEstate_instance.balanceOf(owner.address)).to.eq(1)
    })

    it("3 only owner can change property selling flag", async function () {
        const stopSelling_ = await RealEstate_instance.connect(owner).stopSelling()
        await stopSelling_.wait()
        let [owernship_1, price_1, isSelling_1] = await RealEstate_instance.property()
        expect(isSelling_1).to.equal(false)

        const startSelling_ = await RealEstate_instance.connect(owner).startSelling()
        await startSelling_.wait()
        let [owernship_2, price_2, isSelling_2] = await RealEstate_instance.property()
        expect(isSelling_2).to.equal(true)

        expect(RealEstate_instance.connect(buyer).stopSelling()).to.be.reverted //null
        expect(RealEstate_instance.connect(buyer).startSelling()).to.be.reverted //null

    })

    it("4 only owner can change property price", async function (){
        const new_price = 2
        const setPrice_ = await RealEstate_instance.connect(owner).setPrice(new_price)
        await setPrice_.wait()
        let [owernship, price, isSelling] = await RealEstate_instance.property()
        expect(price).to.equal(new_price)

        expect(RealEstate_instance.connect(buyer).setPrice(new_price)).to.be.reverted //null
    })
})

        //const tokenAmount = 3
        //const tx = await buyer.sendTransaction({
        //    value: tokenAmount,
        //    to: shop.address
        //})
        //await tx.wait()

        //expect(await erc20.balanceOf(buyer.address)).to.eq(tokenAmount)
        //await expect(() => tx)
        //    .to.changeEtherBalance(shop, tokenAmount)
        //
        //await expect (tx)
        //    .to.emit(shop, "Bought")
        //    .withArgs(buyer.address, tokenAmount)



        //const tx = await buyer.sendTransaction({
        //    value: 3,
        //    to: shop.address
        //})
        //await tx.wait()

        //const sellAmount = 2
        //const approval = await erc20.connect(buyer).approve(shop.address, sellAmount)
        //await approval.wait()

        //const sellTx = await shop.connect(buyer).sell(sellAmount)
        //expect(await erc20.balanceOf(buyer.address)).to.eq(1)

        //await expect(() => sellTx)
        //    .to.changeEtherBalance(shop, -sellAmount)

        //await expect (sellTx)
        //    .to.emit(shop, "Sold")
        //    .withArgs(buyer.address, sellAmount)