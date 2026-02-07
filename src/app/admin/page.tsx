import { type Metadata } from "next";
import { AdminPage } from "./AdminPage";

export const metadata: Metadata = {
  title: "Admin",
  description: "FVS administration panel.",
};

export default function Page() {
  return <AdminPage />;
}
