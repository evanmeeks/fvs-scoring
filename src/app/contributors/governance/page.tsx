import { type Metadata } from "next";
import { GovernancePage } from "./GovernancePage";

export const metadata: Metadata = {
  title: "Protocol Governance",
  description:
    "Vote on metric definitions and contribute to FVS protocol governance.",
};

export default function Page() {
  return <GovernancePage />;
}
