const baseURL = "/tokens/";

export interface Token {
  name: string;
  logo: string;
  protocolTokenId: number;
  contractAddresses: Record<number, string>;
}

export const tokens: Token[] = [
  {
    name: "USDT",
    logo: baseURL + "usdt.png",
    protocolTokenId: 1,
    // Add contract addresses for different chains
    contractAddresses: {
      84532: "0x0b8C9Cf4F43811D9A22Be732AbE81617D4BD4183", // Base
      11155420: "0x0CeD166eA80d4e88Be1ce546FbBB07F410A47ca0", // Optimism
      10143: "0xa0dE9f0c2626462E1fEf5db158FF0350e3F94215", // Monad
      43113: "0xa3c2D2Be95B29B6C6909fF3Ad19e82995BA283DC", // Avalanche
      300: "0xb8c7e1f97C2D6C1893B1fEe7D0c42A9468761908", // zkSync
    },
  },
  // {
  //   name: "ETH",
  //   logo: baseURL + "eth.png",
  //   protocolTokenId: 2,
  //   // ETH is native, no contract address needed
  //   contractAddresses: {},
  // },
  // {
  //   name: "WETH",
  //   logo: baseURL + "weth.png",
  //   protocolTokenId: 3,
  //   contractAddresses: {}, // Add later
  // },
  // {
  //   name: "USDC",
  //   logo: baseURL + "usdc.png",
  //   protocolTokenId: 4,
  //   contractAddresses: {}, // Add later
  // },
  // {
  //   name: "PufETH",
  //   logo: baseURL + "pufeth.png",
  //   protocolTokenId: 5,
  //   contractAddresses: {}, // Add later
  // },
];
