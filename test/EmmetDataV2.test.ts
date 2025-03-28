import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { EmmetDataV2, EmmetPriceFeed } from "../typechain-types";
import { keccak256, ZeroAddress } from "ethers";
import { pricePOL, priceBNB, priceTON, pricefeedDecimals } from "./consts";

describe("Data V2", () => {

    let emmetDataV2: EmmetDataV2;
    let admin: any;
    let another: any;
    const ADMIN_ROLE: string = keccak256(Buffer.from("ADMIN_ROLE"));

    let maticPriceFeed: EmmetPriceFeed;
    let maticPriceFeedAddress: string;
    let bnbPriceFeed: EmmetPriceFeed;
    let bnbPriceFeedAddress: string;
    let tonPriceFeed: EmmetPriceFeed;
    let tonPriceFeedAddress: string;

    beforeEach(async () => {
        [admin, another] = await ethers.getSigners();
        // Deploy EmmetDataV2
        const factory = await ethers.getContractFactory("EmmetDataV2");
        emmetDataV2 = await factory.deploy(137n, "POL");
        await emmetDataV2.waitForDeployment();
        // MATIC
        const factoryPriceFeed = await ethers.getContractFactory('EmmetPriceFeed');
        maticPriceFeed = await upgrades.deployProxy(factoryPriceFeed,
            [pricefeedDecimals, "MATIC/USD", admin.address, admin.address],
            { initializer: 'initializePriceFeed' }
        );
        await maticPriceFeed.waitForDeployment();
        maticPriceFeedAddress = await maticPriceFeed.getAddress();
        await maticPriceFeed.connect(admin).updateTokenPrice(pricePOL, 3n);
        // BNB
        bnbPriceFeed = await upgrades.deployProxy(factoryPriceFeed,
            [pricefeedDecimals, "BNB/USD", admin.address, admin.address],
            { initializer: 'initializePriceFeed' }
        );
        await bnbPriceFeed.waitForDeployment();
        bnbPriceFeedAddress = await bnbPriceFeed.getAddress();
        await bnbPriceFeed.connect(admin).updateTokenPrice(priceBNB, 3n);

        // TON
        const tonFactory = await ethers.getContractFactory('EmmetPriceFeed');
        tonPriceFeed = await upgrades.deployProxy(tonFactory,
            [14n, "TON/USD", admin.address, admin.address],
            { initializer: 'initializePriceFeed' }
        );
        await tonPriceFeed.waitForDeployment();
        tonPriceFeedAddress = await tonPriceFeed.getAddress();
        await tonPriceFeed.connect(admin).updateTokenPrice(priceTON, 3n);

    });

    it("1. Should deploy EmmetDataV2", async () => {
        expect(await emmetDataV2.ADMIN_ROLE()).to.equal(ADMIN_ROLE);
        expect(await emmetDataV2.roles(admin.address)).to.equal(ADMIN_ROLE);

        expect(await tonPriceFeed.decimals()).to.equal(14n);
    });

    it("2. Should update Admin", async () => {
        await emmetDataV2.connect(admin).updateAdmin(another.address);
        expect(await emmetDataV2.roles(another.address)).to.equal(ADMIN_ROLE);
        expect(await emmetDataV2.roles(admin.address)).to.equal("0x" + "0".repeat(64));
    });

    it("3. Should set chain & check isChainSupported", async () => {
        const chainData1 = {
            CCTPClaim: 100n,
            lprelease: 200n,
            mint: 300n,
            unlock: 400n,
            swap1: 500n,
            swap2: 600n,
            swap3: 700n,
            swap4: 800n,
            swap5: 900n,
            swap6: 0n,
            name: ethers.encodeBytes32String("Polygon").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: maticPriceFeedAddress,
        };

        await emmetDataV2.connect(admin).setChain(137, chainData1);

        expect(await emmetDataV2.getChain(137)).to.deep.equal([
            100n,
            200n,
            300n,
            400n,
            500n,
            600n,
            700n,
            800n,
            900n,
            0n,
            ethers.encodeBytes32String("Polygon").slice(0, 2 + 32),
            18n,
            ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            chainData1.priceFeed
        ]);

        expect(await emmetDataV2.isChainSupported(137n)).to.equal(true);
        expect(await emmetDataV2.isChainSupported(56n)).to.equal(false);

        expect(await emmetDataV2.getForeignFee(137n, 0x02)).to.equal(chainData1.CCTPClaim);
        expect(await emmetDataV2.getForeignFee(137n, 0x08)).to.equal(chainData1.lprelease);
        expect(await emmetDataV2.getForeignFee(137n, 0x04)).to.equal(chainData1.mint);
        expect(await emmetDataV2.getForeignFee(137n, 0x06)).to.equal(chainData1.unlock);
        expect(await emmetDataV2.getForeignFee(137n, 0x09)).to.equal(chainData1.swap1);
        expect(await emmetDataV2.getForeignFee(137n, 0x0A)).to.equal(chainData1.swap2);
        expect(await emmetDataV2.getForeignFee(137n, 0x0B)).to.equal(chainData1.swap3);
        expect(await emmetDataV2.getForeignFee(137n, 0x0C)).to.equal(chainData1.swap4);
        expect(await emmetDataV2.getForeignFee(137n, 0x0D)).to.equal(chainData1.swap5);
    });


    it("4. Should set chains", async () => {
        const chainData1 = {
            CCTPClaim: 100n,
            lprelease: 200n,
            mint: 300n,
            unlock: 400n,
            swap1: 500n,
            swap2: 600n,
            swap3: 700n,
            swap4: 800n,
            swap5: 900n,
            swap6: 0n,
            name: ethers.encodeBytes32String("Polygon").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: ZeroAddress,
        };

        const chainData2 = {
            CCTPClaim: 150n,
            lprelease: 250n,
            mint: 350n,
            unlock: 450n,
            swap1: 550n,
            swap2: 650n,
            swap3: 750n,
            swap4: 850n,
            swap5: 950n,
            swap6: 1050n,
            name: ethers.encodeBytes32String("BSC").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: ZeroAddress,
        };

        await emmetDataV2.connect(admin).setChains([137n, 56n], [chainData1, chainData2]);

        const storedChain1 = await emmetDataV2.getChain(137);
        expect(storedChain1.CCTPClaim).to.equal(chainData1.CCTPClaim);
        expect(storedChain1.mint).to.equal(chainData1.mint);

        const storedChain2 = await emmetDataV2.getChain(56);
        expect(storedChain2.CCTPClaim).to.equal(chainData2.CCTPClaim);
        expect(storedChain2.mint).to.equal(chainData2.mint);
    });

    it("5. Should set a token & check isTokenSupported", async () => {
        const symbol = "ETH";
        const target = another.address;
        const tokenDecimals = 18;
        const priceDecimals = 8;
        const priceFeed = another.address;

        await emmetDataV2.connect(admin).setToken(symbol, target, tokenDecimals, priceDecimals, priceFeed);

        const storedToken = await emmetDataV2.getToken(symbol);
        expect(storedToken.tokenDecimals).to.equal(tokenDecimals);
        expect(storedToken.priceDecimals).to.equal(priceDecimals);

        expect(await emmetDataV2.isTokenSupported("ETH")).to.equal(true);
        expect(await emmetDataV2.isTokenSupported("BNB")).to.equal(false);
    });

    it("6. Should set Strategies", async () => {

        const params = {
            chainId: 137n,
            fromToken: "USDT",
            toToken: "USDT",
            foreign: [4],
            incoming: [6],
            local: [3]
        }

        await emmetDataV2.connect(admin).setStrategies(
            params.chainId,
            params.fromToken,
            params.toToken,
            params.foreign,
            params.incoming,
            params.local
        );

        expect(await emmetDataV2.getStrategies(
            params.chainId,
            params.fromToken,
            params.toToken))
            .to.deep.equal([
                params.foreign,
                params.incoming,
                params.local
            ])

    });

    it("7. Should estimate foreign fees BNB -> POL", async () => {
        const foreignChainData = {
            CCTPClaim: 46728971960000000n,
            lprelease: 46728971960000000n,
            mint: 46728971960000000n,
            unlock: 46728971960000000n,
            swap1: 46728971960000000n,
            swap2: 46728971960000000n,
            swap3: 46728971960000000n,
            swap4: 46728971960000000n,
            swap5: 46728971960000000n,
            swap6: 46728971960000000n,
            name: ethers.encodeBytes32String("Polygon").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: maticPriceFeedAddress,
        };

        const nativeChainData = {
            CCTPClaim: 0n,
            lprelease: 0n,
            mint: 0n,
            unlock: 0n,
            swap1: 0n,
            swap2: 0n,
            swap3: 0n,
            swap4: 0n,
            swap5: 0n,
            swap6: 0n,
            name: ethers.encodeBytes32String("BSC").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: bnbPriceFeedAddress,
        };

        // Deploy EmmetDataV2
        const factory = await ethers.getContractFactory("EmmetDataV2");
        const emmetDataV2BNB = await factory.deploy(56n, "BNB");
        await emmetDataV2BNB.waitForDeployment();

        const params = {
            chainId: 137n,
            fromToken: "USDT",
            toToken: "USDT",
            foreign: [8, 9],
            incoming: [6],
            local: [3]
        }

        await emmetDataV2BNB.connect(admin).setStrategies(
            params.chainId,
            params.fromToken,
            params.toToken,
            params.foreign,
            params.incoming,
            params.local
        );

        await emmetDataV2BNB.connect(admin).setChain(137, foreignChainData);
        await emmetDataV2BNB.connect(admin).setChain(56, nativeChainData);

        // Compute expected fee
        const expectedFee = (foreignChainData.lprelease + foreignChainData.swap1) * pricePOL / priceBNB;

        const fee = await emmetDataV2BNB.estimateForeignFees(
            params.chainId,
            params.fromToken,
            params.toToken
        ); // lprelease + swap1
        expect(fee).to.equal(expectedFee);
    });

    it("8. Should estimate foreign fees POL -> BNB", async () => {
        const nativeChainData = {
            CCTPClaim: 0n,
            lprelease: 0n,
            mint: 0n,
            unlock: 0n,
            swap1: 0n,
            swap2: 0n,
            swap3: 0n,
            swap4: 0n,
            swap5: 0n,
            swap6: 0n,
            name: ethers.encodeBytes32String("Polygon").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: maticPriceFeedAddress,
        };

        const foreignChainData = {
            CCTPClaim: 856443020800000n,
            lprelease: 976345043800000n,
            mint: 856443020800000n,
            unlock: 856443020800000n,
            swap1: 856443020800000n,
            swap2: 856443020800000n,
            swap3: 856443020800000n,
            swap4: 856443020800000n,
            swap5: 856443020800000n,
            swap6: 856443020800000n,
            name: ethers.encodeBytes32String("BSC").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: bnbPriceFeedAddress,
        };

        await emmetDataV2.connect(admin).setChain(137, nativeChainData);
        await emmetDataV2.connect(admin).setChain(56, foreignChainData);

        // Compute expected fee
        const expectedFee = (foreignChainData.lprelease + foreignChainData.swap1) * priceBNB / pricePOL;

        const params = {
            chainId: 56n,
            fromToken: "USDT",
            toToken: "USDT",
            foreign: [8, 9],
            incoming: [6],
            local: [3]
        }

        await emmetDataV2.connect(admin).setStrategies(
            params.chainId,
            params.fromToken,
            params.toToken,
            params.foreign,
            params.incoming,
            params.local
        );

        const fee = await emmetDataV2.estimateForeignFees(
            params.chainId,
            params.fromToken,
            params.toToken
        ); // lprelease + swap1
        expect(fee).to.equal(expectedFee);
    });

    it("9. Should estimate foreign fees POL -> TON", async () => {
        const nativeChainData = {
            CCTPClaim: 0n,
            lprelease: 0n,
            mint: 0n,
            unlock: 0n,
            swap1: 0n,
            swap2: 0n,
            swap3: 0n,
            swap4: 0n,
            swap5: 0n,
            swap6: 0n,
            name: ethers.encodeBytes32String("Polygon").slice(0, 2 + 32),
            tokenDecimals: 18,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: maticPriceFeedAddress,
        };

        const foreignChainData = {
            CCTPClaim: 177304965n,
            lprelease: 177304965n,
            mint: 177304965n,
            unlock: 177304965n,
            swap1: 177304965n,
            swap2: 177304965n,
            swap3: 177304965n,
            swap4: 177304965n,
            swap5: 177304965n,
            swap6: 177304965n,
            name: ethers.encodeBytes32String("TON").slice(0, 2 + 32),
            tokenDecimals: 9,
            flags: ethers.encodeBytes32String("FlagTest").slice(0, 2 + 22),
            priceFeed: tonPriceFeedAddress,
        };

        await emmetDataV2.connect(admin).setChain(137, nativeChainData);
        await emmetDataV2.connect(admin).setChain(65534, foreignChainData);

        const params = {
            chainId: 65534n,
            fromToken: "USDT",
            toToken: "USDT",
            foreign: [8, 9],
            incoming: [6],
            local: [3]
        }

        await emmetDataV2.connect(admin).setStrategies(
            params.chainId,
            params.fromToken,
            params.toToken,
            params.foreign,
            params.incoming,
            params.local
        );

        // Compute expected fee
        const expectedFee = (foreignChainData.lprelease + foreignChainData.swap1) * priceTON / pricePOL;
        // console.log(expectedFee)

        const fee = await emmetDataV2.estimateForeignFees(
            params.chainId,
            params.fromToken,
            params.toToken
        ); // lprelease + swap1
        expect(fee).to.equal(expectedFee);
    });
});