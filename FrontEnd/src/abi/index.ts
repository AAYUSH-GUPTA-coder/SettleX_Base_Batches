export const abi = [
  {
    name: "createTransaction",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      {
        name: "transaction_",
        type: "tuple",
        internalType: "struct Spoke.CrossChainTransfer",
        components: [
          {
            name: "sourceChainSelector",
            type: "uint24",
            internalType: "uint24",
          },
          {
            name: "destinationChainSelector",
            type: "uint24",
            internalType: "uint24",
          },
          {
            name: "protocolTokenId",
            type: "uint24",
            internalType: "uint24",
          },
          {
            name: "receiver",
            type: "address",
            internalType: "address",
          },
          { name: "amount", type: "uint256", internalType: "uint256" },
        ],
      },
    ],
    outputs: [],
  },
  {
    type: "function",
    name: "allowance",
    inputs: [
      { name: "owner", type: "address", internalType: "address" },
      { name: "spender", type: "address", internalType: "address" },
    ],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
] as const;
