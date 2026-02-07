import { type Metadata } from "next";
import { LoginPage } from "./LoginPage";

export const metadata: Metadata = {
  title: "Login",
  description: "Sign in to Forecast Audit",
  robots: { index: false, follow: false },
};

export default function Page() {
  return <LoginPage />;
}
