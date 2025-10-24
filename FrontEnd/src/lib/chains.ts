const baseURL = "/chains/";
export const chains = [
  { name: "BASE", logo: baseURL + "BASE.avif", chainId: 84532 },
  { name: "Optimism", logo: baseURL + "Optimism.avif", chainId: 11155420 },
  // { name: "Scroll", logo: baseURL + "Scroll.avif", chainId: 534351 },
  // { name: "ARB", logo: baseURL + "ARB.avif", chainId: 421614 },
  // { name: "Ethereum", logo: baseURL + "Ethereum.avif", chainId: 1 },
  // { name: "BSC", logo: baseURL + "BSC.avif", chainId: 56 },
  // { name: "Unichain", logo: baseURL + "Unichain.svg", chainId: 130 },
  // { name: "Polygon", logo: baseURL + "Polygon.avif", chainId: 137 },
  { name: "Monad", logo: baseURL + "Monad.svg", chainId: 10143 },
  { name: "Avalanche", logo: baseURL + "Avalanche.png", chainId: 43113 },
  { name: "zkSync", logo: baseURL + "zksync.avif", chainId: 300 },
  // { name: "Ronin", logo: baseURL + "Ronin.avif", chainId: 2020 },
  // { name: "Ape-Chain", logo: baseURL + "Ape-Chain.avif", chainId: 33139 },
  // { name: "Mode", logo: baseURL + "Mode.avif", chainId: 34443 },
  // { name: "zircuit", logo: baseURL + "zircuit.svg", chainId: 48900 },
  // { name: "Linea", logo: baseURL + "Linea.avif", chainId: 59144 },
  // { name: "blast", logo: baseURL + "blast.png", chainId: 81457 },
  // { name: "Taiko", logo: baseURL + "Taiko.avif", chainId: 167000 },
];

export const contractAddressMapping: Record<string, `0x${string}`> = {
  Arbitrum: "0x7D9f7b6dAA5407bFd4A935aae48c64aa0FE69bcb",
  BASE: "0x91e2E34718EFD173389c7876BBBb57594cE27e37",
  Optimism: "0xAAb11c371F68a1fD16E10d77642a7E4EE5097619",
  Monad: "0xe21c9e823C31aD208db00457d41A817D01B807B9",
  Avalanche: "0x6D7eD1Df1D9c39520F4512bdF8BC8F0D1fEb805C",
  zkSync: "0x52A080b057ff51274C60b33f48b82bDd788bA0d1",
};
