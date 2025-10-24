"use client";

import { cookieStorage, createStorage } from "@wagmi/core";
import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";
import {
  arbitrumSepolia,
  baseSepolia,
  scrollSepolia,
  optimismSepolia,
  avalancheFuji,
  monadTestnet,
  zksyncSepoliaTestnet,
  AppKitNetwork,
} from "@reown/appkit/networks";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createAppKit } from "@reown/appkit/react";
import React, { type ReactNode } from "react";
import { cookieToInitialState, WagmiProvider, type Config } from "wagmi";

// Set up queryClient
const queryClient = new QueryClient();

// Get projectId from https://cloud.reown.com
export const projectId = process.env["NEXT_PUBLIC_REOWN_PROJECT_ID"];

if (!projectId) {
  throw new Error("Project ID is not defined");
}

export const networks = [
  baseSepolia,
  arbitrumSepolia,
  avalancheFuji,
  scrollSepolia,
  optimismSepolia,
  monadTestnet,
  zksyncSepoliaTestnet,
];

// Set up the Wagmi Adapter (Config)
export const wagmiAdapter = new WagmiAdapter({
  storage: createStorage({
    storage: cookieStorage,
  }),
  ssr: true,
  projectId,
  networks,
});

export const config = wagmiAdapter.wagmiConfig;

// Set up metadata
const metadata = {
  name: "SettleX",
  description: "The Settlement Layer for Stablecoins",
  url: "https://settlex.fi",
  icons: ["https://assets.reown.com/reown-profile-pic.png"],
};

// Ensure networks is a tuple with at least one entry (baseSepolia at position 0)
const appkitNetworks: [AppKitNetwork, ...AppKitNetwork[]] = [
  baseSepolia,
  ...(networks.filter((n) => n !== baseSepolia) as AppKitNetwork[]),
];

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const modal = createAppKit({
  adapters: [wagmiAdapter],
  projectId,
  networks: appkitNetworks,
  defaultNetwork: baseSepolia,
  metadata: metadata,
  features: {
    analytics: true, // Optional - defaults to your Cloud configuration
  },
  themeMode: "dark",
  themeVariables: {
    "--w3m-accent": "var(--accent-80)",
    "--w3m-color-mix": "var(--card)",
    "--w3m-color-mix-strength": 40,
    "--w3m-font-family": "Helvetica Neue, Inter, sans-serif",
    // "--w3m-border-radius-master": "0.5rem",
  },
});

function ContextProvider({
  children,
  cookies,
}: {
  children: ReactNode;
  cookies: string | null;
}) {
  const initialState = cookieToInitialState(
    wagmiAdapter.wagmiConfig as Config,
    cookies
  );

  return (
    <WagmiProvider
      config={wagmiAdapter.wagmiConfig as Config}
      initialState={initialState}
    >
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    </WagmiProvider>
  );
}

export default ContextProvider;
