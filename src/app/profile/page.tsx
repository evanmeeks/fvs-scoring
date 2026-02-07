import { type Metadata } from "next";
import { ProfilePage } from "./ProfilePage";

export const metadata: Metadata = {
  title: "Profile",
  description: "Manage your FVS profile, submissions, and settings.",
};

export default function Page() {
  return <ProfilePage />;
}
