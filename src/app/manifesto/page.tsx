import { type Metadata } from "next";
import { Manifesto } from "~/components/views/landing/Manifesto";

export const metadata: Metadata = {
  title: "Manifesto",
  description:
    "The Manifesto — principles and methodology behind Forecast Audit.",
  openGraph: {
    title: "Manifesto | Forecast Audit",
    description:
      "The Manifesto — principles and methodology behind Forecast Audit.",
    type: "website",
    url: "/manifesto",
  },
};

export default function ManifestoPage() {
  return <Manifesto />;
}
