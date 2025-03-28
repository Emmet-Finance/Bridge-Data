import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
// require("@nomicfoundation/hardhat-foundry");
import "@openzeppelin/hardhat-upgrades";
import { readENV } from "./scripts/utils";
import { ethers } from "ethers";

const INFURA_KEY = readENV('INFURA_KEY');
const ETHERSCAN_API_KEY = readENV('ETHERSCAN_API_KEY');
const OPTIMISTIC = readENV('OPTIMISTIC');
const ARBISCAN_API_KEY = readENV('ARBISCAN_API_KEY');
const BASE_API_KEY = readENV('BASE_API_KEY');
const POLYGON_API_KEY = readENV('POLYGON_API_KEY');
const BSC_API_KEY = readENV("BSC_API_KEY");
const FLARE_EXPLORER_API_KEY = "songbird";
const GNOSIS_API_KEY = readENV("GNOSIS_API_KEY");
const FRAX_API_KEY = readENV("FRAX_API_KEY");
const zkEVM_API_KEY = readENV("zkEVM_API_KEY");

const IS_TESTNET: boolean = (readENV("IS_TESTNET")) == 'true';
const SK: string = IS_TESTNET ? readENV("TSK") : readENV("MSK");
const accounts = [SK];

const config: HardhatUserConfig = {
  networks: {
    fire: {
      url: "https://rpc.5ire.network",
      accounts,
      chainId: 995
    },
    hardhat: {
      forking: {
        url: "https://songbird-api.flare.network/ext/bc/C/rpc",
        blockNumber: 82726225, // (Optional) Pin to a stable block
      },
      hardfork: "merge", // ✅ Explicitly define a known hardfork
    },
    berachainBartio: {
      url: "https://bartio.rpc.berachain.com",
      accounts,
      chainId: 80084 // 0x138d4
    },
    bsc: {
      url: "https://bsc.blockrazor.xyz",
      accounts,
      chainId: 56,
      gasPrice: 1000000000,
    },
    bscTestnet:{
      url: "https://bsc-testnet-rpc.publicnode.com",
      accounts,
      chainId: 97
    },
    sepolia: {
      url: "https://ethereum-sepolia.blockpi.network/v1/rpc/public",
      accounts,
      chainId: 11155111
    },
    songbird: {
      url: "https://songbird-api.flare.network/ext/bc/C/rpc",
      accounts,
      chainId: 19
    },
    avalanche: {
      url: `https://avalanche-mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts,
      chainId: 43114
    },
    snowtrace: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      accounts,
      chainId: 43113
    },
    arbitrum: {
      url: 'https://arb-pokt.nodies.app',
      accounts,
      chainId: 42161
    },
    onlylayer : {
      url: 'https://onlylayer.org',
      accounts,
      chainId: 728696,
    },
    optimism: {
      url: `https://optimism-mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts,
      chainId: 10
    },
    optimismSepolia: { // Need Paris to verify
      url: "https://optimism-sepolia.blockpi.network/v1/rpc/public",
      accounts,
      chainId: 11155420
    },
    arbitrumSepolia: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      accounts,
      chainId: 421614
    },
    baseSepolia: {
      url: "https://base-sepolia.blockpi.network/v1/rpc/public",
      accounts,
      chainId: 84532
    },
    frax: {
      url: "https://fraxtal.drpc.org",
      accounts,
      chainId: 252
    },
    gnosis: {
      url: "https://rpc.gnosischain.com",
      accounts: accounts,
    },
    mode: {
      url: "https://mainnet.mode.network",
      accounts,
      chainId: 34443
    },
    polygon: {
      url: "https://polygon.llamarpc.com",
      accounts,
      chainId: 137,
      // gas: "auto",
      // gasMultiplier: 25,
      gasPrice: 101000000000,
    },
    amoy: {
      url: "https://rpc-amoy.polygon.technology", //"https://polygon-amoy-bor-rpc.publicnode.com",
      accounts,
      chainId: 80002,
    },
    zkevm: {
      url: "https://polygon-zkevm.drpc.org",
      accounts,
      chainId: 1101
    }
  },
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000
      },
      outputSelection: {
        "*": {
          "*": ["metadata"]
        }
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  sourcify: {
    enabled: false
  },
  mocha: {
    timeout: 40000
  },
  etherscan: {
    apiKey: {
      fire: "Etherscan",
      berachainBartio: 'YourApiKeyToken',
      arbitrum: ARBISCAN_API_KEY,
      avalanche: 'snowtrace',
      base: BASE_API_KEY,
      bsc: BSC_API_KEY,
      bscTestnet: BSC_API_KEY,
      ethereum: ETHERSCAN_API_KEY,
      frax: FRAX_API_KEY,
      gnosis: GNOSIS_API_KEY,
      mode: "empty",
      optimism: OPTIMISTIC,
      optimismSepolia: OPTIMISTIC,
      snowtrace: "snowtrace", // apiKey is not required, just set a placeholder
      sepolia: ETHERSCAN_API_KEY,
      polygon: POLYGON_API_KEY,
      amoy: POLYGON_API_KEY,
      zkevm: zkEVM_API_KEY
    },
    customChains: [
      {
        network: 'berachainBartio',
        chainId: 80084,
        urls: {
          apiURL: 'https://api.routescan.io/v2/network/testnet/evm/80084/etherscan/api/',
          browserURL: 'https://bartio.beratrail.io/'
        }
      },
      {
        network: "bsc",
        chainId: 56,
        urls: {
          apiURL: "https://api.bscscan.com/api",
          browserURL: "https://bscscan.com/"
        }
      },
      {
        network:"bscTestnet",
        chainId: 97,
        urls:{
          apiURL: "https://api-testnet.bscscan.com/api",
          browserURL:"https://testnet.bscscan.com/"
        }
      },
      {
        network: "sepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io"
        }
      },
      { // https://github.com/flare-foundation/flare-hardhat-starter/blob/master/hardhat.config.ts
        network: "songbird",
        chainId: 19,
        urls: {
          apiURL: "https://songbird-explorer.flare.network/api" + (FLARE_EXPLORER_API_KEY ? `?x-apikey=${FLARE_EXPLORER_API_KEY}` : ""), // Must not have / endpoint
          browserURL: "https://songbird-explorer.flare.network/"
        }
      },
      { // https://snowtrace.io/documentation/recipes/hardhat-verification
        network: 'avalanche',
        chainId: 43114,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/mainnet/evm/43114/etherscan/api",
          browserURL: "https://snowtrace.io"
        }
      },
      { // https://snowtrace.io/documentation/recipes/hardhat-verification
        network: "snowtrace",
        chainId: 43113,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/43113/etherscan",
          browserURL: "https://testnet.snowtrace.io"
        }
      },
      {
        network: 'arbitrum',
        chainId: 42161,
        urls: {
          apiURL: "https://api.arbiscan.io/api",
          browserURL: "https://arbiscan.io/"
        }
      },
      {
        network: 'onlylayer',
        chainId: 728696,
        urls: {
          apiURL: '',
          browserURL: 'https://onlyscan.info'
        }
      },
      {
        network: 'optimism',
        chainId: 10,
        urls: {
          apiURL: 'https://api-optimistic.etherscan.io/api',
          browserURL: 'https://optimistic.etherscan.io/'
        }
      },
      { // https://docs.optimism.etherscan.io/v/optimism-sepolia-etherscan
        network: 'optimismSepolia',
        chainId: 11155420,
        urls: {
          apiURL: 'https://api-sepolia-optimistic.etherscan.io/api',
          browserURL: 'https://sepolia-optimism.etherscan.io/'
        }

      },
      {
        network: "arbitrumSepolia",
        chainId: 421614,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia.arbiscan.io"
        }
      },
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org"
        }
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org"
        }
      },
      {
        network: "frax",
        chainId: 252,
        urls: {
          apiURL: "https://api.fraxscan.com/api",
          browserURL: "https://docs.fraxscan.com/"
        }
      },
      { // https://docs.gnosischain.com/developers/dev-environment/hardhat
        network: "gnosis",
        chainId: 100,
        urls: {
          apiURL: "https://api.gnosisscan.io/api",
          browserURL: "https://gnosisscan.io/",
          // Blockscout
          //apiURL: "https://blockscout.com/xdai/mainnet/api",
          //browserURL: "https://blockscout.com/xdai/mainnet",
        }
      },
      {
        network: "fire",
        chainId: 995,
        urls: {
          apiURL: "https://contract.evm.scan.5ire.network/5ire/verify",
          browserURL: "https://5irescan.io",
        },
      },
      {
        network: "mode",
        chainId: 34443,
        urls: {
          apiURL: "https://explorer-mode-mainnet-0.t.conduit.xyz/api",
          browserURL: "https://explorer-mode-mainnet-0.t.conduit.xyz:443"
        }
      },
      {
        network: "polygon",
        chainId: 137,
        urls: {
          apiURL: "https://api.polygonscan.com/api",
          browserURL: "https://polygonscan.com/"
        }
      },
      {
        network: "amoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com/"
        }
      },
      {
        network: "zkevm",
        chainId: 1101,
        urls: {
          apiURL: "https://api-zkevm.polygonscan.com/api",
          browserURL: "https://zkevm.polygonscan.com/"
        }
      }
    ]
  }
};

export default config;
