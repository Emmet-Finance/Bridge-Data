import { ethers } from "ethers";

export const pricefeedDecimals: bigint = 8n;
export const pricePOL: bigint = 21400000n;
export const priceBNB: bigint = 58381000000n;
export const priceETH: bigint = 199600000000n;
export const priceTON: bigint = 282000000000000n;

export const BridgeTypes = {
    Step: {
        None: 0x00,
        // CCTP steps
        CCTPBurn: 0x01,
        CCTPClaim: 0x02,
        // Lock and mint steps
        Lock: 0x03,
        Mint: 0x04,
        Burn: 0x05,
        Unlock: 0x06,
        // Liquidity
        LPStake: 0x07,
        LPRelease: 0x08,
        // Swapping steps
        SWAP1: 0x09,
        SWAP2: 0x0a,
        SWAP3: 0x0b,
        SWAP4: 0x0c,
        SWAP5: 0x0d,
        SWAP6: 0x0e
    }
}

// ROLES
export const BRIDGE_ROLE: string = ethers.keccak256(ethers.toUtf8Bytes("BRIDGE_ROLE"));
export const CFO_ROLE: string = ethers.keccak256(ethers.toUtf8Bytes("CFO_ROLE"));
export const DEFAULT_ADMIN_ROLE: string = "0x" + "0".repeat(64);
export const MANAGER_ROLE: string = ethers.keccak256(ethers.toUtf8Bytes("MANAGER_ROLE"));

export const ether: bigint = 10n ** 18n;

